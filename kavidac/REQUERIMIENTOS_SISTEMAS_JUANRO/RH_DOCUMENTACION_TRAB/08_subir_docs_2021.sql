-- SE CREA ESQUEMA P/CONTROL DE DOCUMENTOS OFICIALES DE TRABAJADORES
CREATE SCHEMA documentos;

-- TRABAJADORES MEXICANOS
CREATE TABLE documentos.acta( -- 1 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.curp( -- 2 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.rfc( -- 3 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.ine( -- 4 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.comp_domicilio( -- 5 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.comp_estudios( -- 6 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.nss( -- 7 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.const_fiscal( -- 8 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.ant_penales( -- 9 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

-- TRABAJADORES EXTRANJEROS
CREATE TABLE documentos.dpi( -- 10 * <<IDENTIFICACION_EXT>> OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.pase_agricola( -- 11 * <<TRAJETA_RESIDENCIA>> OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.comp_domi_ext( -- 12 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

-- DOCUMENTOS FINALES (MEX/EXT)
CREATE TABLE documentos.contrato( -- 13 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.evaluacion( -- 14 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.beneficiario( -- 15 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

CREATE TABLE documentos.cuestionario( -- 16 * OK
  id_trab varchar references public.trabajadores,
  url varchar,
  fechahora timestamp default current_timestamp(0),
  edo_doc integer default 1, -- estado del documento: 1-activo, 2-desactivado
  primary key(id_trab)
);

/* ///////////////////////////////////////// PROCEDIMIENTOS /////////////////////////////////////////////////////////// */
-- FUNCION NVA P/INSERTAR REGISTROS DE DOCUMENTOS
-- DROP FUNCTION documentos.guardar_documento; -- 1 OK
CREATE OR REPLACE FUNCTION documentos.guardar_documento(id_t varchar,ruta varchar,ref varchar) RETURNS integer AS $$
declare
	veri record;	
begin	
  raise notice 'VALIDACION P/DUARDAR DOCUMENTO';
  -- ---------------------------------------------------------------------------------------------------------------------------  
  if (ref='ACTA') then -- tb1
    SELECT into veri id_trab,url from documentos.acta WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.acta values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.acta SET url=ruta, fechahora = current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia acta	    
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='CURP') then -- tb2
    SELECT into veri id_trab,url from documentos.curp WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.curp values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.curp SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia curp	
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='RFC') then -- tb3
    SELECT into veri id_trab,url from documentos.rfc WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.rfc values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.rfc SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia rfc 
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='INE') then -- tb4
    SELECT into veri id_trab,url from documentos.ine WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.ine values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.ine SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia ine	   
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='COMP_DOMICILIO') then -- tb5
    SELECT into veri id_trab,url from documentos.comp_domicilio WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.comp_domicilio values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.comp_domicilio SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia comp_domicilio  
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='COMP_ESTUDIOS') then -- tb6
    SELECT into veri id_trab,url from documentos.comp_estudios WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.comp_estudios values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.comp_estudios SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia comp_estudios  
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='NSS') then -- tb7
    SELECT into veri id_trab,url from documentos.nss WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.nss values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.nss SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia nss  
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='CONST_FISCAL') then -- tb8
    SELECT into veri id_trab,url from documentos.const_fiscal WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.const_fiscal values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.const_fiscal SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia const_fiscal  
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='ANT_NO_PENALES') then -- tb9
    SELECT into veri id_trab,url from documentos.ant_penales WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.ant_penales values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.ant_penales SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia ant_penales  
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='IDENTIFICACION_EXT') then -- tb10 <<DPI>>
    SELECT into veri id_trab,url from documentos.dpi WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.dpi values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.dpi SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia dpi 
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='TARJETA_RESIDENCIA') then -- tb11 <<PASE_AGRICOLA>>
    SELECT into veri id_trab,url from documentos.pase_agricola WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.pase_agricola values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.pase_agricola SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia pase_agricola 
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='COMP_DOMICILIO_EXT') then -- tb12
    SELECT into veri id_trab,url from documentos.comp_domi_ext WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.comp_domi_ext values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.comp_domi_ext SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia comp_domi_ext 
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='CONTRATO') then -- tb13
    SELECT into veri id_trab,url from documentos.contrato WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.contrato values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.contrato SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia contrato  
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='EVALUACION') then -- tb14
    SELECT into veri id_trab,url from documentos.evaluacion WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.evaluacion values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.evaluacion SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia evaluacion 
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='BENEFICIARIO') then -- tb15
    SELECT into veri id_trab,url from documentos.beneficiario WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.beneficiario values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.beneficiario SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia beneficiario 
  -- ---------------------------------------------------------------------------------------------------------------------------
  if (ref='CUESTIONARIO') then -- tb16
    SELECT into veri id_trab,url from documentos.cuestionario WHERE id_trab=id_t;

    if (veri is null) then -- si esta en baja
      raise notice '1) el empleado no tiene registros';
      insert into documentos.cuestionario values(id_t,ruta);	
      return 1;
    else
      raise notice '1) el empleado ya tiene registros';
      UPDATE documentos.cuestionario SET url=ruta, fechahora =current_timestamp(0), edo_doc = 1 WHERE id_trab=id_t;
      return 2;
    end if;-- if validando si ya tiene registros
  end if;-- if validacion de referencia cuestionario
  -- ---------------------------------------------------------------------------------------------------------------------------
END;
$$ LANGUAGE plpgsql; -- OK

/* EJECUTANDO EJEMPLO DEL PROCEDIMIENTO */
select documentos.guardar_documento('FM1314','JDHJKS/DFEFD/LDKAF.pdf','ACTA');

/* ///////////////////////////////////////// PROCEDIMIENTOS /////////////////////////////////////////////////////////// */
-- funcion NVA p/dar generar reporte de cajas por rango de fecha
-- DROP FUNCTION documentos.ver_docs(varchar); OK
CREATE OR REPLACE FUNCTION documentos.ver_docs(id_t varchar) returns setof record as $$
declare    
    actax record;  curpx record;  rfcx record;  inex record;  comp_domiciliox record;  comp_estudiosx record;  nssx record;  const_fiscalx record;  ant_penalesx record;  dpix record;  pase_agricolax record;  comp_domi_extx record;  contratox record;  evaluacionx record;  beneficiariox record;  cuestionariox record;  
begin	

  CREATE TEMPORARY TABLE registros(-- tb temporal p/almacenar registros
    trab varchar, -- folio trab
    ruta varchar, -- ruta del archivo
    ref varchar -- referencia de arch
  ) on commit drop;
  
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into actax * from documentos.acta where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'ACTA: %', actax;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO ACTA';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','ACTA');  
    ELSE
      raise notice 'VALORES TIENE DATOS ACTA';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', actax.id_trab,actax.url,'ACTA'); 
    END IF;   
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into curpx * from documentos.curp where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'CURP: %', curpx;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO CURP';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','CURP');  
    ELSE
      raise notice 'VALORES TIENE DATOS CURP';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', curpx.id_trab,curpx.url,'CURP'); 
    END IF; 
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into rfcx * from documentos.rfc where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'rfcx: %', rfcx;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO rfcx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','RFC');  
    ELSE
      raise notice 'VALORES TIENE DATOS rfcx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', rfcx.id_trab,rfcx.url,'RFC'); 
    END IF;   
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into inex * from documentos.ine where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'inex: %', inex;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO inex';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','INE');  
    ELSE
      raise notice 'VALORES TIENE DATOS inex';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', inex.id_trab,inex.url,'INE'); 
    END IF;   
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into comp_domiciliox * from documentos.comp_domicilio where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'comp_domiciliox: %', comp_domiciliox;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO comp_domiciliox';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','COMP_DOMICILIO');  
    ELSE
      raise notice 'VALORES TIENE DATOS comp_domiciliox';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', comp_domiciliox.id_trab,comp_domiciliox.url,'COMP_DOMICILIO'); 
    END IF;    
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into comp_estudiosx * from documentos.comp_estudios where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'comp_estudiosx: %', comp_estudiosx;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO comp_estudiosx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','COMP_ESTUDIOS');  
    ELSE
      raise notice 'VALORES TIENE DATOS comp_estudiosx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', comp_estudiosx.id_trab,comp_estudiosx.url,'COMP_ESTUDIOS'); 
    END IF;    
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into nssx * from documentos.nss where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'nssx: %', nssx;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO nssx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','NSS');  
    ELSE
      raise notice 'VALORES TIENE DATOS nssx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', nssx.id_trab,nssx.url,'NSS'); 
    END IF;   
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into const_fiscalx * from documentos.const_fiscal where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'const_fiscalx: %', const_fiscalx;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO const_fiscalx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','COMP_FISCAL');  
    ELSE
      raise notice 'VALORES TIENE DATOS const_fiscalx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', const_fiscalx.id_trab,const_fiscalx.url,'COMP_FISCAL'); 
    END IF; 
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into ant_penalesx * from documentos.ant_penales where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'ant_penalesx: %', ant_penalesx;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO ant_penalesx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','ANT_NO_PENALES');  
    ELSE
      raise notice 'VALORES TIENE DATOS nssx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', ant_penalesx.id_trab,ant_penalesx.url,'ANT_NO_PENALES'); 
    END IF; 
  -- ---------------------------------------------------------------------------------------------------------------------------
  select into dpix * from documentos.dpi where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'dpix: %', dpix;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO dpix'; -- <<DPI>>
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','IDENTIFICACION_EXT');  
    ELSE
      raise notice 'VALORES TIENE DATOS dpix';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', dpix.id_trab,dpix.url,'IDENTIFICACION_EXT'); 
    END IF;  
   -- ---------------------------------------------------------------------------------------------------------------------------
    select into pase_agricolax * from documentos.pase_agricola where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'pase_agricolax: %', pase_agricolax;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO pase_agricolax'; -- <<PASE_AGRICOLA>>
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','TRAJETA_RESIDENCIA');  
    ELSE
      raise notice 'VALORES TIENE DATOS pase_agricolax';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', pase_agricolax.id_trab,pase_agricolax.url,'TRAJETA_RESIDENCIA'); 
    END IF;  
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into comp_domi_extx * from documentos.comp_domi_ext where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'comp_domi_extx: %', comp_domi_extx;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO comp_domi_extx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','COMP_DOMICILIO_EXT');  
    ELSE
      raise notice 'VALORES TIENE DATOS comp_domi_extx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', comp_domi_extx.id_trab,comp_domi_extx.url,'COMP_DOMICILIO_EXT'); 
    END IF;    
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into contratox * from documentos.contrato where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'contratox: %', contratox;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO contratox';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','CONTRATO');  
    ELSE
      raise notice 'VALORES TIENE DATOS contratox';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', contratox.id_trab,contratox.url,'CONTRATO'); 
    END IF;   
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into evaluacionx * from documentos.evaluacion where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'evaluacionx: %', evaluacionx;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO evaluacionx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','EVALUACION');  
    ELSE
      raise notice 'VALORES TIENE DATOS evaluacionx';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', evaluacionx.id_trab,evaluacionx.url,'EVALUACION'); 
    END IF;  
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into beneficiariox * from documentos.beneficiario where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'beneficiariox: %', beneficiariox;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO beneficiariox';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','BENEFICIARIO');  
    ELSE
      raise notice 'VALORES TIENE DATOS beneficiariox';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', beneficiariox.id_trab,beneficiariox.url,'BENEFICIARIO'); 
    END IF;   
  -- ---------------------------------------------------------------------------------------------------------------------------
    select into cuestionariox * from documentos.cuestionario where edo_doc = 1 and id_trab = id_t; -- obteniendo registros actuales de tb_temporal
    raise notice 'cuestionariox: %', cuestionariox;
  
    IF NOT FOUND THEN 
      raise notice 'VALORES NULO cuestionariox';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', id_t,'NOT FOUND','CUESTIONARIO');  
    ELSE
      raise notice 'VALORES TIENE DATOS cuestionariox';
      EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L)', 'registros', cuestionariox.id_trab,cuestionariox.url,'CUESTIONARIO'); 
    END IF;
  -- ---------------------------------------------------------------------------------------------------------------------------
    return query select * from registros;-- retorna los reg. capturados
    
  RETURN;
END;
$$ language plpgsql; -- OK

-- INVOCANDO Y CONSULTANDO LA FUNCTION: documentos.ver_docs
begin work;
  select trab,ruta,ref from documentos.ver_docs('FC008') AS (trab varchar,ruta varchar,ref varchar);
commit work;

/* ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- FUNCION NVA P/DAR DE BAJA DOCUMENTOS
-- DROP FUNCTION documentos.baja_docs; -- 1 OK
CREATE OR REPLACE FUNCTION documentos.baja_docs(id_t varchar) RETURNS integer AS $$
declare
	veri record;	
begin	
  raise notice 'VALIDACION P/DUARDAR DOCUMENTO';
  -- ---------------------------------------------------------------------------------------------------------------------------  
  raise notice '1) el empleado ya tiene registros'; -- NO
  UPDATE documentos.acta SET edo_doc = 1 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros'; -- NO
  UPDATE documentos.curp SET edo_doc = 1 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros'; -- NO
  UPDATE documentos.rfc SET edo_doc = 1 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros'; -- NO
  UPDATE documentos.ine SET edo_doc = 1 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros';
  UPDATE documentos.comp_domicilio SET edo_doc = 0 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
 raise notice '1) el empleado ya tiene registros';
  UPDATE documentos.comp_estudios SET edo_doc = 0 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros'; -- NO
  UPDATE documentos.nss SET edo_doc = 1 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros';
  UPDATE documentos.const_fiscal SET edo_doc = 0 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros';
  UPDATE documentos.ant_penales SET edo_doc = 0 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros'; -- <<IDENTIFICACION_EXT>>
  UPDATE documentos.dpi SET edo_doc = 0 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros'; -- <<TRAJETA_RESIDENCIA>>
  UPDATE documentos.pase_agricola SET edo_doc = 0 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros';
  UPDATE documentos.comp_domi_ext SET edo_doc = 0 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros';
  UPDATE documentos.contrato SET edo_doc = 0 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros';
  UPDATE documentos.evaluacion SET edo_doc = 0 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros';
  UPDATE documentos.beneficiario SET edo_doc = 0 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  raise notice '1) el empleado ya tiene registros';
  UPDATE documentos.cuestionario SET edo_doc = 0 WHERE id_trab=id_t;
  -- ---------------------------------------------------------------------------------------------------------------------------
  RETURN 1;
END;
$$ LANGUAGE plpgsql; -- OK

/* EJECUTANDO EJEMPLO DEL PROCEDIMIENTO */
begin work;
  select documentos.baja_docs('FM1318');
commit work;

ruta2 = "C:\\Users\\" +"\""+ SysUser +"\""+ "\\AppData\\Local\\Temp\\Setup_RP-"+ ProductDB[9].trim() +".exe"; -- << SERVIDOR CENTRAL >>

/* ////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */
/* ==> AGREGAR CARPETA: (tks_juan_new_2021) EN REPOSITORIO DE PROYECTOS P/CONTROL DE CONSULTAS EN MODULOS << REG. PERSONAL || ALMACEN >> OK */ 
 