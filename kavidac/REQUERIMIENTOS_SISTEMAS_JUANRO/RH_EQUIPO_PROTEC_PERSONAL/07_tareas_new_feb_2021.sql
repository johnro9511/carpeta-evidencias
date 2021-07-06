/* /////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- insert new type of moviment for unlocked people's *
insert into public.tipos_de_movimientos values(17,'Se Desbloqueo Trabajador',1); -- OK

-- NUEVO PERMISO PARA VER NOTIFICACIONES PENDIENTES **
alter table public.privilegios_usuarios add column noti_pen integer default 0; -- p/ver notificaciones

ALTER TABLE public.area_trabajo ADD COLUMN estado boolean DEFAULT true; -- OK
ALTER TABLE public.cargo ADD COLUMN estado boolean DEFAULT true; -- OK

-- ==> INGRESAR CATALOGO DE LABORES A NIVEL DE BASE DE DATOS || CREAR MODULO P/INSERTAR LABORES (no se pudo... xD)
INSERT INTO PUBLIC.LABOR VALUES (65,'NO ASIGNADO',1); -- OK

-- TABLA P/EL CONTROL DE TRABAJADORES BLOQUEADOS
CREATE TABLE trab_bloqueados(
  id_trabx serial primary key,
  nombres varchar,
  ape_pat varchar,
  ape_mat varchar,
  motivo varchar,
  -- estado: 0-. bloqueado, 1-. desbloqueado
  estado integer default 0,
  fecha date default current_date
);

insert into trab_bloqueados(nombres,ape_pat,ape_mat,motivo) values('FRANCISCO GUILLERMO','OCHOA','LOPEZ','AGRESION AL COMPAÑERO');
insert into trab_bloqueados(nombres,ape_pat,ape_mat,motivo) values('HENRY JAVIER','MARTIN','PEREZ','AGRESION AL COMPAÑERO');
insert into trab_bloqueados(nombres,ape_pat,ape_mat,motivo) values('EMMANUEL LAZOS','AGUILERA','GALVES','AGRESION AL COMPAÑERO');
insert into trab_bloqueados(nombres,ape_pat,ape_mat,motivo) values('PAUL NICOLAR','AGUILAR','CARDENAS','AGRESION AL COMPAÑERO');
insert into trab_bloqueados(nombres,ape_pat,ape_mat,motivo) values('RICHARD OCTAVIO','SANCHEZ','MENDEZ','AGRESION AL COMPAÑERO');
insert into trab_bloqueados(nombres,ape_pat,ape_mat,motivo) values('SEBASTIAN MARCIAL','CORDOVA','GONZALEZ','AGRESION AL COMPAÑERO');
insert into trab_bloqueados(nombres,ape_pat,ape_mat,motivo) values('JORGE DOROTEO','SANCHEZ','RIOS','AGRESION AL COMPAÑERO');

-- consulta p/validar trab. bloqueados al dar de alta.
select COUNT(*) as bloq FROM trab_bloqueados where nombres like '%SER_%' AND APE_PAT='LOPEZ' AND APE_MAT='CRUZ' AND ESTADO=0;

/* /////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- FUNCION ACTUALIZADA P/DAR DE BAJA A TRABAJADOR
-- DROP FUNCTION xxdar_de_baja_trabajador_r; -- 1
CREATE OR REPLACE FUNCTION xxdar_de_baja_trabajador_r(varchar,integer,integer,varchar,varchar,integer) RETURNS integer AS $$
declare
	-- id_trab $1;
	-- id_finca $2;
	-- tipo_de_baja $3; 
	-- comentario $4;
	-- clave_finca $5;
    -- asignacion $6; (1-. DAR DE BAJA, 2.- RECHAZADO, 6-. BAJA POR TERMINO CONTRATO)
	veri record;
	total integer;
	transfer integer;
	idFincaTransfer integer;
	idNext character varying;
	
	-- 0 No se pudo
	-- 1 Dado De Baja
	-- 2 Ya fue dado de baja
begin	
  
  PERFORM documentos.baja_docs($1); -- dando de baja documentacion de trabajador
  
  IF ($6 = 1 OR $6 = 6) THEN
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

		if  veri.status_trab=0 then -- si esta dado de baja
			raise notice '1) el empleado ya fue dado de baja ';
			return 2;
		end if;
		
		if veri.status_trab is null then
			raise notice '1) el empleado tiene un status Nulo ';
			return 0;
		end if;	

		if veri.status_trab=1 then -- TRABAJADOR ACTIVO
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

		if  veri.status_trab=2 then -- si esta RECHAZADO
			raise notice '1) el empleado ya fue RECHAZADO';
			return 3;
		end if;
		
		if veri.status_trab is null then
			raise notice '1) el empleado tiene un status Nulo ';
			return 0;
		end if;	
        
        if veri.status_trab=0 then -- ESTA DADO DE BAJA
            raise notice '1) ACTUALIZANDO ESTATUS DEL TRABAJADOR P/RECHAZAR DADO DE BAJA';
			insert into baja_trabajadores(id_baja,id_trab,id_finca,id_tipo_trab,fecha_ingreso, fecha_registro,id_tipo_baja,comentario,fecha_baja,turno24,transferencia,id_finca_transferencia) values(idNext,$1,$2,veri.id_tipo_trab,veri.fecha_ingreso,veri.fecha_registro,$3,$4, current_date::text,veri.turno24, transfer, idFincaTransfer);	
			-- AGREGO ACTUALIZACION PARA EL ESTADO DEL VALE_GEN = 0 
			UPDATE trabajadores SET status_trab='2', vale_gen = '0', gafete = null, motivo_rechazo = $4 WHERE id_trab=$1;
			return 1;
		end if;	
        
		if veri.status_trab=3 then -- TRABAJADOR PENDIENTE 
            raise notice '1) ACTUALIZANDO ESTATUS DEL TRABAJADOR P/RECHAZAR';
			insert into baja_trabajadores(id_baja,id_trab,id_finca,id_tipo_trab,fecha_ingreso, fecha_registro,id_tipo_baja,comentario,fecha_baja,turno24,transferencia,id_finca_transferencia) values(idNext,$1,$2,veri.id_tipo_trab,veri.fecha_ingreso,veri.fecha_registro,$3,$4, current_date::text,veri.turno24, transfer, idFincaTransfer);	
			-- AGREGO ACTUALIZACION PARA EL ESTADO DEL VALE_GEN = 0 
			UPDATE trabajadores SET status_trab='2', vale_gen = '0', gafete = null, motivo_rechazo = $4 WHERE id_trab=$1;
			return 1;
		end if;	
        
        if veri.status_trab=4 then -- TRABAJADOR EN REINGRESO
            raise notice '1) ACTUALIZANDO ESTATUS DEL TRABAJADOR P/RECHAZAR';
			insert into baja_trabajadores(id_baja,id_trab,id_finca,id_tipo_trab,fecha_ingreso, fecha_registro,id_tipo_baja,comentario,fecha_baja,turno24,transferencia,id_finca_transferencia) values(idNext,$1,$2,veri.id_tipo_trab,veri.fecha_ingreso,veri.fecha_registro,$3,$4, current_date::text,veri.turno24, transfer, idFincaTransfer);	
			-- AGREGO ACTUALIZACION PARA EL ESTADO DEL VALE_GEN = 0 
			UPDATE trabajadores SET status_trab='2', vale_gen = '0', gafete = null, motivo_rechazo = $4 WHERE id_trab=$1;
			return 1;
		end if;	
  END IF; -- ELSE VALIDACION DE ASIGNACION   
END;
$$ LANGUAGE plpgsql; -- OK *

/* //////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- FUNCION NVA P/DESBLOQUEAR TRABAJADOR
-- DROP FUNCTION desbloquear_trabajador; -- 2
CREATE OR REPLACE FUNCTION desbloquear_trabajador(varchar,integer,integer,varchar,varchar,integer) RETURNS integer AS $$
declare
	-- id_trab $1;
	-- id_finca $2;
	-- tipo_de_baja $3; 
	-- comentario $4;
	-- clave_finca $5;
    -- asignacion $6; (7-. DESBLOQUEAR TRABAJADOR)
	veri record;
	total integer;
	transfer integer;
	idFincaTransfer integer;
	idNext character varying;
begin	
  raise notice 'VALIDACION P/DESBLOQUEAR';
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

  if  veri.status_trab=0 then -- si esta en baja
    raise notice '1) el empleado ya fue DESBLOQUEADO';
    return 2;
  end if;
  
  if  veri.status_trab=1 then -- si esta en baja
    raise notice '1) el empleado ya fue DESBLOQUEADO ACTIVADO';
    return 2;
  end if;
  
  if  veri.status_trab=4 then -- si esta en baja
    raise notice '1) el empleado ya fue DESBLOQUEADO ACTIVADO REINGRESO';
    return 2;
  end if;
		
  if veri.status_trab=2 then -- ESTA RECHAZADO
    raise notice '1) ACTUALIZANDO ESTATUS DEL TRABAJADOR P/DESBLOQUEAR A DADO DE BAJA';
	insert into baja_trabajadores(id_baja,id_trab,id_finca,id_tipo_trab,fecha_ingreso, fecha_registro,id_tipo_baja,comentario,fecha_baja,turno24,transferencia,id_finca_transferencia) values(idNext,$1,$2,veri.id_tipo_trab,veri.fecha_ingreso,veri.fecha_registro,$3,$4, current_date::text,veri.turno24, transfer, idFincaTransfer);	
    -- AGREGO ACTUALIZACION PARA EL ESTADO DEL VALE_GEN = 0 
	UPDATE trabajadores SET status_trab='0', vale_gen = '0', gafete = null, motivo_rechazo = $4 WHERE id_trab=$1;
	return 1;
  end if;	      		
END;
$$ LANGUAGE plpgsql; -- OK *

/* //////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- VALIDAR INSERCCION DE TRABAJADORES BLOQUEADOS (LISTA NEGRA) REVISANDO SI ESTA ACTIVO EN FINCA**
select COUNT(*) as bloq FROM trab_bloqueados where nombres like '%SER_%' AND APE_PAT='LOPEZ' AND APE_MAT='CRUZ' AND ESTADO=0;
select COUNT(*) as bloq FROM trabajadores where nombre_trab like '%EDUARDO%' AND APE_PATerno='VILLAGRAN' AND APE_MATerno='CRUZ' AND status_trab between 0 and 4;

/* //////////////////////////////////////////////////////////////////////////////////////////////////////// */
