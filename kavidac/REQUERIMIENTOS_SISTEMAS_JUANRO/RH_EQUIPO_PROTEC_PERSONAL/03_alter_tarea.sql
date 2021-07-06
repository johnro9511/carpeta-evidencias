/* ////////////////////////// AQUI EMPIEZA MODIFICACION EV. CLINICA ///////////////////////////////////// */
-- FUNCION P/VER MOVIMIENTOS PENDIENTES EN EL ALMACEN
drop function epp.mov_pendi_alm(varchar,varchar,date,date); -- 04 ** (actualizacion) <<10/11/2020>>
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
        WHERE N.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

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
        WHERE R.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND R.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE REPOSICIONES

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
        WHERE P.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (ENTREGA)

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
        WHERE P.RECEPCION = FALSE AND (P.EST = 1 OR P.EST = 2) AND T.STATUS_TRAB = 1 AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (DEVOLUCION)

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
        WHERE N.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

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
        WHERE N.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE BAJA TRABAJADOR

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
        WHERE N.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

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
        WHERE R.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND R.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE REPOSICIONES
     
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
        WHERE P.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (ENTREGA)

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
        WHERE P.RECEPCION = FALSE AND (P.EST = 1 OR P.EST = 2) AND T.STATUS_TRAB = 1 AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (DEVOLUCION)

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
        WHERE N.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (CAMBIO LABOR)

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
        WHERE N.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE BAJA TRABAJADOR

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
        WHERE N.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND A.NOMBRE_ALMACEN = pidAl AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

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
        WHERE R.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND A.NOMBRE_ALMACEN = pidAl AND R.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE REPOSICIONES

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
        WHERE P.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND A.NOMBRE_ALMACEN = pidAl AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (ENTREGA)

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
        WHERE P.RECEPCION = FALSE AND (P.EST = 1 OR P.EST = 2) AND T.STATUS_TRAB = 1 AND A.NOMBRE_ALMACEN = pidAl AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (DEVOLUCION)

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
        WHERE N.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND A.NOMBRE_ALMACEN = pidAl AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

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
        WHERE N.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND T.STATUS_TRAB = 1 AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

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
        WHERE N.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND A.NOMBRE_ALMACEN = pidAl AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

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
        WHERE R.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND A.NOMBRE_ALMACEN = pidAl AND R.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE REPOSICIONES
     
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
        WHERE P.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND A.NOMBRE_ALMACEN = pidAl AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (ENTREGA)

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
        WHERE P.RECEPCION = FALSE AND (P.EST = 1 OR P.EST = 2) AND T.STATUS_TRAB = 1 AND A.NOMBRE_ALMACEN = pidAl AND P.FECHA_INI_PRESTA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (DEVOLUCION)

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
        WHERE N.ENTREGADO = FALSE AND T.STATUS_TRAB = 1 AND A.NOMBRE_ALMACEN = pidAl AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE PRESTAMOS (CAMBIO LABOR)

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
        WHERE N.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = pidAl AND T.STATUS_TRAB = 1 AND N.FECHA::DATE BETWEEN pidFi AND pidXf loop -- OBTIENE NUEVOS INGRESOS

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
$$ language plpgsql;

/* //////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de nuevos (gft/epp) ----------------------------
drop function epp.distribucion_material(varchar,varchar,varchar,varchar); -- 30 ** EN USO
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
    SELECT DISTINCT f.nombre_finca,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 1) and t.id_trab = pIdTr and f.nombre_finca = pIdFn; -- TRABAJADORES
  
  material CURSOR(pIdMt varchar, pIdFn varchar) FOR 
    SELECT DISTINCT f.nombre_finca,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 1) and m.nombre_material = pIdMt and f.nombre_finca = pIdFn;
    
   todos CURSOR(pIdFn varchar) FOR 
    SELECT DISTINCT f.nombre_finca,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 1) and f.nombre_finca = pIdFn;

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
$$ language plpgsql;

 /* //////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de nuevos (gft/epp) ----------------------------
drop function epp.distribucion_materialv2(varchar,varchar,varchar,varchar); -- 31 ** EN USO
create or replace function epp.distribucion_materialv2(varchar,varchar,varchar,varchar)  returns setof record as $$
declare
  pidWc   alias for $1; -- filtro p/busqueda
  pIdTr   alias for $2; -- id_trab 
  pIdMt   alias for $3; -- nombre_material
  pIdFn   alias for $4; -- nombre_finca
  
  rep_trab    RECORD; -- valores: por trabajador 
  rep_mate    RECORD; -- valores: por material
  rep_todo    RECORD; -- valores: todos trab y mat
  
  trabajador CURSOR(pIdTr varchar, pIdFn varchar) FOR 
    SELECT DISTINCT f.nombre_finca,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 0) and t.id_trab = pIdTr and f.nombre_finca = pIdFn; -- TRABAJADORES
  
  material CURSOR(pIdMt varchar, pIdFn varchar) FOR 
    SELECT DISTINCT f.nombre_finca,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 0) and m.nombre_material = pIdMt and f.nombre_finca = pIdFn;
    
   todos CURSOR(pIdFn varchar) FOR 
    SELECT DISTINCT f.nombre_finca,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 0) and f.nombre_finca = pIdFn;

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
$$ language plpgsql;

/* /////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- FUNCION NVA P/DAR DE BAJA A TRABAJADOR
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
$$ LANGUAGE plpgsql; -- OK 

/* //////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte DETALLADO DE DESCUENTOS (epp) ----------------------------
drop function epp.descuentos_det_epp(varchar,date,date); -- 24
create or replace function epp.descuentos_det_epp(varchar,date,date)  returns setof record as $$
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
  vigi_acum     NUMERIC(10,3); -- monto indv x vigilante
  
  extra        numeric(10,2); -- recargo 20 % por extravio
  agreg        numeric(10,2); -- valor agregado
  final        numeric(10,3); -- monto final con recargo
  
      -- CONSULTA P/GENERAR COBROS POR REPOSICION (EXTRAVIO)
  repo CURSOR(pIdFi date, pIdfx date) FOR SELECT DISTINCT f.nombre_finca as finca,k.folio,m.id_material,m.nombre_material,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, k.monto as costo,k.fecha,k.tipo_cobro from public.trabajadores t 
    inner join public.fincas f on f.id_finca = f.id_finca
    inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab
    inner join almacen.materiales m on m.id_material = x.id_material 
    inner join epp.det_mov_repo_epp_enf p on p.id_finca=f.id_finca and p.folio = x.folio and p.id_material = m.id_material
    inner join epp.cobros_detalle k on k.id_finca = p.id_finca and k.folio = p.folio and k.id_material = p.id_material and x.id_trab = k.id_trab and k.surtido = true
    where k.fecha::date between pIdFi and pIdfx;
    -- FILTRO POR FINCA --> where f.nombre_finca = '';

    -- CONSULTA P/GENERAR COBROS POR PRESTAMOS NO DEVUELTOS
  presta CURSOR(pIdFi date, pIdfx date) FOR SELECT p.folio,f.nombre_finca as finca,t.id_trab,m.id_material,m.nombre_material,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, m.costo_reposicion_epp AS costo,p.fecha_fin_presta
    FROM public.trabajadores t
    inner join public.fincas f on f.id_finca = f.id_finca
    inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab
    inner join almacen.materiales m on m.id_material = x.id_material 
    inner join epp.det_mov_presta_epp_alm p on m.id_material=p.id_material and p.id_finca = f.id_finca and p.folio = x.folio and p.id_material = x.id_material
    where p.recepcion = false and p.est = 3 and p.fecha_fin_presta::date between pIdFi and pIdfx; 
    -- FILTRO POR FINCA --> where f.nombre_finca = '';

    -- CONSULTA P/GENERAR COBROS POR REPO CON COBRO DE GFT VISITANTES
  vigi CURSOR(pIdFi date, pIdfx date) FOR SELECT F.NOMBRE_FINCA as finca,C.FOLIO,C.FECHA::DATE,C.CANTIDAD::integer,x.id_material,x.nombre_material,X.COSTO_REPOSICION_EPP AS COSTO_UNIT,C.MONTO as costo,W.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo
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
  
  CREATE TEMPORARY TABLE descuentos_det_epp( -- tabla temporal acumulativa
    finca varchar, -- nombre finca
    id_trab varchar, -- id trabajador
    nom_completo varchar, -- nombre de trabajador
    material varchar, -- material de descuento
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
       
        select into rep_val * from descuentos_det_epp where id_trab = reposicion.id_trab; -- obteniendo registros actuales de tb_temporal
        raise notice 'REP_VAL: %', rep_val;
        IF NOT FOUND THEN 
          raise notice 'VALORES NULO REPO';
          
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', reposicion.FINCA,reposicion.ID_TRAB,reposicion.nombre_completo,reposicion.nombre_material,reposicion.costo,pIdFi,pIdFx);  
        ELSE
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', reposicion.FINCA,reposicion.ID_TRAB,reposicion.nombre_completo,reposicion.nombre_material,reposicion.costo,pIdFi,pIdFx); 
        END IF; -- ACUMULADOR REPOSICION POR TRAB 
      END LOOP;  -- LOOP DE REPOSICION  
    close repo; -- CIERRA CURSOR REPOSICION
    
    /* ///////////////////////////////////////////////////////////////////////////////////////////////// */
    
    open presta(pIdFi,pIdfx); -- cursor de prestamos
      LOOP
        FETCH presta into prestamo; -- obtenemos valores del cursor
        raise notice 'prestamo: %', prestamo;
      
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        
        select into rep_val * from descuentos_det_epp where id_trab = prestamo.id_trab; -- obteniendo registros actuales de tb_temporal
        raise notice 'REP_VAL: %', rep_val;
        IF NOT FOUND THEN 
          raise notice 'VALORES NULO REPO';
          
          agreg = (prestamo.costo * extra); -- obteniendo el valor del 20 %
          raise notice 'AGREG: %', agreg;

          final = (prestamo.costo + agreg); -- monto final con porcentaje incluido
          raise notice 'FINAL: %', final;

          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', prestamo.FINCA,prestamo.ID_TRAB,prestamo.nombre_completo,prestamo.nombre_material,final,pIdFi,pIdFx); 
        ELSE
          agreg = (prestamo.costo * extra); -- obteniendo el valor del 20 %
          raise notice 'AGREG: %', agreg;

          final = (prestamo.costo + agreg); -- monto final con porcentaje incluido
          raise notice 'FINAL: %', final;
          
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', prestamo.FINCA,prestamo.ID_TRAB,prestamo.nombre_completo,prestamo.nombre_material,final,pIdFi,pIdFx); 
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
                                                                    
        select into rep_val * from descuentos_det_epp where id_trab = vigilantes.id_trab; -- obteniendo registros actuales de tb_temporal
        raise notice 'REP_VAL: %', rep_val;
        
        IF NOT FOUND THEN 
          raise notice 'VALORES NULO REPO';
          -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', vigilantes.FINCA,vigilantes.ID_TRAB,vigilantes.nombre_completo,vigilantes.nombre_material,vigi_acum,pIdFi,pIdFx);  
        ELSE
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', vigilantes.FINCA,vigilantes.ID_TRAB,vigilantes.nombre_completo,vigilantes.nombre_material,vigi_acum,pIdFi,pIdFx); 
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
          
          select into rep_val * from descuentos_det_epp where id_trab = reposicion.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
          raise notice 'REP_VAL: %', rep_val;
          IF NOT FOUND THEN 
            raise notice 'VALORES NULO REPO';
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', reposicion.FINCA,reposicion.ID_TRAB,reposicion.nombre_completo,reposicion.nombre_material,reposicion.costo,pIdFi,pIdFx); 
          ELSE
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', reposicion.FINCA,reposicion.ID_TRAB,reposicion.nombre_completo,reposicion.nombre_material,reposicion.costo,pIdFi,pIdFx); 
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
          
          select into rep_val * from descuentos_det_epp where id_trab = prestamo.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
          raise notice 'REP_VAL: %', rep_val;
          IF NOT FOUND THEN 
            raise notice 'VALORES NULO REPO';
            agreg = (prestamo.costo * extra); -- obteniendo el valor del 20 %
            raise notice 'AGREG: %', agreg;

            final = (prestamo.costo + agreg); -- monto final con porcentaje incluido
            raise notice 'FINAL: %', final;

            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', prestamo.FINCA,prestamo.ID_TRAB,prestamo.nombre_completo,prestamo.nombre_material,final,pIdFi,pIdFx);  
          ELSE
            agreg = (prestamo.costo * extra); -- obteniendo el valor del 20 %
            raise notice 'AGREG: %', agreg;

            final = (prestamo.costo + agreg); -- monto final con porcentaje incluido
            raise notice 'FINAL: %', final;
            
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', prestamo.FINCA,prestamo.ID_TRAB,prestamo.nombre_completo,prestamo.nombre_material,final,pIdFi,pIdFx);  
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
                                                                    
          select into rep_val * from descuentos_det_epp where id_trab = vigilantes.id_trab; -- obteniendo registros  -- obteniendo registros actuales de tb_temporal
          raise notice 'REP_VAL: %', rep_val;
          IF NOT FOUND THEN 
            raise notice 'VALORES NULO REPO';
            -- INSERTA TODOS LOS REGISTROS SIN DISTINCION
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', vigilantes.FINCA,vigilantes.ID_TRAB,vigilantes.nombre_completo,vigilantes.nombre_material,vigi_acum,pIdFi,pIdFx);  
          ELSE
            EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L)', 'descuentos_det_epp', vigilantes.FINCA,vigilantes.ID_TRAB,vigilantes.nombre_completo,vigilantes.nombre_material,vigi_acum,pIdFi,pIdFx);
          END IF; -- ACUMULADOR VIGILANTES POR TRAB 
        END IF; -- VALIDACION DE FINCA SELECCIONADA
      END LOOP;  -- LOOP DE VIGILANTES  
     close vigi; -- CIERRA CURSOR VIGILANTES
                                                               
  END IF; -- ELSE IF VALIDACION TODAS LAS FINCAS 

return query select * from descuentos_det_epp; -- retorna consulta c/materiales a entregar 1

RETURN;
END;
$$ language plpgsql;

/* //////////////////////////////////////////////////////////////////////////////////////////////////// */
-- funcion p/dar de alta nuevamente al trabajador << REINGRESO >> **
CREATE OR REPLACE FUNCTION dar_de_alta_trabajador(character varying,integer,character varying,character varying,character varying)
  RETURNS integer AS $$
declare
	-- id_trab $1;
	-- id_finca $2;
	-- fecha_registro $3;
	-- fecha_ingreso $4;
    -- id_usuario $5;  
	veri record;
	total integer;
	idNext character varying;
	-- 0 No se pudo
	-- 1 Dado De Baja
	-- 2 Ya fue dado de alta
begin	
	veri = null;
    
    SELECT into veri id_trab, id_finca, id_tipo_trab, fecha_ingreso, fecha_registro, turno24, status_trab from trabajadores WHERE id_trab=$1;

    if  veri.status_trab = 1 then -- si esta activo
		raise notice '1) el empleado esta activo';
		return 2;
    end if;
		
	if veri.status_trab is null then
		raise notice '1) el empleado tiene un status Nulo ';
		return 0;
	end if;	
    
    if $5 :: int = 0 then
      if veri.status_trab = 0 then
          raise notice '*) trabajador inactivo ';
          UPDATE trabajadores SET status_trab='1', vale_gen = '1', gafete = null, id_cargo = 25, id_area_trabajo = 6, id_labor = 65, fecha_registro=$3, fecha_ingreso=$4, id_finca=$2 WHERE id_trab=$1;
          return 1;
      end if;

      if veri.status_trab = 4 then
          raise notice '*) reingreso de trabajador';
          UPDATE trabajadores SET status_trab='1', vale_gen = '1', gafete = null, id_cargo = 25, id_area_trabajo = 6, id_labor = 65, fecha_registro=$3, fecha_ingreso=$4, id_finca=$2 WHERE id_trab=$1;
          return 1;
      end if;
    end if; -- usuario Lic. Roberto
    
    if ($5 :: int = 6) or ($5 :: int = 7) then
      if veri.status_trab = 0 then
          raise notice '*) trabajador inactivo ';
          UPDATE trabajadores SET status_trab='4', vale_gen = '1', gafete = null, id_cargo = 25, id_area_trabajo = 6, id_labor = 65, fecha_registro=$3, fecha_ingreso=$4, id_finca=$2 WHERE id_trab=$1;
          return 1;
      end if;

      if veri.status_trab = 4 then
          raise notice '*) reingreso de trabajador';
          UPDATE trabajadores SET status_trab='4', vale_gen = '1', gafete = null, id_cargo = 25, id_area_trabajo = 6, id_labor = 65, fecha_registro=$3, fecha_ingreso=$4, id_finca=$2 WHERE id_trab=$1;
          return 1;
      end if;
    end if; -- usuarios: Cont. Lennin y Tecnologias
END;
$$ language plpgsql;

/* //////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- --------- funcion para el reporte de reposiciones detalladas por folio enf (gft/epp) --------------------
drop function epp.repo_det_reposicion(varchar,varchar); -- 29
create or replace function epp.repo_det_reposicion(varchar,varchar) returns setof record as $$
declare
  pidFn   alias for $1; -- nombre finca (no se ocupa)
  pIdTc   alias for $2; --  folio epp
  
  cobro_detwx    RECORD; -- valores: cobros 
  repo_detwx     RECORD; -- valores: reposiciones 
  
  cobrowx CURSOR(pIdTc varchar) FOR 
    SELECT DISTINCT k.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, concat(1) as cantidad, u.nombre_unidad_medida as um, k.monto as costo, (CASE WHEN k.surtido = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, k.fecha from public.trabajadores t 
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
    SELECT DISTINCT k.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, concat(1) as cantidad, u.nombre_unidad_medida as um, k.monto as costo, (CASE WHEN k.surtido = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, k.fecha from public.trabajadores t 
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
    estado varchar, -- status entregado alm
    fecha timestamp -- fecha y hora mov
 ) ON COMMIT DROP;
  
  open cobrowx(pIdTc);
    LOOP
      FETCH cobrowx into cobro_detwx; -- obtenemos valores del cursor COBRO X REPOSICIONES
        raise notice 'cobro_detwx: %', cobro_detwx;
          
        EXIT WHEN NOT FOUND; -- salir cuando no tenga nada
        raise notice 'SI PASA DATOS DEL COBRO REP';
        
        IF cobro_detwx.estado = 'ENTREGADO' THEN -- COMPARA SI EL MATERIAL YA FUE SURTIDO        
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'repo_det_reposicion', cobro_detwx.folio,cobro_detwx.finca,cobro_detwx.id_trab,cobro_detwx.nombre_completo,cobro_detwx.tipo_trab,cobro_detwx.cargo,cobro_detwx.area,cobro_detwx.labor,cobro_detwx.id_material,cobro_detwx.clave,cobro_detwx.nombre_material,cobro_detwx.cantidad,cobro_detwx.um,cobro_detwx.costo,cobro_detwx.estado,cobro_detwx.fecha);                 
        ELSE -- EL MATERIAL ESTA PENDIENTE DE ENTREGA
          EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'repo_det_reposicion', cobro_detwx.folio,cobro_detwx.finca,cobro_detwx.id_trab,cobro_detwx.nombre_completo,cobro_detwx.tipo_trab,cobro_detwx.cargo,cobro_detwx.area,cobro_detwx.labor,cobro_detwx.id_material,cobro_detwx.clave,cobro_detwx.nombre_material,cobro_detwx.cantidad,cobro_detwx.um,0.00,cobro_detwx.estado,cobro_detwx.fecha);  
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
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'repo_det_reposicion', repo_detwx.folio,repo_detwx.finca,repo_detwx.id_trab,repo_detwx.nombre_completo,repo_detwx.tipo_trab,repo_detwx.cargo,repo_detwx.area,repo_detwx.labor,repo_detwx.id_material,repo_detwx.clave,repo_detwx.nombre_material,repo_detwx.cantidad,repo_detwx.um,repo_detwx.costo,repo_detwx.estado,repo_detwx.fecha);  
      ELSE
        EXECUTE FORMAT ('insert into %I VALUES (%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L,%L)', 'repo_det_reposicion', repo_detwx.folio,repo_detwx.finca,repo_detwx.id_trab,repo_detwx.nombre_completo,repo_detwx.tipo_trab,repo_detwx.cargo,repo_detwx.area,repo_detwx.labor,repo_detwx.id_material,repo_detwx.clave,repo_detwx.nombre_material,repo_detwx.cantidad,repo_detwx.um,0.00,repo_detwx.estado,repo_detwx.fecha);  
      END IF; -- VALIDACION STATUS DE ENTREGA
    END LOOP;  -- LOOP DE REPOSICION  
  close repowx; -- CIERRA CURSOR REPOSICION
    
return query select * from repo_det_reposicion; -- retorna consulta c/materiales a entregar

RETURN;
END;
$$ language plpgsql;

/* //////////////////////////////////////////////////////////////////////////////////////////////////// */
