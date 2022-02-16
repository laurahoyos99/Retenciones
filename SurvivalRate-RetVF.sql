WITH 

RETENIDOS AS(
SELECT DISTINCT RIGHT(CONCAT('0000000000',Contrato) ,10) AS Contrato, MAX(DATE(FECHA_FINALIZACION)) AS FechaTiquete, SOLUCION_FINAL
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.2022-02-02_TIQUETES_GENERALES_DE_DESCONEXIONES_T` 
WHERE Contrato IS NOT NULL AND SOLUCION_FINAL="RETENIDO" 
--AND EXTRACT(YEAR FROM DATE(FECHA_FINALIZACION))=2021
GROUP BY Contrato, SOLUCION_FINAL
),

CHURNERSCRM AS(
    SELECT DISTINCT RIGHT(CONCAT('0000000000',ACT_ACCT_CD) ,10) AS ACT_ACCT_CD, MAX(CST_CHRN_DT) AS Maxfecha
    FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.2022-02-02_CRM_BULK_FILE_FINAL_HISTORIC_DATA_2021_D`
    --WHERE EXTRACT(YEAR FROM CST_CHRN_DT)=2021
    GROUP BY ACT_ACCT_CD
    HAVING EXTRACT (MONTH FROM Maxfecha) = EXTRACT (MONTH FROM MAX(FECHA_EXTRACCION))
),

MESESCHURN AS(
SELECT DISTINCT ACT_ACCT_CD,
CASE WHEN (EXTRACT(MONTH FROM MaxFecha)=1) THEN "Enero"
WHEN EXTRACT(MONTH FROM MaxFecha)=2 THEN "Febrero"
WHEN EXTRACT(MONTH FROM MaxFecha)=3 THEN "Marzo"
WHEN EXTRACT(MONTH FROM MaxFecha)=4 THEN "Abril"
WHEN EXTRACT(MONTH FROM MaxFecha)=5 THEN "Mayo"
WHEN EXTRACT(MONTH FROM MaxFecha)=6 THEN "Junio"
WHEN EXTRACT(MONTH FROM MaxFecha)=7 THEN "Julio"
WHEN EXTRACT(MONTH FROM MaxFecha)=8 THEN "Agosto"
WHEN EXTRACT(MONTH FROM MaxFecha)=9 THEN "Septiembre"
WHEN EXTRACT(MONTH FROM MaxFecha)=10 THEN "Octubre"
WHEN EXTRACT(MONTH FROM MaxFecha)=11 THEN "Noviembre"
WHEN EXTRACT(MONTH FROM MaxFecha)=12 THEN "Diciembre" END AS Mesesitos
FROM CHURNERSCRM
WHERE EXTRACT(YEAR FROM Maxfecha)=2021
)

SELECT 
Mesesitos, COUNT(DISTINCT r.Contrato)
FROM RETENIDOS r INNER JOIN MESESCHURN c ON c.ACT_ACCT_CD=r.Contrato
WHERE EXTRACT(MONTH FROM FechaTiquete)=1
AND EXTRACT(YEAR FROM FechaTiquete)=2021
--AND EXTRACT(YEAR FROM Maxfecha)=2021

GROUP BY Mesesitos ORDER BY CASE WHEN Mesesitos="Enero" THEN 1
                                 WHEN Mesesitos="Febrero" THEN 2
                                 WHEN Mesesitos="Marzo" THEN 3
                                 WHEN Mesesitos="Abril" THEN 4
                                 WHEN Mesesitos="Mayo" THEN 5
                                 WHEN Mesesitos="Junio" THEN 6
                                 WHEN Mesesitos="Julio" THEN 7
                                 WHEN Mesesitos="Agosto" THEN 8
                                 WHEN Mesesitos="Septiembre"THEN 9
                                 WHEN Mesesitos="Octubre" THEN 10
                                 WHEN Mesesitos="Noviembre" THEN 11
                                 WHEN Mesesitos="Diciembre" THEN 12 END



