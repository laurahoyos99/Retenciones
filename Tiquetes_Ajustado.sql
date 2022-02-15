WITH

RETENCIONES AS(
SELECT DISTINCT RIGHT(CONCAT('0000000000',Contrato) ,10) AS Contrato
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.2022-02-02_TIQUETES_GENERALES_DE_DESCONEXIONES_T` 
WHERE Contrato IS NOT NULL 
--AND EXTRACT(YEAR FROM FECHA_FINALIZACION)=2021
GROUP BY Contrato),

ORDENES AS(
SELECT DISTINCT RIGHT(CONCAT('0000000000',CONTRATO) ,10) AS CONTRATO
FROM `gcp-bia-tmps-vtr-dev-01.gcp_temp_cr_dev_01.2022-01-12_CR_TIQUETES_SERVICIO_2021-01_A_2021-11_D` 
WHERE CONTRATO IS NOT NULL AND MOTIVO="LLAMADA  CONSULTA DESINSTALACION"
GROUP BY CONTRATO),

CRUCE AS(
SELECT DISTINCT r.Contrato 
FROM RETENCIONES r INNER JOIN ORDENES o ON r.Contrato=o.CONTRATO
GROUP BY r.Contrato
)

SELECT COUNT(DISTINCT Contrato)
FROM CRUCE
