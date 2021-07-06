/* LISTADO DE PROCEDIMIENTOS ALMACENADOS */

-- FUNCION NVA P/DAR DE BAJA A TRABAJADOR
DROP FUNCTION xxdar_de_baja_trabajador_r; -- 1
CREATE OR REPLACE FUNCTION xxdar_de_baja_trabajador_r(varchar,integer,integer,varchar,varchar,integer) RETURNS integer AS $$
declare
	-- id_trab $1;
	-- id_finca $2;
	-- tipo_de_baja $3; 
	-- comentario $4;
	-- clave_finca $5;
    -- asignacion $6; (1-. DAR DE BAJA, 2.- RECHAZADO)
	
	veri record;

	total integer;
	transfer integer;
	idFincaTransfer integer;
	idNext character varying;
	
	-- 0 No se pudo
	-- 1 Dado De Baja
	-- 2 Ya fue dado de baja
begin	
  
  IF $6 = 1 THEN
    raise notice 'VALIDACION P/DAR DE BAJA';
    
	transfer = 0;
	idFincaTransfer = 0;
	veri=null;
		SELECT into veri id_trab, id_finca, id_tipo_trab, fecha_ingreso, fecha_registro, turno24, status_trab from trabajadores WHERE id_trab=$1;

		SELECT INTO total count(id_baja) FROM baja_trabajadores WHERE id_finca=$2;
		total = total + 1;
        
        raise notice 'CLAVE: %', $5;
		if total = 0 then
			idNext = CONCAT($5,total);
		else
			if total > 99 then
				idNext = CONCAT($5,'0');
				idNext = CONCAT(idNext,total);
			else
				if total > 9 then
					idNext = CONCAT($5,'00');
					idNext = CONCAT(idNext,total);
				else
					idNext = CONCAT($5,'000');
					idNext = CONCAT(idNext,total);
				end if;
			end if;
		end if;

		if  veri.status_trab=0 then --si esta dado de baja
			raise notice '1) el empleado ya fue dado de baja ';
			return 2;
		end if;
		
		if veri.status_trab is null then
			raise notice '1) el empleado tiene un status Nulo ';
			return 0;
		end if;	

		if veri.status_trab=1 then
            raise notice '1) ACTUALIZANDO ESTATUS DEL TRABAJADOR P/DAR DE BAJA';
			insert into baja_trabajadores(id_baja,id_trab,id_finca,id_tipo_trab,fecha_ingreso, fecha_registro,id_tipo_baja,comentario,fecha_baja,turno24,transferencia,id_finca_transferencia) values(idNext,$1,$2,veri.id_tipo_trab,veri.fecha_ingreso,veri.fecha_registro,$3,$4, current_date::text,veri.turno24, transfer, idFincaTransfer);	
			-- AGREGO ACTUALIZACION PARA EL ESTADO DEL VALE_GEN = 0 
			UPDATE trabajadores SET status_trab='0', vale_gen = '0', gafete = null, motivo_rechazo = $4, fin_contrato = null WHERE id_trab=$1;
			return 1;
		end if;	
  ELSE
    raise notice 'VALIDACION P/RECHAZAR';
    transfer = 0;
	idFincaTransfer = 0;
	veri=null;
		SELECT into veri id_trab, id_finca, id_tipo_trab, fecha_ingreso, fecha_registro, turno24, status_trab from trabajadores WHERE id_trab=$1;

		SELECT INTO total count(id_baja) FROM baja_trabajadores WHERE id_finca=$2;
		total = total + 1;
			
        raise notice 'CLAVE: %', $5;
		if total = 0 then
			idNext = CONCAT($5,total);
		else
			if total > 99 then
				idNext = CONCAT($5,'0');
				idNext = CONCAT(idNext,total);
			else
				if total > 9 then
					idNext = CONCAT($5,'00');
					idNext = CONCAT(idNext,total);
				else
					idNext = CONCAT($5,'000');
					idNext = CONCAT(idNext,total);
				end if;
			end if;
		end if;

		if  veri.status_trab=2 then --si esta dado de baja
			raise notice '1) el empleado ya fue dado de baja ';
			return 2;
		end if;
		
		if veri.status_trab is null then
			raise notice '1) el empleado tiene un status Nulo ';
			return 0;
		end if;	

		if veri.status_trab=3 then
            raise notice '1) ACTUALIZANDO ESTATUS DEL TRABAJADOR P/RECHAZAR';
			insert into baja_trabajadores(id_baja,id_trab,id_finca,id_tipo_trab,fecha_ingreso, fecha_registro,id_tipo_baja,comentario,fecha_baja,turno24,transferencia,id_finca_transferencia) values(idNext,$1,$2,veri.id_tipo_trab,veri.fecha_ingreso,veri.fecha_registro,$3,$4, current_date::text,veri.turno24, transfer, idFincaTransfer);	
			-- AGREGO ACTUALIZACION PARA EL ESTADO DEL VALE_GEN = 0 
			UPDATE trabajadores SET status_trab='2', vale_gen = '0', gafete = null, motivo_rechazo = $4 WHERE id_trab=$1;
			return 1;
		end if;	
  END IF; -- ELSE VALIDACION DE ASIGNACION
END;
$$ LANGUAGE plpgsql; -- OK 

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- ------------------ funcion para obtener folio de movimientos nvo_ingreso epp ---------------------------------------
drop function epp.obt_folio_nvo_ingre(integer); -- 2
CREATE OR REPLACE FUNCTION epp.obt_folio_nvo_ingre(integer) RETURNS character varying AS $$ 
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
    inicial := 'N';
    
	SELECT INTO clavefnc nombre_corto FROM public.fincas WHERE id_finca= pIdFn;

	if clavefnc is null then
		idNext = 'Vacio';
		IDTrabReturn = 'Vacio';
	else	
		claveFinca = clavefnc;
		clave = CONCAT('%',clavefnc,'%');
		clavefnc = '';

		SELECT INTO total count(id_folio) FROM epp.cntrl_folio_nvo_ingre WHERE folio LIKE clave;

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
				SELECT INTO idTrabExist id_trab FROM epp.movimiento_epp WHERE id_trab = idTrabSearch;
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
    
    select into det_folio folio from epp.cntrl_folio_nvo_ingre where folio = clave;
    
    IF NOT FOUND THEN
      insert into epp.cntrl_folio_nvo_ingre values (1,clave);
    ELSE
      return clave;
    END IF;

	return clave;
end;
 $$ LANGUAGE plpgsql; -- OK
 
/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- ------------------ funcion para obtener folio de movimientos prestamo epp ---------------------------------------
drop function epp.obt_folio_presta(integer); -- 3
CREATE OR REPLACE FUNCTION epp.obt_folio_presta(integer) RETURNS character varying AS $$ 
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
    inicial := 'P';
    
	SELECT INTO clavefnc nombre_corto FROM public.fincas WHERE id_finca= pIdFn;

	if clavefnc is null then
		idNext = 'Vacio';
		IDTrabReturn = 'Vacio';
	else	
		claveFinca = clavefnc;
		clave = CONCAT('%',clavefnc,'%');
		clavefnc = '';

		SELECT INTO total count(id_folio) FROM epp.cntrl_folio_presta WHERE folio LIKE clave;

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
				SELECT INTO idTrabExist id_trab FROM epp.movimiento_epp WHERE id_trab = idTrabSearch;
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
    
    select into det_folio folio from epp.cntrl_folio_presta where folio = clave;
    
    IF NOT FOUND THEN
      insert into epp.cntrl_folio_presta values (1,clave);
    ELSE
      return clave;
    END IF;

	return clave;
end;
 $$ LANGUAGE plpgsql; -- OK
 
/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- ------------------ funcion para obtener folio de movimientos reposicion epp ---------------------------------------
drop function epp.obt_folio_repo(integer); -- 4
CREATE OR REPLACE FUNCTION epp.obt_folio_repo(integer) RETURNS character varying AS $$ 
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
    inicial := 'R';
    
	SELECT INTO clavefnc nombre_corto FROM public.fincas WHERE id_finca= pIdFn;

	if clavefnc is null then
		idNext = 'Vacio';
		IDTrabReturn = 'Vacio';
	else	
		claveFinca = clavefnc;
		clave = CONCAT('%',clavefnc,'%');
		clavefnc = '';

		SELECT INTO total count(id_folio) FROM epp.cntrl_folio_repo WHERE folio LIKE clave;

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
				SELECT INTO idTrabExist id_trab FROM epp.movimiento_epp WHERE id_trab = idTrabSearch;
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
    
    select into det_folio folio from epp.cntrl_folio_repo where folio = clave;
    
    IF NOT FOUND THEN
      insert into epp.cntrl_folio_repo values (1,clave);
    ELSE
      return clave;
    END IF;

	return clave;
end;
 $$ LANGUAGE plpgsql; -- OK 
 
/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- ------------------ funcion para obtener folio de movimientos gafete epp ---------------------------------------
drop function epp.obt_folio_gft(integer); -- 5
CREATE OR REPLACE FUNCTION epp.obt_folio_gft(integer) RETURNS character varying AS $$ 
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
    inicial := 'G';
    
	SELECT INTO clavefnc nombre_corto FROM public.fincas WHERE id_finca= pIdFn;

	if clavefnc is null then
		idNext = 'Vacio';
		IDTrabReturn = 'Vacio';
	else	
		claveFinca = clavefnc;
		clave = CONCAT('%',clavefnc,'%');
		clavefnc = '';

		SELECT INTO total count(id_folio) FROM epp.cntrl_folio_gft WHERE folio LIKE clave;

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
				SELECT INTO idTrabExist id_trab FROM epp.movimiento_epp WHERE id_trab = idTrabSearch;
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
    
    select into det_folio folio from epp.cntrl_folio_gft where folio = clave;
    
    IF NOT FOUND THEN
      insert into epp.cntrl_folio_gft values (1,clave);
    ELSE
      return clave;
    END IF;

	return clave;
end;
 $$ LANGUAGE plpgsql; -- OK 
 
/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- ------------------ funcion para obtener folio de movimientos gafete vst ---------------------------------------
drop function epp.obt_folio_gft_vst(integer); -- 6
CREATE OR REPLACE FUNCTION epp.obt_folio_gft_vst(integer) RETURNS character varying AS $$ 
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
    inicial := 'GV';
    
	SELECT INTO clavefnc nombre_corto FROM public.fincas WHERE id_finca= pIdFn;

	if clavefnc is null then
		idNext = 'Vacio';
		IDTrabReturn = 'Vacio';
	else	
		claveFinca = clavefnc;
		clave = CONCAT('%',clavefnc,'%');
		clavefnc = '';

		SELECT INTO total count(id_folio) FROM epp.cntrl_folio_gft_vst WHERE folio LIKE clave;

		if  total is null then -- -	
			idNext = clavefnc & '000';
			IDTrabReturn = idNext;
		else
			WHILE notExistIDTrab!=1 LOOP
				total = total ;		

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
				SELECT INTO idTrabExist folio FROM epp.mov_gft_vst WHERE folio = idTrabSearch;
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
    
    select into det_folio folio from epp.cntrl_folio_gft_vst where folio = clave;
    
    IF NOT FOUND THEN
      insert into epp.cntrl_folio_gft_vst values (1,clave);
    ELSE
      return clave;
    END IF;

	return clave;
end;
 $$ LANGUAGE plpgsql; -- OK
 
/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- ------------------ funcion para obtener folio de movimientos por cambio de labor -------------------------------
drop function epp.obt_folio_cambio(varchar); -- 7
CREATE OR REPLACE FUNCTION epp.obt_folio_cambio(varchar) RETURNS character varying AS $$ 
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
    inicial := 'CL';
    
	SELECT INTO clavefnc nombre_corto FROM public.fincas WHERE nombre_finca = pIdFn;

	if clavefnc is null then
		idNext = 'Vacio';
		IDTrabReturn = 'Vacio';
	else	
		claveFinca = clavefnc;
		clave = CONCAT('%',clavefnc,'%');
		clavefnc = '';

		SELECT INTO total count(id_folio) FROM epp.cntrl_folio_cambio WHERE folio LIKE clave;

		if  total is null then -- -	
			idNext = clavefnc & '000';
			IDTrabReturn = idNext;
		else
			WHILE notExistIDTrab!=1 LOOP
				total = total - 1;		

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
				SELECT INTO idTrabExist folio FROM epp.mov_gft_vst WHERE folio = idTrabSearch;
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
    
    select into det_folio folio from epp.cntrl_folio_cambio where folio = clave;
    
    IF NOT FOUND THEN
      insert into epp.cntrl_folio_cambio values (1,clave);
    ELSE
      return clave;
    END IF;

	return clave;
end;
 $$ LANGUAGE plpgsql; -- OK
 
/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- ------------------ funcion para obtener folio de repocision gafete vst ---------------------------------------
drop function epp.obt_folio_repo_gft_vst(varchar); -- 8
CREATE OR REPLACE FUNCTION epp.obt_folio_repo_gft_vst(varchar) RETURNS character varying AS $$ 
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
    inicial := 'RG';
    
	SELECT INTO clavefnc nombre_corto FROM public.fincas WHERE nombre_finca = pIdFn;

	if clavefnc is null then
		idNext = 'Vacio';
		IDTrabReturn = 'Vacio';
	else	
		claveFinca = clavefnc;
		clave = CONCAT('%',clavefnc,'%');
		clavefnc = '';

		SELECT INTO total count(id_folio) FROM epp.cntrl_folio_repo_gft_vst WHERE folio LIKE clave;

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
				SELECT INTO idTrabExist folio FROM epp.mov_gft_vst WHERE folio = idTrabSearch;
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
    
    select into det_folio folio from epp.cntrl_folio_repo_gft_vst where folio = clave;
    
    IF NOT FOUND THEN
      insert into epp.cntrl_folio_repo_gft_vst (id_folio,folio,finca) values (1,clave,pIdFn);
    ELSE
      return clave;
    END IF;

	return clave;
end;
 $$ LANGUAGE plpgsql; -- OK
 
/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- ------------------ funcion para obtener folio de movimientos reposicion epp ---------------------------------------
drop function epp.obt_folio_baja(integer); -- 9
CREATE OR REPLACE FUNCTION epp.obt_folio_baja(integer) RETURNS character varying AS $$ 
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
    inicial := 'B';
    
	SELECT INTO clavefnc nombre_corto FROM public.fincas WHERE id_finca= pIdFn;

	if clavefnc is null then
		idNext = 'Vacio';
		IDTrabReturn = 'Vacio';
	else	
		claveFinca = clavefnc;
		clave = CONCAT('%',clavefnc,'%');
		clavefnc = '';

		SELECT INTO total count(id_folio) FROM epp.cntrl_folio_baja_epp WHERE folio LIKE clave;

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
				SELECT INTO idTrabExist id_trab FROM epp.movimiento_epp WHERE id_trab = idTrabSearch;
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
    
    select into det_folio folio from epp.cntrl_folio_baja_epp where folio = clave;
    
    IF NOT FOUND THEN
      insert into epp.cntrl_folio_baja_epp values (1,clave);
    ELSE
      return clave;
    END IF;

	return clave;
end;
 $$ LANGUAGE plpgsql; -- OK
 
/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- DROP FUNCTION public.registrar_movim_usuario(character varying, integer, character varying, integer, integer, character varying, character varying, character varying); -- 10

CREATE OR REPLACE FUNCTION public.registrar_movim_usuario(
	character varying,
	integer,
	character varying,
	integer,
	integer,
	character varying,
	character varying,
	character varying)
    RETURNS integer

AS $$

declare
	-- id_trab $1;
	-- TypeMovim $2;
	-- fechaMovim $3;
	-- idUser $4;
	-- fincaLog $5;
	-- ip address $6;
	-- mac $7;
	-- host $8;
	
	claveuser character varying;
	idBaja character varying;
	
	total integer;
	idFincaTrab integer;
	idFincaTransf integer;
	idNext character varying;
	tipoMovim integer;
	
	-- 0 No se pudo
	-- 1 Movim Registrado
	-- 2 Movim Registrado
begin	
	idBaja = 'BTMP';
	tipoMovim = $2;
	idFincaTransf = 0;

	SELECT INTO claveuser clave_movim FROM usuarios WHERE id_usuario=$4;

	SELECT INTO total count(id_movim) FROM movimientos WHERE id_usuario=$4;		
    -- select count(id_movim) FROM movimientos WHERE id_usuario=7;
	if  total is null then--	
		idNext = CONCAT(claveuser,'00001');
	else
		total = total + 1;

		if total > 9999 then
			idNext = CONCAT(claveuser,'');
			idNext = CONCAT(idNext,total);
		else 
			if total > 999 then
				idNext = CONCAT(claveuser,'0');
				idNext = CONCAT(idNext,total);
			else 
				if total > 99 then
					idNext = CONCAT(claveuser,'00');
					idNext = CONCAT(idNext,total);
				else
					if total > 9 then
						idNext = CONCAT(claveuser,'000');
						idNext = CONCAT(idNext,total);
					else
						idNext = CONCAT(claveuser,'0000');
						idNext = CONCAT(idNext,total);
					end if;
				end if;
			end if;
		end if;
	end if;

	idFincaTrab = $5;
    
    RAISE NOTICE 'FOLIO: %', idNext;
    
    if  tipoMovim=12 then
      raise notice '12) TRABAJADOR P/RECHAZAR';
		SELECT INTO idBaja id_baja FROM baja_trabajadores WHERE id_trab=$1 AND transferencia='0' ORDER BY fecha_hora_baja DESC LIMIT 1;
    end if;
    
	if  tipoMovim=3 then
		SELECT INTO idBaja id_baja FROM baja_trabajadores WHERE id_trab=$1 AND transferencia='0' ORDER BY fecha_hora_baja DESC LIMIT 1;
	else
		if tipoMovim=10 then
			SELECT INTO idBaja id_baja FROM baja_trabajadores WHERE id_trab=$1 AND transferencia='1' ORDER BY fecha_hora_baja DESC LIMIT 1;
			SELECT INTO idFincaTransf id_finca_transferencia FROM baja_trabajadores WHERE id_trab=$1 AND transferencia='1' ORDER BY fecha_hora_baja DESC LIMIT 1;
		else
			if tipoMovim=6 then
				SELECT INTO idFincaTrab id_finca FROM trabajadores WHERE id_trab=$1;
			end if;
		end if;
	end if;
	
	insert into movimientos (id_movim, id_trab, id_tipo_movim, fecha_movim, id_usuario, log_finca, direccion_ip, mac_address, hostname_machine, id_baja, id_finca_transferencia ) values(idNext,$1,$2,$3,$4,idFincaTrab,$6,$7,$8, idBaja, idFincaTransf);	
	return 1;		
end;
$$ LANGUAGE plpgsql; -- OK 

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- FUNCION P/VER MOVIMIENTOS PENDIENTES EN EL ALMACEN
drop function epp.mov_pendi_alm(varchar,varchar,date,date); -- 11
create or replace function epp.mov_pendi_alm(varchar,varchar,date,date) returns setof record as $$
declare
  pidAl   alias for $1; -- nombre_almacen
  pidTm   alias for $2; -- tipo_movimiento
  pidFi   alias for $3; -- fecha inicio
  pidXf   alias for $4; -- fecha fin
  
  nuevo   record; -- pendientes nuevos
  repo    record; -- pendientes reposicion
  presta  record; -- pendientes prestamo (entrega)
  dvpres  record; -- pendientes devolucion prestamo
  dvcamb  record; -- pendientes devolucion cambio labor
  dvbaja  record; -- pendientes devolucion baja
  
  cnvo    record; -- comparador nuevo
  crep    record; -- comparador reposicion
  cpres   record; -- comparador prestamo (entrega)
  cdvpre  record; -- comparador devolucion prestamo
  cambdv  record; -- comparador devolucion cambio labor
  bajadv  record; -- comparador devolucion baja
begin
  
  create temporary table mov_pendientes( -- TABLA TEMPORAL P/ALMACENAMIENTO
    almacen varchar,
    folio varchar,
    id_trab varchar,
    nom_completo varchar,
    fecha date,
    referencia varchar
  ) on commit drop;
  
  IF pidAl = 'TODOS' THEN -- TODOS LOS ALMACENES (NO SE AGREGA FILTRO POR USUARIO)
    RAISE NOTICE 'TODOS LOS ALMACENES';
    
    IF pidTm = 'TODOS' THEN -- TODOS LOS TIPOS DE MOVIMIENTO 
      RAISE NOTICE 'TODOS LOS ALMACENES';
      
      for nuevo in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as           nombre_completo, N.FECHA::DATE, CONCAT('NVO. INGRESO POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_NVO_EPP_ALM N
        INNER JOIN EPP.MOVIMIENTO_EPP M ON N.FOLIO = M.FOLIO AND M.ID_FINCA = N.ID_FINCA AND M.ID_MATERIAL = N.ID_MATERIAL
        INNER JOIN FINCAS F ON N.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

        select into cnvo *from mov_pendientes where folio = nuevo.folio;

        if not found then
          RAISE NOTICE 'nuevo %', nuevo;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', nuevo.nombre_almacen,nuevo.folio,nuevo.id_trab,nuevo.nombre_completo,nuevo.fecha,nuevo.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO NVO';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop NUEVO

      for repo in SELECT DISTINCT A.NOMBRE_ALMACEN,R.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as           nombre_completo, R.FECHA::DATE, CONCAT('REPOSICION POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_REPO_EPP_ALM R
        INNER JOIN EPP.MOVIMIENTO_EPP M ON R.FOLIO = M.FOLIO AND M.ID_FINCA = R.ID_FINCA AND M.ID_MATERIAL = R.ID_MATERIAL
        INNER JOIN FINCAS F ON R.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND R.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = R.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE R.ENTREGADO = FALSE AND R.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE REPOSICIONES

        select into crep *from mov_pendientes where folio = repo.folio;

        if not found then
          RAISE NOTICE 'repo %', repo;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', repo.nombre_almacen,repo.folio,repo.id_trab,repo.nombre_completo,repo.fecha,repo.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO REPO';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop repo

      for presta in SELECT DISTINCT A.NOMBRE_ALMACEN,P.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as         nombre_completo, P.FECHA_INI_PRESTA::DATE, CONCAT('PRESTAMO POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_PRESTA_EPP_ALM P
        INNER JOIN EPP.MOVIMIENTO_EPP M ON P.FOLIO = M.FOLIO AND M.ID_FINCA = P.ID_FINCA AND M.ID_MATERIAL = P.ID_MATERIAL
        INNER JOIN FINCAS F ON P.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND P.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = P.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE P.ENTREGADO = FALSE AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (ENTREGA)

        select into cpres *from mov_pendientes where folio = presta.folio;

        if not found then
          RAISE NOTICE 'presta %', presta;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', presta.nombre_almacen,presta.folio,presta.id_trab,presta.nombre_completo,presta.fecha_ini_presta,presta.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO PRESTA ENT';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop presta (ENTREGA)

      for dvpres in SELECT DISTINCT A.NOMBRE_ALMACEN,P.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as         nombre_completo, P.FECHA_FIN_PRESTA::DATE , CONCAT('PRESTAMO POR DEVOLVER') AS REFERENCIA
        FROM EPP.DET_MOV_PRESTA_EPP_ALM P
        INNER JOIN EPP.MOVIMIENTO_EPP M ON P.FOLIO = M.FOLIO AND M.ID_FINCA = P.ID_FINCA AND M.ID_MATERIAL = P.ID_MATERIAL
        INNER JOIN FINCAS F ON P.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND P.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = P.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE P.RECEPCION = FALSE AND (P.EST = 1 OR P.EST = 2) AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (DEVOLUCION)

        select into cdvpre *from mov_pendientes where folio = dvpres.folio;

        if not found then
          RAISE NOTICE 'dvpres %', dvpres;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvpres.nombre_almacen,dvpres.folio,dvpres.id_trab,dvpres.nombre_completo,dvpres.fecha_fin_presta,dvpres.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO PRESTA DEV';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop presta (DEVOLUCION)
      
      for dvcamb in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, N.FECHA::DATE, CONCAT('DEVOLUCION POR CAMBIO DE LABOR') AS REFERENCIA
        FROM epp.dev_x_cambio_labor N
        INNER JOIN FINCAS F ON N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = N.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

        select into cambdv *from mov_pendientes where folio = dvcamb.folio;

        if not found then
          RAISE NOTICE 'dvcamb %', dvcamb;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvcamb.nombre_almacen,dvcamb.folio,dvcamb.id_trab,dvcamb.nombre_completo,dvcamb.fecha,dvcamb.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO CAMBIO LABOR 1';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop CAMBIO LABOR
      
      for dvbaja in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as           nombre_completo, N.FECHA::DATE, CONCAT('DEVOLUCION POR BAJA') AS REFERENCIA
        FROM EPP.DET_MOV_BAJA_EPP_ALM N
        INNER JOIN EPP.MOVIMIENTO_EPP M ON N.FOLIO = M.FOLIO AND M.ID_FINCA = N.ID_FINCA AND M.ID_MATERIAL = N.ID_MATERIAL
        INNER JOIN FINCAS F ON N.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE BAJA TRABAJADOR

        select into bajadv *from mov_pendientes where folio = dvbaja.folio;

        if not found then
          RAISE NOTICE 'dvbaja %', dvbaja;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvbaja.nombre_almacen,dvbaja.folio,dvbaja.id_trab,dvbaja.nombre_completo,dvbaja.fecha,dvbaja.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO BAJA';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop BAJA

    
    END IF; -- IF TODOS LOS TIPOS DE MOVIMIENTO
    
    IF pidTm = 'NVO. INGRESO' THEN -- PASA TIPO DE MOVIMIENTO 
      RAISE NOTICE 'NUEVO INGRESO'; 
      
      for nuevo in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as       nombre_completo, N.FECHA::DATE, CONCAT('NVO. INGRESO POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_NVO_EPP_ALM N
        INNER JOIN EPP.MOVIMIENTO_EPP M ON N.FOLIO = M.FOLIO AND M.ID_FINCA = N.ID_FINCA AND M.ID_MATERIAL = N.ID_MATERIAL
        INNER JOIN FINCAS F ON N.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

        select into cnvo *from mov_pendientes where folio = nuevo.folio;

        if not found then
          RAISE NOTICE 'nuevo %', nuevo;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', nuevo.nombre_almacen,nuevo.folio,nuevo.id_trab,nuevo.nombre_completo,nuevo.fecha,nuevo.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO NVO';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop NUEVO
    END IF; -- IF TIPO NVO INGRESO
    
    IF pidTm = 'REPOSICION' THEN -- PASA TIPO MOVIMIENTO
      RAISE NOTICE 'REPOSICION'; 
      
      for repo in SELECT DISTINCT A.NOMBRE_ALMACEN,R.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as         nombre_completo, R.FECHA::DATE, CONCAT('REPOSICION POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_REPO_EPP_ALM R
        INNER JOIN EPP.MOVIMIENTO_EPP M ON R.FOLIO = M.FOLIO AND M.ID_FINCA = R.ID_FINCA AND M.ID_MATERIAL = R.ID_MATERIAL
        INNER JOIN FINCAS F ON R.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND R.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = R.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE R.ENTREGADO = FALSE AND R.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE REPOSICIONES
     
        select into crep *from mov_pendientes where folio = repo.folio;

        if not found then
          RAISE NOTICE 'repo %', repo;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', repo.nombre_almacen,repo.folio,repo.id_trab,repo.nombre_completo,repo.fecha,repo.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO REPO';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop repo
    END IF; -- IF TIPO REPOSICION
   
    IF pidTm = 'PRESTAMO (SURTIR)' THEN -- PASA TIPO MOVIMIENTO
      RAISE NOTICE 'PRESTAMO ENT';
      
      for presta in SELECT DISTINCT A.NOMBRE_ALMACEN,P.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as       nombre_completo, P.FECHA_INI_PRESTA::DATE, CONCAT('PRESTAMO POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_PRESTA_EPP_ALM P
        INNER JOIN EPP.MOVIMIENTO_EPP M ON P.FOLIO = M.FOLIO AND M.ID_FINCA = P.ID_FINCA AND M.ID_MATERIAL = P.ID_MATERIAL
        INNER JOIN FINCAS F ON P.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND P.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = P.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE P.ENTREGADO = FALSE AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (ENTREGA)

        select into cpres *from mov_pendientes where folio = presta.folio;

        if not found then
          RAISE NOTICE 'presta %', presta;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', presta.nombre_almacen,presta.folio,presta.id_trab,presta.nombre_completo,presta.fecha_ini_presta,presta.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO PRESTA ENT';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop presta (ENTREGA)
    END IF; -- IF TIPO PRESTAMO ENT
    
    IF pidTm = 'DEV. DE PRESTAMO' THEN -- PASA TIPO MIVIMIENTO
      RAISE NOTICE 'PRESTAMO DEV'; 
      
      for dvpres in SELECT DISTINCT A.NOMBRE_ALMACEN,P.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as       nombre_completo, P.FECHA_FIN_PRESTA::DATE, CONCAT('PRESTAMO POR DEVOLVER') AS REFERENCIA
        FROM EPP.DET_MOV_PRESTA_EPP_ALM P
        INNER JOIN EPP.MOVIMIENTO_EPP M ON P.FOLIO = M.FOLIO AND M.ID_FINCA = P.ID_FINCA AND M.ID_MATERIAL = P.ID_MATERIAL
        INNER JOIN FINCAS F ON P.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND P.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = P.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE P.RECEPCION = FALSE AND (P.EST = 1 OR P.EST = 2) AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (DEVOLUCION)

        select into cdvpre *from mov_pendientes where folio = dvpres.folio;

        if not found then
          RAISE NOTICE 'dvpres %', dvpres;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvpres.nombre_almacen,dvpres.folio,dvpres.id_trab,dvpres.nombre_completo,dvpres.fecha_fin_presta,dvpres.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO PRESTA DEV';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop presta (DEVOLUCION)
    END IF; -- IF TIPO PRESTAMO DEV
    
    IF pidTm = 'DEV. POR CAMBIO LABOR' THEN -- PASA TIPO MIVIMIENTO
      RAISE NOTICE 'PRESTAMO CAMBIO LABOR'; 
      
      for dvcamb in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, N.FECHA::DATE, CONCAT('DEVOLUCION POR CAMBIO DE LABOR') AS REFERENCIA
        FROM epp.dev_x_cambio_labor N
        INNER JOIN FINCAS F ON N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = N.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (CAMBIO LABOR)

        select into cambdv *from mov_pendientes where folio = dvcamb.folio;

        if not found then
          RAISE NOTICE 'dvcamb %', dvcamb;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvcamb.nombre_almacen,dvcamb.folio,dvcamb.id_trab,dvcamb.nombre_completo,dvcamb.fecha,dvcamb.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO CAMBIO LABOR 2';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop presta (DEV. POR CAMBIO LABOR)
    END IF; -- IF TIPO DEV. POR CAMBIO LABOR
    
    IF pidTm = 'DEV. BAJA TRABAJADOR' THEN -- PASA TIPO DE MOVIMIENTO 
      RAISE NOTICE 'BAJA TRABAJADOR'; 
      
      for dvbaja in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as       nombre_completo, N.FECHA::DATE, CONCAT('DEVOLUCION POR BAJA') AS REFERENCIA
        FROM EPP.DET_MOV_BAJA_EPP_ALM N
        INNER JOIN EPP.MOVIMIENTO_EPP M ON N.FOLIO = M.FOLIO AND M.ID_FINCA = N.ID_FINCA AND M.ID_MATERIAL = N.ID_MATERIAL
        INNER JOIN FINCAS F ON N.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE BAJA TRABAJADOR

        select into bajadv *from mov_pendientes where folio = dvbaja.folio;

        if not found then
          RAISE NOTICE 'baja %', dvbaja;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvbaja.nombre_almacen,dvbaja.folio,dvbaja.id_trab,dvbaja.nombre_completo,dvbaja.fecha,dvbaja.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO BAJA';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop BAJA
    END IF; -- IF TIPO BAJA
    
  
  ELSE -- SI PASA UN ALMACEN
    RAISE NOTICE 'SI PASA ALMACEN';
    
    IF pidTm = 'TODOS' THEN -- TODOS LOS TIPOS DE MOVIMIENTO 
      RAISE NOTICE 'TODOS LOS ALMACENES';
      
      for nuevo in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as           nombre_completo, N.FECHA::DATE, CONCAT('NVO. INGRESO POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_NVO_EPP_ALM N
        INNER JOIN EPP.MOVIMIENTO_EPP M ON N.FOLIO = M.FOLIO AND M.ID_FINCA = N.ID_FINCA AND M.ID_MATERIAL = N.ID_MATERIAL
        INNER JOIN FINCAS F ON N.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

        select into cnvo *from mov_pendientes where folio = nuevo.folio;

        if not found then
          RAISE NOTICE 'nuevo %', nuevo;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', nuevo.nombre_almacen,nuevo.folio,nuevo.id_trab,nuevo.nombre_completo,nuevo.fecha,nuevo.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO NVO';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop NUEVO

      for repo in SELECT DISTINCT A.NOMBRE_ALMACEN,R.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as           nombre_completo, R.FECHA::DATE, CONCAT('REPOSICION POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_REPO_EPP_ALM R
        INNER JOIN EPP.MOVIMIENTO_EPP M ON R.FOLIO = M.FOLIO AND M.ID_FINCA = R.ID_FINCA AND M.ID_MATERIAL = R.ID_MATERIAL
        INNER JOIN FINCAS F ON R.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND R.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = R.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE R.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND R.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE REPOSICIONES

        select into crep *from mov_pendientes where folio = repo.folio;

        if not found then
          RAISE NOTICE 'repo %', repo;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', repo.nombre_almacen,repo.folio,repo.id_trab,repo.nombre_completo,repo.fecha,repo.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO REPO';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop repo

      for presta in SELECT DISTINCT A.NOMBRE_ALMACEN,P.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as         nombre_completo, P.FECHA_INI_PRESTA::DATE, CONCAT('PRESTAMO POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_PRESTA_EPP_ALM P
        INNER JOIN EPP.MOVIMIENTO_EPP M ON P.FOLIO = M.FOLIO AND M.ID_FINCA = P.ID_FINCA AND M.ID_MATERIAL = P.ID_MATERIAL
        INNER JOIN FINCAS F ON P.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND P.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = P.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE P.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (ENTREGA)

        select into cpres *from mov_pendientes where folio = presta.folio;

        if not found then
          RAISE NOTICE 'presta %', presta;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', presta.nombre_almacen,presta.folio,presta.id_trab,presta.nombre_completo,presta.fecha_ini_presta,presta.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO PRESTA ENT';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop presta (ENTREGA)

      for dvpres in SELECT DISTINCT A.NOMBRE_ALMACEN,P.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as         nombre_completo, P.FECHA_FIN_PRESTA::DATE, CONCAT('PRESTAMO POR DEVOLVER') AS REFERENCIA
        FROM EPP.DET_MOV_PRESTA_EPP_ALM P
        INNER JOIN EPP.MOVIMIENTO_EPP M ON P.FOLIO = M.FOLIO AND M.ID_FINCA = P.ID_FINCA AND M.ID_MATERIAL = P.ID_MATERIAL
        INNER JOIN FINCAS F ON P.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND P.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = P.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE P.RECEPCION = FALSE AND (P.EST = 1 OR P.EST = 2) AND A.NOMBRE_ALMACEN = pidAl AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (DEVOLUCION)

        select into cdvpre *from mov_pendientes where folio = dvpres.folio;

        if not found then
          RAISE NOTICE 'dvpres %', dvpres;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvpres.nombre_almacen,dvpres.folio,dvpres.id_trab,dvpres.nombre_completo,dvpres.fecha_fin_presta,dvpres.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO PRESTA DEV';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop presta (DEVOLUCION)
      
      for dvcamb in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, N.FECHA::DATE, CONCAT('DEVOLUCION POR CAMBIO DE LABOR') AS REFERENCIA
        FROM epp.dev_x_cambio_labor N
        INNER JOIN FINCAS F ON N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = N.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

        select into cambdv *from mov_pendientes where folio = dvcamb.folio;

        if not found then
          RAISE NOTICE 'dvcamb %', dvcamb;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvcamb.nombre_almacen,dvcamb.folio,dvcamb.id_trab,dvcamb.nombre_completo,dvcamb.fecha,dvcamb.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO CAMBIO LABOR 3';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop CAMBIO LABOR
      
      for dvbaja in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as           nombre_completo, N.FECHA::DATE, CONCAT('DEVOLUCION POR BAJA') AS REFERENCIA
        FROM EPP.DET_MOV_BAJA_EPP_ALM N
        INNER JOIN EPP.MOVIMIENTO_EPP M ON N.FOLIO = M.FOLIO AND M.ID_FINCA = N.ID_FINCA AND M.ID_MATERIAL = N.ID_MATERIAL
        INNER JOIN FINCAS F ON N.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

        select into bajadv *from mov_pendientes where folio = dvbaja.folio;

        if not found then
          RAISE NOTICE 'dvbaja %', dvbaja;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvbaja.nombre_almacen,dvbaja.folio,dvbaja.id_trab,dvbaja.nombre_completo,dvbaja.fecha,dvbaja.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO BAJA';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop BAJA
    
    END IF; -- IF TODOS LOS TIPOS DE MOVIMIENTO
    
    IF pidTm = 'NVO. INGRESO' THEN -- PASA TIPO DE MOVIMIENTO 
      RAISE NOTICE 'NUEVO INGRESO'; 
      
      for nuevo in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as       nombre_completo, N.FECHA::DATE, CONCAT('NVO. INGRESO POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_NVO_EPP_ALM N
        INNER JOIN EPP.MOVIMIENTO_EPP M ON N.FOLIO = M.FOLIO AND M.ID_FINCA = N.ID_FINCA AND M.ID_MATERIAL = N.ID_MATERIAL
        INNER JOIN FINCAS F ON N.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

        select into cnvo *from mov_pendientes where folio = nuevo.folio;

        if not found then
          RAISE NOTICE 'nuevo %', nuevo;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', nuevo.nombre_almacen,nuevo.folio,nuevo.id_trab,nuevo.nombre_completo,nuevo.fecha,nuevo.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO NVO';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop NUEVO
    END IF; -- IF TIPO NVO INGRESO
    
    IF pidTm = 'REPOSICION' THEN -- PASA TIPO MOVIMIENTO
      RAISE NOTICE 'REPOSICION'; 
      
      for repo in SELECT DISTINCT A.NOMBRE_ALMACEN,R.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as         nombre_completo, R.FECHA::DATE, CONCAT('REPOSICION POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_REPO_EPP_ALM R
        INNER JOIN EPP.MOVIMIENTO_EPP M ON R.FOLIO = M.FOLIO AND M.ID_FINCA = R.ID_FINCA AND M.ID_MATERIAL = R.ID_MATERIAL
        INNER JOIN FINCAS F ON R.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND R.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = R.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE R.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND R.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE REPOSICIONES
     
        select into crep *from mov_pendientes where folio = repo.folio;

        if not found then
          RAISE NOTICE 'repo %', repo;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', repo.nombre_almacen,repo.folio,repo.id_trab,repo.nombre_completo,repo.fecha,repo.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO REPO';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop repo
    END IF; -- IF TIPO REPOSICION
   
    IF pidTm = 'PRESTAMO (SURTIR)' THEN -- PASA TIPO MOVIMIENTO
      RAISE NOTICE 'PRESTAMO ENT';
      
      for presta in SELECT DISTINCT A.NOMBRE_ALMACEN,P.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as       nombre_completo, P.FECHA_INI_PRESTA::DATE, CONCAT('PRESTAMO POR SURTIR') AS REFERENCIA
        FROM EPP.DET_MOV_PRESTA_EPP_ALM P
        INNER JOIN EPP.MOVIMIENTO_EPP M ON P.FOLIO = M.FOLIO AND M.ID_FINCA = P.ID_FINCA AND M.ID_MATERIAL = P.ID_MATERIAL
        INNER JOIN FINCAS F ON P.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND P.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = P.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE P.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (ENTREGA)

        select into cpres *from mov_pendientes where folio = presta.folio;

        if not found then
          RAISE NOTICE 'presta %', presta;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', presta.nombre_almacen,presta.folio,presta.id_trab,presta.nombre_completo,presta.fecha_ini_presta,presta.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO PRESTA ENT';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop presta (ENTREGA)
    END IF; -- IF TIPO PRESTAMO ENT
    
    IF pidTm = 'DEV. DE PRESTAMO' THEN -- PASA TIPO MIVIMIENTO
      RAISE NOTICE 'PRESTAMO DEV'; 
      
      for dvpres in SELECT DISTINCT A.NOMBRE_ALMACEN,P.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as       nombre_completo, P.FECHA_FIN_PRESTA::DATE, CONCAT('PRESTAMO POR DEVOLVER') AS REFERENCIA
        FROM EPP.DET_MOV_PRESTA_EPP_ALM P
        INNER JOIN EPP.MOVIMIENTO_EPP M ON P.FOLIO = M.FOLIO AND M.ID_FINCA = P.ID_FINCA AND M.ID_MATERIAL = P.ID_MATERIAL
        INNER JOIN FINCAS F ON P.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND P.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = P.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE P.RECEPCION = FALSE AND (P.EST = 1 OR P.EST = 2) AND A.NOMBRE_ALMACEN = pidAl AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (DEVOLUCION)

        select into cdvpre *from mov_pendientes where folio = dvpres.folio;

        if not found then
          RAISE NOTICE 'dvpres %', dvpres;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvpres.nombre_almacen,dvpres.folio,dvpres.id_trab,dvpres.nombre_completo,dvpres.fecha_fin_presta,dvpres.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO PRESTA DEV';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop presta (DEVOLUCION)
    END IF; -- IF TIPO PRESTAMO DEV
    
    IF pidTm = 'DEV. POR CAMBIO LABOR' THEN -- PASA TIPO MIVIMIENTO
      RAISE NOTICE 'PRESTAMO CAMBIO LABOR'; 
      
      for dvcamb in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, N.FECHA::DATE, CONCAT('DEVOLUCION POR CAMBIO DE LABOR') AS REFERENCIA
        FROM epp.dev_x_cambio_labor N
        INNER JOIN FINCAS F ON N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = N.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (CAMBIO LABOR)

        select into cambdv *from mov_pendientes where folio = dvcamb.folio;

        if not found then
          RAISE NOTICE 'dvcamb %', dvcamb;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvcamb.nombre_almacen,dvcamb.folio,dvcamb.id_trab,dvcamb.nombre_completo,dvcamb.fecha,dvcamb.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO CAMBIO LABOR 4';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop presta (DEV. POR CAMBIO LABOR)
    END IF; -- IF TIPO DEV. POR CAMBIO LABOR
    
  IF pidTm = 'DEV. BAJA TRABAJADOR' THEN -- PASA TIPO DE MOVIMIENTO 
      RAISE NOTICE 'BAJA TRABAJADOR'; 
  
    for dvbaja in SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as       nombre_completo, N.FECHA::DATE, CONCAT('DEVOLUCION POR BAJA') AS REFERENCIA
        FROM EPP.DET_MOV_BAJA_EPP_ALM N
        INNER JOIN EPP.MOVIMIENTO_EPP M ON N.FOLIO = M.FOLIO AND M.ID_FINCA = N.ID_FINCA AND M.ID_MATERIAL = N.ID_MATERIAL
        INNER JOIN FINCAS F ON N.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

        select into bajadv *from mov_pendientes where folio = dvbaja.folio;

        if not found then
          RAISE NOTICE 'dvbaja %', dvbaja;
          execute format('insert into %I values (%L,%L,%L,%L,%L,%L)', 'mov_pendientes', dvbaja.nombre_almacen,dvbaja.folio,dvbaja.id_trab,dvbaja.nombre_completo,dvbaja.fecha,dvbaja.referencia);
        else
          RAISE NOTICE 'REGISTRO DUPLICADO BAJA';
        end if; -- else INSERTAR DATOS
      end loop; -- end loop BAJA
    END IF; -- IF TIPO NVO BAJA
  
  END IF; -- ELSE IF TODOS LOS ALMACENES
 
  return query select * from mov_pendientes; -- retorna consulta c/materiales a entregar
  
  RETURN; -- retorna los valores de la tabla
END;
$$ language plpgsql; -- OK 

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
DROP FUNCTION epp.movimientos_almacen(text[], text[]); -- 12
CREATE OR REPLACE FUNCTION epp.movimientos_almacen(pdatos_movimiento text[], p_materiales text[]) RETURNS text AS
$$
DECLARE

	vCantidad         INT; 		vCantidad_inv	   INT;
	vExistencia_mat   FLOAT; 	vNextfolio		   text;
	vFolio            text;		vid_movimiento	   INT;
	vCns_detalle      INT;		vid_centro_costo   INT;
	vid_material      INT;		i			       INT;
	longitud_mat      INT; 		longitud_datos 	   INT;
	QueryMovimiento   text;		QueryDetalle	   text;
	QueryInventario   text;		vId_almacen		   INT;
	vId_usuario       INT;		Query_kardex	   text;
    updsal            text;            updrec	   text;
	
BEGIN
	SELECT id_almacen INTO vId_almacen FROM almacen.almacen WHERE nombre_almacen=pdatos_movimiento[5];
	SELECT (COALESCE (COUNT(*),0)+1) :: INT INTO vCantidad FROM almacen.movimientos WHERE id_almacen=vId_almacen;
	SELECT abrev INTO vFolio FROM almacen.almacen WHERE id_almacen=vId_almacen;
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
	-- INSERT INTO movimientos (cantidad,id_almacen,folio,id_periodo,id_tipo_movimiento,fecha_proceso) VALUES (pCantidad,vId_almacen,vNextfolio,pId_periodo,pId_tipo_movimiento,pFecha_proceso);
	/*
	pdatos_movimiento[1]  --> Fecha de proceso
	pdatos_movimiento[2]  --> Cantidad Total de unidades
	pdatos_movimiento[3]  --> Tipo de Movimiento
	pdatos_movimiento[4]  --> Usuario
	pdatos_movimiento[5]  --> Nombre del almacen
	pdatos_movimiento[6]  --> id_proveedor / centro de costo
    pdatos_movimiento[7]  --> NULL
    pdatos_movimiento[8]  --> id_finca
	pdatos_movimiento[9]  --> folio epp
	pdatos_movimiento[10] --> id_almacenista
    pdatos_movimiento[11] --> mov_epp :: 1-.nuevo, 2-.reposicion, 3-.prestamo, 4-.Dev x cambio, 5-.Baja
    pdatos_movimiento[12] --> id_trabajador p/baja y cambio labor
	*/
	SELECT id_usuario INTO vId_usuario FROM almacen.usuarios WHERE usuario = pdatos_movimiento[4];
	QueryMovimiento = 'INSERT INTO almacen.movimientos (cantidad,id_almacen,folio,id_periodo,id_tipo_movimiento,fecha_proceso,id_usuario) VALUES ('||pdatos_movimiento[2]||','||vId_almacen||','''||vNextfolio||''','||pdatos_movimiento[6]||','||pdatos_movimiento[3]||','''||pdatos_movimiento[1]||''','||vId_usuario||');'; 
	RAISE NOTICE 'QueryMovimiento --> %',QueryMovimiento;
	EXECUTE QueryMovimiento;
	SELECT id_movimiento INTO vid_movimiento FROM almacen.movimientos WHERE folio=vNextfolio AND id_almacen=vId_almacen;
	RAISE NOTICE 'vid_movimiento --> %',vid_movimiento;
	
	IF vid_movimiento IS NULL THEN 
		vid_movimiento=1;
	END IF;
	longitud_mat:=array_length(p_materiales,1);
	RAISE NOTICE 'LENGTH ARRAY %',longitud_mat;
	FOR i IN 1..longitud_mat LOOP 
/*
		RAISE NOTICE 'VALORES ARRAY [%][1]=%',i,p_materiales[i][1]; -- CLAVE MATERIAL
		RAISE NOTICE 'VALORES ARRAY [%][2]=%',i,p_materiales[i][2]; -- NOMBRE
		RAISE NOTICE 'VALORES ARRAY [%][3]=%',i,p_materiales[i][3]; -- CANTIDAD
		RAISE NOTICE 'VALORES ARRAY [%][4]=%',i,p_materiales[i][4]; -- REFERENCIA
		RAISE NOTICE 'VALORES ARRAY [%][5]=%',i,p_materiales[i][5]; -- NOMBRE CENTRO DE COSTO
*/
		-- RAISE NOTICE 'INSERT INTO detalle_movimientos (id_movimiento,cns_detalle_movimiento,cantidad,id_material,referencia,id_centro_costo) VALUES (%,%,%,%,%,%);',vid_movimiento,vCns_detalle,    p_materiales[i][3],p_materiales[i][1],p_materiales[i][4],p_materiales[i][5];
		-- SELECT id_centro_costo INTO vid_centro_costo FROM  centro_costo WHERE nombre_centro_costo=p_materiales[i][5];
		SELECT id_material INTO vid_material FROM almacen.materiales WHERE clave=p_materiales[i][1];
		
		IF (pdatos_movimiento[3]::INT=1) THEN -- ENTRADA
			QueryDetalle= 'INSERT INTO almacen.detalle_movimientos (id_movimiento,cns_detalle_movimiento,cantidad,id_material,referencia,id_proveedor) VALUES ('||vid_movimiento||','||i||','||p_materiales[i][3]||','||vid_material||','''||p_materiales[i][4]||''','||p_materiales[i][5]||');';
		END IF;
		IF (pdatos_movimiento[3]::INT=2) THEN -- SALIDA
			QueryDetalle= 'INSERT INTO almacen.detalle_movimientos (id_movimiento,cns_detalle_movimiento,cantidad,id_material,referencia,id_centro_costo) VALUES ('||vid_movimiento||','||i||','||p_materiales[i][3]||','||vid_material||','''||p_materiales[i][4]||''','||p_materiales[i][5]::int||');';
		END IF;
		IF (pdatos_movimiento[3]::INT=6) THEN -- ENTRADA POR DEVOLUCIÓN
			QueryDetalle= 'INSERT INTO almacen.detalle_movimientos (id_movimiento,cns_detalle_movimiento,cantidad,id_material,referencia) VALUES ('||vid_movimiento||','||i||','||p_materiales[i][3]||','||vid_material||','''||p_materiales[i][4]||''');';
		END IF;
		RAISE NOTICE 'QueryDetalle --> %',QueryDetalle;
		EXECUTE QueryDetalle;
		SELECT count(*) :: INT INTO vCantidad_inv FROM almacen.inventario WHERE id_material = vid_material AND id_almacen = vId_almacen; -- AND id_centro_costo = vid_centro_costo;
		RAISE NOTICE 'Cantidad de registro de Material en Inventario --> %',vCantidad_inv;

		IF vCantidad_inv > 0 THEN -- VERIFICO SI YA EXISTE DICHO MATERIAL
			SELECT existencia INTO vExistencia_mat FROM almacen.inventario WHERE id_material = vid_material AND id_almacen = vId_almacen; -- AND id_centro_costo = vid_centro_costo;
			RAISE NOTICE 'EXISTENCIA ACTUAL --> %',vExistencia_mat;
          IF (pdatos_movimiento[3]::INT=1 or pdatos_movimiento[3]::INT=6) THEN -- TIPO DE MOVIMIENTO ENTRADA O                     ENTRADA_X_DEVOLUCION REALIZA LA SUMA DE LA EXISTENCIA ACTUAL CON LA NUEVA CANTIDAD. 
                Query_kardex = 'INSERT INTO almacen.detalle_inventario (id_movimiento,id_cns_detalle,id_material, cantidad_anterior, cant_entrada,cantidad_new) VALUES ('||vid_movimiento||','||i||','||vid_material||','||vExistencia_mat||','||p_materiales[i][3]::FLOAT||','||vExistencia_mat+(p_materiales[i][3]::FLOAT)||')';
                RAISE NOTICE 'Query_kardex-->%',Query_kardex;
                vExistencia_mat = vExistencia_mat+(p_materiales[i][3]::FLOAT);
                
            /* AQUI VOY A GUARDAR LA ACTUALIZACION RECEPCION MATERIAL P/EPP_ALMACEN (PRESTAMO) ADD VID_MOVIMIENTO */
              IF(pdatos_movimiento[11]::INT = 3) THEN -- PRESTAMO EPP
                raise notice 'DEVOLUCION DE PRESTAMO ALM';
                updrec = 'update epp.det_mov_presta_epp_alm set recepcion = true, id_almacenista_fin ='||pdatos_movimiento[10]||', id_movimiento_rec = '||vid_movimiento||' WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||'  ';
                EXECUTE updrec;
                RAISE NOTICE 'UPDREC DEV PRESTA --> %',updrec;
                
                updsal = 'update epp.Movimiento_epp set estado_epp = 2 WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||'  ';
                EXECUTE updsal;
                RAISE NOTICE 'UPDREC Movimiento_epp --> %',updsal;
              END IF; -- IF PRESTAMO  
              
              IF(pdatos_movimiento[11]::INT = 4) THEN -- DEVOLUCION X CAMBIO LABOR
                raise notice 'DEVOLUCION X CAMBIO LABOR ALM';
                
                updrec = 'update epp.det_mov_nvo_epp_alm set devolucion = true WHERE id_finca = '||pdatos_movimiento[8]||' and folio_dev = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||'  ';
                EXECUTE updrec;
                RAISE NOTICE 'UPDREC DEV X CAMBIO --> %',updrec;
                
                updsal = 'update epp.dev_x_cambio_labor set entregado = true, fecha = current_timestamp(0), id_movimiento = '||vid_movimiento||' WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||' ';
                EXECUTE updsal;
                RAISE NOTICE 'UPDSAL DEV X CAMBIO --> %',updsal;
                
                updsal = 'update epp.Movimiento_epp set estado_epp = 2 WHERE id_finca = '||pdatos_movimiento[8]||' and id_trab = '''||pdatos_movimiento[12]||''' and id_material = '||vid_material||'  ';
                EXECUTE updsal;
                RAISE NOTICE 'UPDREC Movimiento_epp --> %',updsal;
              END IF; -- IF DEVOLUCION X CAMBIO LABOR
              
              IF(pdatos_movimiento[11]::INT = 5) THEN -- BAJA EPP
                raise notice 'DEVOLUCION POR BAJA ALM';
                updrec = 'update epp.det_mov_baja_epp_alm set entregado = true, id_almacenista ='||pdatos_movimiento[10]||', id_movimiento = '||vid_movimiento||' WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||'  ';
                EXECUTE updrec;
                RAISE NOTICE 'UPDREC DEV BAJA --> %',updrec;
                
                updsal = 'update epp.Movimiento_epp set estado_epp = 2 WHERE id_finca = '||pdatos_movimiento[8]||' and id_trab = '''||pdatos_movimiento[12]||''' and id_material = '||vid_material||'  ';
                EXECUTE updsal;
                RAISE NOTICE 'UPDREC Movimiento_epp --> %',updsal;
              END IF; -- IF BAJA 
              
		   ELSE -- TIPO DE ENTRADA ES DINTINTO A 1, ENTONCES ES SALIDA, SE REALIZA EL DESCUENTA DE LA EXISTENCIA ACTUAL CON LA CANTIDAD A SALIR. 
				IF(pdatos_movimiento[3]::INT=2) THEN -- SALIDA DE MATERIAL
				  IF(p_materiales[i][3]::FLOAT <= vExistencia_mat) THEN -- LA CANTIDAD DE SALIDA ES MENOR A LA EXISTENCIA
					Query_kardex = 'INSERT INTO almacen.detalle_inventario (id_movimiento,id_cns_detalle,id_material, cantidad_anterior, cant_salida,cantidad_new) VALUES ('||vid_movimiento||','||i||','||vid_material||','||vExistencia_mat||','||p_materiales[i][3]::FLOAT||','||vExistencia_mat-(p_materiales[i][3]::FLOAT)||')';					
						vExistencia_mat = vExistencia_mat-(p_materiales[i][3]::FLOAT);
                        
                    /* AQUI GUARDAR LA ACTUALIZACION ENTREGA MATERIAL P/EPP_ALMACEN EN: (NUEVO,REPO,PRESTAMO)  ADD VID_MOVIMIENTO */
                    IF(pdatos_movimiento[11]::INT = 3) THEN -- PRESTAMO EPP
                      raise notice 'SALIDA PRESTAMO EPP ALM';
                      updsal = 'update epp.det_mov_presta_epp_alm set entregado = true, pendiente = false, id_almacenista_ini ='||pdatos_movimiento[10]||', id_movimiento_ini = '||vid_movimiento||', fecha_ini_presta = current_timestamp(0), fecha_fin_presta = current_timestamp(0) + ''36 HOUR'' WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||' ';
                      EXECUTE updsal;
                      RAISE NOTICE 'UPDSAL PRESTA --> %',updsal;
                      
                      updrec = 'update epp.Movimiento_epp set estado_epp = 1 WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||'  ';
                      EXECUTE updrec;
                      RAISE NOTICE 'UPDREC Movimiento_epp --> %',updrec;
                
                    END IF; 

                    IF(pdatos_movimiento[11]::INT = 2) THEN -- REPOSICION EPP
                      raise notice 'SALIDA REPOSICION EPP ALM';
                      updsal = 'update epp.det_mov_repo_epp_alm set entregado = true, pendiente = false, id_almacenista = '||pdatos_movimiento[10]||', id_movimiento = '||vid_movimiento||' WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||' ';
                      EXECUTE updsal;
                      RAISE NOTICE 'UPDSAL REPO --> %',updsal;
                      
                      updrec = 'update epp.cobros_detalle set surtido = true WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||' ';
                      EXECUTE updrec;
                      RAISE NOTICE 'UPDREC REPO COBRO --> %',updrec;
                      
                      updrec = 'update epp.reposiciones set surtido = true WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||' ';
                      EXECUTE updrec;
                      RAISE NOTICE 'UPDREC REPO GRATIS --> %',updrec;
                      
                      updrec = 'update epp.Movimiento_epp set estado_epp = 1 WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||'  ';
                      EXECUTE updrec;
                      RAISE NOTICE 'UPDREC Movimiento_epp --> %',updrec;
                      
                    END IF; -- IF REPOSICION EPP

                    IF(pdatos_movimiento[11]::INT = 1) THEN -- NUEVO EPP
                      raise notice 'SALIDA NVO EPP ALM';
                      updsal = 'update epp.det_mov_nvo_epp_alm set entregado = true, pendiente = false, id_almacenista = '||pdatos_movimiento[10]||', id_movimiento = '||vid_movimiento||' WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||' ';
                      EXECUTE updsal;
                      RAISE NOTICE 'UPDSAL NVO --> %',updsal;
                      
                      updrec = 'update epp.Movimiento_epp set estado_epp = 1 WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||'  ';
                      EXECUTE updrec;
                      RAISE NOTICE 'UPDREC Movimiento_epp --> %',updrec;
                    END IF; 
            
				  ELSE -- LA CANTIDAD DE SALIDA ES MAYOR A LA EXISTENCIA
						DELETE FROM almacen.detalle_movimientos WHERE id_movimiento=vid_movimiento;
						DELETE FROM almacen.movimientos WHERE id_movimiento=vid_movimiento;			
						vNextfolio='OCURRIO UN ERROR AL REALIZAR UN TIPO DE MOV POR SALIDA,
						NO SE CUENTA CON EXISTENCIA DE MATERIAL PARA REALIZAR UNA SALIDA.';	
                        
                        /* NO ACTUALIZA EN EPP_ALMACEN XQ NO SE HA SURTIDO MATERIAL */                        
				  END IF;
					
				END IF;
			END IF;
			EXECUTE Query_kardex;
			QueryInventario = 'UPDATE almacen.inventario SET existencia = ('||vExistencia_mat||')  WHERE id_material ='|| vid_material||' AND id_almacen = '||vId_almacen; -- ||' AND id_centro_costo = '||vid_centro_costo||';';
			EXECUTE QueryInventario;
		ELSE  -- NO EXISTE MATERIAL EN INVENTARIO
			IF (pdatos_movimiento[3]::INT=1 or pdatos_movimiento[3]::INT=6) THEN -- REALIZO EL REGISTRO DIRECTO. 
				QueryInventario = 'INSERT INTO almacen.inventario (id_material,id_almacen,existencia) VALUES ('||vid_material||','||vId_almacen||','||p_materiales[i][3]||');';
				Query_kardex = 'INSERT INTO almacen.detalle_inventario (id_movimiento,id_cns_detalle,id_material, cantidad_anterior, cant_entrada,cantidad_new) VALUES ('||vid_movimiento||','||i||','||vid_material||',0,'||p_materiales[i][3]::FLOAT||','||(p_materiales[i][3]::FLOAT)||')';
				-- QueryInventario = 'INSERT INTO inventario (id_material,id_almacen,existencia,id_centro_costo) VALUES ('||vid_material||','||vId_almacen||','||p_materiales[i][3]||','||vid_centro_costo||');';
				EXECUTE QueryInventario;
				EXECUTE Query_kardex;
                
                /* AQUI GUARDAR NUEVO ACTUALIZACION ENTREGA MATERIAL P/EPP_ALMACEN EN: (PRESTAMO) ADD VID_MOVIMIENTO */
                IF(pdatos_movimiento[11]::INT = 3) THEN -- PRESTAMO EPP
                  raise notice 'DEVOLUCION PRESTAMO EPP ALM NULL';
                  updrec = 'update epp.det_mov_presta_epp_alm set recepcion = true, id_almacenista_fin ='||pdatos_movimiento[10]||', id_movimiento_rec = '||vid_movimiento||' WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||'  ';
                  EXECUTE updrec;
                  RAISE NOTICE 'UPDREC PRESTA --> %',updrec;
                  
                  updsal = 'update epp.Movimiento_epp set estado_epp = 2 WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||'  ';
                  EXECUTE updsal;
                  RAISE NOTICE 'UPDREC Movimiento_epp --> %',updsal;
                END IF;  -- IF PRESTAMO EPP
                
                IF(pdatos_movimiento[11]::INT = 4) THEN -- DEVOLUCION X CAMBIO LABOR
                  raise notice 'DEVOLUCION X CAMBIO LABOR ALM';

                  updrec = 'update epp.det_mov_nvo_epp_alm set devolucion = true WHERE id_finca = '||pdatos_movimiento[8]||' and folio_dev = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||'  ';
                  EXECUTE updrec;
                  RAISE NOTICE 'UPDREC DEV X CAMBIO --> %',updrec;

                  updsal = 'update epp.dev_x_cambio_labor set entregado = true, fecha = current_timestamp(0), id_movimiento = '||vid_movimiento||' WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||' ';
                  EXECUTE updsal;
                  RAISE NOTICE 'UPDSAL DEV X CAMBIO --> %',updsal;
                  
                  updsal = 'update epp.Movimiento_epp set estado_epp = 2 WHERE id_finca = '||pdatos_movimiento[8]||' and id_trab = '''||pdatos_movimiento[12]||''' and id_material = '||vid_material||'  ';
                EXECUTE updsal;
                RAISE NOTICE 'UPDREC Movimiento_epp --> %',updsal;
              END IF; -- IF DEVOLUCION X CAMBIO LABOR
                
              IF(pdatos_movimiento[11]::INT = 5) THEN -- BAJA EPP
                raise notice 'DEVOLUCION POR BAJA ALM';
                updrec = 'update epp.det_mov_baja_epp_alm set entregado = true, id_almacenista ='||pdatos_movimiento[10]||', id_movimiento = '||vid_movimiento||' WHERE id_finca = '||pdatos_movimiento[8]||' and folio = '''||pdatos_movimiento[9]||''' and id_material = '||vid_material||'  ';
                EXECUTE updrec;
                RAISE NOTICE 'UPDREC DEV BAJA --> %',updrec;
                
                updsal = 'update epp.Movimiento_epp set estado_epp = 2 WHERE id_finca = '||pdatos_movimiento[8]||' and id_trab = '''||pdatos_movimiento[12]||''' and id_material = '||vid_material||'  ';
                EXECUTE updsal;
                RAISE NOTICE 'UPDREC Movimiento_epp --> %',updsal;
              END IF; -- IF BAJA 
              
			ELSE -- ENTRA A ELSE CUANDO SE REALICE UN MOVIMIENTO DISTINTO A ENTRADA, PUEDE SER SALIDA Y NO HAY EXISTENCIA DEL MATERIAL, ENTONCES NO DEJAR REALIZAR NADA Y ELIMINAMOS LOS REGISTROS. 
				vNextfolio='OCURRIO UN ERROR AL REALIZAR UN TIPO DE MOV POR SALIDA,
				NO SE CUENTA CON EXISTENCIA DE MATERIAL PARA REALIZAR UNA SALIDA.';
				DELETE FROM almacen.detalle_movimientos WHERE id_movimiento=vid_movimiento;
				DELETE FROM almacen.movimientos WHERE id_movimiento=vid_movimiento;
                
                /* NO ACTUALIZA EN EPP_ALMACEN XQ NO HAY EXISTENCIA P/SURTIR MATERIAL */                
			END IF; -- ELSE REGISTRO DIRECTO
			
		END IF; -- ELSE NO EXISTE MATERIAL EN INVENTARIO
		
		RAISE NOTICE 'QueryInventario --> %',QueryInventario;
		RAISE NOTICE ' ';
	END LOOP;
	
	longitud_datos:=array_length(pdatos_movimiento,1);
	RAISE NOTICE 'LENGTH ARRAY %',longitud_datos;
	FOR i IN 1..longitud_datos LOOP 
		RAISE NOTICE 'VALORES ARRAY [%]=%',i,pdatos_movimiento[i];
	END LOOP;
	
	RETURN vNextfolio;
END;
$$ LANGUAGE plpgsql ; -- OK
  
/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el almacenamiento de equipos de proteccion ----------------------------
drop function epp.epp_kavidac_vale(integer,varchar,integer,integer,integer,numeric(10,3),varchar,integer,integer,varchar); -- 13
create or replace function epp.epp_kavidac_vale(integer,varchar,integer,integer,integer,numeric(10,3),varchar,integer,integer,varchar) returns integer as $$
declare

  pidFn   alias for $1; -- id_finca
  pIdTr   alias for $2; -- id_trab 
  pIdMt   alias for $3; -- id_material
  pIdRx   alias for $4; -- id_tipo_mov_epp
  pIdZg   alias for $5; -- id_enfermera
  pIdCt   alias for $6; -- cantidad material
  pIdFl   alias for $7; -- folio
  pIdGf   alias for $8; -- validacion Gafete (1.- NO ES GFT, 2.- SI ES GFT)
  PidWh   alias for $9; -- id_almacen (destino)
  PidBj   alias for $10; -- tipo de baja_epp NULL
  
  vresult      integer;
  cont         integer;
  tnoc         integer;
  det_mov      RECORD;
  cns_epp      RECORD;
  alm_cns      RECORD;
  tip_t        RECORD; -- TIPO TRABAJADOR
  filtroF      VARCHAR; -- FILTRO FINCA
  filtroT      VARCHAR; -- FILTRO NOMBRE TIPO TRAB
  PidWhX2      RECORD;
  
BEGIN
  -- PidWhX2 := 0; -- RESETEAMOS EL ALM DESTINO
  
  select INTO tip_t k.id_tipo_trab,k.nombre_tipo_trab from public.trabajadores t inner join public.labor l on l.id_labor = t.id_labor inner join public.tipo_trabajador k on l.id_tipo_trab = k.id_tipo_trab where t.id_trab = pIdTr; -- OK
  
  raise notice 'TIPO TRAB: %', tip_t;
  
  filtroF = '';
  filtroT = '';
  
   /* VALIDACION P/OBTENER ALMACEN DE CAMBIO */
   if(pIdFn = 1) THEN -- DON ROLANDO
            raise notice 'ENTRO DR';
            filtroF = ' AND X.NOMBRE_FINCA = ''DON ROLANDO'' ';
            filtroT = ' AND A.NOMBRE_ALMACEN LIKE ''%'||tip_t.nombre_tipo_trab||'%'' ';
            raise notice 'filtroF: %', filtroF;
            raise notice 'filtroT: %', filtroT;
   END IF;
   
   if(pIdFn = 9) THEN -- ESPERANZA
            raise notice 'ENTRO ES';
            filtroF = ' AND X.NOMBRE_FINCA = ''ESPERANZA'' ';
            filtroT = ' AND A.NOMBRE_ALMACEN LIKE ''%'||tip_t.nombre_tipo_trab||'%'' ';
            raise notice 'filtroF: %', filtroF;
            raise notice 'filtroT: %', filtroT;
   END IF;
   
   if(pIdFn = 21) THEN -- MARY CARMEN
            raise notice 'ENTRO MC';
            filtroF = ' AND X.NOMBRE_FINCA = ''MARY CARMEN'' ';
            filtroT = ' AND A.NOMBRE_ALMACEN LIKE ''%'||tip_t.nombre_tipo_trab||'%'' ';
            raise notice 'filtroF: %', filtroF;
            raise notice 'filtroT: %', filtroT;
   END IF;
   
   if(pIdFn = 15) THEN -- CALZADITA
            raise notice 'ENTRO CZ';
            filtroF = ' AND X.NOMBRE_FINCA = ''CALZADITA'' ';
   END IF;
   
   if(pIdFn = 24) THEN -- SANTA MARIA
            raise notice 'ENTRO SM';
            filtroF = ' AND X.NOMBRE_FINCA = ''SANTA MARIA'' ';
   END IF;
   
   IF (pIdFn = 23) THEN -- LOS CARLOS
            raise notice 'ENTRO LC';
            filtroF = ' AND X.NOMBRE_FINCA = ''LOS CARLOS'' ';
   END IF;
   
   IF (pIdFn = 19) THEN -- TOBRUK
        raise notice 'ENTRO TB';
        filtroF = ' AND X.NOMBRE_FINCA = ''TOBRUK'' ';
   END IF;
        
   EXECUTE 'SELECT A.ID_ALMACEN FROM ALMACEN.ALMACEN A INNER JOIN ALMACEN.FINCA F ON F.ID_FINCA = A.ID_FINCA INNER JOIN PUBLIC.FINCAS X ON F.ID_FINCA_PUB = X.ID_FINCA WHERE A.TIPO_ENFERMERIA = FALSE '||filtroF||'  '||filtroT||'  ' INTO PidWhX2; 
                
   raise notice 'ID_ALM_CAMBIO: %', PidWhX2.id_almacen;
   
  vresult := 1;
  cont := 1; -- CONTADOR DE MOV ENFERMERIA
  tnoc := 1; -- CONTADOR DE MOV ALMACENISTA
  
  -- Buscando el detalle de movimientos
  select into det_mov *from epp.movimiento_epp where id_finca = pIdFn and id_trab = pIdTr and folio = pIdFl and id_material = pIdMt;
   
  IF NOT FOUND THEN
    raise notice 'NO TIENE DATOS';
    insert into epp.movimiento_epp (id_finca,folio,id_material,id_trab,id_tipo_mov_epp,id_enfermera,alm_destino) values (pidFn,pIdFl,pIdMt,pIdTr,pIdRx,pIdZg,PidWhX2.id_almacen);    
  END IF;  -- IF INSERTANDO EN MOVIMIENTOS
  
  IF pIdRx = 1 THEN 
    raise notice 'NUEVO INGRESO';
    
    IF pIdGf = 1 THEN
      raise notice 'NO ES GAFETE';
      select into cns_epp cns from epp.det_mov_nvo_epp_enf order by cns desc limit 1;

      IF NOT FOUND THEN
        insert into epp.det_mov_nvo_epp_enf(id_finca,folio,id_material,cns,cantidad) values (pidFn,pIdFl,pIdMt,cont,pIdCt);
      ELSE
        cont := cns_epp.cns + 1;
        insert into epp.det_mov_nvo_epp_enf(id_finca,folio,id_material,cns,cantidad) values (pidFn,pIdFl,pIdMt,cont,pIdCt);
      END IF; -- ELSE INSERTAR ENFERMERIA

      -- AQUI SE VA INSERTAR TAMBIEN EN EL ALMACEN
      select into alm_cns cns from epp.det_mov_nvo_epp_alm order by cns desc limit 1;

      IF NOT FOUND THEN
        insert into epp.det_mov_nvo_epp_alm(id_finca,folio,id_material,cns,cantidad,alm_destino) values (pidFn,pIdFl,pIdMt,cont,pIdCt,PidWhX2.id_almacen);
      ELSE
        tnoc := alm_cns.cns + 1;
        insert into epp.det_mov_nvo_epp_alm(id_finca,folio,id_material,cns,cantidad,alm_destino) values (pidFn,pIdFl,pIdMt,tnoc,pIdCt,PidWhX2.id_almacen);
      END IF; -- ELSE INSERTAR ALMACEN
      
    ELSE
      raise notice 'SI ES GAFETE';
      update epp.movimiento_epp set estado_epp = 3 where id_finca = pIdFn and id_trab = pIdTr and folio = pIdFl and id_material = pIdMt;
      
      select into cns_epp cns from epp.det_mov_nvo_epp_enf order by cns desc limit 1;
    
      IF NOT FOUND THEN
        insert into epp.det_mov_nvo_epp_enf(id_finca,folio,id_material,cns,cantidad) values (pidFn,pIdFl,pIdMt,cont,pIdCt);
      ELSE
        cont := cns_epp.cns + 1;
        insert into epp.det_mov_nvo_epp_enf(id_finca,folio,id_material,cns,cantidad) values (pidFn,pIdFl,pIdMt,cont,pIdCt);
      END IF; -- ELSE INSERTAR ENFERMERIA
    END IF; -- ELSE VALIDACION GAFETE
  END IF; -- IF NUEVO INGRESO
  
  IF pIdRx = 2 THEN 
  raise notice 'PRESTAMO';
    select into cns_epp cns from epp.det_mov_presta_epp_enf order by cns desc limit 1;
    
    IF NOT FOUND THEN
    insert into epp.det_mov_presta_epp_enf(id_finca,folio,id_material,cns,cantidad) values (pidFn,pIdFl,pIdMt,cont,pIdCt);
    ELSE
      cont := cns_epp.cns + 1;
      insert into epp.det_mov_presta_epp_enf(id_finca,folio,id_material,cns,cantidad) values (pidFn,pIdFl,pIdMt,cont,pIdCt);
    END IF; -- ELSE INSERTAR ENFERMERIA
    
    -- AQUI SE VA INSERTAR TAMBIEN EN EL ALMACEN
    select into alm_cns cns from epp.det_mov_presta_epp_alm order by cns desc limit 1;
    
    IF NOT FOUND THEN
      insert into epp.det_mov_presta_epp_alm(id_finca,folio,id_material,cns,cantidad,fecha_fin_presta,alm_destino) values (pidFn,pIdFl,pIdMt,cont,pIdCt,current_timestamp(0) + '36 HOUR',PidWhX2.id_almacen);
    ELSE
      tnoc := alm_cns.cns + 1;
      insert into epp.det_mov_presta_epp_alm(id_finca,folio,id_material,cns,cantidad,fecha_fin_presta,alm_destino) values (pidFn,pIdFl,pIdMt,tnoc,pIdCt,current_timestamp(0) + '+36 HOUR',PidWhX2.id_almacen);
    END IF; -- ELSE INSERTAR ALMACEN
  END IF; -- IF REGISTROS PRESTAMOS
  
  IF pIdRx = 3 THEN 
  raise notice 'REPOSICION';
    
    IF pIdGf = 1 THEN
      raise notice 'NO ES GAFETE';
      select into cns_epp cns from epp.det_mov_repo_epp_enf order by cns desc limit 1;
    
      IF NOT FOUND THEN
        insert into epp.det_mov_repo_epp_enf(id_finca,folio,id_material,cns,cantidad) values (pidFn,pIdFl,pIdMt,cont,pIdCt);
      ELSE
        cont := cns_epp.cns + 1;
        insert into epp.det_mov_repo_epp_enf(id_finca,folio,id_material,cns,cantidad) values (pidFn,pIdFl,pIdMt,cont,pIdCt);
      END IF; -- ELSE INSERTAR ENFERMERIA
      
      -- AQUI SE VA INSERTAR TAMBIEN EN EL ALMACEN
      select into alm_cns cns from epp.det_mov_repo_epp_alm order by cns desc limit 1;

      IF NOT FOUND THEN
        insert into epp.det_mov_repo_epp_alm(id_finca,folio,id_material,cns,cantidad,alm_destino) values (pidFn,pIdFl,pIdMt,cont,pIdCt,PidWhX2.id_almacen);
      ELSE
        tnoc := alm_cns.cns + 1;
        insert into epp.det_mov_repo_epp_alm(id_finca,folio,id_material,cns,cantidad,alm_destino) values (pidFn,pIdFl,pIdMt,tnoc,pIdCt,PidWhX2.id_almacen);
      END IF; -- ELSE INSERTAR ALMACEN
    ELSE -- SI ES GAFETE
      raise notice 'SI ES GAFETE';
      update epp.movimiento_epp set estado_epp = 3 where id_finca = pIdFn and id_trab = pIdTr and folio = pIdFl and id_material = pIdMt;
      
      select into cns_epp cns from epp.det_mov_repo_epp_enf order by cns desc limit 1;
    
      IF NOT FOUND THEN
        insert into epp.det_mov_repo_epp_enf(id_finca,folio,id_material,cns,cantidad) values (pidFn,pIdFl,pIdMt,cont,pIdCt);
      ELSE
        cont := cns_epp.cns + 1;
        insert into epp.det_mov_repo_epp_enf(id_finca,folio,id_material,cns,cantidad) values (pidFn,pIdFl,pIdMt,cont,pIdCt);
      END IF; -- ELSE INSERTAR ENFERMERIA
    END IF; -- ELSE VALIDACION GAFETE
  END IF; -- IF REGISTROS REPOSICION
  
  IF pIdRx = 5 THEN 
  raise notice 'BAJA EPP';
    update epp.movimiento_epp set estado_epp = 1 where id_finca = pIdFn and id_trab = pIdTr and folio = pIdFl and id_material = pIdMt;
      
    select into cns_epp cns from epp.det_mov_baja_epp_enf order by cns desc limit 1;
    
    IF NOT FOUND THEN
    insert into epp.det_mov_baja_epp_enf(id_finca,folio,id_material,cns,cantidad,tipo_baja) values (pidFn,pIdFl,pIdMt,cont,pIdCt,pidBj);
    ELSE
      cont := cns_epp.cns + 1;
      insert into epp.det_mov_baja_epp_enf(id_finca,folio,id_material,cns,cantidad,tipo_baja) values (pidFn,pIdFl,pIdMt,cont,pIdCt,pidBj);
    END IF; -- ELSE INSERTAR ENFERMERIA
    
    -- AQUI SE VA INSERTAR TAMBIEN EN EL ALMACEN
    select into alm_cns cns from epp.det_mov_baja_epp_alm order by cns desc limit 1;
    
    IF NOT FOUND THEN
      insert into epp.det_mov_baja_epp_alm(id_finca,folio,id_material,cns,cantidad,tipo_baja,alm_destino) values (pidFn,pIdFl,pIdMt,cont,pIdCt,pidBj,PidWhX2.id_almacen);
    ELSE
      tnoc := alm_cns.cns + 1;
      insert into epp.det_mov_baja_epp_alm(id_finca,folio,id_material,cns,cantidad,tipo_baja,alm_destino) values (pidFn,pIdFl,pIdMt,cont,pIdCt,pidBj,PidWhX2.id_almacen);
    END IF; -- ELSE INSERTAR ALMACEN
  END IF; -- IF REGISTROS PRESTAMOS
  
  RETURN vresult; -- resultado
  
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- FUNCION P/COMPARAR LABORES Y EVITAR REPETIR MATERIAL
drop function epp.cambio_labor(varchar,varchar,integer); -- 14
create or replace function epp.cambio_labor(varchar,varchar,integer) returns setof record as $$

declare
  pidTb   alias for $1; -- id_trabajador
  pidFn   alias for $2; -- nombre_finca
  pidEf   alias for $3; -- id_enfermera
  
  folio_dev_x_camb   varchar; -- folio dev x cambio
  
  res  record; -- materiales actuales (1)
  ser  record; -- materiales nuevos   (2)
  trsp record; -- generar dev x labor (3)
  det_mov      RECORD;
  
  camb record; -- (1)
  bmac record; -- (2)
  psrt record; -- (3)
begin
  
  create temporary table cambio( -- TABLA TEMPORAL P/ALMACENAMIENTO
    clave varchar primary key,
    material varchar,
    cantidad numeric(10,3),
    unidad varchar
  ) on commit drop;
  
  RAISE NOTICE 'folio cambio inicial:  %', folio_dev_x_camb;
  
   -- ANALIZANDO LOS MATERIALES ACTUALES ACTIVOS EN USO -- 1 
    for trsp in SELECT DISTINCT A.ID_ALMACEN,A.nombre_almacen as almacen,f.id_finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,w.id_material,w.clave,w.nombre_material,d.cantidad,u.nombre_unidad_medida as um 
      FROM  EPP.MOVIMIENTO_EPP M 
      INNER JOIN FINCAS F ON M.ID_FINCA = F.ID_FINCA
      INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
      INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
      INNER JOIN ALMACEN.MATERIALES W ON M.ID_MATERIAL = W.ID_MATERIAL
      INNER JOIN ALMACEN.DETALLE_MATERIALES_LABOR D ON D.ID_MATERIAL = W.ID_MATERIAL
      INNER JOIN ALMACEN.UNIDAD_MEDIDA U ON W.ID_UNIDAD_MEDIDA = U.ID_UNIDAD_MEDIDA
      INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = M.ALM_DESTINO
      WHERE M.ESTADO_EPP = 1 AND T.ID_TRAB = pIdTb AND F.NOMBRE_FINCA = pIdFn loop -- OBTIENE LOS MATERIALES ANTIGUOS *
    
     PERFORM epp.obt_folio_cambio(pidFn);
     folio_dev_x_camb := epp.obt_folio_cambio(pidFn); -- igualando el resultado de la funcion en folio
     RAISE NOTICE 'folio cambio %', folio_dev_x_camb;
     raise notice 'folio insertado';
 
      select into det_mov *from epp.movimiento_epp where id_finca = trsp.id_finca and id_trab = trsp.id_trab and folio = folio_dev_x_camb and id_material = trsp.id_material;
   
      IF NOT FOUND THEN
        raise notice 'NO TIENE DATOS';
        insert into epp.movimiento_epp (id_finca,folio,id_material,id_trab,id_tipo_mov_epp,estado_epp,id_enfermera,alm_destino) values (trsp.id_finca,folio_dev_x_camb,trsp.id_material,trsp.id_trab,6,1,pidEf,trsp.id_almacen);    
      END IF;  -- IF INSERTANDO EN MOVIMIENTOS
  
  
      select into psrt *from epp.dev_x_cambio_labor where id_trab = trsp.id_trab and id_material = trsp.id_material and entregado = false;
      
      if not found then
        RAISE NOTICE 'trsp %', trsp;
        insert into epp.dev_x_cambio_labor values (trsp.id_finca,folio_dev_x_camb,trsp.id_material,trsp.clave,trsp.cantidad,trsp.um,trsp.id_trab,trsp.id_almacen);
        
      /*  raise notice 'folio insertado en nvo alm';
        update EPP.DET_MOV_NVO_EPP_ALM set folio_dev = folio_dev_x_camb where id_finca = trsp.id_finca and folio = trsp.folio and id_material = trsp.id_material; */
      else
        RAISE NOTICE 'eliminar trsp = %', trsp;
        -- delete from cambio where clave = res.clave;
        delete from epp.movimiento_epp where id_finca = trsp.id_finca and id_material = trsp.id_material and id_trab = pidTb and folio = folio_dev_x_camb;
        
        DELETE FROM epp.cntrl_folio_cambio where id_folio = 1 and folio = folio_dev_x_camb;
      end if; -- else validacion existencia
  end loop; -- loop trsp  
    
  -- BUSCANDO MATERIALES ENTREGADOS EN LABOR ANTERIOR REPETIDOS CON LA NUEVA -- 2
  for res in SELECT DISTINCT w.clave, w.nombre_material, d.cantidad, u.nombre_unidad_medida as um 
    FROM EPP.MOVIMIENTO_EPP M 
    INNER JOIN FINCAS F ON M.ID_FINCA = F.ID_FINCA
    INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
    INNER JOIN LABOR L ON T.ID_LABOR = L.ID_LABOR
    INNER JOIN ALMACEN.DETALLE_MATERIALES_LABOR D ON L.ID_LABOR = D.ID_LABOR
    INNER JOIN ALMACEN.MATERIALES W ON D.ID_MATERIAL = W.ID_MATERIAL AND M.ID_MATERIAL = W.ID_MATERIAL
    INNER JOIN ALMACEN.UNIDAD_MEDIDA U ON W.ID_UNIDAD_MEDIDA = U.ID_UNIDAD_MEDIDA
    INNER JOIN CARGO C ON T.ID_CARGO = C.ID_CARGO
    INNER JOIN AREA_TRABAJO A ON T.ID_AREA_TRABAJO = A.ID_AREA_TRABAJO
    INNER JOIN TIPO_TRABAJADOR V ON L.ID_TIPO_TRAB = V.ID_TIPO_TRAB
    WHERE M.ESTADO_EPP = 1 AND T.ID_TRAB = pIdTb AND F.NOMBRE_FINCA = pIdFn loop -- MATERIALES ANTIGUOS REPETIDOS 
       
    select into bmac *from cambio where clave = res.clave;
      
      if not found then
        RAISE NOTICE 'res %', res;
        execute format('insert into %I values (%L,%L,%L,%L)', 'cambio', res.clave,res.nombre_material,res.cantidad,res.um);
      else
        RAISE NOTICE 'eliminar res = %', res;
        delete from cambio where clave = res.clave;
      end if; -- else validacion existencia
    end loop; -- end loop res
  
    -- MATERIALES EN LABOR NUEVA -- 3
    for ser in select m.id_material, m.clave, m.nombre_material, d.cantidad, u.nombre_unidad_medida as um,f.id_finca FROM public.trabajadores t, public.labor l, almacen.detalle_materiales_labor d, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v WHERE t.id_labor = l.id_labor and l.id_labor = d.id_labor and d.id_material = m.id_material and m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and t.id_trab = pIdTb and f.nombre_finca = pIdFn loop -- OBTIENE MATERIALES NUEVOS

      select into camb *from cambio where clave = ser.clave;
      RAISE NOTICE 'camb %', camb;
      RAISE NOTICE 'folio cambio %', folio_dev_x_camb;
      
      if not found then
        RAISE NOTICE 'ser %', ser;
        execute format('insert into %I values (%L,%L,%L,%L)', 'cambio', ser.clave,ser.nombre_material,ser.cantidad,ser.um);
      else
        RAISE NOTICE 'eliminar ser = %', ser;
        delete from cambio where clave = ser.clave; -- eliminando los materiales repetidos
        delete from epp.dev_x_cambio_labor where clave = ser.clave and id_trab = pidTb and entregado = false;
        delete from epp.movimiento_epp where id_material = ser.id_material and id_trab = pidTb and folio = folio_dev_x_camb and id_finca = ser.id_finca;
        
        DELETE FROM epp.cntrl_folio_cambio where id_folio = 1 and folio = folio_dev_x_camb;
      end if;-- else if validacion existencia
    end loop; -- end loop ser
       
  return query select * from cambio; -- retorna consulta c/materiales a entregar
  
  RETURN; -- retorna los valores de la tabla
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- FUNCION P/COMPARAR LABORES Y EVITAR REPETIR MATERIAL
drop function epp.presta_labor(varchar,varchar,varchar); -- 15
create or replace function epp.presta_labor(varchar,varchar,varchar) returns setof record as $$

declare
  pidTb   alias for $1; -- id_trabajador
  pidFn   alias for $2; -- nombre_finca
  pidLb   alias for $3; -- nombre_finca
  
  res  record; -- materiales actuales (1)
  ser  record; -- materiales nuevos   (2)
  
  camb record; -- (1)
  bmac record; -- (2)
 
begin
  
  create temporary table presta( -- TABLA TEMPORAL P/ALMACENAMIENTO
    clave varchar primary key,
    material varchar,
    cantidad numeric(10,3),
    unidad varchar
  ) on commit drop;
    
    -- MATERIALES EN LABOR NUEVA (PRESTAMO)
    for ser in SELECT L.NOMBRE_LABOR,M.CLAVE,M.NOMBRE_MATERIAL,D.CANTIDAD,U.NOMBRE_UNIDAD_MEDIDA AS UM,M.ID_MATERIAL FROM ALMACEN.DETALLE_MATERIALES_LABOR D INNER JOIN PUBLIC.LABOR L ON L.ID_LABOR = D.ID_LABOR INNER JOIN ALMACEN.MATERIALES M ON M.ID_MATERIAL = D.ID_MATERIAL INNER JOIN ALMACEN.UNIDAD_MEDIDA U ON U.ID_UNIDAD_MEDIDA = M.ID_UNIDAD_MEDIDA WHERE L.NOMBRE_LABOR = pIdLb loop -- OBTIENE MATERIALES NUEVOS

      select into camb *from presta where clave = ser.clave;
     
      if not found then
        RAISE NOTICE 'ser %', ser;
        RAISE NOTICE 'LABORES P/PRESTAMO';
        execute format('insert into %I values (%L,%L,%L,%L)', 'presta', ser.clave,ser.nombre_material,ser.cantidad,ser.um);
      else
        RAISE NOTICE 'eliminar ser = %', ser;
      end if;-- else if validacion existencia
    end loop; -- end loop ser
    
    -- BUSCANDO MATERIALES ENTREGADOS EN LABOR ANTERIOR REPETIDOS CON LA NUEVA
    for res in select m.clave, m.nombre_material, d.cantidad, u.nombre_unidad_medida as um FROM public.trabajadores t, public.labor l, almacen.detalle_materiales_labor d, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v WHERE t.id_labor = l.id_labor and l.id_labor = d.id_labor and d.id_material = m.id_material and m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and t.id_trab = pIdTb and f.nombre_finca = pIdFn loop -- MATERIALES ACTUALES DE LABOR 
      
      select into bmac *from presta where clave = res.clave;
      
      if not found then
        RAISE NOTICE 'res %', res;
        RAISE NOTICE 'LABORES ACTUALES';
        execute format('insert into %I values (%L,%L,%L,%L)', 'presta', res.clave,res.nombre_material,res.cantidad,res.um);
      else
        RAISE NOTICE 'eliminar res = %', res;
       delete from presta where clave = res.clave;
      end if; -- else validacion existencia
      
      delete from presta where clave = res.clave; -- eliminar materiales de labor original de todos modos
   
    end loop; -- end loop res
      
  return query select * from presta; -- retorna consulta c/materiales a entregar
  
  RETURN; -- retorna los valores de la tabla
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el almacenamiento de equipos de gafetes vst ----------------------------
drop function epp.epp_gft_vst(integer,integer,integer,integer,numeric(10,3),varchar,integer,integer); -- 16
create or replace function epp.epp_gft_vst(integer,integer,integer,integer,numeric(10,3),varchar,integer,integer) returns integer as $$
declare

  pidFn   alias for $1; -- id_finca
  pIdMt   alias for $2; -- id_material
  pIdRx   alias for $3; -- id_tipo_mov_epp
  pIdZg   alias for $4; -- id_enfermera
  pIdCt   alias for $5; -- cantidad material
  pIdFl   alias for $6; -- folio
  pIdGf   alias for $7; -- validacion Gafete (1.- COBRO, 2.- REPO)
  pIdAr   alias for $8; -- id_area_trabajo
  
  vresult      integer;
  cont         integer;
  det_mov      RECORD;
  cns_epp      RECORD;
  monto        RECORD;
  
BEGIN
  
  vresult := 1;
  cont := 1; -- CONTADOR DE MOV ENFERMERIA
  
  -- Buscando el detalle de movimientos
  select into det_mov *from epp.mov_gft_vst where id_finca = pIdFn and id_material = pIdMt and folio = pIdFl;
   
  IF NOT FOUND THEN
    raise notice 'NO TIENE DATOS';
    insert into epp.mov_gft_vst (id_finca,folio,id_material,cantidad,id_tipo_mov_epp,id_enfermera) values (pidFn,pIdFl,pIdMt,pIdCt,pIdRx,pIdZg);    
  END IF;  -- IF INSERTANDO EN MOVIMIENTOS
  
  IF pIdRx = 1 THEN 
  raise notice 'NUEVO INGRESO GFT VST';
    select into cns_epp cns from epp.det_mov_nvo_gft_vst order by cns desc limit 1;
    
    IF NOT FOUND THEN
    insert into epp.det_mov_nvo_gft_vst(id_finca,folio,id_material,id_area_trabajo,cns,cantidad) values (pidFn,pIdFl,pIdMt,pIdAr,cont,pIdCt);
    ELSE
      cont := cns_epp.cns + 1;
      insert into epp.det_mov_nvo_gft_vst(id_finca,folio,id_material,id_area_trabajo,cns,cantidad) values (pidFn,pIdFl,pIdMt,pIdAr,cont,pIdCt);
    END IF; -- ELSE INSERTAR NVO GFT VST
  END IF; -- IF REGISTROS NUEVO INGRESO GFT VST
  
  select into monto id_material,costo_reposicion_epp from almacen.materiales where id_material = pIdMt;
  raise notice 'MATE: %', monto;

  IF pIdRx = 4 THEN -- TIPO GAFETE
    raise notice 'REPOSICIONES';
    
    IF pIdGf = 1 THEN
      raise notice 'CON COBRO';
      select into cns_epp cns from epp.cobros_gft_vst order by cns desc limit 1;

      IF NOT FOUND THEN
        insert into epp.cobros_gft_vst(id_finca,folio,id_material,id_area_trabajo,cns,cantidad,monto,tipo_cobro) values (pidFn,pIdFl,pIdMt,pIdAr,cont,pIdCt,(pIdCt * monto.costo_reposicion_epp),'GAFETE');
      ELSE
        cont := cns_epp.cns + 1;
        insert into epp.cobros_gft_vst(id_finca,folio,id_material,id_area_trabajo,cns,cantidad,monto,tipo_cobro) values (pidFn,pIdFl,pIdMt,pIdAr,cont,pIdCt,(pIdCt * monto.costo_reposicion_epp),'GAFETE');
      END IF; -- ELSE INSERTAR COBROS GFT VST
      
    ELSE
      raise notice 'REPOSICION';
      select into cns_epp cns from epp.reposiciones_gft_vst order by cns desc limit 1;
    
      IF NOT FOUND THEN
        insert into epp.reposiciones_gft_vst(id_finca,folio,id_material,id_area_trabajo,cns,cantidad,monto,tipo_cobro) values (pidFn,pIdFl,pIdMt,pIdAr,cont,pIdCt,0.00,'GAFETE');
      ELSE
        cont := cns_epp.cns + 1;
        insert into epp.reposiciones_gft_vst(id_finca,folio,id_material,id_area_trabajo,cns,cantidad,monto,tipo_cobro) values (pidFn,pIdFl,pIdMt,pIdAr,cont,pIdCt,0.00,'GAFETE');
      END IF; -- ELSE INSERTAR REPO GFT VST
    END IF; -- ELSE VALIDACION COBRO
  END IF; -- IF TIPO GFT 4
  
  RETURN vresult;
  
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de reposiciones (gft) vst ----------------------------
drop function epp.rep_reposiciones_gft_vst(integer,varchar,date,date); -- 17 
create or replace function epp.rep_reposiciones_gft_vst(integer,varchar,date,date) returns setof record as $$
declare
  pidFn   alias for $1; -- id_finca
  pIdTc   alias for $2; -- tipo repo (daño/extravio)
  pIdFi   alias for $3; -- fecha_inicio
  pIdFx   alias for $4; -- fecha_fin

  vresult        integer; -- resultado
  cobro_det      RECORD; -- valores: cobros CON FINCA
  cobro_detwx    RECORD; -- valores: cobros SIN FINCA
  repo_det       RECORD; -- valores: reposiciones CON FINCA
  repo_detwx     RECORD; -- valores: reposiciones SIN FINCA
  
  cobrowx CURSOR(pIdFi date,pIdfx date) FOR 
    SELECT F.NOMBRE_FINCA,C.FOLIO,T.NOMBRE_AREA_TRABAJO as area,C.FECHA,C.CANTIDAD,X.COSTO_REPOSICION_EPP AS COSTO_UNIT,C.MONTO
    FROM epp.mov_gft_vst M 
    INNER JOIN epp.cobros_gft_vst C ON C.FOLIO = M.FOLIO AND C.ID_MATERIAL = M.ID_MATERIAL AND C.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND C.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.AREA_TRABAJO T ON C.ID_AREA_TRABAJO = T.ID_AREA_TRABAJO
    INNER JOIN ALMACEN.MATERIALES X ON C.ID_MATERIAL = X.ID_MATERIAL AND M.ID_MATERIAL = X.ID_MATERIAL
    WHERE (C.fecha::date between pIdFi and pIdFx); -- CURSOR P/COBROS SIN FINCA
  
  cobro CURSOR(pIdFn integer, pIdFi date,pIdfx date) FOR 
    SELECT F.NOMBRE_FINCA,C.FOLIO,T.NOMBRE_AREA_TRABAJO as area,C.FECHA,C.CANTIDAD,X.COSTO_REPOSICION_EPP AS COSTO_UNIT,C.MONTO
    FROM epp.mov_gft_vst M 
    INNER JOIN epp.cobros_gft_vst C ON C.FOLIO = M.FOLIO AND C.ID_MATERIAL = M.ID_MATERIAL AND C.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND C.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.AREA_TRABAJO T ON C.ID_AREA_TRABAJO = T.ID_AREA_TRABAJO
    INNER JOIN ALMACEN.MATERIALES X ON C.ID_MATERIAL = X.ID_MATERIAL AND M.ID_MATERIAL = X.ID_MATERIAL
    WHERE C.ID_FINCA = pIdFn and (C.fecha::date between pIdFi and pIdFx); -- CURSOR P/REPO CON FINCA
    
  repowx CURSOR(pIdFi date,pIdfx date) FOR 
    SELECT F.NOMBRE_FINCA,C.FOLIO,T.NOMBRE_AREA_TRABAJO as area,C.FECHA,C.CANTIDAD,X.COSTO_REPOSICION_EPP AS COSTO_UNIT,C.MONTO
    FROM epp.mov_gft_vst M 
    INNER JOIN epp.reposiciones_gft_vst C ON C.FOLIO = M.FOLIO AND C.ID_MATERIAL = M.ID_MATERIAL AND C.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND C.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.AREA_TRABAJO T ON C.ID_AREA_TRABAJO = T.ID_AREA_TRABAJO
    INNER JOIN ALMACEN.MATERIALES X ON C.ID_MATERIAL = X.ID_MATERIAL AND M.ID_MATERIAL = X.ID_MATERIAL
    WHERE (C.fecha::date between pIdFi and pIdFx); -- CURSOR P/REPO SIN FINCA
  
  repo CURSOR(pIdFn integer, pIdFi date,pIdfx date) FOR 
    SELECT F.NOMBRE_FINCA,C.FOLIO,T.NOMBRE_AREA_TRABAJO as area,C.FECHA,C.CANTIDAD,X.COSTO_REPOSICION_EPP AS COSTO_UNIT,C.MONTO
    FROM epp.mov_gft_vst M 
    INNER JOIN epp.reposiciones_gft_vst C ON C.FOLIO = M.FOLIO AND C.ID_MATERIAL = M.ID_MATERIAL AND C.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND C.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.AREA_TRABAJO T ON C.ID_AREA_TRABAJO = T.ID_AREA_TRABAJO
    INNER JOIN ALMACEN.MATERIALES X ON C.ID_MATERIAL = X.ID_MATERIAL AND M.ID_MATERIAL = X.ID_MATERIAL
    WHERE C.ID_FINCA = pIdFn and (C.fecha::date between pIdFi and pIdFx); -- CURSOR P/COBROS CON FINCA
 
BEGIN

  CREATE TEMPORARY TABLE rep_reposiciones_gft_vst( -- ELIMINADO
    finca varchar, -- nombre finca
    folio varchar, -- folio de reposicion
    area varchar, -- area donde proviene el gafete
    fecha date default current_date, -- fecha 
    cant_gft numeric(10,3), -- total de gafetes
    costo_unit numeric(10,3), -- costo por gafete
    monto_total numeric(10,3), -- monto asignado
    tipo_cobro varchar default 'GAFETE VISITANTE', -- tipo (gft)
    movimiento varchar -- (daño/extravio)
  ) on commit drop;
  
  
  IF pIdFn = 0 THEN -- TODAS LAS FINCAS
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open cobrowx(pIdFi,pIdfx);
      LOOP
        FETCH cobrowx into cobro_detwx; -- obtenemos valores del cursor
          raise notice 'cobro_detwx: %', cobro_detwx;

          EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

          IF pIdTc = 'TODOS' THEN -- REPORTE GENERAL DE TODOS LOS TIPOS
            raise notice 'TRABAJADOR NULL REP';
            
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_reposiciones_gft_vst', cobro_detwx.NOMBRE_FINCA,cobro_detwx.folio,cobro_detwx.area,cobro_detwx.FECHA::DATE,cobro_detwx.cantidad,cobro_detwx.costo_unit,cobro_detwx.monto,'GAFETE','EXTRAVIO');  
          END IF; -- IF VALIDACION TODOS

          IF pIdTc = 'EXTRAVIO' THEN -- SI PASA DATOS DE COBRO   
            raise notice 'SI PASA DATOS DEL COBRO REP';
            
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_reposiciones_gft_vst', cobro_detwx.NOMBRE_FINCA,cobro_detwx.folio,cobro_detwx.area,cobro_detwx.FECHA::DATE,cobro_detwx.cantidad,cobro_detwx.costo_unit,cobro_detwx.monto,'GAFETE','EXTRAVIO');  
          END IF; -- ELSE VALIDACION DE EXTRAVIO
      END LOOP;  -- LOOP DE REPOSICION  
    close cobrowx; -- CIERRA CURSOR REPOSICION
     
    open repowx(pIdFi,pIdfx);
      LOOP
        FETCH repowx into repo_detwx; -- obtenemos valores del cursor
          raise notice 'repo_detwx: %', repo_detwx;

          EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

          IF pIdTc = 'TODOS' THEN -- REPORTE GENERAL DE TODOS LOS TIPOS
            raise notice 'TRABAJADOR NULL REP';
            
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_reposiciones_gft_vst',  repo_detwx.NOMBRE_FINCA,repo_detwx.folio,repo_detwx.area,repo_detwx.FECHA::DATE,repo_detwx.cantidad,repo_detwx.costo_unit,repo_detwx.monto,'GAFETE','DETERIORO');   
          END IF; -- IF VALIDACION TODOS

          IF pIdTc = 'DETERIORO' THEN -- SI PASA DATOS DE COBRO   
            raise notice 'SI PASA DATOS DEL REPO REP';
            
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_reposiciones_gft_vst', repo_detwx.NOMBRE_FINCA,repo_detwx.folio,repo_detwx.area,repo_detwx.FECHA::DATE,repo_detwx.cantidad,repo_detwx.costo_unit,repo_detwx.monto,'GAFETE','DETERIORO');    
          END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
      END LOOP;  -- LOOP DE REPOSICION  
    close REPowx; -- CIERRA CURSOR REPOSICION

  ELSE -- VALIDACION SI PASA DATOS DE FINCA
    open cobro(pIdFn,pIdFi,pIdfx);
      LOOP
        FETCH cobro into cobro_det; -- obtenemos valores del cursor
          raise notice 'cobro_det: %', cobro_det;

          EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

          IF pIdTc = 'TODOS' THEN -- REPORTE GENERAL DE TODOS LOS TIPOS
            raise notice 'TRABAJADOR NULL REP';
           
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_reposiciones_gft_vst', cobro_det.NOMBRE_FINCA,cobro_det.folio,cobro_det.area,cobro_det.FECHA::DATE,cobro_det.cantidad,cobro_det.costo_unit,cobro_det.monto,'GAFETE','EXTRAVIO');   
          END IF; -- IF VALIDACION TODOS
          
          IF pIdTc = 'EXTRAVIO' THEN -- SI PASA DATOS DE COBRO   
            raise notice 'SI PASA DATOS DEL COBRO REP';
            
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_reposiciones_gft_vst', cobro_det.NOMBRE_FINCA,cobro_det.folio,cobro_det.area,cobro_det.FECHA::DATE,cobro_det.cantidad,cobro_det.costo_unit,cobro_det.monto,'GAFETE','EXTRAVIO');
          END IF; -- ELSE VALIDACION DE TODOS EXTRAVIO
        END LOOP;  -- LOOP DE REPOSICION  
    close cobro; -- CIERRA CURSOR REPOSICION
     
     open repo(pIdFn,pIdFi,pIdfx);
      LOOP
        FETCH repo into repo_det; -- obtenemos valores del cursor
          raise notice 'repo_det: %', repo_det;

          EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

          IF pIdTc = 'TODOS' THEN -- REPORTE GENERAL DE TODOS LOS TIPOS
            raise notice 'TRABAJADOR NULL REP';
            
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_reposiciones_gft_vst', repo_det.NOMBRE_FINCA,repo_det.folio,repo_det.area,repo_det.FECHA::DATE,repo_det.cantidad,repo_det.costo_unit,repo_det.monto,'GAFETE','DETERIORO');  
          END IF; -- IF VALIDACION TODOS
          
          IF pIdTc = 'DETERIORO' THEN -- SI PASA DATOS DE COBRO   
            raise notice 'SI PASA DATOS DEL REPO REP';
            
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_reposiciones_gft_vst', repo_det.NOMBRE_FINCA,repo_det.folio,repo_det.area,repo_det.FECHA::DATE,repo_det.cantidad,repo_det.costo_unit,repo_det.monto,'GAFETE','DETERIORO');     
          END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
        END LOOP;  -- LOOP DE REPOSICION  
     close repo; -- CIERRA CURSOR REPOSICION
  END IF; -- ELSE IF VALIDACION TODAS LAS FINCAS 
  return query select * from rep_reposiciones_gft_vst; -- retorna consulta c/materiales a entregar
RETURN;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de reposiciones_ detallado con vigilantes (gft) vst ---------------------------
drop function epp.det_rep_gft_vst(varchar,varchar); -- 18
create or replace function epp.det_rep_gft_vst(varchar,varchar) returns setof record as $$
declare
  pidFl   alias for $1; -- folio MOV
  pidNf   alias for $2; -- NOMBRE_FINCA 
  
  vresult      integer; -- resultado
  cont         INTEGER; -- valores: cobros CON FINCA
  cobro_detwx  RECORD; -- valores: cobros SIN FINCA
  repo_detwx   RECORD; -- valores: reposiciones SIN FINCA
  
  cobro CURSOR(pIdFl varchar) FOR 
    SELECT F.NOMBRE_FINCA,C.FOLIO,T.NOMBRE_AREA_TRABAJO as area,C.FECHA::DATE,C.CANTIDAD::integer,X.COSTO_REPOSICION_EPP AS COSTO_UNIT,C.MONTO,W.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,W.id_tipo_trab
    FROM epp.mov_gft_vst M 
    INNER JOIN epp.cobros_gft_vst C ON C.FOLIO = M.FOLIO AND C.ID_MATERIAL = M.ID_MATERIAL AND C.ID_FINCA = M.ID_FINCA
    INNER JOIN TRABAJADORES W ON W.ID_TRAB = W.ID_TRAB
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND C.ID_FINCA = F.ID_FINCA AND f.id_finca = W.id_finca
    inner join tipo_trabajador p on W.id_tipo_trab = p.id_tipo_trab
    INNER JOIN PUBLIC.AREA_TRABAJO T ON C.ID_AREA_TRABAJO = T.ID_AREA_TRABAJO
    INNER JOIN ALMACEN.MATERIALES X ON C.ID_MATERIAL = X.ID_MATERIAL AND M.ID_MATERIAL = X.ID_MATERIAL
    WHERE C.FOLIO = pIdFl and  W.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES'; -- CURSOR P/COBRO CON FINCA
    
  repo CURSOR(pIdFl varchar) FOR 
    SELECT F.NOMBRE_FINCA,C.FOLIO,T.NOMBRE_AREA_TRABAJO as area,C.FECHA::DATE,C.CANTIDAD::integer,X.COSTO_REPOSICION_EPP AS COSTO_UNIT,C.MONTO,W.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,W.id_tipo_trab
    FROM epp.mov_gft_vst M 
    INNER JOIN epp.reposiciones_gft_vst C ON C.FOLIO = M.FOLIO AND C.ID_MATERIAL = M.ID_MATERIAL AND C.ID_FINCA = M.ID_FINCA
    INNER JOIN TRABAJADORES W ON W.ID_TRAB = W.ID_TRAB
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND C.ID_FINCA = F.ID_FINCA AND f.id_finca = W.id_finca
    inner join tipo_trabajador p on W.id_tipo_trab = p.id_tipo_trab
    INNER JOIN PUBLIC.AREA_TRABAJO T ON C.ID_AREA_TRABAJO = T.ID_AREA_TRABAJO
    INNER JOIN ALMACEN.MATERIALES X ON C.ID_MATERIAL = X.ID_MATERIAL AND M.ID_MATERIAL = X.ID_MATERIAL
    WHERE C.FOLIO = pIdFl and W.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES'; -- CURSOR P/REPOS CON FINCA
 
BEGIN

CREATE TEMPORARY TABLE det_rep_gft_vst(
  finca varchar, -- nombre finca
  id_trab varchar, -- id de trabajador
  nombre_t varchar, -- nombre de trabajador
  folio varchar, -- folio de reposicion
  area varchar, -- area donde proviene el gafete
  fecha date, -- fecha
  cant_gft integer,  -- total de gafetes
  costo_unit numeric(10,3), -- costo por gafete
  tot_vigilantes integer, -- vigilantes en finca
  monto_indiv numeric(10,3), -- monto x vigilante
  tipo_cobro varchar, -- tipo (gft)
  movimiento varchar -- (daño/extravio)
) on commit drop;
  
  select into cont COUNT(*) from trabajadores t inner join tipo_trabajador p on t.id_tipo_trab = p.id_tipo_trab inner join fincas f on f.id_finca = t.id_finca where t.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES' and F.nombre_finca = pidNf;
  raise notice 'cont: %', cont;
        
    -- comenzar a correr el ciclo para detalle de REPOSICION:
  open cobro(pIdFl);
    LOOP
      FETCH cobro into cobro_detwx; -- obtenemos valores del cursor
        raise notice 'cobro_detwx: %', cobro_detwx;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'det_rep_gft_vst', cobro_detwx.NOMBRE_FINCA,cobro_detwx.id_trab,cobro_detwx.nombre_t,cobro_detwx.folio,cobro_detwx.area,cobro_detwx.FECHA::DATE,cobro_detwx.cantidad,cobro_detwx.costo_unit,cont,(cobro_detwx.monto / cont),'GAFETE','EXTRAVIO');  
          
    END LOOP;  -- LOOP DE REPOSICION  
  close cobro; -- CIERRA CURSOR REPOSICION
     
  open repo(pIdFl);
    LOOP
      FETCH repo into repo_detwx; -- obtenemos valores del cursor
        raise notice 'repo_detwx: %', repo_detwx;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

        -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'det_rep_gft_vst', repo_detwx.NOMBRE_FINCA,repo_detwx.id_trab,repo_detwx.nombre_t,repo_detwx.folio,repo_detwx.area,repo_detwx.FECHA::DATE,repo_detwx.cantidad,0.00,cont,0.00,'GAFETE','DETERIORO');
          
    END LOOP;  -- LOOP DE REPOSICION  
  close repo; -- CIERRA CURSOR REPOSICION

return query select * from det_rep_gft_vst; -- retorna consulta c/materiales a entregar

RETURN;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de reposiciones (gft/epp) ----------------------------
drop function epp.rep_presta(integer,varchar,date,date); -- 19
create or replace function epp.rep_presta(integer,varchar,date,date) returns setof record as $$
declare
  pidFn   alias for $1; -- id_finca
  pIdTr   alias for $2; -- id_trab 
  pIdFi   alias for $3; -- fecha_inicio
  pIdFx   alias for $4; -- fecha_fin

  vresult      integer; -- resultado
  rep_det      RECORD; -- valores: reposiciones 
  rep_detwx    RECORD; -- valores: reposiciones  todos
  cont_tot     integer; -- contador total de materiales
  cont_mat     integer; -- contador de materiales surtidos
  cont_dev     integer; -- contador de materiales devueltos
  estatus      VARCHAR; -- estado guardado x filtro
  devolucion   varchar; -- estado de devolucion
  
  reposwx CURSOR(pIdFi date,pIdfx date) FOR 
    SELECT DISTINCT F.NOMBRE_FINCA,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA_INI_PRESTA::DATE,E.FOLIO
    FROM epp.det_mov_presta_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE (E.fecha_ini_presta::date between pIdFi and PidFx); -- REPORTE CON FINCA
  
  repos CURSOR(pIdFn integer, pIdFi date,pIdfx date) FOR 
    SELECT DISTINCT F.NOMBRE_FINCA,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA_INI_PRESTA::DATE,E.FOLIO
    FROM epp.det_mov_presta_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE E.id_finca = pIdFn and (E.fecha_ini_presta::date between pIdFi and pIdFx); 
   
BEGIN
  
  CREATE TEMPORARY TABLE rep_presta(
    finca varchar, -- nombre finca
    id_trab varchar, -- id trabajador
    nom_t varchar, -- nombre de trabajador
    fecha date, -- fecha
    tipo text, -- tipo mov
    folio varchar, -- folio epp
    estado varchar, -- estatus surtido
    devolucion varchar -- estatus recepcion
  ) ON COMMIT DROP;

  IF pIdFn = 0 THEN -- TODAS LAS FINCAS
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open reposwx(pIdFi,pIdfx);
      LOOP
        FETCH reposwx into rep_detwx; -- obtenemos valores del cursor
        raise notice 'rep_detwx: %', rep_detwx;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        select into cont_tot COUNT(*) AS tot from epp.det_mov_presta_epp_alm WHERE folio = rep_detwx.folio;
        select into cont_mat COUNT(*) AS mat from epp.det_mov_presta_epp_alm E WHERE e.entregado = true and folio = rep_detwx.folio;
        select into cont_dev COUNT(*) AS mat from epp.det_mov_presta_epp_alm E WHERE e.recepcion = true and folio = rep_detwx.folio;
        raise notice 'TOTAL %,  MAT %,  DEV %', cont_tot, cont_mat, cont_dev;
        
        -- validacion de estados de surtido
        IF cont_tot = cont_mat THEN
            raise notice 'CONTADOR IGUAL ENTREGADO';
            estatus := 'SURTIDO';
          END IF;
          
          IF cont_tot > cont_mat THEN
            raise notice 'CONTADOR MAYOR ESTA PARCIAL';
            estatus := 'PARCIAL';
          END IF;
          
          IF cont_mat = 0 THEN
            raise notice 'CONTADOR MAT CERO PENDIENTE';
            estatus := 'PENDIENTE';
          END IF;
        
        -- validacion de estado de recepcion
        IF cont_tot = cont_dev THEN
            raise notice 'CONTADOR IGUAL ENTREGADO X';
            devolucion := 'COMPLETO';
          END IF;
          
          IF cont_tot > cont_dev THEN
            raise notice 'CONTADOR MAYOR ESTA PARCIAL X';
            devolucion := 'PARCIAL';
          END IF;
          
          IF cont_dev = 0 THEN
            raise notice 'CONTADOR MAT CERO PENDIENTE X';
            devolucion := 'PENDIENTE';
          END IF;
          
        IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
          raise notice 'TRABAJADOR NULL REP';
        
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_presta', rep_detwx.NOMBRE_FINCA,rep_detwx.ID_TRAB,rep_detwx.nombre_t,rep_detwx.FECHA_INI_PRESTA::DATE,'PRESTAMO',rep_detwx.folio,estatus,devolucion);   
        ELSE -- SI PASA DATOS DE TRABAJADOR 
            
          IF (rep_detwx.id_trab = pIdTr) THEN 
          raise notice 'SI PASA DATOS DEL TRABAJADOR REP';
          
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_presta', rep_detwx.NOMBRE_FINCA,rep_detwx.ID_TRAB,rep_detwx.nombre_t,rep_detwx.FECHA_INI_PRESTA::DATE,'PRESTAMO',rep_detwx.folio,estatus,devolucion);  
           END IF; -- IF VALIDACION TRABAJADOR
        END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
      END LOOP;  -- LOOP DE REPOSICION  
    close reposwx; -- CIERRA CURSOR REPOSICION

  ELSE -- VALIDACION SI PASA DATOS DE FINCA
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open repos(pIdFn,pIdFi,pIdfx);
      LOOP
        FETCH repos into rep_det; -- obtenemos valores del cursor
        raise notice 'rep_det: %', rep_det;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

        select into cont_tot COUNT(*) AS tot from epp.det_mov_presta_epp_alm WHERE folio = rep_det.folio;
        select into cont_mat COUNT(*) AS mat from epp.det_mov_presta_epp_alm E WHERE e.entregado = true and folio = rep_det.folio;
        select into cont_dev COUNT(*) AS mat from epp.det_mov_presta_epp_alm E WHERE e.recepcion = true and folio = rep_det.folio;
        raise notice 'TOTAL %,  MAT %,  DEV %', cont_tot, cont_mat, cont_dev;
        
        IF cont_tot = cont_mat THEN
            raise notice 'CONTADOR IGUAL ENTREGADO R';
            estatus := 'SURTIDO';
          END IF;
          
          IF cont_tot > cont_mat THEN
            raise notice 'CONTADOR MAYOR ESTA PARCIAL R';
            estatus := 'PARCIAL';
          END IF;
          
          IF cont_mat = 0 THEN
            raise notice 'CONTADOR MAT CERO PENDIENTE R';
            estatus := 'PENDIENTE';
          END IF;
          
          -- validacion de estado de recepcion
        IF cont_tot = cont_dev THEN
            raise notice 'CONTADOR IGUAL ENTREGADO RX';
            devolucion := 'COMPLETO';
          END IF;
          
          IF cont_tot > cont_dev THEN
            raise notice 'CONTADOR MAYOR ESTA PARCIAL RX';
            devolucion := 'PARCIAL';
          END IF;
          
          IF cont_dev = 0 THEN
            raise notice 'CONTADOR MAT CERO PENDIENTE RX';
            devolucion := 'PENDIENTE';
          END IF;
          
        IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
          raise notice 'TRABAJADOR NULL REP R';
         
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_presta', rep_det.NOMBRE_FINCA,rep_det.ID_TRAB,rep_det.nombre_t,rep_det.FECHA_INI_PRESTA::DATE,'PRESTAMO',rep_det.folio,estatus,devolucion); 
        ELSE -- SI PASA DATOS DE TRABAJADOR    
          IF (rep_det.id_trab = pIdTr) THEN 
            raise notice 'SI PASA DATOS DEL TRABAJADOR REP R';
          
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_presta', rep_det.NOMBRE_FINCA,rep_det.ID_TRAB,rep_det.nombre_t,rep_det.FECHA_INI_PRESTA::DATE,'PRESTAMO',rep_det.folio,estatus,devolucion);  
          END IF; -- IF VALIDACION TRABAJADOR
        END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
      END LOOP;  -- LOOP DE REPOSICION  
     close repos; -- CIERRA CURSOR REPOSICION
  END IF; -- ELSE IF VALIDACION TODAS LAS FINCAS 

return query select * from rep_presta; -- retorna consulta c/materiales a entregar 1

RETURN;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de nuevos (gft/epp) ----------------------------
drop function epp.rep_nuevos(integer,varchar,date,date); -- 20
create or replace function epp.rep_nuevos(integer,varchar,date,date)  returns setof record as $$
declare
  pidFn   alias for $1; -- id_finca
  pIdTr   alias for $2; -- id_trab 
  pIdFi   alias for $3; -- fecha_inicio
  pIdFx   alias for $4; -- fecha_fin

  vresult      integer; -- resultado
  rep_det      RECORD; -- valores: reposiciones 
  rep_detwx    RECORD; -- valores: reposiciones  todos
  cont_tot     integer; -- contador total de materiales
  cont_mat     integer; -- contador de materiales surtidos
  estatus      VARCHAR; -- estado guardado x filtro
  
  reposwx CURSOR(pIdFi date,pIdfx date) FOR 
    SELECT DISTINCT F.NOMBRE_FINCA,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA::DATE,E.FOLIO
    FROM epp.det_mov_nvo_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE (E.fecha::date between pIdFi and PidFx); -- REPORTE CON FINCA
  
  repos CURSOR(pIdFn integer, pIdFi date,pIdfx date) FOR 
    SELECT DISTINCT F.NOMBRE_FINCA,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA::DATE,E.FOLIO
    FROM epp.det_mov_nvo_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE E.id_finca = pIdFn and (E.fecha::date between pIdFi and pIdFx); 
   
BEGIN
  
  CREATE TEMPORARY TABLE rep_nuevos(
    finca varchar, -- nombre finca
    id_trab varchar, -- id trabajador
    nom_t varchar, -- nombre de trabajador
    fecha date, -- fecha
    tipo text, -- tipo mov
    folio varchar, -- folio epp
    estado varchar -- estatus entrega
  ) ON COMMIT DROP;

  IF pIdFn = 0 THEN -- TODAS LAS FINCAS
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open reposwx(pIdFi,pIdfx);
      LOOP
        FETCH reposwx into rep_detwx; -- obtenemos valores del cursor
        raise notice 'rep_detwx: %', rep_detwx;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        select into cont_tot COUNT(*) AS tot from epp.det_mov_nvo_epp_alm WHERE folio = rep_detwx.folio;
        select into cont_mat COUNT(*) AS mat from epp.det_mov_nvo_epp_alm E WHERE e.entregado = true and folio = rep_detwx.folio;
        raise notice 'TOTAL %,  MAT %', cont_tot, cont_mat;
        
        IF cont_tot = cont_mat THEN
            raise notice 'CONTADOR IGUAL ENTREGADO';
            estatus := 'SURTIDO';
          END IF;
          
          IF cont_tot > cont_mat THEN
            raise notice 'CONTADOR MAYOR ESTA PARCIAL';
            estatus := 'PARCIAL';
          END IF;
          
          IF cont_mat = 0 THEN
            raise notice 'CONTADOR MAT CERO PENDIENTE';
            estatus := 'PENDIENTE';
          END IF;
          
        IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
          raise notice 'TRABAJADOR NULL REP';
        
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'rep_nuevos', rep_detwx.NOMBRE_FINCA,rep_detwx.ID_TRAB,rep_detwx.nombre_t,rep_detwx.FECHA::DATE,'NVO. INGRESO',rep_detwx.folio,estatus);   
        ELSE -- SI PASA DATOS DE TRABAJADOR 
            
          IF (rep_detwx.id_trab = pIdTr) THEN 
          raise notice 'SI PASA DATOS DEL TRABAJADOR REP';
          
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'rep_nuevos', rep_detwx.NOMBRE_FINCA,rep_detwx.ID_TRAB,rep_detwx.nombre_t,rep_detwx.FECHA::DATE,'NVO. INGRESO',rep_detwx.folio,estatus);  
           END IF; -- IF VALIDACION TRABAJADOR
        END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
      END LOOP;  -- LOOP DE REPOSICION  
    close reposwx; -- CIERRA CURSOR REPOSICION

  ELSE -- VALIDACION SI PASA DATOS DE FINCA
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open repos(pIdFn,pIdFi,pIdfx);
      LOOP
        FETCH repos into rep_det; -- obtenemos valores del cursor
        raise notice 'rep_det: %', rep_det;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

        select into cont_tot COUNT(*) AS tot from epp.det_mov_nvo_epp_alm WHERE folio = rep_det.folio;
        select into cont_mat COUNT(*) AS mat from epp.det_mov_nvo_epp_alm E WHERE e.entregado = true and folio = rep_det.folio;
        raise notice 'TOTAL %,  MAT %', cont_tot, cont_mat;
        
        IF cont_tot = cont_mat THEN
            raise notice 'CONTADOR IGUAL ENTREGADO R';
            estatus := 'SURTIDO';
          END IF;
          
          IF cont_tot > cont_mat THEN
            raise notice 'CONTADOR MAYOR ESTA PARCIAL R';
            estatus := 'PARCIAL';
          END IF;
          
          IF cont_mat = 0 THEN
            raise notice 'CONTADOR MAT CERO PENDIENTE R';
            estatus := 'PENDIENTE';
          END IF;
          
        IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
          raise notice 'TRABAJADOR NULL REP R';
         
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'rep_nuevos', rep_det.NOMBRE_FINCA,rep_det.ID_TRAB,rep_det.nombre_t,rep_det.FECHA::DATE,'NVO. INGRESO',rep_det.folio,estatus); 
        ELSE -- SI PASA DATOS DE TRABAJADOR    
          IF (rep_det.id_trab = pIdTr) THEN 
            raise notice 'SI PASA DATOS DEL TRABAJADOR REP R';
          
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'rep_nuevos', rep_det.NOMBRE_FINCA,rep_det.ID_TRAB,rep_det.nombre_t,rep_det.FECHA::DATE,'NVO. INGRESO',rep_det.folio,estatus);  
          END IF; -- IF VALIDACION TRABAJADOR
        END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
      END LOOP;  -- LOOP DE REPOSICION  
     close repos; -- CIERRA CURSOR REPOSICION
  END IF; -- ELSE IF VALIDACION TODAS LAS FINCAS 

return query select * from rep_nuevos; -- retorna consulta c/materiales a entregar 1

RETURN;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de baja (epp) ----------------------------
drop function epp.rep_baja(integer,varchar,date,date); -- 21
create or replace function epp.rep_baja(integer,varchar,date,date)  returns setof record as $$
declare
  pidFn   alias for $1; -- id_finca
  pIdTr   alias for $2; -- id_trab 
  pIdFi   alias for $3; -- fecha_inicio
  pIdFx   alias for $4; -- fecha_fin

  vresult      integer; -- resultado
  rep_det      RECORD; -- valores: reposiciones 
  rep_detwx    RECORD; -- valores: reposiciones  todos
  cont_tot     integer; -- contador total de materiales
  cont_mat     integer; -- contador de materiales surtidos
  estatus      VARCHAR; -- estado guardado x filtro
  
  reposwx CURSOR(pIdFi date,pIdfx date) FOR 
    SELECT DISTINCT F.NOMBRE_FINCA,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA::DATE,E.TIPO_BAJA,E.FOLIO
    FROM epp.det_mov_baja_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE (E.fecha::date between pIdFi and PidFx); -- REPORTE CON FINCA
  
  repos CURSOR(pIdFn integer, pIdFi date,pIdfx date) FOR 
    SELECT DISTINCT F.NOMBRE_FINCA,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA::DATE,E.TIPO_BAJA,E.FOLIO
    FROM epp.det_mov_baja_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE E.id_finca = pIdFn and (E.fecha::date between pIdFi and pIdFx); 
   
BEGIN
  
  CREATE TEMPORARY TABLE rep_baja(
    finca varchar, -- nombre finca
    id_trab varchar, -- id trabajador
    nom_t varchar, -- nombre de trabajador
    fecha date, -- fecha
    tipo text, -- tipo mov
    motivo varchar, -- motivo baja
    folio varchar, -- folio epp
    estado varchar -- estatus entrega
  ) ON COMMIT DROP;

  IF pIdFn = 0 THEN -- TODAS LAS FINCAS
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open reposwx(pIdFi,pIdfx);
      LOOP
        FETCH reposwx into rep_detwx; -- obtenemos valores del cursor
        raise notice 'rep_detwx: %', rep_detwx;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        select into cont_tot COUNT(*) AS tot from epp.det_mov_baja_epp_alm WHERE folio = rep_detwx.folio;
        select into cont_mat COUNT(*) AS mat from epp.det_mov_baja_epp_alm E WHERE e.entregado = true and folio = rep_detwx.folio;
        raise notice 'TOTAL %,  MAT %', cont_tot, cont_mat;
        
        IF cont_tot = cont_mat THEN
            raise notice 'CONTADOR IGUAL ENTREGADO';
            estatus := 'DEVUELTO';
          END IF;
          
          IF cont_tot > cont_mat THEN
            raise notice 'CONTADOR MAYOR ESTA PARCIAL';
            estatus := 'INCOMPLETO';
          END IF;
          
          IF cont_mat = 0 THEN
            raise notice 'CONTADOR MAT CERO PENDIENTE';
            estatus := 'PENDIENTE';
          END IF;
          
        IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
          raise notice 'TRABAJADOR NULL REP';
        
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_baja', rep_detwx.NOMBRE_FINCA,rep_detwx.ID_TRAB,rep_detwx.nombre_t,rep_detwx.FECHA::DATE,'BAJA EPP',rep_detwx.tipo_baja,rep_detwx.folio,estatus);   
        ELSE -- SI PASA DATOS DE TRABAJADOR 
            
          IF (rep_detwx.id_trab = pIdTr) THEN 
          raise notice 'SI PASA DATOS DEL TRABAJADOR REP';
          
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_baja', rep_detwx.NOMBRE_FINCA,rep_detwx.ID_TRAB,rep_detwx.nombre_t,rep_detwx.FECHA::DATE,'BAJA EPP',rep_detwx.tipo_baja,rep_detwx.folio,estatus);  
           END IF; -- IF VALIDACION TRABAJADOR
        END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
      END LOOP;  -- LOOP DE REPOSICION  
    close reposwx; -- CIERRA CURSOR REPOSICION

  ELSE -- VALIDACION SI PASA DATOS DE FINCA
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open repos(pIdFn,pIdFi,pIdfx);
      LOOP
        FETCH repos into rep_det; -- obtenemos valores del cursor
        raise notice 'rep_det: %', rep_det;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

        select into cont_tot COUNT(*) AS tot from epp.det_mov_baja_epp_alm WHERE folio = rep_det.folio;
        select into cont_mat COUNT(*) AS mat from epp.det_mov_baja_epp_alm E WHERE e.entregado = true and folio = rep_det.folio;
        raise notice 'TOTAL %,  MAT %', cont_tot, cont_mat;
        
        IF cont_tot = cont_mat THEN
            raise notice 'CONTADOR IGUAL ENTREGADO R';
            estatus := 'DEVUELTO';
          END IF;
          
          IF cont_tot > cont_mat THEN
            raise notice 'CONTADOR MAYOR ESTA PARCIAL R';
            estatus := 'INCOMPLETO';
          END IF;
          
          IF cont_mat = 0 THEN
            raise notice 'CONTADOR MAT CERO PENDIENTE R';
            estatus := 'PENDIENTE';
          END IF;
          
        IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
          raise notice 'TRABAJADOR NULL REP R';
         
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_baja', rep_det.NOMBRE_FINCA,rep_det.ID_TRAB,rep_det.nombre_t,rep_det.FECHA::DATE,'BAJA EPP',rep_det.tipo_baja,rep_det.folio,estatus); 
        ELSE -- SI PASA DATOS DE TRABAJADOR    
          IF (rep_det.id_trab = pIdTr) THEN 
            raise notice 'SI PASA DATOS DEL TRABAJADOR REP R';
          
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_baja', rep_det.NOMBRE_FINCA,rep_det.ID_TRAB,rep_det.nombre_t,rep_det.FECHA::DATE,'BAJA EPP',rep_det.tipo_baja,rep_det.folio,estatus);  
          END IF; -- IF VALIDACION TRABAJADOR
        END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
      END LOOP;  -- LOOP DE REPOSICION  
     close repos; -- CIERRA CURSOR REPOSICION
  END IF; -- ELSE IF VALIDACION TODAS LAS FINCAS 

return query select * from rep_baja; -- retorna consulta c/materiales a entregar 1

RETURN;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de COBROS POR PRESTAMO (epp) ----------------------------
drop function epp.cobro_presta(integer,varchar,date,date); -- 22 
create or replace function epp.cobro_presta(integer,varchar,date,date)  returns setof record as $$
declare
  pidFn   alias for $1; -- id_finca
  pIdTr   alias for $2; -- id_trab 
  pIdFi   alias for $3; -- fecha_inicio
  pIdFx   alias for $4; -- fecha_fin

  vresult      integer; -- resultado
  rep_det      RECORD; -- valores: reposiciones 
  rep_detwx    RECORD; -- valores: reposiciones  todos
  
  reposwx CURSOR(pIdFi date,pIdfx date) FOR 
    SELECT DISTINCT F.NOMBRE_FINCA,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA_FIN_PRESTA::DATE,E.FOLIO
    FROM epp.det_mov_presta_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE E.RECEPCION = FALSE AND EST = 3 AND (E.FECHA_FIN_PRESTA::DATE between pIdFi and PidFx); -- REPORTE SIN FINCA
  
  repos CURSOR(pIdFn integer, pIdFi date,pIdfx date) FOR 
    SELECT DISTINCT F.NOMBRE_FINCA,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA_FIN_PRESTA::DATE,E.FOLIO
    FROM epp.det_mov_presta_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE E.RECEPCION = FALSE AND EST = 3 AND E.id_finca = pIdFn and (E.FECHA_FIN_PRESTA::DATE between pIdFi and pIdFx); 
   
BEGIN
  
  CREATE TEMPORARY TABLE cobro_presta(
    finca varchar, -- nombre finca
    id_trab varchar, -- id trabajador
    nom_t varchar, -- nombre de trabajador
    fecha date, -- fecha
    tipo text, -- tipo mov
    folio varchar -- folio epp
  ) ON COMMIT DROP;

  IF pIdFn = 0 THEN -- TODAS LAS FINCAS
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open reposwx(pIdFi,pIdfx);
      LOOP
        FETCH reposwx into rep_detwx; -- obtenemos valores del cursor
        raise notice 'rep_detwx: %', rep_detwx;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
          
        IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
          raise notice 'TRABAJADOR NULL REP';
        
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'cobro_presta', rep_detwx.NOMBRE_FINCA,rep_detwx.ID_TRAB,rep_detwx.nombre_t,rep_detwx.FECHA_FIN_PRESTA::DATE,'COBRO PRESTAMO',rep_detwx.folio);   
        ELSE -- SI PASA DATOS DE TRABAJADOR 
            
          IF (rep_detwx.id_trab = pIdTr) THEN 
          raise notice 'SI PASA DATOS DEL TRABAJADOR REP';
          
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'cobro_presta', rep_detwx.NOMBRE_FINCA,rep_detwx.ID_TRAB,rep_detwx.nombre_t,rep_detwx.FECHA_FIN_PRESTA::DATE,'COBRO PRESTAMO',rep_detwx.folio);  
           END IF; -- IF VALIDACION TRABAJADOR
        END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
      END LOOP;  -- LOOP DE REPOSICION  
    close reposwx; -- CIERRA CURSOR REPOSICION

  ELSE -- VALIDACION SI PASA DATOS DE FINCA
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open repos(pIdFn,pIdFi,pIdfx);
      LOOP
        FETCH repos into rep_det; -- obtenemos valores del cursor
        raise notice 'rep_det: %', rep_det;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

        IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
          raise notice 'TRABAJADOR NULL REP R';
         
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'cobro_presta', rep_det.NOMBRE_FINCA,rep_det.ID_TRAB,rep_det.nombre_t,rep_det.FECHA_FIN_PRESTA::DATE,'COBRO PRESTAMO',rep_det.folio); 
        ELSE -- SI PASA DATOS DE TRABAJADOR    
          IF (rep_det.id_trab = pIdTr) THEN 
            raise notice 'SI PASA DATOS DEL TRABAJADOR REP R';
          
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'cobro_presta', rep_det.NOMBRE_FINCA,rep_det.ID_TRAB,rep_det.nombre_t,rep_det.FECHA_FIN_PRESTA::DATE,'COBRO PRESTAMO',rep_det.folio);  
          END IF; -- IF VALIDACION TRABAJADOR
        END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
      END LOOP;  -- LOOP DE REPOSICION  
     close repos; -- CIERRA CURSOR REPOSICION
  END IF; -- ELSE IF VALIDACION TODAS LAS FINCAS 

return query select * from cobro_presta; -- retorna consulta c/materiales a entregar 1

RETURN;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para TAREA POR PRESTAMO (epp) ---------------------------
drop function epp.tarea_presta(); -- 23
create or replace function epp.tarea_presta() returns integer as $$
declare
 
  vresult      integer; -- resultado
  rep_detwx    RECORD; -- valores: DETALLE PRESTAMOS NO DEVUELTOS
  
  reposwx CURSOR FOR SELECT DISTINCT E.ID_FINCA,F.NOMBRE_FINCA,T.ID_TRAB,E.ID_MATERIAL,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA_FIN_PRESTA::DATE,E.ENTREGADO,E.FOLIO,E.RECEPCION,E.est
    FROM epp.det_mov_presta_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE E.entregado = true AND E.RECEPCION = FALSE AND (E.FECHA_FIN_PRESTA::DATE <= CURRENT_DATE); -- det presta
   
BEGIN
  
  vResult := 1;
  open reposwx; -- abriendo cursor
    LOOP
      FETCH reposwx into rep_detwx; -- obtenemos valores del cursor
      raise notice 'rep_detwx: %', rep_detwx;
      
      EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
      raise notice 'SI PASA DATOS DEL TRABAJADOR REP R';
        
      -- ACTUALIZA EL STATUS P/GENERAR COBRO POR PRESTAMO NO DEVUELTO
      UPDATE epp.det_mov_presta_epp_alm E SET EST = 3 WHERE E.folio =  rep_detwx.folio;
      
      -- ACTUALIZA EL STATUS P/GENERAR COBRO POR PRESTAMO NO DEVUELTO
     UPDATE epp.movimiento_epp M SET estado_epp = 2 WHERE M.id_trab = rep_detwx.id_trab and M.id_material = rep_detwx.id_material and M.id_finca = rep_detwx.id_finca and M.folio =  rep_detwx.folio; 
          
    END LOOP;  -- LOOP DE REPOSICION  
  close reposwx; -- CIERRA CURSOR REPOSICION

RETURN vResult;
END; 
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de DESCUENTOS (epp) ----------------------------
drop function epp.descuentos_epp(varchar,date,date); -- 24
create or replace function epp.descuentos_epp(varchar,date,date)  returns setof record as $$
declare
  pidFn   alias for $1; -- nombre_finca
  pIdFi   alias for $2; -- fecha_inicio
  pIdFx   alias for $3; -- fecha_fin

  prestamo      RECORD; -- valores: prestamos funcion 
  reposicion    RECORD; -- valores: reposicion funcion
  vigilantes    RECORD; -- valores: Rep gft visitantes
  
  rep_val       RECORD; -- validar y acumular datos trab
  acumulado     NUMERIC(10,3); -- acumulador de importe
  cont          INTEGER; -- valores: total de vigilantes
  vigi_acum      NUMERIC(10,3); -- monto indv x vigilante
  
  extra        numeric(10,2); -- recargo 20 % por extravio
  agreg        numeric(10,2); -- valor agregado
  final        numeric(10,3); -- monto final con recargo
  
      -- CONSULTA P/GENERAR COBROS POR REPOSICION (EXTRAVIO)
  repo CURSOR(pIdFi date, pIdfx date) FOR SELECT DISTINCT f.nombre_finca as finca,k.folio,m.id_material,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, k.monto as costo,k.fecha,k.tipo_cobro from public.trabajadores t 
    inner join public.fincas f on f.id_finca = f.id_finca
    inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab
    inner join almacen.materiales m on m.id_material = x.id_material 
    inner join epp.det_mov_repo_epp_enf p on p.id_finca=f.id_finca and p.folio = x.folio and p.id_material = m.id_material
    inner join epp.cobros_detalle k on k.id_finca = p.id_finca and k.folio = p.folio and k.id_material = p.id_material and x.id_trab = k.id_trab and k.surtido = true
    where k.fecha::date between pIdFi and pIdfx;
    -- FILTRO POR FINCA --> where f.nombre_finca = '';

    -- CONSULTA P/GENERAR COBROS POR PRESTAMOS NO DEVUELTOS
  presta CURSOR(pIdFi date, pIdfx date) FOR SELECT p.folio,f.nombre_finca as finca,t.id_trab,m.id_material,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, m.costo_reposicion_epp AS costo,p.fecha_fin_presta
    FROM public.trabajadores t
    inner join public.fincas f on f.id_finca = f.id_finca
    inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab
    inner join almacen.materiales m on m.id_material = x.id_material 
    inner join epp.det_mov_presta_epp_alm p on m.id_material=p.id_material and p.id_finca = f.id_finca and p.folio = x.folio and p.id_material = x.id_material
    where p.recepcion = false and p.est = 3 and p.fecha_fin_presta::date between pIdFi and pIdfx; 
    -- FILTRO POR FINCA --> where f.nombre_finca = '';

    -- CONSULTA P/GENERAR COBROS POR REPO CON COBRO DE GFT VISITANTES
  vigi CURSOR(pIdFi date, pIdfx date) FOR SELECT F.NOMBRE_FINCA as finca,C.FOLIO,C.FECHA::DATE,C.CANTIDAD::integer,X.COSTO_REPOSICION_EPP AS COSTO_UNIT,C.MONTO as costo,W.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo
    FROM epp.mov_gft_vst M 
    INNER JOIN epp.cobros_gft_vst C ON C.FOLIO = M.FOLIO AND C.ID_MATERIAL = M.ID_MATERIAL AND C.ID_FINCA = M.ID_FINCA
    INNER JOIN TRABAJADORES W ON W.ID_TRAB = W.ID_TRAB
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND C.ID_FINCA = F.ID_FINCA AND f.id_finca = W.id_finca
    inner join tipo_trabajador p on W.id_tipo_trab = p.id_tipo_trab
    INNER JOIN PUBLIC.AREA_TRABAJO T ON C.ID_AREA_TRABAJO = T.ID_AREA_TRABAJO
    INNER JOIN ALMACEN.MATERIALES X ON C.ID_MATERIAL = X.ID_MATERIAL AND M.ID_MATERIAL = X.ID_MATERIAL
    WHERE c.fecha::date between pIdFi and pIdfx AND W.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES';
    -- FILTRO POR FINCA --> where f.nombre_finca = ''; 
   
BEGIN
  
  CREATE TEMPORARY TABLE descuentos_epp( -- tabla temporal acumulativa
    finca varchar, -- nombre finca
    id_trab varchar, -- id trabajador
    nom_completo varchar, -- nombre de trabajador
    importe numeric(10,3), -- importe total
    fec_ini date, -- fecha inicio
    fec_fin date -- fecha fin
  ) ON COMMIT DROP;
  
  extra := 0.20; -- 20 % penalizacion
  agreg := 0.00; -- valor agregado
  final := 0.00; -- monto final con recargo
  

  IF pIdFn = 'TODOS' THEN -- TODAS LAS FINCAS
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open repo(pIdFi,pIdfx); -- cursor de reposiciones 
      LOOP
        FETCH repo into reposicion; -- obtenemos valores del cursor
        raise notice 'reposicion: %', reposicion;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
       
        select into rep_val * from descuentos_epp where id_trab = reposicion.id_trab; -- obteniendo registros actuales de tb_temporal
        raise notice 'REP_VAL: %', rep_val;
        IF NOT FOUND THEN 
          raise notice 'VALORES NULO REPO';
          
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', reposicion.FINCA,reposicion.ID_TRAB,reposicion.nombre_completo,reposicion.costo,pIdFi,pIdFx);  
        ELSE
          select into rep_val * from descuentos_epp where id_trab = reposicion.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
          raise notice 'REP_VAL EN ELSE VAL: %', rep_val;
        
          IF rep_val.id_trab = reposicion.id_trab THEN 
            raise notice 'ID_TRAB --> DESC = REPO REPO';
            
            acumulado := (rep_val.importe + reposicion.costo);
            raise notice 'ACUMULADO: %', acumulado;
            
            EXECUTE format('UPDATE descuentos_epp SET importe = %L WHERE id_trab = %L', acumulado, rep_val.id_trab); 
          ELSE
            raise notice 'ID_TRAB --> DIFERENTE REPO';
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', reposicion.FINCA,reposicion.ID_TRAB,reposicion.nombre_completo,reposicion.costo,pIdFi,pIdFx);
          END IF; -- VALIDACION COMPARANDO ID TRAB
        END IF; -- ACUMULADOR REPOSICION POR TRAB 
      END LOOP;  -- LOOP DE REPOSICION  
    close repo; -- CIERRA CURSOR REPOSICION
    
    /* ///////////////////////////////////////////////////////////////////////////////////////////////// */
    
    open presta(pIdFi,pIdfx); -- cursor de prestamos
      LOOP
        FETCH presta into prestamo; -- obtenemos valores del cursor
        raise notice 'prestamo: %', prestamo;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        select into rep_val * from descuentos_epp where id_trab = prestamo.id_trab; -- obteniendo registros actuales de tb_temporal
        raise notice 'REP_VAL: %', rep_val;
        IF NOT FOUND THEN 
          raise notice 'VALORES NULO REPO';
          
          agreg = (prestamo.costo * extra); -- obteniendo el valor del 20 %
          raise notice 'AGREG: %', agreg;

          final = (prestamo.costo + agreg); -- monto final con porcentaje incluido
          raise notice 'FINAL: %', final;

          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', prestamo.FINCA,prestamo.ID_TRAB,prestamo.nombre_completo,final,pIdFi,pIdFx);  
        ELSE
          select into rep_val * from descuentos_epp where id_trab = prestamo.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
          raise notice 'REP_VAL EN ELSE VAL: %', rep_val;
        
          IF rep_val.id_trab = prestamo.id_trab THEN 
            raise notice 'ID_TRAB --> DESC = REPO REPO';
            
            agreg = (prestamo.costo * extra); -- obteniendo el valor del 20 %
            raise notice 'AGREG: %', agreg;

            final = (prestamo.costo + agreg); -- monto final con porcentaje incluido
            raise notice 'FINAL: %', final;

            
            acumulado := (rep_val.importe + final);
            raise notice 'ACUMULADO: %', acumulado;
            
            EXECUTE format('UPDATE descuentos_epp SET importe = %L WHERE id_trab = %L', acumulado, rep_val.id_trab);
          ELSE
            raise notice 'ID_TRAB --> DIFERENTE PRESTA';
            agreg = (prestamo.costo * extra); -- obteniendo el valor del 20 %
            raise notice 'AGREG: %', agreg;

            final = (prestamo.costo + agreg); -- monto final con porcentaje incluido
            raise notice 'FINAL: %', final;
            
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', prestamo.FINCA,prestamo.ID_TRAB,prestamo.nombre_completo,final,pIdFi,pIdFx);
          END IF; -- VALIDACION COMPARANDO ID TRAB
        END IF; -- ACUMULADOR PRESTAMO POR TRAB 
      END LOOP;  -- LOOP DE PRESTAMO 
    close presta; -- CIERRA CURSOR PRESTAMO
                                                                    
    /* ///////////////////////////////////////////////////////////////////////////////////////////////// */
    
    open vigi(pIdFi,pIdfx); -- cursor de vigilantes
      LOOP
        FETCH vigi into vigilantes; -- obtenemos valores del cursor
        raise notice 'vigilantes: %', vigilantes;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        select into cont COUNT(*) from trabajadores t inner join tipo_trabajador p on t.id_tipo_trab = p.id_tipo_trab inner join fincas f on f.id_finca = t.id_finca where t.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES' and F.nombre_finca = vigilantes.finca;
                                                                    
        raise notice 'cont: %, finca: % ', cont, vigilantes.finca;
                                                                    
        vigi_acum := (vigilantes.costo / cont);
        raise notice 'VIGI_ACUM: %', vigi_acum;             
                                                                    
        select into rep_val * from descuentos_epp where id_trab = vigilantes.id_trab; -- obteniendo registros actuales de tb_temporal
        raise notice 'REP_VAL: %', rep_val;
        IF NOT FOUND THEN 
          raise notice 'VALORES NULO REPO';
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', vigilantes.FINCA,vigilantes.ID_TRAB,vigilantes.nombre_completo,vigi_acum,pIdFi,pIdFx);  
        ELSE
          select into rep_val * from descuentos_epp where id_trab = vigilantes.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
          raise notice 'REP_VAL EN ELSE VAL: %', rep_val;
        
          IF rep_val.id_trab = vigilantes.id_trab THEN 
            raise notice 'ID_TRAB --> DESC = REPO REPO';
            
            acumulado := (rep_val.importe + vigi_acum);
            raise notice 'ACUMULADO: %', acumulado;
            
            EXECUTE format('UPDATE descuentos_epp SET importe = %L WHERE id_trab = %L', acumulado, rep_val.id_trab);
          ELSE
            raise notice 'ID_TRAB --> DIFERENTE REPO';
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', vigilantes.FINCA,vigilantes.ID_TRAB,vigilantes.nombre_completo,vigi_acum,pIdFi,pIdFx);
          END IF; -- VALIDACION COMPARANDO ID TRAB
        END IF; -- ACUMULADOR VIGILANTES POR TRAB 
      END LOOP;  -- LOOP DE VIGILANTES
    close vigi; -- CIERRA CURSOR VIGILANTES
                                                                    
  ELSE -- VALIDACION SI PASA DATOS DE FINCA
    open repo(pIdFi,pIdfx); -- cursor reposicion
      LOOP
        FETCH repo into reposicion; -- obtenemos valores del cursor
        raise notice 'reposicion: %', reposicion;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

        IF pIdFn = reposicion.finca THEN -- VALIDANDO FINCA SELECCIONADA  
          raise notice 'FINCA: %', pIdFn; -- finca seleccionada
          
          select into rep_val * from descuentos_epp where id_trab = reposicion.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
          raise notice 'REP_VAL: %', rep_val;
          IF NOT FOUND THEN 
            raise notice 'VALORES NULO REPO';
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', reposicion.FINCA,reposicion.ID_TRAB,reposicion.nombre_completo,reposicion.costo,pIdFi,pIdFx); 
          ELSE
            select into rep_val * from descuentos_epp where id_trab = reposicion.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
            raise notice 'REP_VAL EN ELSE VAL: %', rep_val;
        
            IF rep_val.id_trab = reposicion.id_trab THEN 
              raise notice 'ID_TRAB --> DESC = REPO REPO';
              
              acumulado := (rep_val.importe + reposicion.costo);
              raise notice 'ACUMULADO ELSE %', acumulado;
              
              EXECUTE format('UPDATE descuentos_epp SET importe = %L WHERE id_trab = %L', acumulado, rep_val.id_trab);
            ELSE
              raise notice 'ID_TRAB --> DIFERENTE REPO';
              EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', reposicion.FINCA,reposicion.ID_TRAB,reposicion.nombre_completo,reposicion.costo,pIdFi,pIdFx);
            END IF; -- VALIDACION COMPARANDO ID TRAB
          END IF; -- ACUMULADOR REPOSICION POR TRAB 
        END IF; -- VALIDACION DE FINCA SELECCIONADA
      END LOOP;  -- LOOP DE REPOSICION  
     close repo; -- CIERRA CURSOR REPOSICION
     
     /* /////////////////////////////////////////////////////////////////////////////////////////////////// */ 
     
     open presta(pIdFi,pIdfx); -- cursor prestamo
      LOOP
        FETCH presta into prestamo; -- obtenemos valores del cursor
        raise notice 'prestamo: %', prestamo;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

        IF pIdFn = prestamo.finca THEN -- VALIDANDO FINCA SELECCIONADA  
          raise notice 'FINCA: %', pIdFn; -- finca seleccionada
          
          select into rep_val * from descuentos_epp where id_trab = prestamo.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
          raise notice 'REP_VAL: %', rep_val;
          IF NOT FOUND THEN 
            raise notice 'VALORES NULO REPO';
            agreg = (prestamo.costo * extra); -- obteniendo el valor del 20 %
            raise notice 'AGREG: %', agreg;

            final = (prestamo.costo + agreg); -- monto final con porcentaje incluido
            raise notice 'FINAL: %', final;

            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', prestamo.FINCA,prestamo.ID_TRAB,prestamo.nombre_completo,final,pIdFi,pIdFx);  
          ELSE
            select into rep_val * from descuentos_epp where id_trab = prestamo.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
            raise notice 'REP_VAL EN ELSE VAL: %', rep_val;
        
            IF rep_val.id_trab = prestamo.id_trab THEN 
              raise notice 'ID_TRAB --> DESC = REPO REPO';
              
              agreg = (prestamo.costo * extra); -- obteniendo el valor del 20 %
              raise notice 'AGREG: %', agreg;

              final = (prestamo.costo + agreg); -- monto final con porcentaje incluido
              raise notice 'FINAL: %', final;

              acumulado := (rep_val.importe + final);
              raise notice 'ACUMULADO ELSE %', acumulado;
              
              EXECUTE format('UPDATE descuentos_epp SET importe = %L WHERE id_trab = %L', acumulado, rep_val.id_trab);
            ELSE
              raise notice 'ID_TRAB --> DIFERENTE REPO';
              agreg = (prestamo.costo * extra); -- obteniendo el valor del 20 %
              raise notice 'AGREG: %', agreg;

              final = (prestamo.costo + agreg); -- monto final con porcentaje incluido
              raise notice 'FINAL: %', final;

              EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', prestamo.FINCA,prestamo.ID_TRAB,prestamo.nombre_completo,final,pIdFi,pIdFx);
            END IF; -- VALIDACION COMPARANDO ID TRAB
          END IF; -- ACUMULADOR REPOSICION POR TRAB 
        END IF; -- VALIDACION DE FINCA SELECCIONADA
      END LOOP;  -- LOOP DE PRESTAMO  
     close presta; -- CIERRA CURSOR PRESTAMO

     /* /////////////////////////////////////////////////////////////////////////////////////////////////// */ 
     
     open vigi(pIdFi,pIdfx); -- cursor vigilantes
      LOOP
        FETCH vigi into vigilantes; -- obtenemos valores del cursor
        raise notice 'vigilantes: %', vigilantes;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada

        IF pIdFn = vigilantes.finca THEN -- VALIDANDO FINCA SELECCIONADA  
          raise notice 'FINCA: %', pIdFn; -- finca seleccionada
          
          select into cont COUNT(*) from trabajadores t inner join tipo_trabajador p on t.id_tipo_trab = p.id_tipo_trab inner join fincas f on f.id_finca = t.id_finca where t.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES' and F.nombre_finca = vigilantes.finca;
                                                                    
          raise notice 'cont: %, finca: % ', cont, vigilantes.finca;

          vigi_acum := (vigilantes.costo / cont);
          raise notice 'VIGI_ACUM: %', vigi_acum;  
                                                                    
          select into rep_val * from descuentos_epp where id_trab = vigilantes.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
          raise notice 'REP_VAL: %', rep_val;
          IF NOT FOUND THEN 
            raise notice 'VALORES NULO REPO';
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', vigilantes.FINCA,vigilantes.ID_TRAB,vigilantes.nombre_completo,vigi_acum,pIdFi,pIdFx);  
          ELSE
            select into rep_val * from descuentos_epp where id_trab = vigilantes.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
            raise notice 'REP_VAL EN ELSE VAL: %', rep_val;
        
            IF rep_val.id_trab = vigilantes.id_trab THEN 
              raise notice 'ID_TRAB --> DESC = REPO REPO';
              
              acumulado := (rep_val.importe + vigi_acum);
              raise notice 'ACUMULADO ELSE %', acumulado;
              
              EXECUTE format('UPDATE descuentos_epp SET importe = %L WHERE id_trab = %L', acumulado, rep_val.id_trab);
            ELSE
              raise notice 'ID_TRAB --> DIFERENTE REPO';
              EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L)', 'descuentos_epp', vigilantes.FINCA,vigilantes.ID_TRAB,vigilantes.nombre_completo,vigi_acum,pIdFi,pIdFx);
            END IF; -- VALIDACION COMPARANDO ID TRAB
          END IF; -- ACUMULADOR VIGILANTES POR TRAB 
        END IF; -- VALIDACION DE FINCA SELECCIONADA
      END LOOP;  -- LOOP DE VIGILANTES  
     close vigi; -- CIERRA CURSOR VIGILANTES
                                                               
  END IF; -- ELSE IF VALIDACION TODAS LAS FINCAS 

return query select * from descuentos_epp; -- retorna consulta c/materiales a entregar 1

RETURN;
END;
$$ language plpgsql; -- OK


/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el almacenamiento de cobros ----------------------------
drop function epp.cobros_trab(integer,varchar,varchar,integer,varchar,numeric(10,3)); -- 25
create or replace function epp.cobros_trab(integer,varchar,varchar,integer,varchar,numeric(10,3)) returns integer as $$
declare

  pidFn   alias for $1; -- id_finca
  pIdTr   alias for $2; -- id_trab 
  pIdTc   alias for $3; -- tipo_cobro
  pIdRx   alias for $4; -- id_material
  pIdFl   alias for $5; -- folio
  pIdCn   alias for $6; -- cantidad_material

  vresult      integer;
  trabaja      RECORD;
  det_cob      RECORD;
  monto        RECORD;
  extra        numeric(10,2); -- recargo 20 % por extravio
  agreg        numeric(10,2); -- valor agregado
  final        numeric(10,3); -- monto final con recargo
   
BEGIN
  
  vresult := 1;
  extra := 0.20; -- 20 % penalizacion
  agreg := 0.00; -- valor agregado
  final := 0.00; -- monto final con recargo
  
  -- Buscando el detalle de cobros
  select into det_cob * from epp.cobros_detalle where id_finca = pIdFn and id_material = pIdRx and folio = pIdFl;
   
  IF NOT FOUND THEN -- no tiene datos en detalle
    raise notice 'NO TIENE DATOS';
    
    IF pIdTc = 'EQ. PROTECCION' THEN -- INGRESA EQUIPO DE PROTECCION
      select into monto id_material,costo_reposicion_epp from almacen.materiales where id_material = pIdRx;
      raise notice 'MATE EPP: %', monto;
      
      agreg = (monto.costo_reposicion_epp * extra); -- obteniendo el valor del 20 %
      raise notice 'AGREG: %', agreg;
      
      final = (monto.costo_reposicion_epp + agreg); -- monto final con porcentaje incluido
      raise notice 'FINAL: %', final;
      
      -- insertando en la tabla cobros_detalle
      insert into epp.cobros_detalle(id_finca,folio,id_material,id_trab,monto,tipo_cobro,surtido) values (pidFn,pIdFl,pIdRx,pIdTr,(pIdCn * final),pIdTc,false);
    ELSE
      raise notice 'GAFETE :: ENTREGA INMEDIATA';
      
      select into monto id_material,costo_reposicion_epp from almacen.materiales where id_material = pIdRx;
      raise notice 'MATE GFT: %', monto;
      
      -- insertando en la tabla cobros_detalle
      insert into epp.cobros_detalle(id_finca,folio,id_material,id_trab,monto,tipo_cobro,surtido) values (pidFn,pIdFl,pIdRx,pIdTr,(pIdCn * monto.costo_reposicion_epp),pIdTc,true);
    END IF; -- else validacion tipo de cobro
  END IF; -- validacion de detalle
   
  RETURN vresult;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el almacenamiento de reposiciones ----------------------------
drop function epp.reposiciones(integer,varchar,varchar,integer,varchar); -- 26
create or replace function epp.reposiciones(integer,varchar,varchar,integer,varchar) returns integer as $$
declare

  pidFn   alias for $1; -- id_finca
  pIdTr   alias for $2; -- id_trab 
  pIdTc   alias for $3; -- tipo_cobro
  pIdRx   alias for $4; -- id_material
  pIdFl   alias for $5; -- folio
  
  vresult      integer;
  det_cob      RECORD;
  
BEGIN
  
  vresult := 1;
  
  -- Buscando el detalle de autos
  select into det_cob * from epp.reposiciones where id_finca = pIdFn and id_material = pIdRx and folio = pIdFl;
   
  IF NOT FOUND THEN
    raise notice 'NO TIENE DATOS';
    IF pIdTc = 'EQ. PROTECCION' THEN -- INGRESA EQUIPO DE PROTECCION
        -- insertando en la tabla REPOSICIONES
      insert into epp.reposiciones(id_finca,folio,id_material,id_trab,monto,tipo_cobro,surtido) values (pidFn,pIdFl,pIdRx,pIdTr,0.0,pIdTc,false);
    ELSE
      raise notice 'GAFETE :: ENTREGA INMEDIATA';
      insert into epp.reposiciones(id_finca,folio,id_material,id_trab,monto,tipo_cobro,surtido) values (pidFn,pIdFl,pIdRx,pIdTr,0.0,pIdTc,true);
    END IF; -- else validacion tipo de cobro
  END IF;  -- validacion de detalle 
   
  RETURN vresult;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de reposiciones (gft/epp) ----------------------------
drop function epp.rep_repos(integer,varchar,varchar,date,date); -- 27
create or replace function epp.rep_repos(integer,varchar,varchar,date,date) returns setof record as $$
declare
  pidFn   alias for $1; -- id_finca
  pIdTr   alias for $2; -- id_trab 
  pIdTc   alias for $3; -- tipo_cobro
  pIdFi   alias for $4; -- fecha_inicio
  pIdFx   alias for $5; -- fecha_fin

  cob_det      RECORD; -- valores: cobros_detalle
  rep_det      RECORD; -- valores: reposiciones 
  cob_detwx    RECORD; -- valores: cobros_detalle todos
  rep_detwx    RECORD; -- valores: reposiciones  todos
  
  cont_tot     integer; -- contador total de materiales
  cont_mat     integer; -- contador de materiales surtidos
  estatus      VARCHAR; -- estado guardado x filtro
  monto        NUMERIC(10,2); -- monto a pagar

  cobroswx CURSOR(pIdFi date,pIdfx date) FOR SELECT DISTINCT z.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nom_t,z.fecha,z.tipo_cobro,(CASE WHEN z.surtido = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado from public.trabajadores t 
  inner join public.fincas f on f.id_finca = f.id_finca
  inner join epp.cobros_detalle z on f.id_finca = z.id_finca and t.id_trab = z.id_trab
  where (fecha::date between pIdFi and pIdFx); -- cobros detalle general

  reposwx CURSOR(pIdFi date,pIdfx date) FOR SELECT DISTINCT z.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nom_t,z.fecha,z.tipo_cobro,(CASE WHEN z.surtido = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado from public.trabajadores t 
  inner join public.fincas f on f.id_finca = f.id_finca
  inner join epp.reposiciones z on f.id_finca = z.id_finca and t.id_trab = z.id_trab
  where (fecha::date between pIdFi and pIdFx); -- reposiciones general
  
  cobros CURSOR(pIdFn integer,pIdFi date,pIdfx date) FOR SELECT DISTINCT z.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nom_t,z.fecha,z.tipo_cobro,(CASE WHEN z.surtido = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado from public.trabajadores t 
  inner join public.fincas f on f.id_finca = f.id_finca
  inner join epp.cobros_detalle z on f.id_finca = z.id_finca and t.id_trab = z.id_trab
  where z.id_finca = pIdFn and (fecha::date between pIdFi and pIdFx); -- cobros x finca
  
  repos CURSOR(pIdFn integer, pIdFi date,pIdfx date) FOR SELECT DISTINCT z.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nom_t,z.fecha,z.tipo_cobro,(CASE WHEN z.surtido = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado from public.trabajadores t 
  inner join public.fincas f on f.id_finca = f.id_finca
  inner join epp.reposiciones z on f.id_finca = z.id_finca and t.id_trab = z.id_trab
  where z.id_finca = pIdFn and (fecha::date between pIdFi and pIdFx); -- repos x finca
   
BEGIN
  
  CREATE TEMPORARY TABLE rep_repos(
    finca varchar, -- nombre finca
    id_trab varchar, -- id trabajador
    nom_t varchar, -- nombre de trabajador
    fecha date, -- fecha
    tipo_cobro text, -- tipo mov
    folio varchar, -- folio epp
    movimiento text, -- movimiento
    estado varchar, -- estatus entrega
    monto numeric(10,3) -- monto tot
  ) ON COMMIT DROP;
  
  IF pIdFn = 0 THEN -- TODAS LAS FINCAS
    open cobroswx(pIdFi,pIdfx);
      LOOP
        FETCH cobroswx into cob_detwx; -- obtenemos valores del cursor
          raise notice 'cob_detwx: %', cob_detwx;

          EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
          
          select into cont_tot COUNT(*) AS tot from epp.cobros_detalle WHERE folio = cob_detwx.folio;
          select into cont_mat COUNT(*) AS mat from epp.cobros_detalle E WHERE e.surtido = true and folio = cob_detwx.folio;
          select into monto SUM(E.MONTO) AS PAGO from epp.COBROS_DETALLE E WHERE e.SURTIDO = true and folio = cob_detwx.folio;

          raise notice 'TOTAL %, MAT %, MONTO %', cont_tot, cont_mat, monto;
        
          IF cont_tot = cont_mat THEN
            raise notice 'CONTADOR IGUAL ENTREGADO';
            estatus := 'SURTIDO';
          END IF;
          
          IF cont_tot > cont_mat THEN
            raise notice 'CONTADOR MAYOR ESTA PARCIAL';
            estatus := 'PARCIAL';
          END IF;
          
          IF cont_mat = 0 THEN
            raise notice 'CONTADOR MAT CERO PENDIENTE';
            estatus := 'PENDIENTE';
          END IF;
          
          IF monto is null THEN
            raise notice 'SUMATORIA ES NULL';
            monto := 0.0;
          END IF;
          
          IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
            raise notice 'TRABAJADOR NULL COB';

            IF pIdTc = 'TODOS' THEN -- RECIBE  DE TODOS LOS COBROS 
              raise notice 'TC: TODOS EN NULL COB';
              -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
              
             EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',cob_detwx.finca,cob_detwx.id_trab,cob_detwx.nom_t,cob_detwx.fecha,cob_detwx.tipo_cobro,cob_detwx.folio,'EXTRAVIO',estatus,monto);

            ELSE -- SI PASA TIPO DE COBRO
              raise notice 'SI PASA DATOS DE COBRO EN NULL COB';

              IF (cob_detwx.tipo_cobro = pIdTc) THEN -- RECIBE EL TIPO DE COBRO
                raise notice 'ELSE -- IF: TTC = DET NULL COB';
                EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',cob_detwx.finca,cob_detwx.id_trab,cob_detwx.nom_t,cob_detwx.fecha,cob_detwx.tipo_cobro,cob_detwx.folio,'EXTRAVIO',estatus,monto);
              END IF; -- IF VALIDACION POR TIPO (GFT/EPP)
            END IF; -- ELSE VALIDACION TODOS TIPOS DE COBRO

          ELSE -- SI PASA DATOS DE TRABAJADOR
            IF (cob_detwx.id_trab = pIdTr) THEN 
              raise notice 'SI PASA DATOS DEL TRABAJADOR COB';
              
              IF pIdTc = 'TODOS' THEN -- RECIBE  DE TODOS LOS COBROS
              raise notice 'ELSE -- IF: TRAB = DET (TC: TODOS) COB';
                -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
                EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',cob_detwx.finca,cob_detwx.id_trab,cob_detwx.nom_t,cob_detwx.fecha,cob_detwx.tipo_cobro,cob_detwx.folio,'EXTRAVIO',estatus,monto);
              ELSE -- SI PASA TIPO DE COBRO
                IF (cob_detwx.tipo_cobro = pIdTc) THEN -- RECIBE EL TIPO DE COBRO
                  raise notice 'ELSE -- IF: TRAB = DET (TC: DATO) COB';
                  EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',cob_detwx.finca,cob_detwx.id_trab,cob_detwx.nom_t,cob_detwx.fecha,cob_detwx.tipo_cobro,cob_detwx.folio,'EXTRAVIO',estatus,monto);
                END IF; -- IF VALIDACION POR TIPO (GFT/EPP)
              END IF; -- ELSE VALIDACION TODOS TIPOS DE COBRO
            END IF; -- IF VALIDACION TRABAJADOR
          END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
        END LOOP;  -- LOOP DE COBROS   
     close cobroswx; -- CIERRA CURSOR COBROS

       -- comenzar a correr el ciclo para detalle de REPOSICION:
    open reposwx(pIdFi,pIdfx);
      LOOP
        FETCH reposwx into rep_detwx; -- obtenemos valores del cursor
          raise notice 'rep_detwx: %', rep_detwx;

          EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
          
          select into cont_tot COUNT(*) AS tot from epp.reposiciones WHERE folio = rep_detwx.folio;
          select into cont_mat COUNT(*) AS mat from epp.reposiciones E WHERE e.surtido = true and folio = rep_detwx.folio;
          select into monto SUM(E.MONTO) AS PAGO from epp.reposiciones E WHERE e.SURTIDO = true and folio = rep_detwx.folio;
        
          raise notice 'TOTAL %, MAT %, MONTO %', cont_tot, cont_mat, monto;
        
            IF cont_tot = cont_mat THEN
              raise notice 'CONTADOR IGUAL ENTREGADO';
              estatus := 'SURTIDO';
            END IF;

            IF cont_tot > cont_mat THEN
              raise notice 'CONTADOR MAYOR ESTA PARCIAL';
              estatus := 'PARCIAL';
            END IF;

            IF cont_mat = 0 THEN
              raise notice 'CONTADOR MAT CERO PENDIENTE';
              estatus := 'PENDIENTE';
            END IF;
            
            IF monto is null THEN
              raise notice 'SUMATORIA ES NULL';
              monto := 0.0;
            END IF;
          
          IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
            raise notice 'TRABAJADOR NULL REP';

            IF pIdTc = 'TODOS' THEN -- RECIBE  DE TODOS LOS COBROS 
              raise notice 'TC: TODOS EN NULL REP';
              -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
              EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',rep_detwx.finca,rep_detwx.id_trab,rep_detwx.nom_t,rep_detwx.fecha,rep_detwx.tipo_cobro,rep_detwx.folio,'DETERIORO',estatus,monto);

            ELSE -- SI PASA TIPO DE COBRO
              IF (rep_detwx.tipo_cobro = pIdTc) THEN -- RECIBE EL TIPO DE COBRO
                raise notice 'TC: DATO EN NULL REP';
                EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',rep_detwx.finca,rep_detwx.id_trab,rep_detwx.nom_t,rep_detwx.fecha,rep_detwx.tipo_cobro,rep_detwx.folio,'DETERIORO',estatus,monto);
              END IF; -- IF VALIDACION POR TIPO (GFT/EPP)
            END IF; -- ELSE VALIDACION TODOS TIPOS DE COBRO

          ELSE -- SI PASA DATOS DE TRABAJADOR    
            IF (rep_detwx.id_trab = pIdTr) THEN 
              raise notice 'SI PASA DATOS DEL TRABAJADOR REP';
              
              IF pIdTc = 'TODOS' THEN -- RECIBE  DE TODOS LOS COBROS
              raise notice 'ELSE -- IF: TRAB = DET (TC: TODOS) REP';
                -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
                EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',rep_detwx.finca,rep_detwx.id_trab,rep_detwx.nom_t,rep_detwx.fecha,rep_detwx.tipo_cobro,rep_detwx.folio,'DETERIORO',estatus,monto);
              ELSE -- SI PASA TIPO DE COBRO
                IF (rep_detwx.tipo_cobro = pIdTc) THEN -- RECIBE EL TIPO DE COBRO
                  raise notice 'ELSE -- IF: TRAB = DET (TC: DATO) REP';
                  EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',rep_detwx.finca,rep_detwx.id_trab,rep_detwx.nom_t,rep_detwx.fecha,rep_detwx.tipo_cobro,rep_detwx.folio,'DETERIORO',estatus,monto);
                END IF; -- IF VALIDACION POR TIPO (GFT/EPP)
              END IF; -- ELSE VALIDACION TODOS TIPOS DE REPOSICION
            END IF; -- IF VALIDACION TRABAJADOR
          END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
        END LOOP;  -- LOOP DE REPOSICION  
     close reposwx; -- CIERRA CURSOR REPOSICION

ELSE -- VALIDACION SI PASA DATOS DE FINCA
    -- comenzar a correr el ciclo para detalle de cobros:
    open cobros(pIdFn,pIdFi,pIdfx);
      LOOP
        FETCH cobros into cob_det; -- obtenemos valores del cursor
          raise notice 'cob_det: %', cob_det;

          EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
          
          select into cont_tot COUNT(*) AS tot from epp.cobros_detalle WHERE folio = cob_det.folio;
          select into cont_mat COUNT(*) AS mat from epp.cobros_detalle E WHERE e.surtido = true and folio = cob_det.folio;
          select into monto SUM(E.MONTO) AS PAGO from epp.COBROS_DETALLE E WHERE e.SURTIDO = true and folio = cob_det.folio;
        
          raise notice 'TOTAL %, MAT %, MONTO %', cont_tot, cont_mat, monto;
        
            IF cont_tot = cont_mat THEN
              raise notice 'CONTADOR IGUAL ENTREGADO';
              estatus := 'SURTIDO';
            END IF;

            IF cont_tot > cont_mat THEN
              raise notice 'CONTADOR MAYOR ESTA PARCIAL';
              estatus := 'PARCIAL';
            END IF;

            IF cont_mat = 0 THEN
              raise notice 'CONTADOR MAT CERO PENDIENTE';
              estatus := 'PENDIENTE';
            END IF;
            
            IF monto is null THEN
              raise notice 'SUMATORIA ES NULL';
              monto := 0.0;
            END IF;
          
          IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
            raise notice 'TRABAJADOR NULL COB';

            IF pIdTc = 'TODOS' THEN -- RECIBE  DE TODOS LOS COBROS 
              raise notice 'TC: TODOS EN NULL COB';
              -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
             EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',cob_det.finca,cob_det.id_trab,cob_det.nom_t,cob_det.fecha,cob_det.tipo_cobro,cob_det.folio,'EXTRAVIO',estatus,monto);
            ELSE -- SI PASA TIPO DE COBRO
              raise notice 'SI PASA DATOS DE COBRO EN NULL COB';

              IF (cob_det.tipo_cobro = pIdTc) THEN -- RECIBE EL TIPO DE COBRO
                raise notice 'ELSE -- IF: TTC = DET NULL COB';
                EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',cob_det.finca,cob_det.id_trab,cob_det.nom_t,cob_det.fecha,cob_det.tipo_cobro,cob_det.folio,'EXTRAVIO',estatus,monto);
              END IF; -- IF VALIDACION POR TIPO (GFT/EPP)
            END IF; -- ELSE VALIDACION TODOS TIPOS DE COBRO

          ELSE -- SI PASA DATOS DE TRABAJADOR
            IF (cob_det.id_trab = pIdTr) THEN 
              raise notice 'SI PASA DATOS DEL TRABAJADOR COB';
              
              IF pIdTc = 'TODOS' THEN -- RECIBE  DE TODOS LOS COBROS
              raise notice 'ELSE -- IF: TRAB = DET (TC: TODOS) COB';
                -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
                EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',cob_det.finca,cob_det.id_trab,cob_det.nom_t,cob_det.fecha,cob_det.tipo_cobro,cob_det.folio,'EXTRAVIO',estatus,monto);
              ELSE -- SI PASA TIPO DE COBRO
                IF (cob_det.tipo_cobro = pIdTc) THEN -- RECIBE EL TIPO DE COBRO
                  raise notice 'ELSE -- IF: TRAB = DET (TC: DATO) COB';
                  EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',cob_det.finca,cob_det.id_trab,cob_det.nom_t,cob_det.fecha,cob_det.tipo_cobro,cob_det.folio,'EXTRAVIO',estatus,monto);
                END IF; -- IF VALIDACION POR TIPO (GFT/EPP)
              END IF; -- ELSE VALIDACION TODOS TIPOS DE COBRO
            END IF; -- IF VALIDACION TRABAJADOR
          END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
        END LOOP;  -- LOOP DE COBROS   
     close cobros; -- CIERRA CURSOR COBROS

       -- comenzar a correr el ciclo para detalle de REPOSICION:
    open repos(pIdFn,pIdFi,pIdfx);
      LOOP
        FETCH repos into rep_det; -- obtenemos valores del cursor
          raise notice 'rep_det: %', rep_det;

          EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
          
          select into cont_tot COUNT(*) AS tot from epp.reposiciones WHERE folio = rep_det.folio;
          select into cont_mat COUNT(*) AS mat from epp.reposiciones E WHERE e.surtido = true and folio = rep_det.folio;
          select into monto SUM(E.MONTO) AS PAGO from epp.reposiciones E WHERE e.SURTIDO = true and folio = rep_det.folio;
        
          raise notice 'TOTAL %, MAT %, MONTO %', cont_tot, cont_mat, monto;
        
            IF cont_tot = cont_mat THEN
              raise notice 'CONTADOR IGUAL ENTREGADO';
              estatus := 'SURTIDO';
            END IF;

            IF cont_tot > cont_mat THEN
              raise notice 'CONTADOR MAYOR ESTA PARCIAL';
              estatus := 'PARCIAL';
            END IF;

            IF cont_mat = 0 THEN
              raise notice 'CONTADOR MAT CERO PENDIENTE';
              estatus := 'PENDIENTE';
          END IF;
          
          IF monto is null THEN
            raise notice 'SUMATORIA ES NULL';
            monto := 0.0;
          END IF;
            
          IF pIdTr IS NULL THEN -- REPORTE GENERAL DE TODOS LOS TRBAJADORES
            raise notice 'TRABAJADOR NULL REP';

            IF pIdTc = 'TODOS' THEN -- RECIBE  DE TODOS LOS COBROS 
              raise notice 'TC: TODOS EN NULL REP';
              -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
              EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',rep_det.finca,rep_det.id_trab,rep_det.nom_t,rep_det.fecha,rep_det.tipo_cobro,rep_det.folio,'DETERIORO',estatus,monto);

            ELSE -- SI PASA TIPO DE COBRO
              IF (rep_det.tipo_cobro = pIdTc) THEN -- RECIBE EL TIPO DE COBRO
                raise notice 'TC: DATO EN NULL REP';
                EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',rep_det.finca,rep_det.id_trab,rep_det.nom_t,rep_det.fecha,rep_det.tipo_cobro,rep_det.folio,'DETERIORO',estatus,monto);
              END IF; -- IF VALIDACION POR TIPO (GFT/EPP)
            END IF; -- ELSE VALIDACION TODOS TIPOS DE COBRO

          ELSE -- SI PASA DATOS DE TRABAJADOR    
            IF (rep_det.id_trab = pIdTr) THEN 
              raise notice 'SI PASA DATOS DEL TRABAJADOR REP';
              
              IF pIdTc = 'TODOS' THEN -- RECIBE  DE TODOS LOS COBROS
              raise notice 'ELSE -- IF: TRAB = DET (TC: TODOS) REP';
                -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
                EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',rep_det.finca,rep_det.id_trab,rep_det.nom_t,rep_det.fecha,rep_det.tipo_cobro,rep_det.folio,'DETERIORO',estatus,monto);
              ELSE -- SI PASA TIPO DE COBRO
                IF (rep_det.tipo_cobro = pIdTc) THEN -- RECIBE EL TIPO DE COBRO
                  raise notice 'ELSE -- IF: TRAB = DET (TC: DATO) REP';
                  EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'rep_repos',rep_det.finca,rep_det.id_trab,rep_det.nom_t,rep_det.fecha,rep_det.tipo_cobro,rep_det.folio,'DETERIORO',estatus,monto);
                END IF; -- IF VALIDACION POR TIPO (GFT/EPP)
              END IF; -- ELSE VALIDACION TODOS TIPOS DE REPOSICION
            END IF; -- IF VALIDACION TRABAJADOR
          END IF; -- ELSE VALIDACION DE TODOS LOS TRABAJADORES
        END LOOP;  -- LOOP DE REPOSICION  
     close repos; -- CIERRA CURSOR REPOSICION
  END IF; -- ELSE IF VALIDACION TODAS LAS FINCAS 

return query select * from rep_repos; -- retorna consulta c/materiales a entregar 1

RETURN;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de reposiciones otorgadas desde almacen (gft/epp) ----------------------------
drop function epp.comprobante_repo_alm(varchar,varchar); -- 28
create or replace function epp.comprobante_repo_alm(varchar,varchar) returns setof record as $$
declare
  pidFn   alias for $1; -- nombre finca (no e ocupa)
  pIdTc   alias for $2; --  folio epp
  
  cobro_detwx    RECORD; -- valores: cobros 
  repo_detwx     RECORD; -- valores: reposiciones 
  
  cobrowx CURSOR(pIdTc varchar) FOR 
    SELECT DISTINCT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um, k.monto as costo, (CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, encode(t.foto,'base64') as foto, g.folio as foli_alm from public.trabajadores t 
    inner join public.labor l on t.id_labor = l.id_labor 
    inner join public.cargo c on t.id_cargo = c.id_cargo 
    inner join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
    inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
    inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
    inner join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
    inner join public.fincas f on f.id_finca = f.id_finca
    inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab and m.id_material=x.id_material
    inner join epp.det_mov_repo_epp_alm p on m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material 
    inner join epp.cobros_detalle k on p.folio = k.folio AND m.id_material = k.id_material and k.id_finca = f.id_finca and t.id_trab = k.id_trab 
    left join almacen.movimientos g on p.id_movimiento = g.id_movimiento 
    where p.folio = pIdTc;-- CURSOR P/COBROS 
   
  repowx CURSOR(pIdTc varchar) FOR 
    SELECT DISTINCT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um, z.monto as costo, (CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, encode(t.foto,'base64') as foto, g.folio as foli_alm from public.trabajadores t 
    inner join public.labor l on t.id_labor = l.id_labor 
    inner join public.cargo c on t.id_cargo = c.id_cargo 
    inner join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
    inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
    inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
    inner join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
    inner join public.fincas f on f.id_finca = f.id_finca
    inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab and m.id_material=x.id_material
    inner join epp.det_mov_repo_epp_alm p on m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material 
    inner join epp.reposiciones z on p.folio = z.folio AND m.id_material = z.id_material and z.id_finca = f.id_finca and t.id_trab = z.id_trab 
    left join almacen.movimientos g on p.id_movimiento = g.id_movimiento 
    where p.folio = pIdTc;

BEGIN
  CREATE TEMPORARY TABLE cntrl_sumatoria_repo_epp( -- tabla temporal p/almacenar datos
    folio varchar, -- folio epp
    finca varchar, -- finca
    id_trab varchar, -- id_trabajador
    nombre_completo varchar, -- nombre trab
    tipo_trab varchar, -- tipo
    cargo varchar, -- cargo
    area varchar, -- area
    labor varchar, -- labor
    id_material integer, -- id material
    clave varchar, -- clave mat
    nombre_material varchar, -- nombre mat
    cantidad numeric(10,3), -- cantidad mat
    um varchar, -- unidad de medida
    costo numeric(10,3), -- costo x repo
    estado varchar, -- status entregado alm
    foto text, -- foto trabajador extraida
    folio_alm varchar -- folio movimiento
 ) ON COMMIT DROP;
  
  open cobrowx(pIdTc);
    LOOP
      FETCH cobrowx into cobro_detwx; -- obtenemos valores del cursor COBRO X REPOSICIONES
        raise notice 'cobro_detwx: %', cobro_detwx;
          
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        raise notice 'SI PASA DATOS DEL COBRO REP';
        
        IF cobro_detwx.estado = 'ENTREGADO' THEN -- COMPARA SI EL MATERIAL YA FUE SURTIDO        
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'cntrl_sumatoria_repo_epp', cobro_detwx.folio,cobro_detwx.finca,cobro_detwx.id_trab,cobro_detwx.nombre_completo,cobro_detwx.tipo_trab,cobro_detwx.cargo,cobro_detwx.area,cobro_detwx.labor,cobro_detwx.id_material,cobro_detwx.clave,cobro_detwx.nombre_material,cobro_detwx.cantidad,cobro_detwx.um,cobro_detwx.costo,cobro_detwx.estado,cobro_detwx.foto,cobro_detwx.foli_alm);                 
        ELSE -- EL MATERIAL ESTA PENDIENTE DE ENTREGA
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'cntrl_sumatoria_repo_epp', cobro_detwx.folio,cobro_detwx.finca,cobro_detwx.id_trab,cobro_detwx.nombre_completo,cobro_detwx.tipo_trab,cobro_detwx.cargo,cobro_detwx.area,cobro_detwx.labor,cobro_detwx.id_material,cobro_detwx.clave,cobro_detwx.nombre_material,cobro_detwx.cantidad,cobro_detwx.um,0.00,cobro_detwx.estado,cobro_detwx.foto,cobro_detwx.foli_alm);  
       END IF; -- VALIDACION DE STATUS DE ENTREGA
    END LOOP;  -- LOOP DE COBRO  
  close cobrowx; -- CIERRA CURSOR COBRO
     
  open repowx(pIdTc);
    LOOP
      FETCH repowx into repo_detwx; -- obtenemos valores del cursor REPOSICION GRATIS
        raise notice 'repo_detwx: %', repo_detwx;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        raise notice 'SI PASA DATOS DEL REPO REP';
        
      IF repo_detwx.estado = 'ENTREGADO' THEN -- COMPARA SI EL MATERIAL YA FUE SURTIDO
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'cntrl_sumatoria_repo_epp', repo_detwx.folio,repo_detwx.finca,repo_detwx.id_trab,repo_detwx.nombre_completo,repo_detwx.tipo_trab,repo_detwx.cargo,repo_detwx.area,repo_detwx.labor,repo_detwx.id_material,repo_detwx.clave,repo_detwx.nombre_material,repo_detwx.cantidad,repo_detwx.um,repo_detwx.costo,repo_detwx.estado,repo_detwx.foto,repo_detwx.foli_alm);  
      ELSE
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'cntrl_sumatoria_repo_epp', repo_detwx.folio,repo_detwx.finca,repo_detwx.id_trab,repo_detwx.nombre_completo,repo_detwx.tipo_trab,repo_detwx.cargo,repo_detwx.area,repo_detwx.labor,repo_detwx.id_material,repo_detwx.clave,repo_detwx.nombre_material,repo_detwx.cantidad,repo_detwx.um,0.00,repo_detwx.estado,repo_detwx.foto,repo_detwx.foli_alm);  
      END IF; -- VALIDACION STATUS DE ENTREGA
    END LOOP;  -- LOOP DE REPOSICION  
  close repowx; -- CIERRA CURSOR REPOSICION
    
return query select * from cntrl_sumatoria_repo_epp; -- retorna consulta c/materiales a entregar

RETURN;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de reposiciones detalladas por folio enf (gft/epp) ----------------------------
drop function epp.repo_det_reposicion(varchar,varchar); -- 29
create or replace function epp.repo_det_reposicion(varchar,varchar) returns setof record as $$
declare
  pidFn   alias for $1; -- nombre finca (no se ocupa)
  pIdTc   alias for $2; --  folio epp
  
  cobro_detwx    RECORD; -- valores: cobros 
  repo_detwx     RECORD; -- valores: reposiciones 
  
  cobrowx CURSOR(pIdTc varchar) FOR 
    SELECT DISTINCT k.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, concat(1) as cantidad, u.nombre_unidad_medida as um, k.monto as costo, (CASE WHEN k.surtido = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado from public.trabajadores t 
    inner join public.labor l on t.id_labor = l.id_labor 
    inner join public.cargo c on t.id_cargo = c.id_cargo 
    inner join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
    inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
    inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
    inner join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
    inner join public.fincas f on f.id_finca = f.id_finca
    inner join epp.cobros_detalle k on m.id_material=k.id_material and k.id_finca=f.id_finca and t.id_trab=k.id_trab 
    where k.folio = pIdTc;-- CURSOR P/COBROS 
   
  repowx CURSOR(pIdTc varchar) FOR 
    SELECT DISTINCT k.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, concat(1) as cantidad, u.nombre_unidad_medida as um, k.monto as costo, (CASE WHEN k.surtido = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado from public.trabajadores t 
    inner join public.labor l on t.id_labor = l.id_labor 
    inner join public.cargo c on t.id_cargo = c.id_cargo 
    inner join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
    inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
    inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
    inner join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
    inner join public.fincas f on f.id_finca = f.id_finca
    inner join epp.reposiciones k on m.id_material=k.id_material and k.id_finca=f.id_finca and t.id_trab=k.id_trab 
    where k.folio = pIdTc;-- CURSOR P/COBROS 

BEGIN
  CREATE TEMPORARY TABLE repo_det_reposicion( -- tabla temporal p/almacenar datos
    folio varchar, -- folio epp
    finca varchar, -- finca
    id_trab varchar, -- id_trabajador
    nombre_completo varchar, -- nombre trab
    tipo_trab varchar, -- tipo
    cargo varchar, -- cargo
    area varchar, -- area
    labor varchar, -- labor
    id_material integer, -- id material
    clave varchar, -- clave mat
    nombre_material varchar, -- nombre mat
    cantidad numeric(10,3), -- cantidad mat
    um varchar, -- unidad de medida
    costo numeric(10,3), -- costo x repo
    estado varchar -- status entregado alm
 ) ON COMMIT DROP;
  
  open cobrowx(pIdTc);
    LOOP
      FETCH cobrowx into cobro_detwx; -- obtenemos valores del cursor COBRO X REPOSICIONES
        raise notice 'cobro_detwx: %', cobro_detwx;
          
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        raise notice 'SI PASA DATOS DEL COBRO REP';
        
        IF cobro_detwx.estado = 'ENTREGADO' THEN -- COMPARA SI EL MATERIAL YA FUE SURTIDO        
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'repo_det_reposicion', cobro_detwx.folio,cobro_detwx.finca,cobro_detwx.id_trab,cobro_detwx.nombre_completo,cobro_detwx.tipo_trab,cobro_detwx.cargo,cobro_detwx.area,cobro_detwx.labor,cobro_detwx.id_material,cobro_detwx.clave,cobro_detwx.nombre_material,cobro_detwx.cantidad,cobro_detwx.um,cobro_detwx.costo,cobro_detwx.estado);                 
        ELSE -- EL MATERIAL ESTA PENDIENTE DE ENTREGA
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'repo_det_reposicion', cobro_detwx.folio,cobro_detwx.finca,cobro_detwx.id_trab,cobro_detwx.nombre_completo,cobro_detwx.tipo_trab,cobro_detwx.cargo,cobro_detwx.area,cobro_detwx.labor,cobro_detwx.id_material,cobro_detwx.clave,cobro_detwx.nombre_material,cobro_detwx.cantidad,cobro_detwx.um,0.00,cobro_detwx.estado);  
       END IF; -- VALIDACION DE STATUS DE ENTREGA
    END LOOP;  -- LOOP DE COBRO  
  close cobrowx; -- CIERRA CURSOR COBRO
     
  open repowx(pIdTc);
    LOOP
      FETCH repowx into repo_detwx; -- obtenemos valores del cursor REPOSICION GRATIS
        raise notice 'repo_detwx: %', repo_detwx;

        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        raise notice 'SI PASA DATOS DEL REPO REP';
        
      IF repo_detwx.estado = 'ENTREGADO' THEN -- COMPARA SI EL MATERIAL YA FUE SURTIDO
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'repo_det_reposicion', repo_detwx.folio,repo_detwx.finca,repo_detwx.id_trab,repo_detwx.nombre_completo,repo_detwx.tipo_trab,repo_detwx.cargo,repo_detwx.area,repo_detwx.labor,repo_detwx.id_material,repo_detwx.clave,repo_detwx.nombre_material,repo_detwx.cantidad,repo_detwx.um,repo_detwx.costo,repo_detwx.estado);  
      ELSE
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'repo_det_reposicion', repo_detwx.folio,repo_detwx.finca,repo_detwx.id_trab,repo_detwx.nombre_completo,repo_detwx.tipo_trab,repo_detwx.cargo,repo_detwx.area,repo_detwx.labor,repo_detwx.id_material,repo_detwx.clave,repo_detwx.nombre_material,repo_detwx.cantidad,repo_detwx.um,0.00,repo_detwx.estado);  
      END IF; -- VALIDACION STATUS DE ENTREGA
    END LOOP;  -- LOOP DE REPOSICION  
  close repowx; -- CIERRA CURSOR REPOSICION
    
return query select * from repo_det_reposicion; -- retorna consulta c/materiales a entregar

RETURN;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de nuevos (gft/epp) ----------------------------
drop function epp.distribucion_material(varchar,varchar,varchar,varchar); -- 30
create or replace function epp.distribucion_material(varchar,varchar,varchar,varchar)  returns setof record as $$
declare
  pidWc   alias for $1; -- filtro p/busqueda
  pIdTr   alias for $2; -- id_trab 
  pIdMt   alias for $3; -- nombre_material
  pIdFn   alias for $4; -- nombre_finca
  
  rep_trab    RECORD; -- valores: por trabajador 
  rep_mate    RECORD; -- valores: por material
  rep_todo    RECORD; -- valores: todos trab y mat
  
  trabajador CURSOR(pIdTr varchar, pIdFn varchar) FOR 
    SELECT DISTINCT f.nombre_finca,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 0 or x.estado_epp = 1) and t.id_trab = pIdTr and f.nombre_finca = pIdFn; -- TRABAJADORES
  
  material CURSOR(pIdMt varchar, pIdFn varchar) FOR 
    SELECT DISTINCT f.nombre_finca,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 0 or x.estado_epp = 1) and m.nombre_material = pIdMt and f.nombre_finca = pIdFn;
    
   todos CURSOR(pIdFn varchar) FOR 
    SELECT DISTINCT f.nombre_finca,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 0 or x.estado_epp = 1) and f.nombre_finca = pIdFn;

BEGIN
  
  CREATE TEMPORARY TABLE distribucion_material(
    finca varchar, -- nombre finca
    id_trab varchar, -- id trabajador
    nombre_completo varchar, -- nombre de trabajador
    clave varchar, -- clave material
    nombre_material varchar, -- nombre_ material
    cantidad integer, -- cantidad material
    um varchar, -- unidad de medida
    estado_epp varchar -- estatus de uso
  ) ON COMMIT DROP;

  IF pidWc = 'TODOS' THEN -- TODOS LOS FILTROS
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open todos(pIdFn);
      LOOP
        FETCH todos into rep_todo; -- obtenemos valores del cursor
        raise notice 'rep_todo: %', rep_todo;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L)', 'distribucion_material', rep_todo.nombre_finca,rep_todo.id_trab,rep_todo.nombre_completo,rep_todo.clave,rep_todo.nombre_material,1,rep_todo.um,rep_todo.estado_epp);   
      END LOOP;  -- LOOP DE REPOSICION  
    close todos; -- CIERRA CURSOR REPOSICION
  END IF; -- VALIDACION DE TODOS 

  IF pidWc = 'TRABAJADORES' THEN -- TRABAJADORES LOS FILTROS
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open trabajador(pIdTr,pIdFn);
      LOOP
        FETCH trabajador into rep_trab; -- obtenemos valores del cursor
        raise notice 'rep_trab: %', rep_trab;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L)', 'distribucion_material', rep_trab.nombre_finca,rep_trab.id_trab,rep_trab.nombre_completo,rep_trab.clave,rep_trab.nombre_material,1,rep_trab.um,rep_trab.estado_epp);   
      END LOOP;  -- LOOP DE REPOSICION  
    close trabajador; -- CIERRA CURSOR REPOSICION
  END IF; -- VALIDACION DE TRABAJADORES 
  
  IF pidWc = 'MATERIALES' THEN -- TRABAJADORES LOS FILTROS
    -- comenzar a correr el ciclo para detalle de REPOSICION:
    open material(pIdMt,pIdFn);
      LOOP
        FETCH material into rep_mate; -- obtenemos valores del cursor
        raise notice 'rep_mate: %', rep_mate;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L)', 'distribucion_material', rep_mate.nombre_finca,rep_mate.id_trab,rep_mate.nombre_completo,rep_mate.clave,rep_mate.nombre_material,1,rep_mate.um,rep_mate.estado_epp);   
      END LOOP;  -- LOOP DE REPOSICION  
    close material; -- CIERRA CURSOR REPOSICION
    
  END IF; -- VALIDACION DE MATERIALES 

return query select * from distribucion_material; -- retorna consulta c/materiales a entregar 1

RETURN;
END;
$$ language plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para transferir trabajador ----------------------------
CREATE OR REPLACE FUNCTION transferir_trabajador(character varying, integer, integer, integer, character varying, character varying, character varying, character varying) -- 31
  RETURNS integer AS
$$ declare
	-- id_trab $1;
	-- id_fincaSend $2;
	-- id_fincaTrab $3;
	-- tipoTransf $4;
	-- fechaRegistro $5;
	-- fechaIngreso $6;
	-- comentario $7;
	-- clave_finca $8;
	
	veri record;

	total integer;
	transfer integer;
	idNext character varying;
	
	-- 0 No se pudo
	-- 1 Transferido
	-- 2 El trabajador fue Dado de baja
	-- 3 El trabajador tiene la misma finca asignada
begin	
	veri=null;
	transfer = 1;
	
	SELECT into veri id_trab, id_finca, id_tipo_trab, fecha_ingreso, fecha_registro, turno24, status_trab from trabajadores WHERE id_trab=$1;

	SELECT INTO total count(id_baja) FROM baja_trabajadores WHERE id_finca=$3;
	total = total + 1;
		

	if total = 0 then
		idNext = CONCAT($8,total);
	else
		if total > 99 then
			idNext = CONCAT($8,'0');
			idNext = CONCAT(idNext,total);
		else
			if total > 9 then
				idNext = CONCAT($8,'00');
				idNext = CONCAT(idNext,total);
			else
				idNext = CONCAT($8,'000');
				idNext = CONCAT(idNext,total);
			end if;
		end if;
	end if;

	if  veri.status_trab=0 then --si esta dado de baja
		raise notice '1) el empleado ya fue dado de baja ';
		return 2;
	end if;
	
	if veri.status_trab is null then
		raise notice '1) el empleado tiene un status Nulo ';
		return 0;
	end if;	

	if veri.status_trab=1 then
		if veri.id_finca=$2 then
			raise notice '1) el empleado tiene la misma finca asignada';
			return 3;
		else
			insert into baja_trabajadores(id_baja,id_trab,id_finca,id_tipo_trab,fecha_ingreso, fecha_registro,id_tipo_baja,comentario,fecha_baja,turno24,transferencia,id_finca_transferencia) values(idNext,$1,$3,veri.id_tipo_trab,veri.fecha_ingreso, veri.fecha_registro, $4, $7, current_date::text,veri.turno24,transfer,$2);	
			UPDATE trabajadores SET id_finca=$2, fecha_ingreso=$6 WHERE id_trab=$1;
            UPDATE trabajadores SET vale_gen = '0', gafete = null WHERE id_trab=$1;
			return 1;
		end if;
	end if;
end;
$$ LANGUAGE plpgsql; -- OK

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////// */

/* FALTA AGREGAR EL SCRIPT P/TAREA PROGRAMADA DE COBRO POR NO DEVOLVER PRESTAMO */
