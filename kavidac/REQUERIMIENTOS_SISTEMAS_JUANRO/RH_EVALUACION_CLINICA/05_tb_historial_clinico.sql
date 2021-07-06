/* TABLAS PARA HISTORIAL CLINICO  ES ESQUEMA EVALUACION */

CREATE SCHEMA evaluacion;

-- ficha de identificacion
create table evaluacion.ficha_identificacion( -- 01 OK *
  id_ficha varchar primary key,
  id_trab varchar references public.trabajadores,
  edad varchar,
  escolaridad varchar,
  religion varchar,
  grupo_etnico varchar,
  ocupacion_anterior varchar,
  jefe_inmediato varchar,
  fam_en_finca integer,
  fechahora timestamp default current_timestamp(0)
);

create table evaluacion.fam_finca( -- 25 OK *
  id_trab_new varchar references public.trabajadores,
  id_trab_fam varchar references public.trabajadores,
  primary key (id_trab_new,id_trab_fam)
); -- referencia de fam en finca

create table evaluacion.ant_heredofamiliares( -- 02 OK *
  id_ficha varchar primary key references evaluacion.ficha_identificacion,
  diabetes varchar,
  hipertension_art varchar,
  cancer varchar,
  enferm_hepaticas varchar,
  enferm_renales varchar,
  cardiopatias varchar,
  malform_congenitas varchar,
  enferm_sist_nerv varchar
);

create table evaluacion.ant_per_patologicos( -- 03 OK *
  id_ficha varchar primary key references evaluacion.ficha_identificacion,
  cirugias varchar,
  fracturas varchar,
  transfuciones_san varchar,
  alergias varchar,
  hospitalizaciones_prev varchar,
  tabaquismo varchar,
  alcoholismo varchar,
  drogadiccion varchar,
  uso_medicamento varchar,
  enfermedad_base varchar
);

create table evaluacion.ant_per_no_patologicos( -- 04 OK *
  id_ficha varchar primary key references evaluacion.ficha_identificacion,
  piso varchar,
  paredes varchar,
  techo varchar,
  num_personas integer,
  num_cuartos integer,
  num_sanitarios integer,
  alimentos_consume varchar (512),
  num_ventanas integer,
  hace_necesidades varchar,
  combustible_cocina varchar,
  agua_beber varchar,
  zoonosis varchar (512),
  serv_urbanizacion varchar (512)
);
 
create table evaluacion.ant_gineco_obstetricos( -- 05 OK *
  id_ficha varchar primary key references evaluacion.ficha_identificacion,
  g integer,
  p integer,
  c integer,
  a integer,
  menarca varchar,
  fur varchar,
  ciclos varchar,
  mpf varchar,
  ivsa varchar, 
  papanicolau varchar
);

create table evaluacion.ant_laborales( -- 06 OK *
  id_ficha varchar primary key references evaluacion.ficha_identificacion,
  expuesto_ferti_plagui varchar,
  nombre_plagui varchar,
  tiempo_exposicion varchar,
  via_exposicion varchar,
  enfermedades_causadas varchar (512)
);

create table evaluacion.sintomatologia_actual( -- 07 OK *
  id_ficha varchar primary key references evaluacion.ficha_identificacion,
  dolor_cabeza varchar,
  mareos varchar,
  perdida_apetito varchar,
  ansiedad_alteraciones varchar,
  vision_borrosa varchar,
  debilidad varchar,
  hormigueo varchar,
  nauseas varchar,
  dolor_abdominal varchar,
  disnea varchar
);

create table evaluacion.imc( -- 8 OK *
  id_imc integer primary key,
  val_min numeric(5,2),
  val_max numeric(5,2),
  significado varchar,
  color varchar
);

insert into evaluacion.imc values (1,0,18.49,'DESNUTRICION','ROJO');
insert into evaluacion.imc values (2,18.50,24.99,'NORMAL','VERDE');
insert into evaluacion.imc values (3,25,29.99,'SOBREPESO','AMARILLO');
insert into evaluacion.imc values (4,30,34.99,'OBESIDAD GRADO I','ROJO');
insert into evaluacion.imc values (5,35,39.99,'OBESIDAD GRADO II','ROJO');
insert into evaluacion.imc values (6,40,100,'OBESIDAD MORBIDA','ROJO');

create table evaluacion.exploracion_fisica( -- 09 OK *
  id_ficha varchar primary key references evaluacion.ficha_identificacion,
  presion_arterial varchar,
  frec_cardiaca varchar,
  frec_respiratoria varchar,
  pulso varchar,
  temperatura varchar,
  agudeza_visual varchar,
  destroxtis varchar,
  peso varchar,
  talla varchar,
  imc integer references evaluacion.imc,
  valor_imc numeric(5,2),
  cabeza varchar (512),
  ojos varchar (512),
  cavidad_oral varchar (512),
  cuello varchar (512),
  cardiopulmonar varchar (512),
  abdominal varchar (512),
  urogenital varchar (512),
  extremidades varchar (512),
  piel varchar (512),
  fuerza_muscular varchar,
  reflejos varchar,
  tipo_marcha varchar,
  laboratorio_gabinete varchar (512),
  impresion_diagnostica varchar (512),
  pronostico varchar, -- p/upd
  adscripcion_evaluador varchar, -- p/upd
  observaciones varchar (512), -- p/upd
  evaluacion_sistema varchar -- p/upd ++
);

create table evaluacion.acontecimiento_traumatico( -- 10 OK *
  id_acon varchar primary key,
  id_trab varchar references public.trabajadores,
  accidente varchar,
  asalto varchar,
  acto_violento varchar,
  secuestro varchar,
  amenaza varchar,
  otro_riesgo varchar,
  observacion varchar (512),
  fechahora timestamp default current_timestamp(0)
);

create table evaluacion.recuerdos_persistentes( -- 11 OK *
  id_acon varchar primary key references evaluacion.acontecimiento_traumatico,
  ha_tenido_rdos varchar,
  ha_tenido_suenos varchar
);

create table evaluacion.esfuerzo_por_evitar( -- 12 OK *
  id_acon varchar primary key references evaluacion.acontecimiento_traumatico,
  evitar_sentimientos varchar,
  evitar_actividades varchar,
  dificultad_recordar varchar,
  disminuido_interes varchar,
  sentido_alejado varchar,
  dificultad_expresar varchar,
  vida_corta varchar
);

create table evaluacion.afectacion( -- 13 OK *
  id_acon varchar primary key references evaluacion.acontecimiento_traumatico,
  dificultad_dormir varchar,
  estar_irritable varchar,
  dificultad_concentrarse varchar,
  estar_nervioso varchar,
  sobresaltado varchar
);

create table evaluacion.escolaridad( -- 14 OK *
  id_escolar integer primary key,
  descripcion varchar
);

insert into evaluacion.escolaridad values (1,'ANALFABETA');
insert into evaluacion.escolaridad values (2,'PRIMARIA INCOMPLETA');
insert into evaluacion.escolaridad values (3,'PRIMARIA TERMINADA');
insert into evaluacion.escolaridad values (4,'SECUNDARIA INCOMPLETA');
insert into evaluacion.escolaridad values (5,'SECUNDARIA TERMINADA');
insert into evaluacion.escolaridad values (6,'BACHILLERATO INCOMPLETO');
insert into evaluacion.escolaridad values (7,'BACHILLERATO TERMINADO');
insert into evaluacion.escolaridad values (8,'LICENCIATURA');
insert into evaluacion.escolaridad values (9,'INGENIERIA');
insert into evaluacion.escolaridad values (10,'ESPECIALIDAD');
insert into evaluacion.escolaridad values (11,'MAESTRIA');
insert into evaluacion.escolaridad values (12,'DOCTORADO');

create table evaluacion.parentesco( -- 15 OK *
  id_parent integer primary key,
  descripcion varchar
);

insert into evaluacion.parentesco values (1,'MAMA');
insert into evaluacion.parentesco values (2,'PAPA');
insert into evaluacion.parentesco values (3,'HERMANO(A)');
insert into evaluacion.parentesco values (4,'ABUELO PATERNO');
insert into evaluacion.parentesco values (5,'ABUELA PATERNA');
insert into evaluacion.parentesco values (6,'ABUELO MATERNO');
insert into evaluacion.parentesco values (7,'ABUELA MATERNA');
insert into evaluacion.parentesco values (8,'HIJO(A)');
insert into evaluacion.parentesco values (9,'TIO(A)');
insert into evaluacion.parentesco values (10,'ESPOSO(A)');
insert into evaluacion.parentesco values (11,'SOBRINO(A)');
insert into evaluacion.parentesco values (12,'PRIMO(A)');
insert into evaluacion.parentesco values (13,'CUÑADO(A)');

create table evaluacion.cirugia( -- 16 OK *
  id_cirugia integer primary key,
  descripcion varchar
);

insert into evaluacion.cirugia values (1,'NINGUNA');
insert into evaluacion.cirugia values (2,'APENDICECTOMIA');
insert into evaluacion.cirugia values (3,'COLECISTECTOMIA');
insert into evaluacion.cirugia values (4,'CESAREA');
insert into evaluacion.cirugia values (5,'HERNIPLASTIA INGUINAL O UMBILICAL');
insert into evaluacion.cirugia values (6,'CABEZA Y CUELLO');
insert into evaluacion.cirugia values (7,'COLUMNA U ORTOPEDICA');
insert into evaluacion.cirugia values (8,'OTRA');

create table evaluacion.fractura( -- 17 OK *
  id_fractura integer primary key,
  descripcion varchar
);

insert into evaluacion.fractura values (1,'NINGUNA');
insert into evaluacion.fractura values (2,'CUBITO Y RADIO');
insert into evaluacion.fractura values (3,'HUMERO');
insert into evaluacion.fractura values (4,'CLAVICULA');
insert into evaluacion.fractura values (5,'MUÑECA');
insert into evaluacion.fractura values (6,'CADERA');
insert into evaluacion.fractura values (7,'FEMUR');
insert into evaluacion.fractura values (8,'TIBIA Y PERONE');
insert into evaluacion.fractura values (9,'TOBILLO');
insert into evaluacion.fractura values (10,'RODILLA'); -- ADD
insert into evaluacion.fractura values (11,'OTRA');

create table evaluacion.droga( -- 18 OK *
  id_droga integer primary key,
  descripcion varchar
);

insert into evaluacion.droga values (1,'NO');
insert into evaluacion.droga values (2,'MARIHUANA');
insert into evaluacion.droga values (3,'COCAINA');
insert into evaluacion.droga values (4,'LSD');
insert into evaluacion.droga values (5,'CRACK');
insert into evaluacion.droga values (6,'HEROINA');
insert into evaluacion.droga values (7,'METANFETAMINA');
insert into evaluacion.droga values (8,'OTRA');

create table evaluacion.enfermedad_base( -- 19 OK *
  id_enfermedad integer primary key,
  descripcion varchar
);

insert into evaluacion.enfermedad_base values (1,'NINGUNA');
insert into evaluacion.enfermedad_base values (2,'DIABETES');
insert into evaluacion.enfermedad_base values (3,'HIPERTENSION ARTERIAL');
insert into evaluacion.enfermedad_base values (4,'ENFERMEDAD RENAL CRONICA');
insert into evaluacion.enfermedad_base values (5,'ASMA');
insert into evaluacion.enfermedad_base values (6,'EPILEPSIA');
insert into evaluacion.enfermedad_base values (7,'FIBROSIS PULMONAR');
insert into evaluacion.enfermedad_base values (8,'CARDIOPATIA ISQUEMICA');
insert into evaluacion.enfermedad_base values (9,'ESPONDLIS ANQUILOSANTE');
insert into evaluacion.enfermedad_base values (10,'CANCER');
insert into evaluacion.enfermedad_base values (11,'EPOC');
insert into evaluacion.enfermedad_base values (12,'ENFERMEDAD DE LA TIROIDES');
insert into evaluacion.enfermedad_base values (13,'FIBROMIALGIA');
insert into evaluacion.enfermedad_base values (14,'LUPUS ERITMATOSO SISTEMATICO');
insert into evaluacion.enfermedad_base values (15,'ARTRITIS REUMATOIDE');
insert into evaluacion.enfermedad_base values (16,'INSUFICIENCIA VENOSA CRONICA');
insert into evaluacion.enfermedad_base values (17,'OTRA');

create table evaluacion.uso_medicamento( -- 20 OK *
  id_medicamento integer primary key,
  descripcion varchar
);

insert into evaluacion.uso_medicamento values (1,'NINGUNO');
insert into evaluacion.uso_medicamento values (2,'HIPOGLECEMIANTES ORALES');
insert into evaluacion.uso_medicamento values (3,'INSULINA');
insert into evaluacion.uso_medicamento values (4,'ANTIHIPERTENSIVOS');
insert into evaluacion.uso_medicamento values (5,'ANTICONVULSIVOS');
insert into evaluacion.uso_medicamento values (6,'ANTICOAGULANTES');
insert into evaluacion.uso_medicamento values (7,'ANTIRRITMICOS');
insert into evaluacion.uso_medicamento values (8,'ANTIASMATICOS');
insert into evaluacion.uso_medicamento values (9,'ANTIRRETROVIRALES');
insert into evaluacion.uso_medicamento values (10,'ANTITUBERCULOSOS');
insert into evaluacion.uso_medicamento values (11,'INMUNOMODULARES');
insert into evaluacion.uso_medicamento values (12,'OTRO');

create table evaluacion.metodo_planificacion( -- 21 OK *
  id_metodo integer primary key,
  descripcion varchar
);

insert into evaluacion.metodo_planificacion values (1,'NINGUNO');
insert into evaluacion.metodo_planificacion values (2,'DIU');
insert into evaluacion.metodo_planificacion values (3,'IMPLANTE');
insert into evaluacion.metodo_planificacion values (4,'HORMONAL INYECTABLE');
insert into evaluacion.metodo_planificacion values (5,'HORMONAL ORAL');
insert into evaluacion.metodo_planificacion values (6,'PRESERVATIVO');
insert into evaluacion.metodo_planificacion values (7,'VASECTOMIA'); -- ADD
insert into evaluacion.metodo_planificacion values (8,'OTB'); -- ADD
insert into evaluacion.metodo_planificacion values (9,'OTRO');

create table evaluacion.beneficiario( -- 22 OK *
  id_trab varchar references public.trabajadores,
  ape_pat varchar,
  ape_mat varchar,
  nombres varchar,
  direccion varchar,
  parentesco varchar,
  porcentaje varchar,
  fechahora timestamp default current_timestamp(0),
  primary key (id_trab)
);

/* CAMBIAR TIPO INTEGER A VARCHAR */
-- alter table evaluacion.beneficiario alter column porcentaje set type varchar;

CREATE TABLE evaluacion.cntrl_ficha( -- 23 OK *
  id_folio integer,
  folio varchar,
  primary key(id_folio,folio)		
);

CREATE TABLE evaluacion.cntrl_acon( -- 24 OK *
  id_folio integer,
  folio varchar,
  primary key(id_folio,folio)		
);

CREATE TABLE evaluacion.salario_minimo( -- 26 OK *
    id_salario integer NOT NULL,
    monto numeric(10,2),
    fechahora timestamp without time zone DEFAULT CURRENT_TIMESTAMP(0),
    CONSTRAINT salario_minimo_pkey PRIMARY KEY (id_salario)
); -- OK

insert into evaluacion.salario_minimo values(1,123.22); -- SALARIO MINIMO 2020

/*
/* SELECCIONAR TABLAS EN HISTORIAL CLINICO */
 select * from evaluacion.ficha_identificacion;
 delete from evaluacion.ant_heredofamiliares where id_ficha = 'ECFM123';
 delete from evaluacion.ant_per_patologicos where id_ficha = 'ECFM123';
 delete from evaluacion.ant_per_no_patologicos where id_ficha = 'ECFM123';
 delete from evaluacion.ant_gineco_obstetricos where id_ficha = 'ECFM123';
 delete from evaluacion.ant_laborales where id_ficha = 'ECFM123';
 delete from evaluacion.sintomatologia_actual where id_ficha = 'ECFM123';
 -- delete from evaluacion.imc where id_ficha = 'ECFM123';
 delete from evaluacion.exploracion_fisica where id_ficha = 'ECFM123';
 -- delete from evaluacion.fam_finca where id_ficha = 'ECFM123';
 delete from evaluacion.ficha_identificacion where id_ficha = 'ECFM123';
 
 select * from evaluacion.acontecimiento_traumatico;
 select * from evaluacion.recuerdos_persistentes;
 select * from evaluacion.esfuerzo_por_evitar;
 select * from evaluacion.afectacion;
 select * from evaluacion.acontecimiento_traumatico;
 
 select * from evaluacion.beneficiario;
 
 /*
 delete from evaluacion.escolaridad;
 delete from evaluacion.parentesco;
 delete from evaluacion.cirugia;
 delete from evaluacion.fractura;
 delete from evaluacion.droga;
 delete from evaluacion.enfermedad_base;
 delete from evaluacion.uso_medicamento;
 delete from evaluacion.metodo_planificacion;
 delete from evaluacion.fam_finca;
 */
 
/* BORRADO DE TABLAS HISTORIAL CLINICO */
 drop table evaluacion.ant_heredofamiliares; -- 1
 drop table evaluacion.ant_per_patologicos; -- 2
 drop table evaluacion.ant_per_no_patologicos; -- 3
 drop table evaluacion.ant_gineco_obstetricos; -- 4
 drop table evaluacion.ant_laborales; -- 5
 drop table evaluacion.sintomatologia_actual; -- 6
 drop table evaluacion.exploracion_fisica; -- 7
 drop table evaluacion.imc; -- 8
 drop table evaluacion.ficha_identificacion; -- 9
 
 drop table evaluacion.recuerdos_persistentes; -- 10
 drop table evaluacion.esfuerzo_por_evitar; -- 11
 drop table evaluacion.afectacion; -- 12
 drop table evaluacion.acontecimiento_traumatico; -- 13
 
 drop table evaluacion.beneficiario; -- 14
  
 drop table evaluacion.escolaridad; -- 15
 drop table evaluacion.parentesco; -- 16
 drop table evaluacion.cirugia; -- 17 
 drop table evaluacion.fractura; -- 18
 drop table evaluacion.droga; -- 19
 drop table evaluacion.enfermedad_base; -- 20
 drop table evaluacion.uso_medicamento; -- 21
 drop table evaluacion.metodo_planificacion; -- 22
 drop table evaluacion.fam_finca; -- 23
 drop table evaluacion.cntrl_acon; -- 24
 drop table evaluacion.cntrl_ficha; -- 25
 drop table evaluacion.salario_minimo; -- 26
 
 DROP FUNCTION public.beneficiario(character varying, character varying, character varying, character varying, character varying, character varying, character varying);
 
 DROP FUNCTION public.obt_folio_acon(character varying);
 
 DROP FUNCTION public.obt_folio_ficha(character varying);
 
 /* FILTROS DE BUSQ. EN ALMACEN.MATERIALES */
 nombre_material like '%XXX%' OR TIPO_EPP = TRUE
 */
 
 Get-WMIObject Win32_SerialPort | Select-Object Name,DeviceID,Description
 C:\Program Files\Java\jdk1.8.0_111\bin
 