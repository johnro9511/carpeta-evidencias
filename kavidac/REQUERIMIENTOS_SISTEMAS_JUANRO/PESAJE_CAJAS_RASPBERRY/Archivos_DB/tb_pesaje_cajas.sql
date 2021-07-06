-- CREACION DE SQL Y ESQUEMA PARA PESAJE DE CAJAS DE BANANO EN BD: CARGA
\c carga; -- conectamos a la bd || \c bascula (serv_central)

CREATE SCHEMA cajas;

CREATE TABLE cajas.finca( -- OK
    id_finca integer,
    clave_finca text,
    nombre_finca text,
    abrev_finca text,
    activo boolean NOT NULL DEFAULT true,
    CONSTRAINT finca_pkey PRIMARY KEY (id_finca),
    CONSTRAINT finca_clave_finca_key UNIQUE (clave_finca)
);

insert into cajas.finca values(1,'01','MARY CARMEN','MC','true');
insert into cajas.finca values(2,'02','DON ROLANDO','DR','true');
insert into cajas.finca values(3,'03','ESPERANZA','ES','true');
insert into cajas.finca values(4,'04','CALZADITA','CA','true');
-- insert into cajas.finca values(5,'05','OFICINA CENTRAL','OF','true'); /* MO APLICA */

CREATE TABLE cajas.unidad_medida( -- OK
  id_um integer primary key,
  descripcion varchar(32),
  uni_med varchar(4)
);

insert into cajas.unidad_medida values(1,'LIBRA','lb');
insert into cajas.unidad_medida values(2,'KILOGRAMO','kg');

CREATE TABLE cajas.rango_peso( -- OK
  id_rango integer primary key,
  peso_min numeric(9,4),
  peso_max numeric(9,4),
  descripcion varchar(32), 
  id_um integer references cajas.unidad_medida
);

insert into cajas.rango_peso values(1,0.00,44.29,'BAJO PESO',1);
insert into cajas.rango_peso values(2,44.30,44.95,'NORMAL',1);
insert into cajas.rango_peso values(3,44.96,100.00,'SOBRE PESO',1);
insert into cajas.rango_peso values(4,0.00,20.08,'BAJO PESO',2);
insert into cajas.rango_peso values(5,20.09,20.38,'NORMAL',2);
insert into cajas.rango_peso values(6,20.39,100.00,'SOBRE PESO',2);

-- ACTUALIZACION DE RANGOS ASIGNADOS P/PESO DE CAJAS
update cajas.rango_peso set peso_max = 44.19 where id_rango = 1; -- peso min lb
update cajas.rango_peso set peso_min = 44.20, peso_max = 45.00 where id_rango = 2; -- peso permitido lb
update cajas.rango_peso set peso_min = 45.01 where id_rango = 3; -- sobrepeso lb

update cajas.rango_peso set peso_max = 20.04 where id_rango = 4; -- peso min kg
update cajas.rango_peso set peso_min = 20.05, peso_max = 20.40 where id_rango = 5; -- peso permitido kg
update cajas.rango_peso set peso_min = 20.41 where id_rango = 6; -- sobrepeso kg

CREATE TABLE cajas.peso_x_caja( -- OK
    id_caja serial,
    cns integer,
    peso_caja numeric(9,2),
    folio text,
    id_um integer references cajas.unidad_medida,
    id_finca integer references cajas.finca,
    id_rango integer references cajas.rango_peso,
    fechahora timestamp default current_timestamp(0),
    primary key(id_caja,cns,id_finca)
);

CREATE TABLE cajas.usuarios( -- OK
    id_usuario serial,
    usuario text,
    pass text,
    nombre text,
    ap_paterno text,
    ap_materno text,
    activo boolean,
    id_finca integer,
    CONSTRAINT usuarios_pkey PRIMARY KEY (id_usuario),
    CONSTRAINT usuarios_usuario_key UNIQUE (usuario),
    CONSTRAINT usuarios_id_finca_fkey FOREIGN KEY (id_finca)
        REFERENCES cajas.finca (id_finca) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

/* ////////////////////////// CONSULTAS P/REPORTES PESO X CAJAS ///////////////////////////////// */

-- consulta p/obtener el conteo de cajas durante el dia 
select f.nombre_finca, count(*) as total, (select count(*) as normal from cajas.peso_x_caja c inner join cajas.rango_peso r on c.id_rango = r.id_rango inner join cajas.finca f on f.id_finca = c.id_finca where c.peso_caja between r.peso_min and r.peso_max and (c.id_rango = 2 or c.id_rango = 5) and c.fechahora::date=current_date and f.id_finca = 2),(select count(*) as alto from cajas.peso_x_caja c inner join cajas.rango_peso r on c.id_rango = r.id_rango inner join cajas.finca f on f.id_finca = c.id_finca where c.peso_caja between r.peso_min and r.peso_max and (c.id_rango = 3 or c.id_rango = 6) and c.fechahora::date=current_date and f.id_finca = 2),(select count(*) as bajo from cajas.peso_x_caja c inner join cajas.rango_peso r on c.id_rango = r.id_rango inner join cajas.finca f on f.id_finca = c.id_finca where c.peso_caja between r.peso_min and r.peso_max and (c.id_rango = 1 or c.id_rango = 4) and c.fechahora::date=current_date and f.id_finca = 2) from cajas.peso_x_caja c inner join cajas.finca f on f.id_finca = c.id_finca where c.fechahora::date = current_date and c.id_finca = 2 group by f.id_finca;

-- CONSULTA P/OBTENER UNIDAD DE MEDIDA DE RANGOS
select r.id_rango,r.peso_min,r.peso_max,r.descripcion,u.uni_med,u.descripcion as unidad from cajas.rango_peso r inner join cajas.unidad_medida u on r.id_um = u.id_um;

-- CONSULTA P/OBTENER EL RANGO POR UNIDAD DE MEDIDA
SELECT r.id_rango,r.descripcion,u.uni_med from cajas.rango_peso r inner join cajas.unidad_medida u on r.id_um = u.id_um where u.uni_med = 'kg' and 20.25 between r.peso_min and r.peso_max;

-- CONSULTA P/OBTENER ID DE UNIDAD MEDIDA
SELECT * from cajas.unidad_medida where uni_med = 'lb';

-- consulta p/obtener el conteo de cajas por rango de fechas LISTO PARA PROCEDIMIENTO
select f.nombre_finca, count(*) as total, (select count(*) as normal from cajas.peso_x_caja c inner join cajas.rango_peso r on c.id_rango = r.id_rango inner join cajas.finca f on f.id_finca = c.id_finca where c.peso_caja between r.peso_min and r.peso_max and (c.id_rango = 2 or c.id_rango = 5) and c.fechahora::date=current_date and f.id_finca = 2),(select count(*) as alto from cajas.peso_x_caja c inner join cajas.rango_peso r on c.id_rango = r.id_rango inner join cajas.finca f on f.id_finca = c.id_finca where c.peso_caja between r.peso_min and r.peso_max and (c.id_rango = 3 or c.id_rango = 6) and c.fechahora::date=current_date and f.id_finca = 2),(select count(*) as bajo from cajas.peso_x_caja c inner join cajas.rango_peso r on c.id_rango = r.id_rango inner join cajas.finca f on f.id_finca = c.id_finca where c.peso_caja between r.peso_min and r.peso_max and (c.id_rango = 1 or c.id_rango = 4) and c.fechahora::date=current_date and f.id_finca = 2),to_char(c.fechahora::date,'DD/MM/YYYY') as fecha  from cajas.peso_x_caja c inner join cajas.finca f on f.id_finca = c.id_finca where c.fechahora::date = current_date and c.id_finca = 2 group by f.id_finca,c.fechahora::date;

-- consulta p/obtener diferencia de fechas Y DIA SIG. EN FORMATO COMUN
select '2021-02-02':: date - '2021-01-15':: date as dias;
SELECT to_char('2021-01-07':: DATE + 1,'DD/MM/YYYY') as fecha;

/* ////////////////////////// CONSULTAS P/GENERAR DIFERENCIAS ENTRE SERVIDORES ///////////////////////////////// */

SELECT db_test.id_caja,db_test.cns,db_test.peso_caja,db_test.folio,db_test.id_um,db_test.id_finca,db_test.id_rango,db_test.fechahora 
FROM dblink('dbname=carga port=5432 host=192.168.0.113 user=postgres password=k@v1dac', 
'SELECT id_caja,cns,peso_caja,folio,id_um,id_finca,id_rango,fechahora FROM cajas.peso_x_caja') as db_produccion (id_caja integer,cns integer,peso_caja numeric(9,2),folio text,id_um integer,id_finca integer,id_rango integer,fechahora timestamp) 
right  JOIN cajas.peso_x_caja db_test ON (db_test.id_caja = db_produccion.id_caja) 
WHERE db_produccion.id_caja is null ORDER BY db_test.id_caja;

/* ////////////////////////// CONSULTA || VISTA P/GENERAR DETALLE X CAJA PESADA CON EQUIVALENCIAS DE PESO ///////////////////////////////// */

create view public.detalle_cajas as
SELECT c.id_caja, c.cns, c.peso_caja, c.folio, u.descripcion as uni_med, f.nombre_finca as finca, r.descripcion as rango, c.fechahora::time as hora, c.fechahora::date as fecha,
(CASE WHEN u.uni_med = 'kg' THEN (c.peso_caja * 2.2046) :: NUMERIC(9,2) ELSE c.peso_caja END) AS peso_en_lb,
(CASE WHEN u.uni_med = 'lb' THEN (c.peso_caja / 2.2046) :: NUMERIC(9,2) ELSE c.peso_caja END) AS peso_en_kg 
from cajas.peso_x_caja c
inner join cajas.unidad_medida u on c.id_um = u.id_um
inner join cajas.finca f on f.id_finca = c.id_finca
inner join cajas.rango_peso r on r.id_rango = c.id_rango
-- where c.fechahora::date BETWEEN current_date -3 AND current_date
order by c.fechahora asc,c.cns asc;

-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- INVOCANDO LA VISTA P/CONSULTAR
select *from public.detalle_cajas;

-- GENERANDO LA VISTA DEL REPORTE DESDE JAVA
select finca, cns, peso_caja, uni_med, rango, peso_en_lb, peso_en_kg, hora, to_char(fecha,'DD/MM/YYYY') as fecha from public.detalle_cajas where fecha between current_date and current_date and finca = 'DON ROLANDO' order by fecha desc, cns desc;

-- GENERANDO EL REPORTE DESDE JASPER REPORT
select finca, cns, peso_caja, uni_med, rango, peso_en_lb, peso_en_kg, hora, fecha from public.detalle_cajas where fecha between current_date and current_date and finca = 'DON ROLANDO' order by fecha desc, cns desc;
