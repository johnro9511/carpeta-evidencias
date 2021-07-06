/* //////////////////// PROCEDIMIENTOS ALMACENADOS P/EVALUACION CLINICA ///////////////////////////// */
-- ------------------ funcion para obtener folio de evaluacion clinica --------------------------------------
drop function evaluacion.obt_folio_ficha(varchar); -- 1 OK *
CREATE OR REPLACE FUNCTION evaluacion.obt_folio_ficha(varchar) RETURNS character varying AS $$ 
  declare
	pIdFn alias for $1;
	clavefnc character varying;
	clave character varying;	
	total            integer;
	idNext           varchar;
	claveFinca       varchar;
	idTrabSearch     varchar;
	idTrabExist      varchar;
	notExistIDTrab   integer;
	IDTrabReturn     varchar;
    inicial          varchar;
    det_folio        RECORD;
   
begin
	notExistIDTrab = 0;
    inicial := 'EC';
    
	SELECT INTO clavefnc nombre_corto FROM public.fincas WHERE nombre_finca = pIdFn;

	if clavefnc is null then
		idNext = 'Vacio';
		IDTrabReturn = 'Vacio';
	else	
		claveFinca = clavefnc;
		clave = CONCAT('%',clavefnc,'%');
		clavefnc = '';

		SELECT INTO total count(id_folio) FROM evaluacion.cntrl_ficha WHERE folio LIKE clave;

		if  total is null then -- -	
			idNext = clavefnc & '000';
			IDTrabReturn = idNext;
		else
			WHILE notExistIDTrab!=1 LOOP
				total = total + 1;		

				if total > 99 then
					idNext = CONCAT(clavefnc,total);
				else
					if total > 9 then
						idNext = CONCAT(clavefnc,'0');
						idNext = CONCAT(idNext,total);
					else
						idNext = CONCAT(clavefnc,'00');
						idNext = CONCAT(idNext,total);
					end if;
				end if;

				idTrabSearch = CONCAT(inicial,claveFinca,idNext);
				raise notice '--IDTrab a Evaluar: %',idTrabSearch;
				SELECT INTO idTrabExist id_trab FROM public.trabajadores WHERE id_trab = idTrabSearch;
				raise notice '--IDTrab en DB: %', idTrabExist;

				if idTrabExist is null then
					IDTrabReturn = idNext;
					notExistIDTrab=1;
				else
					notExistIDTrab=0;
				end if;
			end loop;
		end if;
		idNext = IDTrabSearch;
	end if;

	raise notice '--FOLIO a Retornar: %',idNext;
	clave = idNext;
    
    select into det_folio folio from evaluacion.cntrl_ficha where folio = clave;
    
    IF NOT FOUND THEN
      insert into evaluacion.cntrl_ficha (id_folio,folio) values (1,clave);
    ELSE
      return clave;
    END IF;

	return clave;
end;
 $$ LANGUAGE plpgsql;

-- INVOCANDO LA FUNCION FOLIO
/*
begin work;
select evaluacion.obt_folio_ficha('DON ROLANDO');
commit work;

-- CONSULTANDO LA TABLE FOLIOS
SELECT * FROM evaluacion.cntrl_ficha;

-- BORRANDO DATOS DE TABLA FOLIO
DELETE FROM evaluacion.cntrl_ficha;
*/

/* /////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- ------------------ funcion para obtener folio de evaluacion de acontecimiento ----------------------------
drop function evaluacion.obt_folio_acon(varchar); -- 2 OK *
CREATE OR REPLACE FUNCTION evaluacion.obt_folio_acon(varchar) RETURNS character varying AS $$ 
  declare
	pIdFn alias for $1;
	clavefnc character varying;
	clave character varying;	
	total            integer;
	idNext           varchar;
	claveFinca       varchar;
	idTrabSearch     varchar;
	idTrabExist      varchar;
	notExistIDTrab   integer;
	IDTrabReturn     varchar;
    inicial          varchar;
    det_folio        RECORD;
   
begin
	notExistIDTrab = 0;
    inicial := 'CA';
    
	SELECT INTO clavefnc nombre_corto FROM public.fincas WHERE nombre_finca = pIdFn;

	if clavefnc is null then
		idNext = 'Vacio';
		IDTrabReturn = 'Vacio';
	else	
		claveFinca = clavefnc;
		clave = CONCAT('%',clavefnc,'%');
		clavefnc = '';

		SELECT INTO total count(id_folio) FROM evaluacion.cntrl_acon WHERE folio LIKE clave;

		if  total is null then -- -	
			idNext = clavefnc & '000';
			IDTrabReturn = idNext;
		else
			WHILE notExistIDTrab!=1 LOOP
				total = total + 1;		

				if total > 99 then
					idNext = CONCAT(clavefnc,total);
				else
					if total > 9 then
						idNext = CONCAT(clavefnc,'0');
						idNext = CONCAT(idNext,total);
					else
						idNext = CONCAT(clavefnc,'00');
						idNext = CONCAT(idNext,total);
					end if;
				end if;

				idTrabSearch = CONCAT(inicial,claveFinca,idNext);
				raise notice '--IDTrab a Evaluar: %',idTrabSearch;
				SELECT INTO idTrabExist id_trab FROM public.trabajadores WHERE id_trab = idTrabSearch;
				raise notice '--IDTrab en DB: %', idTrabExist;

				if idTrabExist is null then
					IDTrabReturn = idNext;
					notExistIDTrab=1;
				else
					notExistIDTrab=0;
				end if;
			end loop;
		end if;
		idNext = IDTrabSearch;
	end if;

	raise notice '--FOLIO a Retornar: %',idNext;
	clave = idNext;
    
    select into det_folio folio from evaluacion.cntrl_acon where folio = clave;
    
    IF NOT FOUND THEN
      insert into evaluacion.cntrl_acon (id_folio,folio) values (1,clave);
    ELSE
      return clave;
    END IF;

	return clave;
end;
 $$ LANGUAGE plpgsql;

-- INVOCANDO LA FUNCION FOLIO
/*
begin work;
select evaluacion.obt_folio_acon('DON ROLANDO');
commit work;

-- CONSULTANDO LA TABLE FOLIOS
SELECT * FROM evaluacion.cntrl_acon;

-- BORRANDO DATOS DE TABLA FOLIO
DELETE FROM evaluacion.cntrl_acon;
*/

/* ////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- CAMBIAR O ACTUALIZAR DATOS DE BENEFICIARIO
drop function evaluacion.beneficiario(varchar,varchar,varchar,varchar,varchar,varchar,varchar); -- 3 OK *
CREATE OR REPLACE FUNCTION evaluacion.beneficiario(varchar,varchar,varchar,varchar,varchar,varchar,varchar) RETURNS integer AS $$ 
  declare
	pIdTr alias for $1; -- id_trab
    app alias for $2; -- ape_pat
    apm alias for $3; -- ape_mat
    nom alias for $4; -- nombres
    dir alias for $5; -- direccion
    par alias for $6; -- parentesco
    xxx alias for $7; -- porcentaje    
    clave    integer;
    ob_ben   RECORD;
   
begin
	clave := 1;
    
    select into ob_ben * from evaluacion.beneficiario where id_trab = pIdTr;
    
    if not found then
        raise notice 'INSERTA BENEFICIARIO NUEVO';
        insert into evaluacion.beneficiario values (pIdTr,app,apm,nom,dir,par,xxx);
    else
        raise notice 'ACTUALIZA DATOS BENEFICIARIO';
        update evaluacion.beneficiario set ape_pat = app, ape_mat = apm, nombres = nom, direccion = dir, parentesco = par, porcentaje = xxx, fechahora = current_timestamp(0) where id_trab = pIdTr;
    end if;
    
	return clave;
end;
 $$ LANGUAGE plpgsql;

-- INVOCANDO LA FUNCION FOLIO
/*
begin work;
  select evaluacion.beneficiario('FM1314','TORETTO','PEREZ','DOMINIC','TAPACHULA CHIAPAS','PAPA','100');
commit work;
*/

/* //////////////////////////////////////////////////////////////////////////////////////////////////// */
-- ------------------ funcion para obtener la lista de pendientes de evaluacion ----------------------------
drop function evaluacion.pendientes_eva(varchar); -- 04 OK *
create or replace function evaluacion.pendientes_eva(varchar) returns setof record as $$
declare
  pidNf   alias for $1; -- NOMBRE_FINCA 
  
  gcont  RECORD; -- generar contrato
  rcont  RECORD; -- contrato proximo a expirar
  cexpi  RECORD; -- imprimir baja del trab
  reval  RECORD; -- realizar evaluacion
  eexpi  RECORD; -- realizar nueva evaluacion
  
  gcontxf  RECORD; -- generar contrato por finca
  rcontxf  RECORD; -- contrato proximo a expirar
  cexpixf  RECORD; -- imprimir baja del trab
  revalxf  RECORD; -- realizar evaluacion
  eexpixf  RECORD; -- realizar nueva evaluacion
  
  gcont0 CURSOR FOR SELECT F.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('GENERAR CONTRATO') AS MOVIMIENTO,T.FECHA_REGISTRO AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN PUBLIC.FINCAS F ON F.ID_FINCA = T.ID_FINCA WHERE T.STATUS_TRAB = 1 AND T.FECHA_REGISTRO::DATE > '2021-05-21' AND T.FIN_CONTRATO IS NULL ORDER BY T.FECHA_REGISTRO::DATE DESC;
    
  rcont0 CURSOR FOR SELECT F.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('CONTRATO PROXIMO A EXPIRAR') AS MOVIMIENTO,T.FIN_CONTRATO::DATE AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN PUBLIC.FINCAS F ON F.ID_FINCA = T.ID_FINCA WHERE CURRENT_DATE BETWEEN (T.FIN_CONTRATO::DATE -7) AND (T.FIN_CONTRATO::DATE) AND T.STATUS_TRAB = 1 AND T.FIN_CONTRATO IS NOT NULL ORDER BY T.FIN_CONTRATO::DATE;
  
  cexpi0 CURSOR FOR SELECT F.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('IMPRIMIR BAJA DE TRABAJADOR') AS MOVIMIENTO,T.FIN_CONTRATO::DATE AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN PUBLIC.FINCAS F ON F.ID_FINCA = T.ID_FINCA WHERE T.FIN_CONTRATO::DATE < CURRENT_DATE AND T.STATUS_TRAB = 1 AND T.FIN_CONTRATO IS NOT NULL ORDER BY T.FIN_CONTRATO::DATE;
    
  reval0 CURSOR FOR SELECT X.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('REALIZAR EVALUACION') AS MOVIMIENTO,(F.FECHAHORA::DATE) AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN EVALUACION.FICHA_IDENTIFICACION F ON T.ID_TRAB = F.ID_TRAB INNER JOIN PUBLIC.FINCAS X ON X.ID_FINCA = T.ID_FINCA WHERE CURRENT_DATE -366 BETWEEN (F.FECHAHORA::DATE +8) AND (F.FECHAHORA::DATE) AND T.STATUS_TRAB = 1 ORDER BY F.FECHAHORA::DATE;
  
  eexpi0 CURSOR FOR SELECT X.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('REALIZAR NUEVA EVALUACION') AS MOVIMIENTO,(F.FECHAHORA::DATE) AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN EVALUACION.FICHA_IDENTIFICACION F ON T.ID_TRAB = F.ID_TRAB INNER JOIN PUBLIC.FINCAS X ON X.ID_FINCA = T.ID_FINCA WHERE (F.FECHAHORA::DATE) < CURRENT_DATE - 366 AND T.STATUS_TRAB = 1 ORDER BY F.FECHAHORA::DATE;
    
  gcontxf0 CURSOR(pidNf varchar) FOR SELECT F.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('GENERAR CONTRATO') AS MOVIMIENTO,T.FECHA_REGISTRO AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN PUBLIC.FINCAS F ON F.ID_FINCA = T.ID_FINCA WHERE T.STATUS_TRAB = 1 AND T.FECHA_REGISTRO::DATE > '2021-05-21' AND T.FIN_CONTRATO IS NULL AND F.NOMBRE_FINCA = pidNf ORDER BY T.FECHA_REGISTRO::DATE DESC;
  
  rcontxf0 CURSOR(pidNf varchar) FOR SELECT F.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('CONTRATO PROXIMO A EXPIRAR') AS MOVIMIENTO,T.FIN_CONTRATO::DATE AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN PUBLIC.FINCAS F ON F.ID_FINCA = T.ID_FINCA WHERE CURRENT_DATE BETWEEN (T.FIN_CONTRATO::DATE -7) AND (T.FIN_CONTRATO::DATE) AND T.STATUS_TRAB = 1 AND T.FIN_CONTRATO IS NOT NULL AND F.NOMBRE_FINCA = pidNf ORDER BY T.FIN_CONTRATO::DATE;
    
  cexpixf0 CURSOR(pidNf varchar) FOR SELECT F.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('IMPRIMIR BAJA DE TRABAJADOR') AS MOVIMIENTO,T.FIN_CONTRATO::DATE AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN PUBLIC.FINCAS F ON F.ID_FINCA = T.ID_FINCA WHERE T.FIN_CONTRATO::DATE < CURRENT_DATE AND T.STATUS_TRAB = 1 AND T.FIN_CONTRATO IS NOT NULL AND F.NOMBRE_FINCA = pidNf ORDER BY T.FIN_CONTRATO::DATE;
  
  revalxf0 CURSOR(pidNf varchar) FOR SELECT X.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('REALIZAR EVALUACION') AS MOVIMIENTO,(F.FECHAHORA::DATE) AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN EVALUACION.FICHA_IDENTIFICACION F ON T.ID_TRAB = F.ID_TRAB INNER JOIN PUBLIC.FINCAS X ON X.ID_FINCA = T.ID_FINCA WHERE CURRENT_DATE -366 BETWEEN (F.FECHAHORA::DATE +8) AND (F.FECHAHORA::DATE) AND T.STATUS_TRAB = 1 AND X.NOMBRE_FINCA = pidNf ORDER BY F.FECHAHORA::DATE;
    
  eexpixf0 CURSOR(pidNf varchar) FOR SELECT X.NOMBRE_FINCA AS FINCA,T.ID_TRAB,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_t,CONCAT('REALIZAR NUEVA EVALUACION') AS MOVIMIENTO,(F.FECHAHORA::DATE) AS FECHA_TERM FROM PUBLIC.TRABAJADORES T INNER JOIN EVALUACION.FICHA_IDENTIFICACION F ON T.ID_TRAB = F.ID_TRAB INNER JOIN PUBLIC.FINCAS X ON X.ID_FINCA = T.ID_FINCA WHERE (F.FECHAHORA::DATE) < CURRENT_DATE - 366 AND T.STATUS_TRAB = 1 AND X.NOMBRE_FINCA = pidNf ORDER BY F.FECHAHORA::DATE;
  
BEGIN

CREATE TEMPORARY TABLE pendientesxx(
  finca varchar, -- nombre finca
  id_trab varchar, -- id de trabajador
  nombre_t varchar, -- nombre de trabajador
  movimiento varchar, -- movimiento
  fecha_term date -- fecha expiracion
) on commit drop;
      
IF pIdNf = 'TODOS' THEN    
  -- comenzar a correr el ciclo para detalle de RGENERAR CONTRATO
  open gcont0;
    LOOP
      FETCH gcont0 into gcont; -- obtenemos valores del cursor
        raise notice 'gcont: %', gcont;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L)', 'pendientesxx', gcont.finca,gcont.id_trab,gcont.nombre_t,gcont.movimiento,gcont.fecha_term);    
    END LOOP;  -- LOOP DE GENERAR CONTRATO 
  close gcont0; -- CIERRA CURSOR GENERAR CONTRATO
     
  open rcont0;
    LOOP
      FETCH rcont0 into rcont; -- obtenemos valores del cursor
        raise notice 'rcont: %', rcont;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L)', 'pendientesxx', rcont.finca,rcont.id_trab,rcont.nombre_t,rcont.movimiento,rcont.fecha_term);           
    END LOOP;  -- LOOP DE RENOVAR CONTRATO 
  close rcont0; -- CIERRA CURSOR RENOVAR CONTRATO
    
  open cexpi0;
    LOOP
      FETCH cexpi0 into cexpi; -- obtenemos valores del cursor
        raise notice 'cexpi: %', cexpi;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L)', 'pendientesxx', cexpi.finca,cexpi.id_trab,cexpi.nombre_t,cexpi.movimiento,cexpi.fecha_term);           
    END LOOP;  -- LOOP DE CONTRATO EXPIRADO
  close cexpi0; -- CIERRA CURSOR CONTRATO EXPIRADO
  
  open reval0;
    LOOP
      FETCH reval0 into reval; -- obtenemos valores del cursor
        raise notice 'reval: %', reval;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L)', 'pendientesxx', reval.finca,reval.id_trab,reval.nombre_t,reval.movimiento,reval.fecha_term);     
    END LOOP;  -- LOOP DE REALIZAR EVALUACION
  close reval0; -- CIERRA CURSOR REALIZAR EVALUACION
  
  open eexpi0;
    LOOP
      FETCH eexpi0 into eexpi; -- obtenemos valores del cursor
        raise notice 'eexpi: %', eexpi;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L)', 'pendientesxx', eexpi.finca,eexpi.id_trab,eexpi.nombre_t,eexpi.movimiento,eexpi.fecha_term);     
    END LOOP;  -- LOOP DE EVALUACION EXPIRADA
  close eexpi0; -- CIERRA CURSOR EVALUACION EXPIRADA
  
ELSE
-- comenzar a correr el ciclo para detalle de RGENERAR CONTRATO
  open gcontxf0(pIdNf);
    LOOP
      FETCH gcontxf0 into gcontxf; -- obtenemos valores del cursor
        raise notice 'gcontxf: %', gcontxf;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L)', 'pendientesxx', gcontxf.finca,gcontxf.id_trab,gcontxf.nombre_t,gcontxf.movimiento,gcontxf.fecha_term);    
    END LOOP;  -- LOOP DE GENERAR CONTRATO 
  close gcontxf0; -- CIERRA CURSOR GENERAR CONTRATO
     
  open rcontxf0(pIdNf);
    LOOP
      FETCH rcontxf0 into rcontxf; -- obtenemos valores del cursor
        raise notice 'rcontxf: %', rcontxf;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L)', 'pendientesxx', rcontxf.finca,rcontxf.id_trab,rcontxf.nombre_t,rcontxf.movimiento,rcontxf.fecha_term);           
    END LOOP;  -- LOOP DE RENOVAR CONTRATO 
  close rcontxf0; -- CIERRA CURSOR RENOVAR CONTRATO
    
  open cexpixf0(pIdNf);
    LOOP
      FETCH cexpixf0 into cexpixf; -- obtenemos valores del cursor
        raise notice 'cexpixf: %', cexpixf;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L)', 'pendientesxx', cexpixf.finca,cexpixf.id_trab,cexpixf.nombre_t,cexpixf.movimiento,cexpixf.fecha_term);           
    END LOOP;  -- LOOP DE CONTRATO EXPIRADO
  close cexpixf0; -- CIERRA CURSOR CONTRATO EXPIRADO
  
  open revalxf0(pIdNf);
    LOOP
      FETCH revalxf0 into revalxf; -- obtenemos valores del cursor
        raise notice 'revalxf: %', revalxf;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L)', 'pendientesxx', revalxf.finca,revalxf.id_trab,revalxf.nombre_t,revalxf.movimiento,revalxf.fecha_term);     
    END LOOP;  -- LOOP DE REALIZAR EVALUACION
  close revalxf0; -- CIERRA CURSOR REALIZAR EVALUACION
  
  open eexpixf0(pIdNf);
    LOOP
      FETCH eexpixf0 into eexpixf; -- obtenemos valores del cursor
        raise notice 'eexpixf: %', eexpixf;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L)', 'pendientesxx', eexpixf.finca,eexpixf.id_trab,eexpixf.nombre_t,eexpixf.movimiento,eexpixf.fecha_term);     
    END LOOP;  -- LOOP DE EVALUACION EXPIRADA
  close eexpixf0; -- CIERRA CURSOR EVALUACION EXPIRADA
  
END iF; -- CIERRA EL ELSE IF DE COMPARACION

return query select * from pendientesxx; -- retorna consulta c/pendientes enf

RETURN;
END;
$$ language plpgsql;

/*
-- LLAMANDO LA FUNCION P/PENDIENTES::
begin work;
select finca,id_trab,nombre_t,movimiento,to_char(fecha_term,'DD/MM/YYYY') AS fecha_term from evaluacion.pendientes_eva('TODOS') AS (
  finca varchar,
  id_trab varchar, 
  nombre_t varchar,
  movimiento varchar,
  fecha_term date) order by fecha_term::date asc;
commit work;


begin work;
select finca,id_trab,nombre_t,movimiento,to_char(fecha_term,'DD/MM/YYYY') AS fecha_term from evaluacion.pendientes_eva('MARY CARMEN') AS (
  finca varchar,
  id_trab varchar, 
  nombre_t varchar,
  movimiento varchar,
  fecha_term date) order by fecha_term::date asc;
commit work;
*/

/* //////////////////////////////////////////////////////////////////////////////////////////////////// */
