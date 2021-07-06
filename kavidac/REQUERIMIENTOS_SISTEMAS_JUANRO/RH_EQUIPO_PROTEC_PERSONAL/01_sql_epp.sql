/* CONTROL DE TABLAS epp PARA EPP KAVIDAC PRODUCE */
CREATE SCHEMA epp;

-- ----  tabla cntrl_folio_nvo_ingreso  -------
CREATE TABLE epp.cntrl_folio_nvo_ingre( -- 1
  id_folio integer,
  folio varchar,
  primary key(id_folio,folio)		
); -- OK

-- ----  tabla cntrl_folio_prestamo  -------
CREATE TABLE epp.cntrl_folio_presta( -- 2
  id_folio integer,
  folio varchar,
  primary key(id_folio,folio)		
); -- OK

-- ----  tabla cntrl_folio_reposicion  -------
CREATE TABLE epp.cntrl_folio_repo( -- 3
  id_folio integer,
  folio varchar,
  primary key(id_folio,folio)		
); -- OK

-- ----  tabla cntrl_folio_gafete  -------
CREATE TABLE epp.cntrl_folio_gft( -- 4 
  id_folio integer,
  folio varchar,
  primary key(id_folio,folio)		
); -- OK

-- ----  tabla cntrl_folio_gafete_vst  -------
CREATE TABLE epp.cntrl_folio_gft_vst( -- 5
  id_folio integer,
  folio varchar,
  primary key(id_folio,folio)		
); -- OK

-- ----  tabla cntrl_folio_cambio  -------
CREATE TABLE epp.cntrl_folio_cambio( -- 6
  id_folio integer,
  folio varchar,
  primary key(id_folio,folio)		
); -- OK

-- ----  tabla cntrl_folio_REPO_GFT_VST  -------
CREATE TABLE epp.cntrl_folio_repo_gft_vst( -- 7
  id_folio integer,
  folio varchar,
  uso boolean default false, -- (true = si, false = no)
  finca varchar, -- finca de cambio gft
  primary key(id_folio,folio)		
); -- OK

-- ----  tabla cntrl_folio_baja_epp  -------
CREATE TABLE epp.cntrl_folio_baja_epp( -- 8
  id_folio integer,
  folio varchar,
  primary key(id_folio,folio)		
); -- OK


-- ----  tabla tipo movimiento epp  -------
CREATE TABLE epp.tipo_movimiento_epp( -- 9
  id_tipo_mov_epp integer,
  decripcion_mov varchar,
  primary key(id_tipo_mov_epp)		
); -- OK

insert into epp.tipo_movimiento_epp values(1,'NUEVO INGRESO');
insert into epp.tipo_movimiento_epp values(2,'PRESTAMO');
insert into epp.tipo_movimiento_epp values(3,'REPOSICION');
insert into epp.tipo_movimiento_epp values(4,'GAFETE');
insert into epp.tipo_movimiento_epp values(5,'BAJA EPP');
insert into epp.tipo_movimiento_epp values(6,'CAMBIO LABOR');
insert into epp.tipo_movimiento_epp values(7,'ASIGNACION INICIAL');

-- ----  tabla movimientos epp  -------
CREATE TABLE epp.movimiento_epp( -- 10
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR NOMBRE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  id_trab varchar,
  fecha timestamp default current_timestamp(0),
  id_tipo_mov_epp integer,
  estado_epp integer default 0, -- (0-.inicio, 1-.en uso. 2-.devuelto. 3-.gafete. 4-. otro)
  id_enfermera integer,
  alm_destino integer, -- almacen de cambio
  foreign key (id_finca) references public.fincas,
  foreign key (id_material) references almacen.materiales,
  foreign key (id_trab) references public.trabajadores,
  foreign key (id_tipo_mov_epp) references epp.tipo_movimiento_epp,
  foreign key (alm_destino) references almacen.almacen,
  primary key(id_finca,folio,id_material)		
); -- OK

-- ----  tabla movimientos epp nvo ingreso enf  -------
CREATE TABLE epp.det_mov_nvo_epp_enf( -- 11 
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR NOMBRE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cns integer,
  cantidad numeric(10,3),
  fecha timestamp default current_timestamp(0),
  foreign key (id_finca,folio,id_material) references epp.movimiento_epp,
  primary key(id_finca,folio,id_material)		
); -- OK

-- ----  tabla movimientos epp reposicion enf  -------
CREATE TABLE epp.det_mov_repo_epp_enf( -- 12
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR NOMBRE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cns integer,
  cantidad numeric(10,3),
  fecha timestamp default current_timestamp(0),
  foreign key (id_finca,folio,id_material) references epp.movimiento_epp,
  primary key(id_finca,folio,id_material)		
); -- OK

-- ----  tabla movimientos prestamos enf  -------
CREATE TABLE epp.det_mov_presta_epp_enf( -- 13
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR NOMBRE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cns integer,
  cantidad numeric(10,3),
  fecha timestamp default current_timestamp(0),
  lab_presta varchar, -- labor de prestamo enf
  foreign key (id_finca,folio,id_material) references epp.movimiento_epp,
  primary key(id_finca,folio,id_material)		
); -- OK

-- ----  tabla movimientos baja enf  -------
CREATE TABLE epp.det_mov_baja_epp_enf( -- 14
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR NOMBRE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cns integer,
  cantidad numeric(10,3),
  tipo_baja varchar,
  fecha timestamp default current_timestamp(0),
  foreign key (id_finca,folio,id_material) references epp.movimiento_epp,
  primary key(id_finca,folio,id_material)		
); -- OK 

-- ----  tabla movimientos nvo ingreso almacen  -------
CREATE TABLE epp.det_mov_nvo_epp_alm( -- 15
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR NOMBRE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cns integer,
  cantidad numeric(10,3),
  entregado boolean default false,
  pendiente boolean default true, -- ** VERIFICAR
  fecha timestamp default current_timestamp(0),
  id_almacenista integer,
  id_movimiento integer,
  alm_destino integer, -- almacen de cambio
  devolucion boolean default false, -- dev material
  folio_dev varchar, -- folio dev x cambio labor
  foreign key (alm_destino) references almacen.almacen,
  foreign key (id_finca,folio,id_material) references epp.movimiento_epp,
  foreign key (id_movimiento) references almacen.movimientos,
  primary key(id_finca,folio,id_material)		
); -- OK

-- ----  tabla movimientos reposicion almacen  -------
CREATE TABLE epp.det_mov_repo_epp_alm( -- 16
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR NOMBRE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cns integer,
  cantidad numeric(10,3),
  entregado boolean default false,
  pendiente boolean default true, -- ** VERIFICAR
  fecha timestamp default current_timestamp(0),
  id_almacenista integer,
  id_movimiento integer,
  alm_destino integer,
  foreign key (alm_destino) references almacen.almacen,
  foreign key (id_finca,folio,id_material) references epp.movimiento_epp,
  foreign key (id_movimiento) references almacen.movimientos,
  primary key(id_finca,folio,id_material)		
); -- OK

-- ----  tabla movimientos prestamo almacen  -------
CREATE TABLE epp.det_mov_presta_epp_alm( -- 17 
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR NOMBRE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cns integer,
  cantidad numeric(10,3),
  entregado boolean default false,
  pendiente boolean default true, -- ** VERIFICAR
  recepcion boolean default false,
  fecha_ini_presta timestamp default current_timestamp(0),
  fecha_fin_presta timestamp,
  id_almacenista_ini integer,
  id_almacenista_fin integer,
  id_movimiento_ini integer,
  id_movimiento_rec integer,
  alm_destino integer,
  lab_presta varchar, -- labor de prestamo
  est integer default 1, -- est: 1-. ini, 2-. 36 hrs (+), 3-. cob x sist 
  foreign key (alm_destino) references almacen.almacen,
  foreign key (id_finca,folio,id_material) references epp.movimiento_epp,
  foreign key (id_movimiento_ini) references almacen.movimientos,
  foreign key (id_movimiento_rec) references almacen.movimientos,
  primary key(id_finca,folio,id_material)		
); -- OK

-- ----  tabla movimientos baja almacen  -------
CREATE TABLE epp.det_mov_baja_epp_alm( -- 18
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR NOMBRE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cns integer,
  cantidad numeric(10,3),
  tipo_baja varchar, -- tipo de baja
  entregado boolean default false,
  pendiente boolean default true, -- ** VERIFICAR
  fecha timestamp default current_timestamp(0),
  id_almacenista integer,
  id_movimiento integer,
  alm_destino integer,
  foreign key (alm_destino) references almacen.almacen,
  foreign key (id_finca,folio,id_material) references epp.movimiento_epp,
  foreign key (id_movimiento) references almacen.movimientos,
  primary key(id_finca,folio,id_material)		
); -- OK

-- --------  tabla cobros detalle -----------
CREATE TABLE epp.cobros_detalle( -- 19
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR NOMBRE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  id_trab varchar, 
  fecha timestamp default current_timestamp(0),
  monto numeric(10,3),
  tipo_cobro varchar,
  surtido boolean, -- sirve p/verificar si recibe material del almacen
  foreign key (id_finca,folio,id_material) references epp.movimiento_epp,
  foreign key (id_trab) references public.trabajadores,
  primary key(id_finca,folio,id_material)		
); -- OK

-- --------  tabla reposiciones detalle -----------
CREATE TABLE epp.reposiciones( -- 20
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR NOMBRE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  id_trab varchar,
  fecha timestamp default current_timestamp(0),
  monto numeric(10,3),
  tipo_cobro varchar, 
  surtido boolean, -- sirve p/verificar si recibe material del almacen
  foreign key (id_finca,folio,id_material) references epp.movimiento_epp,
  foreign key (id_trab) references public.trabajadores,
  primary key(id_finca,folio,id_material)		
); -- OK

/* ////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////  CONTROL GAFETES DE VISITANTES  //////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////// */
-- tabla: public.area_trabajo
CREATE TABLE public.area_trabajo( -- 27
  id_area_trabajo serial NOT NULL,
  nombre_area_trabajo text,
  color_area text,
  codigo_color text,
  CONSTRAINT area_trabajo_pkey PRIMARY KEY (id_area_trabajo)
); -- OK

-- tabla: public.cargo
CREATE TABLE public.cargo( -- 28
  id_cargo serial NOT NULL,
  nombre_cargo text,
  oficina boolean,
  CONSTRAINT cargo_pkey PRIMARY KEY (id_cargo)
); -- OK

-- tabla: public.detalle_area_trabajo_cargo
CREATE TABLE public.detalle_area_trabajo_cargo( -- 29
  id_cargo integer NOT NULL,
  id_area_trabajo integer NOT NULL,
  CONSTRAINT detalle_area_trabajo_cargo_pkey PRIMARY KEY (id_cargo, id_area_trabajo),
  CONSTRAINT detalle_area_trabajo_cargo_id_area_trabajo_fkey FOREIGN KEY (id_area_trabajo)
      REFERENCES area_trabajo (id_area_trabajo) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT detalle_area_trabajo_cargo_id_cargo_fkey FOREIGN KEY (id_cargo)
      REFERENCES cargo (id_cargo) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
); -- OK

-- tabla: public.labor
CREATE TABLE public.labor( -- 30
  id_labor serial NOT NULL,
  nombre_labor text,
  id_tipo_trab integer,
  CONSTRAINT labor_pkey PRIMARY KEY (id_labor),
  CONSTRAINT labor_id_tipo_trab_fkey FOREIGN KEY (id_tipo_trab)
      REFERENCES tipo_trabajador (id_tipo_trab) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
); -- OK

-- tabla: public.tipo_trabajador
CREATE TABLE public.tipo_trabajador( -- 31
  id_tipo_trab integer NOT NULL,
  nombre_tipo_trab character varying(30),
  status integer,
  CONSTRAINT tipo_trabajador_pkey PRIMARY KEY (id_tipo_trab)
); -- OK

insert into public.tipo_trabajador values(8,'ADMINISTRATIVO OFICINA CENTRAL',1);
update public.tipo_trabajador set nombre_tipo_trab = 'ADMINISTRATIVO FINCA' where id_tipo_trab = 3;

-- ----  tabla movimientos gafetes visitantes  -------
CREATE TABLE epp.mov_gft_vst( -- 21
  id_finca integer,
  folio varchar,
  id_material integer,
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cantidad numeric(10,3),
  fecha timestamp default current_timestamp(0),
  id_tipo_mov_epp integer, -- tipo 4
  estado_epp integer default 0, -- (0-. inicio, 1-. vigente, 2-. fin)
  id_enfermera integer,
  foreign key (id_finca) references public.fincas,
  foreign key (id_material) references almacen.materiales,
  foreign key (id_tipo_mov_epp) references epp.tipo_movimiento_epp,
  primary key(id_finca,folio,id_material)		
); -- OK

-- ----  tabla movimientos epp nvo ft vst -------
CREATE TABLE epp.det_mov_nvo_gft_vst( -- 22
  id_finca integer,
  folio varchar,
  id_material integer,
  id_area_trabajo integer,
  -- EN CONSULTA AGREGAR NOMBRE DE AREA
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cns integer,
  cantidad numeric(10,3),
  fecha timestamp default current_timestamp(0),
  foreign key (id_finca,folio,id_material) references epp.mov_gft_vst, 
  foreign key (id_area_trabajo) references public.area_trabajo, 
  primary key(id_finca,folio,id_material)		
); -- OK

-- --------  tabla cobros gft vst -----------
CREATE TABLE epp.cobros_gft_vst( -- 23
  id_finca integer,
  folio varchar,
  id_material integer,
  id_area_trabajo integer,
  -- EN CONSULTA AGREAGAR NOMBRE DE AREA
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cns integer, -- consecutivo
  cantidad numeric(10,3), -- total de gafetes
  fecha timestamp default current_timestamp(0),
  monto numeric(10,3), -- mult x cant de gft
  tipo_cobro varchar, -- gafete
  foreign key (id_finca,folio,id_material) references epp.mov_gft_vst,
  foreign key (id_area_trabajo) references public.area_trabajo, 
  primary key(id_finca,folio,id_material)		
); -- OK

-- --------  tabla reposiciones gft vst -----------
CREATE TABLE epp.reposiciones_gft_vst( -- 24 
  id_finca integer,
  folio varchar,
  id_material integer,
  id_area_trabajo integer,
  -- EN CONSULTA AGREAGAR NOMBRE DE AREA
  -- EN CONSULTA AGREGAR CLAVE DE MATERIAL
  -- EN CONSULTA AGREGAR UNIDAD DE MEDIDA
  cns integer, -- consecutivo
  cantidad numeric(10,3), -- total de gafetes
  fecha timestamp default current_timestamp(0),
  monto numeric(10,3), -- mult x cant de gft
  tipo_cobro varchar, -- gafete
  foreign key (id_finca,folio,id_material) references epp.mov_gft_vst,
  foreign key (id_area_trabajo) references public.area_trabajo, 
  primary key(id_finca,folio,id_material)		
); -- OK

 /* ////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////  DEVOLUCION POR CAMBIO DE LABOR  //////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////// */
  
-- tabla para registrar devoluciones x cambio de labor
CREATE TABLE epp.dev_x_cambio_labor( -- 25
  id_finca integer,
  folio varchar,
  id_material integer,
  clave varchar,
  cantidad numeric(10,3),
  u_medida varchar,
  id_trab varchar,
  alm_destino integer,
  id_movimiento integer,
  entregado boolean default false,
  fecha timestamp default current_timestamp(0),
  foreign key (id_finca) references public.fincas,
  foreign key (id_material) references almacen.materiales,
  foreign key (id_trab) references public.trabajadores,
  foreign key (alm_destino) references almacen.almacen,
  foreign key (id_movimiento) references almacen.movimientos,
  primary key(id_finca,folio,id_material)
); -- OK 

 /* ////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////  TABLAS EN PUBLIC Y ALMACEN  //////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////// */

-- tabla: almacen.detalle_materiales_labor
CREATE TABLE almacen.detalle_materiales_labor( -- 26
  id_labor integer NOT NULL,
  id_material integer NOT NULL,
  cantidad numeric(10,3),
  CONSTRAINT detalle_materiales_labor_pkey PRIMARY KEY (id_labor, id_material),
  CONSTRAINT detalle_materiales_labor_id_labor_fkey FOREIGN KEY (id_labor)
      REFERENCES labor (id_labor) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT detalle_materiales_labor_id_material_fkey FOREIGN KEY (id_material)
      REFERENCES almacen.materiales (id_material) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
); -- OK

/* ////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////  AGREGAR COLUMNAS A TABLAS EXIST  //////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////// */
/* TABLA PUBLIC.FINCAS */ -- OK
alter table public.fincas add column finca_banano boolean;
alter table public.fincas add column status boolean;

update public.fincas set finca_banano = true, status = true where id_finca = 1 ; -- OK
update public.fincas set finca_banano = true, status = true where id_finca = 9 ; -- OK
update public.fincas set finca_banano = true, status = true where id_finca = 15 ; -- OK 
update public.fincas set finca_banano = false, status = false where id_finca = 19 ; -- OK
update public.fincas set finca_banano = true, status = true where id_finca = 21 ; -- OK
update public.fincas set finca_banano = false, status = true where id_finca = 23 ; -- OK
update public.fincas set finca_banano = false, status = true where id_finca = 24 ; -- OK
update public.fincas set finca_banano = false, status = true where id_finca = 99 ; -- OK

/* TABLA ALMACEN.MATERIALES */ -- OK
alter table almacen.materiales add column tipo_epp boolean;
alter table almacen.materiales add column costo_reposicion_epp numeric(10,3);
update almacen.materiales set costo_reposicion_epp = 100.0 where clave = 'GAFETE' and nombre_material = 'GAFETE';

/* TABLA public.trabajadores */ -- OK
alter table public.trabajadores add column id_area_trabajo integer;
alter table public.trabajadores add foreign key(id_area_trabajo) references public.area_trabajo(id_area_trabajo);

alter table public.trabajadores add column id_cargo integer;
alter table public.trabajadores add foreign key(id_cargo) references public.cargo (id_cargo);

alter table public.trabajadores add column id_labor integer;
alter table public.trabajadores add foreign key(id_labor) references public.labor (id_labor);

alter table public.trabajadores add column vale_gen integer;

alter table public.trabajadores add column motivo_rechazo varchar;

alter table public.trabajadores add column gafete varchar;

update public.trabajadores set vale_gen = 1; -- por default supone que ya todos tienen epp
update public.trabajadores set gafete = 1; -- por default supone que ya todos tienen gafete

/* TABLA public.privilegios_usuarios */ -- OK
alter table public.privilegios_usuarios add column act_trab integer default 0;

update public.privilegios_usuarios set act_trab = 1 where id_usuario = 0; -- OK (Lic. Roberto)
update public.privilegios_usuarios set act_trab = 1 where id_usuario = 7; -- OK (TECNOLOGIAS)

/* TABLA almacen.finca */ -- OK
alter table almacen.finca add column id_finca_pub integer;
alter table almacen.finca add foreign key(id_finca_pub) references public.fincas (id_finca);

update almacen.finca set id_finca_pub = 1 where id_finca = 1 and clave_finca = '01'; -- OK
update almacen.finca set id_finca_pub = 9 where id_finca = 2 and clave_finca = '09'; -- OK
update almacen.finca set id_finca_pub = 15 where id_finca = 3 and clave_finca = '15'; -- OK 
update almacen.finca set id_finca_pub = 19 where id_finca = 4 and clave_finca = '19'; -- OK
update almacen.finca set id_finca_pub = 21 where id_finca = 5 and clave_finca = '21'; -- OK
update almacen.finca set id_finca_pub = 99 where id_finca = 6 and clave_finca = '99'; -- OK
update almacen.finca set id_finca_pub = 23 where id_finca = 7 and clave_finca = '03'; -- OK
update almacen.finca set id_finca_pub = 24 where id_finca = 8 and clave_finca = '11'; -- OK
update almacen.finca set id_finca_pub = 99 where id_finca = 9 and clave_finca = '00'; -- OK

/* TABLA public.tipos_de_movimientos */ -- OK
insert into tipos_de_movimientos values (12,'Se Rechazo Trabajador',1);

/* RESTAURAR VALORES DE TABLAS EN BASE DE DATOS */ -- OK
-- PUBLIC.AREA_TRABAJO
psql -U postgres -h localhost -d kavidac_finca_new -f "C:\Users\erick\Documents\zrespaldo_juanro\Respaldo_tablas\public_area_trabajo.backup"

-- PUBLIC.CARGO
psql -U postgres -h localhost -d kavidac_finca_new -f "C:\Users\erick\Documents\zrespaldo_juanro\Respaldo_tablas\public_cargo.backup"

-- public_detalle_area_trabajo_cargo
psql -U postgres -h localhost -d kavidac_finca_new -f "C:\Users\erick\Documents\zrespaldo_juanro\Respaldo_tablas\public_detalle_area_trabajo_cargo.backup"

-- PUBLIC.LABOR
psql -U postgres -h localhost -d kavidac_finca_new -f "C:\Users\erick\Documents\zrespaldo_juanro\Respaldo_tablas\public_labor.backup"

-- PUBLIC.almacen_detalle_materiales_labor
psql -U postgres -h localhost -d kavidac_finca_new -f "C:\Users\erick\Documents\zrespaldo_juanro\Respaldo_tablas\almacen_detalle_materiales_labor.backup"

/* FALTA AGREGAR RESPALDO DE: ALMACEN.DETALLE_MATERIALES_LABOR */
