WITH 

TABLACOMPLETA AS (
SELECT DISTINCT Contrato, EXTRACT(MONTH FROM FECHA_FINALIZACION) AS Mes, SERVICIOS_AFECTADOS, SOLUCION_FINAL, MAX(FECHA_FINALIZACION) AS FechaTiquete
  ,CASE
    WHEN SERVICIOS_AFECTADOS IN('SERVICIO INTERNET', 'FTTH JASEC', 'INTERNET') THEN 'BB'
    WHEN SERVICIOS_AFECTADOS IN('CABLE + DIGITAL', 'NEXTGEN TV', 'SERVICIO DIGITAL','SERVICIO ADICIONAL DIGITAL', 'HBO' ) THEN 'TV'
    WHEN SERVICIOS_AFECTADOS IN('SERVICIO TELEFONIA IP') THEN 'VO'
    WHEN SERVICIOS_AFECTADOS IN('CABLE + INTERNET + DIGITAL', 'CABLE + INTERNET','INTERNET + DIGITAL' ) THEN 'TV + BB'
    WHEN SERVICIOS_AFECTADOS IN('SERVICIO BASICO') THEN 'SERVICIO BASICO'
    WHEN SERVICIOS_AFECTADOS IN('PACK HD') THEN 'PACK HD'
    WHEN SERVICIOS_AFECTADOS IN('CABLE + INT + DIG+ VOIP','CABLE + INTERNET + VOIP' ) THEN 'TV+BB+VO'
    WHEN SERVICIOS_AFECTADOS IN('CABLE + TELEFONIA IP' ) THEN 'TV+VO'
    WHEN SERVICIOS_AFECTADOS IN('INTERNET + TELEFONIA IP' ) THEN 'BB+VO'
    WHEN SERVICIOS_AFECTADOS IN('PHC' ) THEN 'PHC'
    ELSE 'OTRO'END AS SerHom
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.2022-02-02_TIQUETES_GENERALES_DE_DESCONEXIONES_T` 
WHERE Contrato IS NOT NULL AND EXTRACT(YEAR FROM FECHA_FINALIZACION)=2021
GROUP BY Contrato, Mes, SERVICIOS_AFECTADOS, SOLUCION_FINAL
),

FECHAMAX_RGU AS (
SELECT DISTINCT Contrato, SERVICIOS_AFECTADOS, MAX(FECHA_FINALIZACION) AS FechaMaxRGU
,CASE
    WHEN SERVICIOS_AFECTADOS IN('SERVICIO INTERNET', 'FTTH JASEC', 'INTERNET') THEN 'BB'
    WHEN SERVICIOS_AFECTADOS IN('CABLE + DIGITAL', 'NEXTGEN TV', 'SERVICIO DIGITAL','SERVICIO ADICIONAL DIGITAL', 'HBO' ) THEN 'TV'
    WHEN SERVICIOS_AFECTADOS IN('SERVICIO TELEFONIA IP') THEN 'VO'
    WHEN SERVICIOS_AFECTADOS IN('CABLE + INTERNET + DIGITAL', 'CABLE + INTERNET','INTERNET + DIGITAL' ) THEN 'TV + BB'
    WHEN SERVICIOS_AFECTADOS IN('SERVICIO BASICO') THEN 'SERVICIO BASICO'
    WHEN SERVICIOS_AFECTADOS IN('PACK HD') THEN 'PACK HD'
    WHEN SERVICIOS_AFECTADOS IN('CABLE + INT + DIG+ VOIP','CABLE + INTERNET + VOIP' ) THEN 'TV+BB+VO'
    WHEN SERVICIOS_AFECTADOS IN('CABLE + TELEFONIA IP' ) THEN 'TV+VO'
    WHEN SERVICIOS_AFECTADOS IN('INTERNET + TELEFONIA IP' ) THEN 'BB+VO'
    WHEN SERVICIOS_AFECTADOS IN('PHC' ) THEN 'PHC'
    ELSE 'OTRO'END AS SerHom
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.2022-02-02_TIQUETES_GENERALES_DE_DESCONEXIONES_T` 
WHERE Contrato IS NOT NULL AND EXTRACT(YEAR FROM FECHA_FINALIZACION)=2021
GROUP BY Contrato, SERVICIOS_AFECTADOS
),

BASE AS(
SELECT t.Contrato, t.Mes,t.FechaTiquete,t.SerHom, t.SOLUCION_FINAL
FROM TABLACOMPLETA t INNER JOIN FECHAMAX_RGU f ON t.Contrato=f.Contrato AND t.FechaTiquete=f.FechaMaxRGU
),

SOLUCION_FLAG AS(
SELECT DISTINCT Contrato, FechaTiquete,SOLUCION_FINAL,
CASE WHEN SOLUCION_FINAL="RETENIDO" THEN COUNT(DISTINCT Contrato) END AS Retenidos,
CASE WHEN SOLUCION_FINAL="NO RETENIDO" THEN COUNT(DISTINCT Contrato) END AS NoRetenidos,
CASE WHEN SOLUCION_FINAL="NO LOCALIZADO" THEN COUNT(DISTINCT Contrato) END AS NoLocalizados,
CASE WHEN (SOLUCION_FINAL="TRAMITE REALIZADO" OR SOLUCION_FINAL="0") THEN COUNT(DISTINCT Contrato) END AS Otros
FROM BASE
GROUP BY Contrato, FechaTiquete, SOLUCION_FINAL
)

SELECT EXTRACT(MONTH FROM r.FechaTiquete) as Mes, COUNT(DISTINCT r.Contrato) AS Registros,
 COUNT(Retenidos) AS Retenidos, COUNT(Retenidos)/COUNT(DISTINCT r.Contrato) AS PorcRet,
 COUNT(NoRetenidos) AS NoRetenidos, COUNT(NoRetenidos)/COUNT(DISTINCT r.Contrato) AS PorcNoRet,
 COUNT(NoLocalizados) AS NoLocalizados, COUNT(NoLocalizados)/COUNT(DISTINCT r.Contrato) AS PorcNoLoc,
 COUNT(Otros) AS Otros, COUNT(Otros)/COUNT(DISTINCT r.Contrato) AS PorcOtros
FROM SOLUCION_FLAG  r
GROUP BY Mes ORDER BY Mes


