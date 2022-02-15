WITH

BASE AS(
SELECT DISTINCT AGRUPACION_SUBAREA,  Contrato, SOLUCION_FINAL
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.2022-02-02_TIQUETES_GENERALES_DE_DESCONEXIONES_T` 
GROUP BY Contrato, AGRUPACION_SUBAREA, SOLUCION_FINAL),

RETENIDOS_FLAG AS(
SELECT DISTINCT Contrato,SOLUCION_FINAL,AGRUPACION_SUBAREA,
CASE WHEN SOLUCION_FINAL="RETENIDO" THEN COUNT(DISTINCT Contrato) END AS Retenidos,
CASE WHEN SOLUCION_FINAL="NO RETENIDO" THEN COUNT(DISTINCT Contrato) END AS NoRetenidos 
FROM BASE
GROUP BY Contrato,SOLUCION_FINAL,AGRUPACION_SUBAREA
)

SELECT AGRUPACION_SUBAREA, COUNT(DISTINCT Contrato) AS RegAgSubArea, COUNT(Retenidos) AS RegRet, COUNT(NoRetenidos) AS RegNoRet
FROM RETENIDOS_FLAG 
GROUP BY AGRUPACION_SUBAREA ORDER BY RegAgSubArea DESC
