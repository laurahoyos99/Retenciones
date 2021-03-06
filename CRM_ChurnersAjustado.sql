--CHURNERS CRM CON RETENCIONES
WITH 

BASE AS(
SELECT DISTINCT RIGHT(CONCAT('0000000000',Contrato) ,10) AS Contrato, MAX(DATE(FECHA_FINALIZACION)) AS FechaTiquete, SOLUCION_FINAL
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.2022-02-02_TIQUETES_GENERALES_DE_DESCONEXIONES_T` 
WHERE Contrato IS NOT NULL
GROUP BY Contrato, SOLUCION_FINAL),

RETENIDOS_FLAG AS(
SELECT DISTINCT Contrato, FechaTiquete,SOLUCION_FINAL,
CASE WHEN SOLUCION_FINAL="RETENIDO" THEN COUNT(DISTINCT Contrato) END AS Retenidos,
CASE WHEN SOLUCION_FINAL="NO RETENIDO" THEN COUNT(DISTINCT Contrato) END AS NoRetenidos 
FROM BASE
GROUP BY Contrato, FechaTiquete, SOLUCION_FINAL
),

CHURNERSCRM AS(
    SELECT DISTINCT RIGHT(CONCAT('0000000000',ACT_ACCT_CD) ,10) AS ACT_ACCT_CD, MAX(CST_CHRN_DT) AS Maxfecha
    FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.2022-02-02_CRM_BULK_FILE_FINAL_HISTORIC_DATA_2021_D`
    GROUP BY ACT_ACCT_CD
    HAVING EXTRACT (MONTH FROM Maxfecha) = EXTRACT (MONTH FROM MAX(FECHA_EXTRACCION))
),

CHURNFLAGRESULT AS (
SELECT DISTINCT Contrato, FechaTiquete,SOLUCION_FINAL,MaxFecha,Retenidos,NoRetenidos,
CASE WHEN c.MaxFecha IS NOT NULL THEN "Churner"
WHEN c.Maxfecha IS NULL THEN "NonChurner" end as ChurnFlag
FROM RETENIDOS_FLAG r LEFT JOIN CHURNERSCRM  c ON  r.Contrato=c.ACT_ACCT_CD
WHERE MaxFecha>=FechaTiquete 
GROUP BY Contrato, FechaTiquete,SOLUCION_FINAL, MaxFecha,Retenidos,NoRetenidos)

SELECT EXTRACT(MONTH FROM r.FechaTiquete) as Mes, COUNT(DISTINCT r.Contrato) AS Registros,
 COUNT(Retenidos) AS Retenidos, COUNT(NoRetenidos) as NoRetenidos
FROM CHURNFLAGRESULT r
WHERE ChurnFlag="Churner"
GROUP BY Mes ORDER BY Mes
