/* //////////////// CONSULTAS P/EVALUACION CLINICA //////////////////////////////////// */
-- CONSULTA P/OBTENER DATOS DE TRABAJADOR EN FICHA DE EVALUACIÓN --> 01
SELECT t.id_trab, CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo, t.sexo, t.estado_civil, n.nombre_nacion, t.domicilio, t.rfc, t.num_ass, t.curp, t.dpi, t.fecha_ingreso, w.nombre_tipo_trab, EXTRACT(YEAR FROM age(timestamp 'now()', date(t.fecha_nacim) ) ) as edad,to_char(current_date,'DD TMMONTH YYYY') as fec_act from public.trabajadores t inner join public.nacionalidades n on t.nacionalidad = n.id_nacion inner join public.tipo_trabajador w on t.id_tipo_trab = w.id_tipo_trab where t.id_trab = 'FM1418';

-- CONSULTA P/OBTENER EDAD DE TRABAJADOR EN FICHA DE EVALUACIÓN --> **
SELECT EXTRACT(YEAR FROM age(timestamp 'now()', date(t.fecha_nacim) ) ) as edad FROM public.trabajadores t where t.id_trab = 'FE1061'; 

-- CONSULTA P/EVALUAR STATUS DE TRABAJADOR EN FICHA --> **
SELECT id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,status_trab,status_show,vale_gen from public.trabajadores where id_trab = 'FM1314'; 

-- CONSULTA P/OBTENER DATOS EN CUESTIONARIO Y BENEFICIARIO --> 02, 03
SELECT t.id_trab, CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo, t.sexo, t.estado_civil, n.nombre_nacion, t.domicilio, t.rfc, t.num_ass, t.curp, t.dpi, t.fecha_ingreso, w.nombre_tipo_trab, i.edad from public.trabajadores t inner join public.nacionalidades n on t.nacionalidad = n.id_nacion inner join public.tipo_trabajador w on t.id_tipo_trab = w.id_tipo_trab left join evaluacion.ficha_identificacion i on t.id_trab = i.id_trab where t.id_trab = 'FE1061' ;

-- CONSULTA P/OBTENER DATOS DE FICHA GENERAL
select t.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo, (CASE WHEN t.sexo = 'H' THEN 'HOMBRE' ELSE 'MUJER' END), t.estado_civil, n.nombre_nacion, t.domicilio, t.rfc, t.num_ass, t.curp, t.dpi, t.fecha_ingreso, w.nombre_tipo_trab,f.*,h.*,p.*,np.*,g.*,l.*,s.*,e.* from public.trabajadores t inner join public.nacionalidades n on t.nacionalidad = n.id_nacion inner join public.tipo_trabajador w on t.id_tipo_trab = w.id_tipo_trab left join evaluacion.ficha_identificacion f on f.id_trab = t.id_trab left join evaluacion.ant_heredofamiliares h on f.id_ficha = h.id_ficha left join evaluacion.ant_per_patologicos p on f.id_ficha = p.id_ficha left join evaluacion.ant_per_no_patologicos np on f.id_ficha = np.id_ficha left join evaluacion.ant_gineco_obstetricos g on f.id_ficha = g.id_ficha left join evaluacion.ant_laborales l on f.id_ficha = l.id_ficha left join evaluacion.sintomatologia_actual s on f.id_ficha = s.id_ficha left join evaluacion.exploracion_fisica e on f.id_ficha = e.id_ficha WHERE f.id_trab = 'FE1061';

-- -----------------------------------------------------------------------------------------------------------

-- CONSULTA P/OBTENER ULTIMA FECHA DE EVALUACION CLINICA
SELECT id_ficha,to_char(fechahora::date, 'DD/MM/YYYY') as fechahora from evaluacion.ficha_identificacion where id_trab = 'FM1314' order by id_ficha desc limit 1; 

-- -----------------------------------------------------------------------------------------------------------

-- CONSULTA P/OBTENER DATOS DE FICHA PARTE 1
select t.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo, (CASE WHEN t.sexo = 'H' THEN 'HOMBRE' ELSE 'MUJER' END) as genero,t.estado_civil,n.nombre_nacion,t.domicilio,t.rfc, t.num_ass,t.curp,t.dpi,t.fecha_ingreso,w.nombre_tipo_trab,f.*,h.*,p.*,np.*,g.*,q.nombre_finca,q.nom_fiscal, q.direccion,q.municipio,q.cod_postal,q.rfc_fiscal from public.trabajadores t inner join public.nacionalidades n on t.nacionalidad = n.id_nacion inner join public.tipo_trabajador w on t.id_tipo_trab = w.id_tipo_trab left join evaluacion.ficha_identificacion f on f.id_trab = t.id_trab left join evaluacion.ant_heredofamiliares h on f.id_ficha = h.id_ficha left join evaluacion.ant_per_patologicos p on f.id_ficha = p.id_ficha left join evaluacion.ant_per_no_patologicos np on f.id_ficha = np.id_ficha left join evaluacion.ant_gineco_obstetricos g on f.id_ficha = g.id_ficha left join public.fincas q on t.id_finca = q.id_finca WHERE f.id_trab = 'FM1418' order by f.id_ficha desc limit 1;

-- CONSULTA P/OBTENER DATOS DE FICHA PARTE 2
select f.id_ficha,l.*,s.*,e.*,i.significado,q.nombre_finca,q.nom_fiscal,q.direccion,q.municipio,q.cod_postal, q.rfc_fiscal from public.trabajadores t left join evaluacion.ficha_identificacion f on f.id_trab = t.id_trab left join evaluacion.ant_laborales l on f.id_ficha = l.id_ficha left join evaluacion.sintomatologia_actual s on f.id_ficha = s.id_ficha left join evaluacion.exploracion_fisica e on f.id_ficha = e.id_ficha inner join evaluacion.imc i on i.id_imc = e.imc inner join public.fincas q on t.id_finca = q.id_finca WHERE f.id_trab = 'FE1061' order by f.id_ficha desc limit 1;

-- ----------------------------------------------------------------------------------------------------------

-- CONSULTA P/OBTENER DATOS DE CUESTIONARIO *
select t.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo, (CASE WHEN t.sexo = 'H' THEN 'HOMBRE' ELSE 'MUJER' END) as genero,t.domicilio,t.fecha_ingreso,w.nombre_tipo_trab,f.edad, a.*,r.*,e.*,v.*,q.nombre_finca,q.nom_fiscal,q.direccion,q.municipio,q.cod_postal,q.rfc_fiscal from public.trabajadores t inner join public.tipo_trabajador w on t.id_tipo_trab = w.id_tipo_trab left join evaluacion.ficha_identificacion f on f.id_trab = t.id_trab left join evaluacion.acontecimiento_traumatico a on t.id_trab = a.id_trab left join evaluacion.recuerdos_persistentes r on a.id_acon = r.id_acon left join evaluacion.esfuerzo_por_evitar e on a.id_acon = e.id_acon left join evaluacion.afectacion v on a.id_acon = v.id_acon inner join public.fincas q on t.id_finca = q.id_finca WHERE a.id_trab = 'FM1318' order by a.id_acon desc limit 1;

-- -----------------------------------------------------------------------------------------------------------

-- CONSULTA P/OBTENER DATOS DE BENEFICIARIO *
select t.id_trab,t.nombre_trab, t.ape_paterno,t.ape_materno,t.domicilio,f.nombre_finca,f.municipio,f.nom_fiscal,b.* from public.trabajadores t inner join public.fincas f on f.id_finca = t.id_finca inner join evaluacion.beneficiario b on t.id_trab = b.id_trab where b.id_trab = 'FE1061';

-- -----------------------------------------------------------------------------------------------------------

-- CONSULTA P/OBTENER DATOS DE CARTA COMPROMISO *
select t.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo, t.domicilio,q.nombre_finca,q.nombre_finca,q.nom_fiscal, q.direccion,q.municipio,q.cod_postal from public.trabajadores t inner join public.fincas q on q.id_finca = t.id_finca where t.id_trab = 'FE1061';

-- -----------------------------------------------------------------------------------------------------------

-- OBTENER DATOS PARA RENUNCIA DE TRABAJADOR
select t.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo, f.nombre_finca,f.nom_fiscal, f.direccion,f.municipio,f.cod_postal,f.rfc_fiscal from public.trabajadores t inner join public.fincas f on f.id_finca = t.id_finca where t.id_trab = 'FM1314';

-- -----------------------------------------------------------------------------------------------------------

-- FECHA CON FORMATO LARGO: select to_char(t.fecha_ingreso::date + 60,'DD TMMONTH YYYY') as fecha from trabajadores t where id_trab = 'FM1313';

-- OBTENER DATOS PARA CONTRATO DETERMINADO DE TRABAJADOR
SELECT t.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,t.estado_civil, n.nombre_nacion,t.domicilio, to_char(t.fecha_ingreso::date,'DD TMMONTH YYYY') as fecha_ingreso,w.nombre_tipo_trab,EXTRACT(YEAR FROM age(timestamp 'now()', date(t.fecha_nacim))) as edad,(CASE WHEN t.sexo = 'H' THEN 'MASCULINO' ELSE 'FEMENINO' END) as sexo,f.nombre_finca,f.nom_fiscal, f.direccion,f.municipio,to_char(t.fecha_ingreso::date + 60,'DD TMMONTH YYYY') as fecha_fin from public.trabajadores t inner join public.nacionalidades n on t.nacionalidad = n.id_nacion inner join public.tipo_trabajador w on t.id_tipo_trab = w.id_tipo_trab inner join public.fincas f on f.id_finca = t.id_finca where t.id_trab = 'FE1061';

-- OBTENER DATOS PARA CONTRATO INDETERMINADO DE TRABAJADOR
SELECT t.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,t.estado_civil, n.nombre_nacion,t.domicilio, to_char(t.fecha_ingreso::date,'DD TMMONTH YYYY') as fecha_ingreso,w.nombre_tipo_trab,EXTRACT(YEAR FROM age(timestamp 'now()', date(t.fecha_nacim))) as edad,(CASE WHEN t.sexo = 'H' THEN 'MASCULINO' ELSE 'FEMENINO' END) as sexo,f.nombre_finca,f.nom_fiscal, f.direccion,f.municipio from public.trabajadores t inner join public.nacionalidades n on t.nacionalidad = n.id_nacion inner join public.tipo_trabajador w on t.id_tipo_trab = w.id_tipo_trab inner join public.fincas f on f.id_finca = t.id_finca where t.id_trab = 'FE1061';

-- ACTUALIZAR FECHA DE TERMINO DE CONTRATO DEL TRABAJADOR
/* update trabajadores set fin_contrato = tq.fecha_fin from (select fecha_ingreso::date + '60'::integer as fecha_fin from trabajadores where id_trab= 'FM1318') as tq where id_trab= 'FM1318'; */

-- OBTENER SALARIO_MINIMO (ACTUAL) OK
SELECT MONTO FROM EVALUACION.SALARIO_MINIMO ORDER BY ID_SALARIO DESC LIMIT 1; -- OBT. SALARIO MINIMO

-- -----------------------------------------------------------------------------------------------------------

-- ACTUALIZAR CAMPOS EN FICHA DE TRABAJADOR SEGUN SU EVALUACION
/* alter table evaluacion.exploracion_fisica add column evaluacion_sistema varchar;

update evaluacion.exploracion_fisica set pronostico = '?', adscripcion_evaluador = '?', observaciones = '?', evaluacion_sistema = '?' where id_ficha = 'XXXX' ; */

-- -----------------------------------------------------------------------------------------------------------
-- CONSULTA P/GENERAR CARATULA DEL TRABAJADOR EN CUALQUIER STATUS
SELECT tp.nombre_tipo_trab, t.turno24, t.id_trab, t.nombre_trab, t.ape_paterno, t.ape_materno, t.fecha_nacim, t.sexo, t.estado_civil, t.rfc, t.curp, t.num_ass, n.nombre_nacion, ti.nombre_identificacion, t.num_identif, t.fecha_vigencia_dpi, t.num_nue, t.lugar_origen, t.domicilio, t.nacionalidad, t.id_finca, f.nombre_finca, t.status_trab, t.fecha_ingreso, t.fecha_registro /*, encode(t.foto,'base64') as foto*/ FROM trabajadores t, fincas f, nacionalidades n, tipos_de_identificaciones ti, tipo_trabajador tp WHERE id_trab='FK010' AND t.id_finca=f.id_finca AND t.nacionalidad=n.id_nacion AND t.id_identificacion=ti.id_identificacion AND t.id_tipo_trab=tp.id_tipo_trab;

-- -----------------------------------------------------------------------------------------------------------

-- CONSULTA P/OBTENER DATOS PENDIENTES :: GENERAR CONTRATOS 1
SELECT F.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('GENERAR CONTRATO') AS MOVIMIENTO,T.FECHA_REGISTRO AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN PUBLIC.FINCAS F ON F.ID_FINCA = T.ID_FINCA WHERE T.STATUS_TRAB = 1 AND T.FECHA_REGISTRO::DATE > '2020-12-23' AND T.FIN_CONTRATO IS NULL ORDER BY T.FECHA_REGISTRO::DATE DESC;

-- CONSULTA P/OBTENER DATOS PENDIENTES :: RENOVAR CONTRATOS (7 DIAS ANTES) 2
SELECT F.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('RENOVAR CONTRATO') AS MOVIMIENTO,T.FIN_CONTRATO::DATE AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN PUBLIC.FINCAS F ON F.ID_FINCA = T.ID_FINCA WHERE CURRENT_DATE BETWEEN (T.FIN_CONTRATO::DATE -7) AND (T.FIN_CONTRATO::DATE) AND T.STATUS_TRAB = 1 AND T.FIN_CONTRATO IS NOT NULL ORDER BY T.FIN_CONTRATO::DATE;

-- CONSULTA P/OBTENER DATOS PENDIENTES :: VER CONTRATOS EXPIRADOS 3
SELECT F.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('CONTRATO EXPIRADO') AS MOVIMIENTO,T.FIN_CONTRATO::DATE AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN PUBLIC.FINCAS F ON F.ID_FINCA = T.ID_FINCA WHERE T.FIN_CONTRATO::DATE < CURRENT_DATE AND T.STATUS_TRAB = 1 AND T.FIN_CONTRATO IS NOT NULL ORDER BY T.FIN_CONTRATO::DATE;

-- CONSULTA P/OBTENER DATOS PENDIENTES :: REALIZAR NUEVA EVALUACION 4 ** 
SELECT X.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('REALIZAR EVALUACION') AS MOVIMIENTO,(F.FECHAHORA::DATE) AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN EVALUACION.FICHA_IDENTIFICACION F ON T.ID_TRAB = F.ID_TRAB INNER JOIN PUBLIC.FINCAS X ON X.ID_FINCA = T.ID_FINCA WHERE CURRENT_DATE -366 BETWEEN (F.FECHAHORA::DATE +8) AND (F.FECHAHORA::DATE) AND T.STATUS_TRAB = 1 ORDER BY F.FECHAHORA::DATE;

-- CONSULTA P/OBTENER DATOS PENDIENTES :: VER EVALUACION EXPIRADA 5 **
SELECT X.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('EVALUACION EXPIRADA') AS MOVIMIENTO,(F.FECHAHORA::DATE) AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN EVALUACION.FICHA_IDENTIFICACION F ON T.ID_TRAB = F.ID_TRAB INNER JOIN PUBLIC.FINCAS X ON X.ID_FINCA = T.ID_FINCA WHERE (F.FECHAHORA::DATE) < CURRENT_DATE - 366 AND T.STATUS_TRAB = 1 ORDER BY F.FECHAHORA::DATE;

-- CONSULTA PARA VER LOS MOVIMIENTOS MAS RECIENTES DE BAJAS DE TRABAJADOR
SELECT m.id_trab, to_char(m.fecha_hora_movim,'YYYY-MM-DD') as fecha_servidor,tm.nombre_movimiento, (CASE WHEN m.fecha_hora_movim < (current_date -5) THEN 'nel' ELSE 'sip' END) AS valor FROM movimientos m, baja_trabajadores bt, tipos_de_movimientos tm, tipos_de_baja tb, tipo_trabajador tt WHERE m.id_trab='FC019' AND m.id_baja=bt.id_baja AND m.id_tipo_movim=tm.id_tipo_movim AND bt.id_tipo_baja=tb.id_tipo_baja AND bt.id_tipo_trab=tt.id_tipo_trab AND (m.id_tipo_movim='3') ORDER BY fecha_hora_movim DESC limit 1;

-- -----------------------------------------------------------------------------------------------------------

/* ///////////////////////////// AGREGAR COLUMNA A TABLAS //////////////////////////////////////// */
/* AGREGAR COLUMAS A TABLA FINCAS: DIRECCION, MUNICIPIO, CODIGO_POSTAL, NOM_FISCAL, MPIO_FISCAL, DIR_FISCAL */
alter table public.fincas add column direccion varchar(512);
alter table public.fincas add column municipio varchar(512);
alter table public.fincas add column cod_postal varchar(32);
alter table public.fincas add column nom_fiscal varchar(512);
alter table public.fincas add column mpio_fiscal varchar(512);
alter table public.fincas add column rfc_fiscal varchar(32);
alter table public.fincas add column dir_fiscal varchar(512); 
alter table public.trabajadores add column fin_contrato date; -- new p/evalucion
alter table public.privilegios_usuarios add column eval2 integer default 0; -- nvo p/eval fake

insert into public.tipos_de_movimientos values(16,'baja por termino de contrato',1);

-- FALTA AGREGAR (DIR_FISCAL)

-- NUEVO PERMISO PARA VER NOTIFICACIONES PENDIENTES **
alter table public.privilegios_usuarios add column noti_pen integer default 0; -- p/ver notificaciones OK

-- -----------------------------------------------------------------------------------------------------------
/* AGREGAR VALORES A COLUMNAS NUEVAS */

-- FINCA: DON ROLANDO
update public.fincas set direccion = 'CARRETERA LA LIBERTAD S/N COLONIA LAZARO CARDENAS', municipio = 'SUCHIATE, CHIAPAS', cod_postal = 'C.P. 30840', nom_fiscal ='KAVIDAC PRODUCE S.A. DE C.V.', mpio_fiscal = 'TAPACHULA, CHIAPAS', rfc_fiscal = 'KPR1611048Z5' where nombre_finca like '%DON ROLANDO%';

-- FINCA: ESPERANZA
update public.fincas set direccion = 'CARRETERA AEROPUERTO JARITAS, DESVIO BARRA CAHOACAN', municipio = 'TAPACHULA, CHIAPAS', cod_postal = 'C.P. 30830', nom_fiscal ='KAVIDAC PRODUCE S.A. DE C.V.', mpio_fiscal = 'TAPACHULA, CHIAPAS', rfc_fiscal = 'KPR1611048Z5' where nombre_finca like '%ESPERANZA%';

-- FINCA: MARY CARMEN
update public.fincas set direccion = 'A 200 MTS. LADO ORIENTE DE LA COLONIA SOCONUSCO S/N', municipio = 'ACAPETAHUA, CHIAPAS', cod_postal = 'C.P. 30580', nom_fiscal ='KAVIDAC PRODUCE S.A. DE C.V.', mpio_fiscal = 'ACAPETAHUA, CHIAPAS', rfc_fiscal = 'KPR1611048Z5' where nombre_finca like '%MARY CARMEN%';

-- FINCA: CALZADITA
update public.fincas set direccion = 'CAMINO A CANTON CHUNIAPA S/N 1.5 KM DEL MPIO. DE MAZATAN CHIAPAS', municipio = 'MAZATAN, CHIAPAS', cod_postal = 'C.P. 30650', nom_fiscal ='KAVIDAC PRODUCE S.A. DE C.V.', mpio_fiscal = 'TAPACHULA, CHIAPAS', rfc_fiscal = 'KPR1611048Z5' where nombre_finca like '%CALZADITA%';

-- FINCA: LOS CARLOS
update public.fincas set direccion = 'CARRETERA COSTERA VILLA A HUIXTLA S/N', municipio = 'VILLA COMALTITLAN, CHIAPAS', cod_postal = 'C.P. 30620', nom_fiscal ='AGRIBANANOS DEL TACANA S.A. DE C.V.', mpio_fiscal = 'VILLA COMALTITLAN, CHIAPAS', rfc_fiscal = 'ATA161104JH2' where nombre_finca like '%LOS CARLOS%';

-- OFICINA CENTRAL *
update public.fincas set direccion = 'BOULEVARD GUSTAVO DIAZ ORDAZ No. MZA 50 LT1, COL. LOMAS DE SAYULA,', municipio = 'TAPACHULA, CHIAPAS', cod_postal = 'C.P. 30740', nom_fiscal ='KAVIDAC PRODUCE S.A. DE C.V.', mpio_fiscal = 'TAPACHULA, CHIAPAS', rfc_fiscal = 'KPR1611048Z5' where nombre_finca like '%OFICINA%';

-- -----------------------------------------------------------------------------------------------------------
-- OBTENER FAMILIARES DE TRABAJADORES EN FINCA
SELECT id_trab, CONCAT(nombre_trab||' '||ape_paterno||' '||ape_materno) as nombre_trabajador,X.NOMBRE_TIPO_TRAB AS TIPO FROM trabajadores t INNER JOIN fincas f ON (t.id_finca=f.id_finca) INNER JOIN TIPO_TRABAJADOR X ON T.ID_TIPO_TRAB = X.ID_TIPO_TRAB INNER JOIN evaluacion.fam_finca p on p.id_trab_fam = t.id_trab WHERE  p.id_trab_new LIKE ('%FE1061%') and status_trab = 1 group by id_trab,nombre_trabajador,X.NOMBRE_TIPO_TRAB ORDER BY id_trab;

-- VERIFICACION DE FICHA DE TRABAJADOR (NO FUNCIONA EL REPORT) --
finca : UNKNOW
logo : file:/C:/Users/dt&c3/Documents/NetBeansProjects/SIARH-K/build/classes/imgs/PDFkavidac.jpg
ruta : C:\Users\dt&c3\AppData\Roaming\Registro_De_Personal\photoPDF_TMP.jpg
conNue : 0
-- -----------------------------------------------------------------------------------------------------------
-- VERIFICACION DE FICHA DE TRABAJADOR (CARATULA FAKE) -- OK --> RESUELTO
finca : UNKNOW
logo : file:/C:/Users/dt&c3/Documents/NetBeansProjects/repositorio/SIARH_/build/classes/imgs/PDFkavidac.jpg
ruta : C:\Users\dt&c3\AppData\Roaming\Registro_De_Personal\photoPDF_TMP.jpg
conNue : 0

file:/C:/Users/dt&c3/Documents/NetBeansProjects/repositorio/SIARH_/build/classes/imgs/PDFkavidac.jpg
C:\Users\dt&c3\AppData\Roaming\Registro_De_Personal\photoPDF_TMP.jpg
