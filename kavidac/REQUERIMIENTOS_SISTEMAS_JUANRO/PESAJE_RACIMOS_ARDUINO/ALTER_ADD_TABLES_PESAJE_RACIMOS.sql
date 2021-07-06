-- CREACION DE CATALOGO DE COLOR DE CINTAS
create table public.cat_cintas(
  idcinta integer primary key,
  colorcinta varchar,
  estado integer default 1
);

insert into cat_cintas values (1,'SIN COLOR');
insert into cat_cintas values (2,'NARANJA');
insert into cat_cintas values (3,'AZUL');
insert into cat_cintas values (4,'BLANCO');
insert into cat_cintas values (5,'AMARILLO');
insert into cat_cintas values (6,'NEGRO');
insert into cat_cintas values (7,'ROJO');
insert into cat_cintas values (8,'GRIS');
insert into cat_cintas values (9,'VERDE');
insert into cat_cintas values (10,'LILA');
insert into cat_cintas values (11,'CAFE');
insert into cat_cintas values (12,'PITA');

-- AGREGAR COLUMNA EN DETALLE_CARGA REFERENCIANDO EL COLOR DE CINTA
alter table public.detalle_carga add column idcinta integer references cat_cintas;

/* ////////////////////////// PROCEDIMIENTO P/GENERAR REGISTRO DE RACIMOS ///////////////////////////////// */
-- DROP FUNCTION public.alta_carga(text[], text[]);
CREATE OR REPLACE FUNCTION public.alta_carga(
	pdatos_movimiento text[],
	pdatos_carga text[])
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE
AS $BODY$
DECLARE
	vQuery			text; 
	vrespuesta		text;
	vCantidad		INT;
	contador		INT;
	longitud_datos		INT;
	vFolio			text;
	vNextfolio		text;
	vId_carga		INT;
	vId_finca		INT; 
	vNum_carga		INT;
	vAbrev_finca		text;
    vId_cinta		INT; 
	
BEGIN
	longitud_datos:=array_length(pdatos_movimiento,1);
	FOR contador IN 1..longitud_datos LOOP 
		RAISE NOTICE 'VALORES ARRAY [%]=%',contador,pdatos_movimiento[contador];
	END LOOP;
	
	longitud_datos:=array_length(pdatos_carga,1);
	FOR contador IN 1..longitud_datos LOOP 
		RAISE NOTICE 'VALORES ARRAY [%][1]=%',contador,pdatos_carga[contador][1];
		RAISE NOTICE 'VALORES ARRAY [%][2]=%',contador,pdatos_carga[contador][2];
        RAISE NOTICE 'VALORES ARRAY [%][3]=%',contador,pdatos_carga[contador][3];
	END LOOP;
	
	SELECT id_finca, abrev_finca INTO vId_finca, vAbrev_finca FROM finca WHERE id_finca=pdatos_movimiento[1]::int;
	
	SELECT (COALESCE (COUNT(*),0)+1) :: INT INTO vCantidad FROM carga WHERE id_finca=pdatos_movimiento[1]::int;
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

	SELECT (COALESCE (COUNT(num_carga),0)+1) :: INT  INTO vNum_carga FROM carga WHERE id_finca=pdatos_movimiento[1] :: INT and fecha :: date =  current_date ;
	
	vQuery = 'INSERT INTO carga (num_carga, cant_racimo, total_kg,id_finca,folio,id_lote,torre_ini,torre_fin) VALUES ('||vNum_carga||','||pdatos_movimiento[3]||','||pdatos_movimiento[4]||','||vId_finca||','''||vNextfolio||''','||pdatos_movimiento[5]||','||pdatos_movimiento[6]||','||pdatos_movimiento[7]||')';
	RAISE NOTICE 'vQuery --> %',vQuery;
	EXECUTE vQuery;
	longitud_datos:=array_length(pdatos_carga,1);
	SELECT id_carga INTO vId_carga FROM carga WHERE folio = vNextfolio;
	FOR contador IN 1..longitud_datos LOOP 
		RAISE NOTICE 'VALORES ARRAY [%][1]=%',contador,pdatos_carga[contador][1];
		RAISE NOTICE 'VALORES ARRAY [%][2]=%',contador,pdatos_carga[contador][2];
        RAISE NOTICE 'VALORES ARRAY [%][3]=%',contador,pdatos_carga[contador][3];
        
        SELECT idcinta INTO vId_cinta FROM public.cat_cintas WHERE colorcinta=pdatos_carga[contador][3];
        
		vQuery='INSERT INTO detalle_carga (id_carga, cns, peso_kg, idcinta) VALUES ('||vId_carga||','||pdatos_carga[contador][1]||','||pdatos_carga[contador][2]||','||vId_cinta||')';
		RAISE NOTICE 'vQuery --> %',vQuery;
		EXECUTE vQuery;
	END LOOP;
	
	SELECT COUNT(id_carga) INTO vCantidad FROM detalle_carga WHERE id_carga=vId_carga;
	if(vCantidad>0) then
		vrespuesta=vNextfolio;
	ELSE 
		vrespuesta='ALGO MAL A OCURRIDO, VERIFIQUE LA INFORMACIÓN.';
	END IF;
	RETURN vrespuesta;
END;
$BODY$;
/* ////////////////////////// ///////////////////////////////// ///////////////////////////////// */
