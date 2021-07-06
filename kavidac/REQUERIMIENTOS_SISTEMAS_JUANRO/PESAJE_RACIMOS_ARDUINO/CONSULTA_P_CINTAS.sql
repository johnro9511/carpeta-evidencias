-- ---------------------------------------------------------------------------------------------------------------------
-- CREACION DE VISTA P/GENERAR REPORTE POR COLOR DE CINTAS
CREATE VIEW PUBLIC.CINTAS_DETALLE_RACIMO as
SELECT C.ID_CARGA,C.FECHA::DATE AS FECHA, C.FECHA::TIME(0) AS HORA,C.NUM_CARGA,C.CANT_RACIMO,
C.TOTAL_KG,C.FOLIO,C.ID_FINCA,F.NOMBRE_FINCA,C.ID_LOTE,C.TORRE_INI,C.TORRE_FIN,
D.CNS,D.PESO_KG,D.IDCINTA,Z.COLORCINTA FROM PUBLIC.CARGA C
LEFT JOIN PUBLIC.DETALLE_CARGA D ON C.ID_CARGA = D.ID_CARGA
INNER JOIN PUBLIC.FINCA F ON C.ID_FINCA = F.ID_FINCA
LEFT JOIN PUBLIC.CAT_CINTAS Z ON D.IDCINTA = Z.IDCINTA
/* WHERE C.FECHA :: DATE BETWEEN CURRENT_DATE -180 AND CURRENT_DATE */
ORDER BY C.ID_CARGA ASC;

-- ---------------------------------------------------------------------------------------------------------------------
-- CONSULTAS REALIZADAS PREVIAMENTE P/OBTENER DATOS POR SEPARADO
SELECT * FROM PUBLIC.CINTAS_DETALLE_RACIMO WHERE COLORCINTA='AMARILLO'; -- TOTAL TOTAL
SELECT SUM(PESO_KG) FROM PUBLIC.CINTAS_DETALLE_RACIMO WHERE COLORCINTA='VERDE'; -- SUM(331)
SELECT AVG(PESO_KG)::NUMERIC(9,2) FROM PUBLIC.CINTAS_DETALLE_RACIMO WHERE COLORCINTA='VERDE';-- PROMEDIO
SELECT MIN(PESO_KG) FROM PUBLIC.CINTAS_DETALLE_RACIMO WHERE COLORCINTA='VERDE'; -- MINIMO 
SELECT MAX(PESO_KG) FROM PUBLIC.CINTAS_DETALLE_RACIMO WHERE COLORCINTA='VERDE'; -- MAXIMO
-- SELECT MODE() WITHIN GROUP (ORDER BY PESO_KG) AS MODA FROM PUBLIC.CINTAS_DETALLE_RACIMO WHERE COLORCINTA='ROJO';

-- ---------------------------------------------------------------------------------------------------------------------
-- CONSULTA LA VISTA P/GENERAR PESO(TOTAL, PROME, MIN, MAX) FILTRO POR: RANGO DE FECHAS
SELECT COUNT(*) AS RACIMOS,SUM(PESO_KG)::NUMERIC(9,2) AS TOTAL,AVG(PESO_KG)::NUMERIC(9,2) AS PROMEDIO,
MIN(PESO_KG) AS MINIMO, MAX(PESO_KG) AS MAXIMO,FECHA, NOMBRE_FINCA AS FINCA, COLORCINTA AS CINTA 
FROM PUBLIC.CINTAS_DETALLE_RACIMO WHERE FECHA BETWEEN '2020-08-01' AND '2021-06-06'
GROUP BY FECHA,FINCA,CINTA ORDER BY FECHA DESC; 

-- ---------------------------------------------------------------------------------------------------------------------
-- CONSULTA LA VISTA P/GENERAR PESO(TOTAL, PROME, MIN, MAX) FILTRO POR: RANGO DE FECHAS Y CINTA
SELECT COUNT(*) AS RACIMOS, SUM(PESO_KG)::NUMERIC(9,2) AS TOTAL, AVG(PESO_KG)::NUMERIC(9,2) AS PROMEDIO,
MIN(PESO_KG) AS MINIMO, MAX(PESO_KG) AS MAXIMO,FECHA,NOMBRE_FINCA AS FINCA,COLORCINTA AS CINTA 
FROM PUBLIC.CINTAS_DETALLE_RACIMO WHERE COLORCINTA='AMARILLO' AND FECHA BETWEEN '2020-08-01' AND '2021-06-02'
GROUP BY FECHA,FINCA,CINTA ORDER BY FECHA ASC; 

-- ---------------------------------------------------------------------------------------------------------------------

Ya subi los cambios p/modulo de compras (DANNY)
bd --> kavidac_finca_test_sicak
ip --> 192.168.0.63
contraseña: pampitas15spr 

SELECT seu.id_product,seu.version_product,seu.so_name, seu.arquitectura, seu.version_so, seu.ip_machine, seu.mac_address, seu.hostname, seu.product_update, seu.new_version, lvs.ip_server, lvs.folder_setup, lvs.setup_name, lvs.user_server, lvs.password_server, seu.messenger_update, seu.ultima_vez, seu.actualizacion_importante FROM software_en_uso seu inner join log_version_software lvs on seu.new_version=lvs.version and seu.id_version=lvs.id_version WHERE  seu.mac_address = '10:7B:44:4B:08:74' AND seu.sistema= 'RP';

SELECT id_ficha,to_char(fechahora::date, 'DD/MM/YYYY') as fechahora from evaluacion.ficha_identificacion where id_trab = 'FE041' order by fechahora desc limit 1;