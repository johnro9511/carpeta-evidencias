-- PROCEDIMIENTO PARA INSERTAR PESO_X_CAJA
-- drop function cajas.alta_carga;
CREATE OR REPLACE FUNCTION cajas.alta_carga(peso_cja numeric(9,2),um integer,fin integer,rango integer)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $$
DECLARE
	vQuery text; 
	vrespuesta text;
	vCantidad INT;
	contador INT;
	vFolio text;
	vNextfolio text;
	vId_carga INT;
	vId_finca INT; 
	vNum_carga INT;
	vAbrev_finca text;
	
BEGIN
	SELECT id_finca, abrev_finca INTO vId_finca, vAbrev_finca FROM cajas.finca WHERE id_finca=fin;
	
	SELECT (COALESCE (COUNT(*),0)+1) :: INT INTO vCantidad FROM cajas.peso_x_caja WHERE id_finca=fin;
    
	vFolio= CONCAT('F',VAbrev_finca);
	RAISE NOTICE 'vCantidad --> % || vFolio --> %',vCantidad,vFolio;
		IF  vCantidad = 1 then	
			vNextfolio = CONCAT(vFolio,'0001');
		ELSE
			IF vCantidad > 999 then
				vNextfolio = CONCAT(vFolio,'');
				vNextfolio = CONCAT(vNextfolio,vCantidad);
			ELSE 
				IF vCantidad > 99 then
					vNextfolio = CONCAT(vFolio,'0');
					vNextfolio = CONCAT(vNextfolio,vCantidad);
				ELSE
					IF vCantidad > 9 then
						vNextfolio = CONCAT(vFolio,'00');
						vNextfolio = CONCAT(vNextfolio,vCantidad);
					ELSE
						vNextfolio = CONCAT(vFolio,'000');
						vNextfolio = CONCAT(vNextfolio,vCantidad);
					end IF;
				END IF;
			END IF;
		END IF;
	RAISE NOTICE 'vNextfolio --> %',vNextfolio;

	SELECT (COALESCE(COUNT(id_caja),0)+1) :: INT INTO vNum_carga FROM cajas.peso_x_caja WHERE id_finca=fin and fechahora::date = current_date;
	
	vQuery = 'INSERT INTO cajas.peso_x_caja (cns,peso_caja,id_um,folio,id_finca,id_rango) VALUES ('||vNum_carga||','||peso_cja||','||um||','''||vNextfolio||''','||vId_finca||','||rango||')';
	RAISE NOTICE 'vQuery --> %',vQuery;
	EXECUTE vQuery;
    
	SELECT COUNT(id_caja) INTO vCantidad FROM cajas.peso_x_caja WHERE folio=vNextfolio;
	if(vCantidad>0) then
		vrespuesta='CAJA GUARDADA CON EXITO';
	ELSE 
		vrespuesta='¡¡ERROR: VUELVA A PESAR LA CAJA!!';
	END IF;
	RETURN vrespuesta;
END;
$$;

-- LLAMANDO PROCEDIMIENTO P/INSERTAR REGISTROS
/* begin work;
  Select cajas.alta_carga(44.300,1,2,2);
commit work; */

/* //////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- funcion p/dar generar reporte de cajas por rango de fecha
-- DROP FUNCTION cajas.cajas_x_fechas(varchar, date, date);
CREATE OR REPLACE FUNCTION cajas.cajas_x_fechas(varchar,date,date) returns setof record as $$
declare
	pidFn   alias for $1; -- nombre_finca
    pIdFi   alias for $2; -- fecha_inicio
    pIdFx   alias for $3; -- fecha_fin
    
    dias int; -- dias de consulta
	registro record; -- filas x fecha
    i int; -- cont p/for
    fecha_new date; -- fecha agregando 1 dia x reg.
begin	

  CREATE TEMPORARY TABLE registros(-- tb temporal p/almacenar registros
    finca varchar, -- nombre finca
    total integer, -- total cajas
    normal integer, -- peso normal
    alto integer, -- peso alto
    bajo integer, -- peso bajo
    fecha date -- fecha reg
  ) on commit drop;
  
    SELECT (pidFx - pidFi) as dif into dias; -- obt. num de dias de consulta
    RAISE NOTICE 'DIAS = %', dias;
    
    if dias is null then -- VALIDAMOS EL NULL XQ EL REPORT EN JAVA NO PERMITE EJECUTARSE
      dias := 0;
    end if;
    
    FOR i IN 0..dias LOOP -- ciclo que asigna fechas de consulta
      SELECT (pidFi + i) as fnew into fecha_new; -- agrega 1 dia a la fecha en for
      RAISE NOTICE 'CICLO = %', fecha_new;
      
      SELECT f.nombre_finca as finca, count(*) as total, (select count(*) as normal from cajas.peso_x_caja c inner join cajas.rango_peso r on c.id_rango = r.id_rango inner join cajas.finca f on f.id_finca = c.id_finca where c.peso_caja between r.peso_min and r.peso_max and (c.id_rango = 2 or c.id_rango = 5) and c.fechahora::date=fecha_new and f.nombre_finca = pidFn),(select count(*) as alto from cajas.peso_x_caja c inner join cajas.rango_peso r on c.id_rango = r.id_rango inner join cajas.finca f on f.id_finca = c.id_finca where c.peso_caja between r.peso_min and r.peso_max and (c.id_rango = 3 or c.id_rango = 6) and c.fechahora::date=fecha_new and f.nombre_finca = pidFn),(select count(*) as bajo from cajas.peso_x_caja c inner join cajas.rango_peso r on c.id_rango = r.id_rango inner join cajas.finca f on f.id_finca = c.id_finca where c.peso_caja between r.peso_min and r.peso_max and (c.id_rango = 1 or c.id_rango = 4) and c.fechahora::date=fecha_new and f.nombre_finca = pidFn),to_char(c.fechahora::date,'DD/MM/YYYY') as fecha  from cajas.peso_x_caja c inner join cajas.finca f on f.id_finca = c.id_finca where c.fechahora::date = fecha_new and f.nombre_finca = pidFn group by f.id_finca,c.fechahora::date INTO registro;
      RAISE NOTICE 'REGISTRO = %', registro;
      
      IF registro IS NULL THEN -- no tiene registros esa fecha
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'registros', pidFn,0,0,0,0,fecha_new);
      ELSE -- si tiene datos en fecha
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'registros', pidFn,registro.total,registro.normal,registro.alto,registro.bajo,fecha_new);  
      END IF;
    end loop; -- fin del ciclo
      
    return query select * from registros;-- retorna los reg. capturados
    
  RETURN;
END;
$$ language plpgsql;

-- INVOCANDO Y CONSULTANDO LA FUNCTION: cajas.cajas_x_fechas
begin work;
  select finca,total,normal,alto,bajo, to_char(fecha,'DD/MM/YYYY') as fecha from cajas.cajas_x_fechas('DON ROLANDO','2021-01-01','2021-01-015') AS (
  finca varchar,
  total integer, 
  normal integer,
  alto integer,
  bajo integer,
  fecha date);
commit work;

/* //////////////////////////////////////////////////////////////////////////////////////////////////////// */
SELECT db_test.id_caja,db_test.cns,db_test.peso_caja,db_test.folio,db_test.id_um,db_test.id_finca,db_test.id_rango,db_test.fechahora::timestamp 
FROM dblink('dbname=carga port=5432 host=192.168.0.113 user=postgres password=k@v1dac', 
'SELECT id_caja,cns,peso_caja,folio,id_um,id_finca,id_rango,fechahora FROM cajas.peso_x_caja') as db_produccion (id_caja integer,cns integer,peso_caja numeric(9,2),folio text,id_um integer,id_finca integer,id_rango integer,fechahora timestamp) 
right  JOIN cajas.peso_x_caja db_test ON (db_test.id_caja = db_produccion.id_caja) 
WHERE db_produccion.id_caja is null ORDER BY db_test.id_caja;

/* ////////////////////////// CONSULTAS P/INSERTAR REGISTROS FALTANTES EN TABLA PESO_X_CAJAS ///////////////////////////////// */
-- drop function cajas.replication;
CREATE OR REPLACE FUNCTION cajas.replication()
    RETURNS text
    LANGUAGE 'plpgsql'
AS $$
DECLARE
  repli   RECORD; -- valores de replicacion 
  vrespuesta text;
  
  replica CURSOR FOR SELECT db_test.id_caja,db_test.cns,db_test.peso_caja,db_test.folio,db_test.id_um,db_test.id_finca,db_test.id_rango,db_test.fechahora::timestamp
  FROM dblink('dbname=bascula port=5432 host=192.168.0.3 user=postgres password=k@v1dac', 
  'SELECT id_caja,cns,peso_caja,folio,id_um,id_finca,id_rango,fechahora::timestamp FROM cajas.peso_x_caja') as db_produccion (id_caja integer,cns integer,peso_caja numeric(9,2),folio text,id_um integer,id_finca integer,id_rango integer,fechahora timestamp) 
  right  JOIN cajas.peso_x_caja db_test ON (db_test.id_caja = db_produccion.id_caja) 
  WHERE db_produccion.id_caja is null ORDER BY db_test.id_caja;
	
BEGIN
  open replica;
    LOOP
      FETCH replica into repli; -- obtenemos valores del cursor
      raise notice 'replicacion: %', repli;
      
      EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS FALTANTES EN EL SERVIDOR CENTRAL
        PERFORM dblink_exec('dbname=bascula port=5432 host=192.168.0.3 user=postgres password=k@v1dac', 
        'INSERT INTO cajas.peso_x_caja(id_caja,cns,peso_caja,folio,id_um,id_finca,id_rango,fechahora) values('||repli.id_caja||','||repli.cns||','||repli.peso_caja||','''||repli.folio||''','||repli.id_um||','||repli.id_finca||','||repli.id_rango||','''||repli.fechahora||''' )');
        
        vrespuesta := 'REGISTROS REPLICADOS EXITOSAMENTE';
    END LOOP;  -- LOOP DE REPOSICION  
  close replica; -- CIERRA CURSOR REPOSICION
  
  RETURN vrespuesta;
END;
$$;

-- INVOCANDO LA FUNCION P/RECABAR DATOS FALTANTES EN SERVIDOR CENTRAL 
SELECT CAJAS.REPLICATION();
