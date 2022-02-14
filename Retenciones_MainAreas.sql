WITH

BASE AS(
SELECT DISTINCT SITE_FINALIZADO,  Contrato, SOLUCION_FINAL
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.2022-02-02_TIQUETES_GENERALES_DE_DESCONEXIONES_T` 
--WHERE AGRUPACION_SUBAREA="OFERTA"
GROUP BY Contrato, SITE_FINALIZADO, SOLUCION_FINAL),

RETENIDOS_FLAG AS(
SELECT DISTINCT Contrato,SOLUCION_FINAL,SITE_FINALIZADO,
CASE WHEN SOLUCION_FINAL="RETENIDO" THEN COUNT(DISTINCT Contrato) END AS Retenidos,
CASE WHEN SOLUCION_FINAL="NO RETENIDO" THEN COUNT(DISTINCT Contrato) END AS NoRetenidos 
FROM BASE
GROUP BY Contrato,SOLUCION_FINAL,SITE_FINALIZADO
)

SELECT SITE_FINALIZADO, COUNT(DISTINCT Contrato) AS RegAreaInicio, COUNT(Retenidos) AS RegRet, COUNT(NoRetenidos) AS RegNoRet
FROM RETENIDOS_FLAG
GROUP BY SITE_FINALIZADO ORDER BY RegAreaInicio DESC
