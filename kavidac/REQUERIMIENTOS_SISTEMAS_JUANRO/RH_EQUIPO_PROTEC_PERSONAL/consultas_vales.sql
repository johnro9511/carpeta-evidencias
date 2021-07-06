/* //////////////////// CONSULTAS P/GENERAR VALES ENTREGA DE EPP (ENFERMERIA) /////////////////////////// */
-- CONSULTA P/OBTENER DATOS DE VALE NUEVO INGRESO EPP TRABAJADOR (REPORTE) 
SELECT f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, d.cantidad, u.nombre_unidad_medida as um FROM public.trabajadores t, public.labor l, almacen.detalle_materiales_labor d, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v WHERE t.id_labor = l.id_labor and l.id_labor = d.id_labor and d.id_material = m.id_material and m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and t.id_trab = 'FM1318' and f.nombre_finca = 'DON ROLANDO';

-- CONSULTA P/OBTENER DATOS DE VALE NVO INGRESO EPP TRABAJADOR ENF (REPORTE) ** falta foto
SELECT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um, x.alm_destino, /*, encode(t.foto,'base64') as foto */ FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.det_mov_nvo_epp_enf p,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=p.id_material and p.id_finca=f.id_finca  and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material and t.id_trab = x.id_trab and t.id_trab = 'FM1321' and f.nombre_finca = 'DON ROLANDO' and p.folio = 'NFM006';

/* //////////////////// CONSULTAS P/VER DISTRIBUCION DE MATERIALES /////////////////////////// */
-- CONSULTA P/SABER QUE TIENE MATERIALES ACTUALMENTE POR TRABAJADOR...
SELECT DISTINCT f.nombre_finca,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 0 or x.estado_epp = 1) and t.id_trab = 'FM1321' and f.nombre_finca = 'DON ROLANDO';

-- CONSULTA P/SABER QUIEN TIENE ESOS MATERIALES ACTUALMENTE POR MATERIAL...
SELECT DISTINCT f.nombre_finca,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 0 or x.estado_epp = 1) and m.nombre_material = 'BOTAS DE HULE' and f.nombre_finca = 'DON ROLANDO';

-- CONSULTA P/SABER QUE TIENE MATERIALES ACTUALMENTE POR TODOS LOS TRABAJADORES Y TODOS LOS MATERIALES...
SELECT DISTINCT f.nombre_finca,x.folio,x.id_trab,CONCAT(t.nombre_trab, ' ', t.ape_paterno, ' ', t.ape_materno) as nombre_completo,m.clave, m.nombre_material, u.nombre_unidad_medida as um, x.estado_epp FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=x.id_material and x.id_finca=f.id_finca and t.id_trab = x.id_trab and (x.estado_epp = 0 or x.estado_epp = 1) and f.nombre_finca = 'DON ROLANDO';

/* //////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- CONSULTA P/OBTENER DATOS DE MATERIALES EPP ENF
SELECT a.id_material,a.clave,a.nombre_material,u.nombre_unidad_medida from almacen.materiales a, almacen.unidad_medida u where a.id_unidad_medida=u.id_unidad_medida and a.tipo_epp = true and a.eliminado = false;

-- CONSULTA P/OBTENER DATOS DE VALE PRESTAMO EPP TRABAJADOR ENF
SELECT c.nombre_cargo as cargo,l.nombre_labor as labor FROM public.trabajadores t, public.labor l, almacen.detalle_materiales_labor d, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v WHERE t.id_labor = l.id_labor and l.id_labor = d.id_labor and d.id_material = m.id_material and m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and t.id_trab = 'FM1318' and f.nombre_finca = 'DON ROLANDO' limit 1;

-- CONSULTA P/OBTENER DATOS PRESTAMO EPP ENF
SELECT a.id_material,a.clave,a.nombre_material,p.cantidad,u.nombre_unidad_medida from almacen.materiales a, almacen.unidad_medida u, epp.det_mov_presta_epp_enf p, public.fincas f where a.id_unidad_medida=u.id_unidad_medida and a.id_material=p.id_material and p.id_finca=f.id_finca and folio ='VFM002' and f.nombre_finca = 'DON ROLANDO';

-- CONSULTA P/OBTENER EL ID_MATERIAL SEGUN LA CLAVE
SELECT id_material from almacen.materiales where clave = 'ACE0003'; -- RETORNA 4

-- CONSULTA P/OBTENER DATOS DE VALE PRESTAMO EPP TRABAJADOR ENF (REPORTE) ** falta foto
SELECT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um,x.alm_destino, /*, encode(t.foto,'base64') as foto, */ p.lab_presta FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.det_mov_presta_epp_enf p, epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material and t.id_trab = x.id_trab and t.id_trab = 'FC023' and f.nombre_finca = 'CALZADIITA' and p.folio = 'PFC002';

-- CONSULTA P/OBTENER DATOS DE VALE PRESTAMO EPP CON NULL TRABAJADOR ENF (REPORTE) ** falta foto
SELECT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab, c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor, m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um,x.alm_destino, /*, encode(t.foto,'base64') as foto, */ p.lab_presta FROM public.trabajadores t 
left join public.labor l on t.id_labor = l.id_labor 
left join public.cargo c on t.id_cargo = c.id_cargo 
left join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
left join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
inner join public.fincas f on f.id_finca = f.id_finca  
inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab and m.id_material=x.id_material
inner join epp.det_mov_presta_epp_enf p on m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material
where t.id_trab = 'FC023' and f.nombre_finca = 'CALZADITA' and p.folio = 'PFC002';

-- CONSULTA P/OBTENER DATOS DE VALE REPOSICION EPP ENF TRABAJADOR  ** SIN FOTO
SELECT CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,c.nombre_cargo as cargo,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, d.cantidad, u.nombre_unidad_medida as um FROM public.trabajadores t, public.labor l, almacen.detalle_materiales_labor d, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v WHERE t.id_labor = l.id_labor and l.id_labor = d.id_labor and d.id_material = m.id_material and m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and t.id_trab = 'FM1319' and f.nombre_finca = 'DON ROLANDO';

-- CONSULTA P/OBTENER DATOS DE BAJA DE TRABAJADOR EPP ENF TRABAJADOR  ** SIN FOTO
SELECT CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,a.nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material, m.nombre_material, d.cantidad, u.nombre_unidad_medida as um FROM public.trabajadores t, public.labor l, almacen.detalle_materiales_labor d, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v WHERE t.id_labor = l.id_labor and l.id_labor = d.id_labor and d.id_material = m.id_material and m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and t.id_trab = 'FC013' and f.nombre_finca = 'CALZADITA';

-- CONSULTA P/VALIDAR SI YA SE GENERÓ VALE DE BAJA EPP
SELECT DISTINCT M.ID_TIPO_MOV_EPP,T.ID_TRAB,M.FECHA::DATE FROM PUBLIC.TRABAJADORES T INNER JOIN EPP.MOVIMIENTO_EPP M ON T.ID_TRAB=M.ID_TRAB AND M.ID_TIPO_MOV_EPP = 5 AND M.ESTADO_EPP = 1 WHERE T.ID_TRAB='FK592' ORDER BY ID_TIPO_MOV_EPP DESC LIMIT 1;

-- ACTUALIZA EL MOVIMIENTO DE EPP DE BAJA EPP
update epp.Movimiento_epp set estado_epp = 0 WHERE id_finca = 21 and id_trab = 'FK592'; -- 
 
-- CONSULTA P/OBTENER DATOS DE BAJA DE TRABAJADOR EPP ENF TRABAJADOR  ** CON JOIN
SELECT DISTINCT CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,a.nombre_area_trabajo as area,l.nombre_labor as labor,m.clave, m.nombre_material, d.cantidad, u.nombre_unidad_medida as um FROM public.trabajadores t 
inner join public.labor l on t.id_labor = l.id_labor 
inner join public.cargo c on t.id_cargo = c.id_cargo 
inner join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
inner join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab inner join almacen.materiales m on m.id_material = m.id_material 
inner join almacen.unidad_medida u on m.id_unidad_medida = u.id_unidad_medida 
inner join almacen.detalle_materiales_labor d on l.id_labor = d.id_labor and d.id_material = m.id_material inner join public.fincas f on f.id_finca = f.id_finca 
inner join epp.movimiento_epp z on z.id_material = m.id_material and t.id_trab = z.id_trab and z.estado_epp = 1 where t.id_trab = 'FK592' and f.nombre_finca = 'MARY CARMEN';

-- CONSULTA P/OBTENER DATOS DE BUSQUEDA MATERIALES POR EMPLEADOS  ** AQUII
SELECT m.clave, m.nombre_material, d.cantidad, u.nombre_unidad_medida as um FROM public.trabajadores t, public.labor l, almacen.detalle_materiales_labor d, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v WHERE t.id_labor = l.id_labor and l.id_labor = d.id_labor and d.id_material = m.id_material and m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and t.id_trab = 'FM1319' and f.nombre_finca = 'DON ROLANDO';

-- CONSULTA P/OBTENER DATOS DE VALE REPOSICION EPP TRABAJADOR (REPORTE) ** falta foto
SELECT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um, encode(t.foto,'base64') as foto FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.det_mov_repo_epp_enf p,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material and t.id_trab = x.id_trab and t.id_trab = 'FM1319' and f.nombre_finca = 'DON ROLANDO' and p.folio = 'VFM008';

/* //////////////////////// CONSULTAS P/SURTIR MATERIALES DE EPP (ALMACEN) //////////////////////////////// */
-- CONSULTA P/OBTENER EL DETALLE DEL REPORTE DE NVO INGRESO MATERIALES EPP Y GAFETE ** FALTA FOTO
SELECT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um, p.fecha::date FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.det_mov_nvo_epp_enf p, epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material and t.id_trab = x.id_trab and t.id_trab = 'FM1318' and f.nombre_finca = 'DON ROLANDO';

/* ///////////////////////////// EQUIPO DE PROTECCION ALMACEN //////////////////////////////////////////// */
-- CONSULTA PARA OBTENER LA FINCA DE TRANSFERENCIA DEL ALMACEN A PUBLIC
SELECT K.ID_FINCA AS IFP, K.NOMBRE_FINCA AS NFP, V.ID_FINCA AS IFA,V.NOMBRE_FINCA AS NFA FROM ALMACEN.FINCA V
INNER JOIN ALMACEN.ALMACEN A ON V.ID_FINCA = A.ID_FINCA
INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
INNER JOIN PUBLIC.FINCAS K ON V.ID_FINCA_PUB = K.ID_FINCA
WHERE U.ID_USUARIO = 16;

-- CONSULTA P/OBTENER LISTA DE MATERIALES EPP
SELECT ID_MATERIAL,CLAVE,NOMBRE_MATERIAL,ID_UNIDAD_MEDIDA,TIPO FROM ALMACEN.MATERIALES WHERE ESTATUS = TRUE AND TIPO_EPP =TRUE;

-- CONSULTA P/OBTENER MATERIALES DEL ALMACEN CON EXISTENCIA CUANDO SE HACE SALIDA
SELECT M.id_material,M.clave, M.nombre_material,existencia, n.cantidad
FROM almacen.materiales m INNER JOIN almacen.unidad_medida um ON (m.id_unidad_medida=um.id_unidad_medida)
INNER JOIN almacen.inventario i ON (i.id_material=m.id_material) 
INNER JOIN almacen.almacen a ON (a.id_almacen=i.id_almacen)
INNER JOIN epp.det_mov_nvo_epp_alm n ON (n.id_material = m.id_material)
WHERE nombre_almacen='DON ROLANDO CAMPO' AND existencia >=0 and estatus=TRUE AND eliminado = FALSE
AND n.folio = 'NFM001' ORDER BY clave;

-- CONSULTA P/OBTENER DATOS DE VALE NUEVO EPP ALMACEN  (REPORTE) ** falta foto
/*
SELECT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um,(CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v, epp.det_mov_nvo_epp_alm p, epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material and t.id_trab = x.id_trab and f.nombre_finca = 'DON ROLANDO' and p.folio = 'NFM003';
*/

-- CONSULTA P/OBTENER DATOS DE VALE NUEVO EPP ALMACEN  (REPORTE) ** falta foto
select p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,p.fecha::date,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um,(CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, g.folio as foli_alm /*, encode(t.foto,'base64') as foto */ from public.trabajadores t 
inner join public.labor l on t.id_labor = l.id_labor 
inner join public.cargo c on t.id_cargo = c.id_cargo 
inner join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
inner join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
inner join public.fincas f on f.id_finca = f.id_finca
inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab and m.id_material=x.id_material
inner join epp.det_mov_nvo_epp_alm p on m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material 
left join almacen.movimientos g on p.id_movimiento = g.id_movimiento
where p.folio = 'NFM001';

-- CONSULTA P/OBTENER DATOS DE VALE REPOSICION EPP ALMACEN GRATIS SIN COBRO (REPORTE) ** falta foto
/*
SELECT DISTINCT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um, z.monto as costo, (CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.det_mov_repo_epp_alm p,epp.movimiento_epp x, epp.reposiciones z WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material and t.id_trab = x.id_trab AND p.folio = z.folio and f.nombre_finca = 'DON ROLANDO' and p.folio = 'RFM002'; 
*/

-- CONSULTA P/OBTENER DATOS DE VALE REPOSICION EPP ALMACEN GRATIS SIN COBRO (REPORTE) ** falta foto
SELECT DISTINCT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um, z.monto as costo, (CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, g.folio as foli_alm from public.trabajadores t 
inner join public.labor l on t.id_labor = l.id_labor 
inner join public.cargo c on t.id_cargo = c.id_cargo 
inner join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
inner join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
inner join public.fincas f on f.id_finca = f.id_finca
inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab and m.id_material=x.id_material
inner join epp.det_mov_repo_epp_alm p on m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material 
inner join epp.reposiciones z on p.folio = z.folio
left join almacen.movimientos g on p.id_movimiento = g.id_movimiento
where p.folio = 'RFM002';

-- CONSULTA P/OBTENER DATOS DE VALE REPOSICION EPP ALMACEN CON COBRO (REPORTE) ** falta foto
/*
SELECT DISTINCT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um, k.monto as costo, (CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.det_mov_repo_epp_alm p,epp.movimiento_epp x, epp.cobros_detalle k WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material and t.id_trab = x.id_trab AND p.folio = k.folio and f.nombre_finca = 'DON ROLANDO' and p.folio = 'RFM001';
*/

-- CONSULTA P/OBTENER DATOS DE VALE REPOSICION EPP ALMACEN CON COBRO (REPORTE) ** falta foto
SELECT DISTINCT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um, k.monto as costo, (CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, g.folio as foli_alm from public.trabajadores t 
inner join public.labor l on t.id_labor = l.id_labor 
inner join public.cargo c on t.id_cargo = c.id_cargo 
inner join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
inner join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
inner join public.fincas f on f.id_finca = f.id_finca
inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab and m.id_material=x.id_material
inner join epp.det_mov_repo_epp_alm p on m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material 
inner join epp.cobros_detalle k on p.folio = k.folio
left join almacen.movimientos g on p.id_movimiento = g.id_movimiento
where p.folio = 'RFM001';

-- CONSULTA P/OBTENER DATOS DE PRESTAMO EPP ALMACEN  (REPORTE) ** falta foto
/*
SELECT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um,(CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, (CASE WHEN p.recepcion = false THEN 'NO' ELSE 'SI' END) AS recep, encode(t.foto,'base64') as foto FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.det_mov_presta_epp_alm p,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material and t.id_trab = x.id_trab and f.nombre_finca = 'DON ROLANDO' and p.folio = 'PFM001';
*/

-- CONSULTA P/OBTENER DATOS DE PRESTAMO EPP ALMACEN CON JOIN NULL (REPORTE) ** falta foto
SELECT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um,(CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, (CASE WHEN p.recepcion = false THEN 'NO' ELSE 'SI' END) AS recep, /*encode(t.foto,'base64') as foto,*/(CASE WHEN p.id_movimiento_rec is null THEN h.folio ELSE g.folio END) AS  foli_alm FROM public.trabajadores t
left join public.labor l on t.id_labor = l.id_labor 
left join public.cargo c on t.id_cargo = c.id_cargo 
left join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
left join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
inner join public.fincas f on f.id_finca = f.id_finca
inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab and m.id_material=x.id_material
inner join epp.det_mov_presta_epp_alm p on m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material 
left join almacen.movimientos g on p.id_movimiento_rec = g.id_movimiento
left join almacen.movimientos h on p.id_movimiento_ini = h.id_movimiento
where p.folio = 'PFC002' ORDER BY FOLI_ALM DESC;

/* ////////////////////// CONSULTAS P/VER PENDIENTE DE ENTREGA DE EPP (ALMACEN) /////////////////////////// */
-- CONSULTA P/OBTENER LOS PENDIENTES DE ENTREGA NVO INGRESO DE EPP (ALMACEN) ** MODIFICADO FALTA VALIDAR USUARIO
SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, N.FECHA::DATE, CONCAT('NVO. INGRESO') AS REFERENCIA
FROM EPP.DET_MOV_NVO_EPP_ALM N
INNER JOIN EPP.MOVIMIENTO_EPP M ON N.FOLIO = M.FOLIO AND M.ID_FINCA = N.ID_FINCA AND M.ID_MATERIAL = N.ID_MATERIAL
INNER JOIN FINCAS F ON N.ID_FINCA = M.ID_FINCA AND N.ID_FINCA = F.ID_FINCA
INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
WHERE N.ENTREGADO = FALSE AND A.NOMBRE_ALMACEN = 'DON ROLANDO CAMPO' AND N.FECHA::DATE BETWEEN CURRENT_DATE -22 AND CURRENT_DATE;
FILTRO 1 --> (USUARIO DEFINIDO DE ALMACEN): AND  U.ID_USUARIO = 14 
FILTRO 2 --> (NOMBRE DE ALMACEN): AND A.NOMBRE_ALMACEN = 'ALMACEN CENTRAL';


-- CONSULTA P/OBTENER LOS PENDIENTES DE ENTREGA CAMBIO DE LABOR EPP (ALMACEN) ** MODIFICADO FALTA VALIDAR USUARIO
SELECT DISTINCT A.NOMBRE_ALMACEN,N.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as       nombre_completo, N.FECHA::DATE, CONCAT('CAMBIO LABOR') AS REFERENCIA
        FROM epp.dev_x_cambio_labor N
        INNER JOIN FINCAS F ON N.ID_FINCA = F.ID_FINCA
        INNER JOIN TRABAJADORES T ON T.ID_TRAB = N.ID_TRAB
        INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
        INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
        INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
        INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
        WHERE N.ENTREGADO = false;
        
-- CONSULTA P/OBTENER LOS PENDIENTES DE ENTREGA REPOSICION DE EPP (ALMACEN)
SELECT DISTINCT A.NOMBRE_ALMACEN,R.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, R.FECHA::DATE, CONCAT('REPOSICION') AS REFERENCIA
FROM EPP.DET_MOV_REPO_EPP_ALM R
INNER JOIN EPP.MOVIMIENTO_EPP M ON R.FOLIO = M.FOLIO AND M.ID_FINCA = R.ID_FINCA AND M.ID_MATERIAL = R.ID_MATERIAL
INNER JOIN FINCAS F ON R.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND R.ID_FINCA = F.ID_FINCA
INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = R.ALM_DESTINO
INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
WHERE R.ENTREGADO = FALSE AND U.ID_USUARIO = 1 AND R.FECHA::DATE BETWEEN CURRENT_DATE -15 AND CURRENT_DATE;
FILTRO 1 --> (USUARIO DEFINIDO DE ALMACEN): AND  U.ID_USUARIO = 14 
FILTRO 2 --> (NOMBRE DE ALMACEN): AND A.NOMBRE_ALMACEN = 'ALMACEN CENTRAL';


-- CONSULTA P/OBTENER LOS PENDIENTES DE ENTREGA PRESTAMO DE EPP (ALMACEN)
SELECT DISTINCT A.NOMBRE_ALMACEN,P.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, P.FECHA_INI_PRESTA::DATE, CONCAT('PRESTAMO') AS REFERENCIA
FROM EPP.DET_MOV_PRESTA_EPP_ALM P
INNER JOIN EPP.MOVIMIENTO_EPP M ON P.FOLIO = M.FOLIO AND M.ID_FINCA = P.ID_FINCA AND M.ID_MATERIAL = P.ID_MATERIAL
INNER JOIN FINCAS F ON P.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND P.ID_FINCA = F.ID_FINCA
INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = P.ALM_DESTINO
INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
WHERE P.ENTREGADO = FALSE AND U.ID_USUARIO = 1 AND P.FECHA_INI_PRESTA::DATE BETWEEN CURRENT_DATE -15 AND CURRENT_DATE;
FILTRO 1 --> (USUARIO DEFINIDO DE ALMACEN): AND  U.ID_USUARIO = 14 
FILTRO 2 --> (NOMBRE DE ALMACEN): AND A.NOMBRE_ALMACEN = 'ALMACEN CENTRAL';

-- CONSULTA P/OBTENER LOS PENDIENTES DE RECEPCION PRESTAMO DE EPP (ALMACEN)
SELECT DISTINCT A.NOMBRE_ALMACEN,P.FOLIO,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, P.FECHA_INI_PRESTA::DATE, CONCAT('PRESTAMO') AS REFERENCIA
FROM EPP.DET_MOV_PRESTA_EPP_ALM P
INNER JOIN EPP.MOVIMIENTO_EPP M ON P.FOLIO = M.FOLIO AND M.ID_FINCA = P.ID_FINCA AND M.ID_MATERIAL = P.ID_MATERIAL
INNER JOIN FINCAS F ON P.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND P.ID_FINCA = F.ID_FINCA
INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = P.ALM_DESTINO
INNER JOIN ALMACEN.USUARIOS U ON A.ID_ALMACEN = U.ID_ALMACEN
INNER JOIN ALMACEN.ALMACEN_USUARIOS W ON A.ID_ALMACEN = W.ID_ALMACEN AND  U.ID_USUARIO = W.ID_USUARIO
WHERE P.RECEPCION = FALSE AND U.ID_USUARIO = 1 AND P.FECHA_INI_PRESTA::DATE BETWEEN CURRENT_DATE -15 AND CURRENT_DATE;
FILTRO 1 --> (USUARIO DEFINIDO DE ALMACEN): AND  U.ID_USUARIO = 14 
FILTRO 2 --> (NOMBRE DE ALMACEN): AND A.NOMBRE_ALMACEN = 'ALMACEN CENTRAL';


/* ////////////////////// CONSULTAS P/VALIDAR CAMBIO DE LABORES AL TRABAJADOR ///////////////////////////// */
-- CONSULTA P/VER DIFERENCIA DE MATERIALES TIENE EL TRABAJADOR ACTUALMENTE
SELECT f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,w.id_material,w.clave, w.nombre_material, d.cantidad, u.nombre_unidad_medida as um 
FROM EPP.DET_MOV_NVO_EPP_ALM N
INNER JOIN EPP.MOVIMIENTO_EPP M ON N.FOLIO = M.FOLIO AND M.ID_FINCA = N.ID_FINCA AND M.ID_MATERIAL = N.ID_MATERIAL
INNER JOIN FINCAS F ON N.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND N.ID_FINCA = F.ID_FINCA
INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
INNER JOIN LABOR L ON T.ID_LABOR = L.ID_LABOR
INNER JOIN ALMACEN.DETALLE_MATERIALES_LABOR D ON L.ID_LABOR = D.ID_LABOR
INNER JOIN ALMACEN.MATERIALES W ON D.ID_MATERIAL = W.ID_MATERIAL AND M.ID_MATERIAL = W.ID_MATERIAL AND N.ID_MATERIAL = W.ID_MATERIAL
INNER JOIN ALMACEN.UNIDAD_MEDIDA U ON W.ID_UNIDAD_MEDIDA = U.ID_UNIDAD_MEDIDA
INNER JOIN CARGO C ON T.ID_CARGO = C.ID_CARGO
INNER JOIN AREA_TRABAJO A ON T.ID_AREA_TRABAJO = A.ID_AREA_TRABAJO
INNER JOIN TIPO_TRABAJADOR V ON L.ID_TIPO_TRAB = V.ID_TIPO_TRAB
WHERE T.ID_TRAB = 'FM1318' AND F.NOMBRE_FINCA = 'DON ROLANDO';

-- CONSULTA P/VER QUE MATERIALES TIENE EL TRABAJADOR ACTUALMENTE ENTREGADOS
SELECT DISTINCT A.ID_ALMACEN,A.nombre_almacen as almacen,f.id_finca,n.folio,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,w.id_material,w.clave, w.nombre_material, d.cantidad, u.nombre_unidad_medida as um 
FROM EPP.DET_MOV_NVO_EPP_ALM N
INNER JOIN EPP.MOVIMIENTO_EPP M ON N.FOLIO = M.FOLIO AND M.ID_FINCA = N.ID_FINCA AND M.ID_MATERIAL = N.ID_MATERIAL
INNER JOIN FINCAS F ON N.ID_FINCA = M.ID_FINCA AND M.ID_FINCA = F.ID_FINCA AND N.ID_FINCA = F.ID_FINCA
INNER JOIN TRABAJADORES T ON T.ID_TRAB = M.ID_TRAB
INNER JOIN ALMACEN.FINCA X ON F.ID_FINCA = X.ID_FINCA_PUB
INNER JOIN ALMACEN.MATERIALES W ON M.ID_MATERIAL = W.ID_MATERIAL AND N.ID_MATERIAL = W.ID_MATERIAL
INNER JOIN ALMACEN.DETALLE_MATERIALES_LABOR D ON D.ID_MATERIAL = W.ID_MATERIAL
INNER JOIN ALMACEN.UNIDAD_MEDIDA U ON W.ID_UNIDAD_MEDIDA = U.ID_UNIDAD_MEDIDA
INNER JOIN ALMACEN.ALMACEN A ON X.ID_FINCA = A.ID_FINCA AND A.ID_ALMACEN = N.ALM_DESTINO
WHERE N.DEVOLUCION = FALSE AND T.ID_TRAB = 'FM1318' AND F.NOMBRE_FINCA = 'DON ROLANDO'; -- EDITADO PARCE (1)


-- CONSULTA P/OBTENER DATOS DE VALE DEV X CAMBIO ALMACEN  (REPORTE) ** falta foto
SELECT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um,(CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, p.alm_destino /*, encode(t.foto,'base64') as foto */ FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.dev_x_cambio_labor p WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=p.id_material and p.id_finca=f.id_finca and t.id_trab = P.id_trab and f.nombre_finca = 'DON ROLANDO' and p.id_trab = 'FM1321' AND p.folio = 'CLFM014';

-- CONSULTAR CATALOGO DE LABORES
select * from public.labor order by nombre_labor;

-- CONSULTA P/VISUALIZAR MATERIALES X LABOR ** MODULO
SELECT L.NOMBRE_LABOR, M.CLAVE, M.NOMBRE_MATERIAL, D.CANTIDAD, U.NOMBRE_UNIDAD_MEDIDA AS UM, M.ID_MATERIAL FROM ALMACEN.DETALLE_MATERIALES_LABOR D INNER JOIN PUBLIC.LABOR L ON L.ID_LABOR = D.ID_LABOR INNER JOIN ALMACEN.MATERIALES M ON M.ID_MATERIAL = D.ID_MATERIAL INNER JOIN ALMACEN.UNIDAD_MEDIDA U ON U.ID_UNIDAD_MEDIDA = M.ID_UNIDAD_MEDIDA WHERE L.NOMBRE_LABOR = 'FERTILIZADOR';
 
-- CONSULTA Y FLITROS PARA OBTENER EL ALMACEN DE CAMBIO DE ACUERDO AL TIPO DE TRABAJADOR
SELECT A.ID_ALMACEN, A.NOMBRE_ALMACEN, F.ID_FINCA,F.NOMBRE_FINCA, X.ID_FINCA,X.NOMBRE_FINCA FROM ALMACEN.ALMACEN A INNER JOIN ALMACEN.FINCA F ON F.ID_FINCA = A.ID_FINCA INNER JOIN PUBLIC.FINCAS X ON F.ID_FINCA_PUB = X.ID_FINCA WHERE A.TIPO_ENFERMERIA = FALSE AND X.NOMBRE_FINCA = 'DON ROLANDO' AND A.NOMBRE_ALMACEN LIKE '%CAMPO';
FILTRO 1 --> AND X.NOMBRE_FINCA = 'CALZADITA' 
FILTRO 2 --> AND A.NOMBRE_ALMACEN LIKE '%CAMPO';

-- CONSULTA PARA TRABAJADORES EN MOVIMIENTOS EPP AGREGANDO TIPO DE TRABAJO
SELECT id_trab, CONCAT(nombre_trab||' '||ape_paterno||' '||ape_materno) as nombre_trabajador, X.NOMBRE_TIPO_TRAB AS TIPO 
FROM trabajadores t INNER JOIN fincas f ON (t.id_finca=f.id_finca) INNER JOIN TIPO_TRABAJADOR X ON T.ID_TIPO_TRAB = X.ID_TIPO_TRAB AND  f.nombre_finca = 'DON ROLANDO' group by id_trab,nombre_trabajador,X.NOMBRE_TIPO_TRAB  ORDER BY id_trab;

/* ////////////////////// CONSULTAS P/EXTRAER VIGILANTES ACTIVOS DE FINCA ///////////////////////////// */
-- CONSULTA PARA OBTENER VIGILANTES TOTALES DE TODAS LAS FINCAS
select t.id_trab,t.nombre_trab,t.ape_paterno,t.ape_materno,t.id_tipo_trab from trabajadores t inner join tipo_trabajador p on t.id_tipo_trab = p.id_tipo_trab inner join fincas f on f.id_finca = t.id_finca where t.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES';

-- CONSULTA P/OBTENER VIGILANTES X FINCA (GENERAL)
select t.id_trab,t.nombre_trab,t.ape_paterno,t.ape_materno,t.id_tipo_trab,f.nombre_finca from trabajadores t inner join tipo_trabajador p on t.id_tipo_trab = p.id_tipo_trab inner join fincas f on f.id_finca = t.id_finca where t.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES' and F.nombre_finca = 'MARY CARMEN';

-- CONSULTA P/OBTENER VIGILANTES X FINCA (CONTADOR)
select COUNT(*) from trabajadores t inner join tipo_trabajador p on t.id_tipo_trab = p.id_tipo_trab inner join fincas f on f.id_finca = t.id_finca where t.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES' and F.nombre_finca = 'DON ROLANDO';

-- CONSULTA P/OBTENER EL DETALLE DE GFTES VIGILANTES (TRABAJADORES) CON COBRO
SELECT F.NOMBRE_FINCA,C.FOLIO,T.NOMBRE_AREA_TRABAJO as area,C.FECHA::DATE,C.CANTIDAD,X.COSTO_REPOSICION_EPP AS COSTO_UNIT,C.MONTO,W.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,W.id_tipo_trab
    FROM epp.mov_gft_vst M 
    INNER JOIN epp.cobros_gft_vst C ON C.FOLIO = M.FOLIO AND C.ID_MATERIAL = M.ID_MATERIAL AND C.ID_FINCA = M.ID_FINCA
    INNER JOIN TRABAJADORES W ON W.ID_TRAB = W.ID_TRAB
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND C.ID_FINCA = F.ID_FINCA AND f.id_finca = W.id_finca
    inner join tipo_trabajador p on W.id_tipo_trab = p.id_tipo_trab
    INNER JOIN PUBLIC.AREA_TRABAJO T ON C.ID_AREA_TRABAJO = T.ID_AREA_TRABAJO
    INNER JOIN ALMACEN.MATERIALES X ON C.ID_MATERIAL = X.ID_MATERIAL AND M.ID_MATERIAL = X.ID_MATERIAL
    where W.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES' AND C.FOLIO = 'GVFM001';

-- CONSULTA P/OBTENER EL DETALLE DE GFTES VIGILANTES (TRABAJADORES) GRATIS GRATIS
SELECT F.NOMBRE_FINCA,C.FOLIO,T.NOMBRE_AREA_TRABAJO as area,C.FECHA::DATE,C.CANTIDAD,X.COSTO_REPOSICION_EPP AS COSTO_UNIT,C.MONTO,W.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,W.id_tipo_trab
    FROM epp.mov_gft_vst M 
    INNER JOIN epp.reposiciones_gft_vst C ON C.FOLIO = M.FOLIO AND C.ID_MATERIAL = M.ID_MATERIAL AND C.ID_FINCA = M.ID_FINCA
    INNER JOIN TRABAJADORES W ON W.ID_TRAB = W.ID_TRAB
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND C.ID_FINCA = F.ID_FINCA AND f.id_finca = W.id_finca
    inner join tipo_trabajador p on W.id_tipo_trab = p.id_tipo_trab
    INNER JOIN PUBLIC.AREA_TRABAJO T ON C.ID_AREA_TRABAJO = T.ID_AREA_TRABAJO
    INNER JOIN ALMACEN.MATERIALES X ON C.ID_MATERIAL = X.ID_MATERIAL AND M.ID_MATERIAL = X.ID_MATERIAL
    where W.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES' AND C.FOLIO = 'GVFM003'; -- AQUI

-- CONSULTA PARA OBTENER FOLIOS USADOS REP_DET_GFT_VST
select f.id_finca,f.nombre_finca,f.nombre_corto,g.folio from fincas f, epp.cntrl_folio_repo_gft_vst g where g.uso = false and f.nombre_corto like '%FM%' and g.folio LIKE '%FM%'; -- SOLO G.FOLIO

-- ACTUALIZAR EL STATUS DE USO DE FOLIO GFT_VSIT
UPDATE epp.cntrl_folio_repo_gft_vst SET USO = TRUE WHERE USO = FALSE AND  FOLIO LIKE '%FM%';

-- consulta p/obener materiales con estatus nuevo ingreso 
SELECT DISTINCT F.NOMBRE_FINCA,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA::DATE,E.FOLIO,(CASE WHEN e.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado
    FROM epp.det_mov_nvo_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB ;

-- CONTADORES PARA VALIDAR ESTADO DE ENTREGA 
select COUNT(*) AS tot from epp.det_mov_nvo_epp_alm E WHERE folio = 'NFM001'; -- contar todos los materiales

select COUNT(*) AS mat from epp.det_mov_nvo_epp_alm E WHERE e.entregado = true and folio = 'NFM001'; -- mat surtidos

/* /////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- CONSULTA P/OBTENER ENCABEZADO DE REPORTE REPOSICIONES
SELECT DISTINCT z.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,z.fecha,z.tipo_cobro,(CASE WHEN z.surtido = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado from public.trabajadores t 
inner join public.fincas f on f.id_finca = f.id_finca
inner join epp.reposiciones z on f.id_finca = z.id_finca and t.id_trab = z.id_trab
where z.folio = 'RFM002';

/* /////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- CONSULTA PARA VER PENDIENTE DE ENTRADA POR DEVOLUCION
SELECT M.clave, M.nombre_material,existencia, n.cantidad 
FROM almacen.materiales m INNER JOIN almacen.unidad_medida um ON (m.id_unidad_medida=um.id_unidad_medida) 
INNER JOIN almacen.inventario i ON (i.id_material=m.id_material) 
INNER JOIN almacen.almacen a ON (a.id_almacen=i.id_almacen) 
INNER JOIN epp.dev_x_cambio_labor n ON (n.id_material = m.id_material) 
WHERE nombre_almacen='DON ROLANDO CAMPO' AND existencia>=0 and estatus=TRUE AND eliminado = FALSE 
AND  folio = 'CLFM000' AND n.entregado = false ORDER BY clave;
   
-- CONSULTA P/OBTENER DATOS DE VALE DEV X CAMBIO ALMACEN  (REPORTE) ** falta foto
select p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,p.fecha::date,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um,(CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, g.folio as foli_alm /*, encode(t.foto,'base64') as foto */ from public.trabajadores t 
inner join public.labor l on t.id_labor = l.id_labor 
inner join public.cargo c on t.id_cargo = c.id_cargo 
inner join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
inner join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
inner join public.fincas f on f.id_finca = f.id_finca
inner join epp.dev_x_cambio_labor p on m.id_material=p.id_material and p.id_finca=f.id_finca AND t.id_trab = p.id_trab
left join almacen.movimientos g on p.id_movimiento = g.id_movimiento
where p.folio = 'CLFM000';

/* /////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- PRESTAMOS POR LABOR
SELECT DISTINCT L.NOMBRE_LABOR,M.CLAVE,M.NOMBRE_MATERIAL,D.CANTIDAD::NUMERIC(10,2),U.NOMBRE_UNIDAD_MEDIDA AS UM,M.ID_MATERIAL FROM ALMACEN.DETALLE_MATERIALES_LABOR D INNER JOIN PUBLIC.LABOR L ON L.ID_LABOR = D.ID_LABOR INNER JOIN ALMACEN.MATERIALES M ON M.ID_MATERIAL = D.ID_MATERIAL INNER JOIN ALMACEN.UNIDAD_MEDIDA U ON U.ID_UNIDAD_MEDIDA = M.ID_UNIDAD_MEDIDA WHERE L.NOMBRE_LABOR = 'FERTILIZADOR';

-- CONSULTAR MATERIALES POR CLAVE ALM
SELECT ID_MATERIAL,CLAVE,NOMBRE_MATERIAL FROM ALMACEN.MATERIALES WHERE TIPO_EPP = TRUE; WHERE CLAVE ='ZAP0003';

-- MATERIALES ACTUALES POR LABOR POR TRABAJADOR
select m.clave, m.nombre_material, d.cantidad, u.nombre_unidad_medida as um FROM public.trabajadores t, public.labor l, almacen.detalle_materiales_labor d, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v WHERE t.id_labor = l.id_labor and l.id_labor = d.id_labor and d.id_material = m.id_material and m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and t.id_trab = 'FE1141' and f.nombre_finca = 'DON ROLANDO';

/* /////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- CONSULTA P/OBTENER DATOS DE VALE BAJA EPP TRABAJADOR (REPORTE) ** falta foto
SELECT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um /*, encode(t.foto,'base64') as foto */ FROM public.trabajadores t, public.labor l, almacen.materiales m, almacen.unidad_medida u, fincas f, cargo c, area_trabajo a, tipo_trabajador v,epp.det_mov_baja_epp_enf p,epp.movimiento_epp x WHERE t.id_labor = l.id_labor and  m.id_unidad_medida = u.id_unidad_medida and t.id_cargo = c.id_cargo and t.id_area_trabajo = a.id_area_trabajo and l.id_tipo_trab = v.id_tipo_trab and m.id_material=p.id_material and p.id_finca=f.id_finca  and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material and t.id_trab = x.id_trab and t.id_trab = 'FM1321' and f.nombre_finca = 'DON ROLANDO' and p.folio = 'NFM006'; 

-- CONSULTA P/OBTENER EL REPORTE DETALLADO DE BAJA CON COSTO A PAGAR
select p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,p.fecha::date,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um, (CASE WHEN p.entregado = false THEN ((m.costo_reposicion_epp * 0.20) + m.costo_reposicion_epp) ELSE 0.0 END) AS costo,(CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'DEVUELTO' END) AS estado, g.folio as foli_alm /*, encode(t.foto,'base64') as foto */ from public.trabajadores t 
inner join public.labor l on t.id_labor = l.id_labor 
inner join public.cargo c on t.id_cargo = c.id_cargo 
inner join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
inner join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
inner join public.fincas f on f.id_finca = f.id_finca
inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab and m.id_material=x.id_material
inner join epp.det_mov_baja_epp_alm p on m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material 
left join almacen.movimientos g on p.id_movimiento = g.id_movimiento
where p.folio = 'BFM001';

/* /////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- ENCABEZADO P/OBTENER COBROS POR NO DEVOLVER PRESTAMOS
SELECT DISTINCT E.ID_FINCA,F.NOMBRE_FINCA,T.ID_TRAB,E.ID_MATERIAL,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA_FIN_PRESTA::DATE,E.FOLIO
    FROM epp.det_mov_presta_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE E.RECEPCION = FALSE AND E.FECHA_FIN_PRESTA::DATE BETWEEN CURRENT_DATE - 10 AND CURRENT_DATE + 2; 

-- CONSULTA P/OBTENER EL REPORTE DETALLADO DE PRESTAMO NO DEVUELTO A PAGAR
SELECT p.folio,f.nombre_finca as finca,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo,v.nombre_tipo_trab as tipo_trab,c.nombre_cargo as cargo,nombre_area_trabajo as area,l.nombre_labor as labor,m.id_material,m.clave, m.nombre_material, p.cantidad, u.nombre_unidad_medida as um,(CASE WHEN p.entregado = false THEN 'PENDIENTE' ELSE 'ENTREGADO' END) AS estado, (CASE WHEN p.recepcion = false THEN 'NO' ELSE 'SI' END) AS recep,(CASE WHEN p.recepcion = false THEN ((m.costo_reposicion_epp * 0.20) + m.costo_reposicion_epp) ELSE 0.0 END) AS costo, /*encode(t.foto,'base64') as foto,*/(CASE WHEN p.id_movimiento_rec is null THEN h.folio ELSE g.folio END) AS  foli_alm FROM public.trabajadores t
inner join public.labor l on t.id_labor = l.id_labor 
inner join public.cargo c on t.id_cargo = c.id_cargo 
inner join public.area_trabajo a on t.id_area_trabajo = a.id_area_trabajo 
inner join almacen.unidad_medida u on u.id_unidad_medida = u.id_unidad_medida 
inner join almacen.materiales m on m.id_unidad_medida = u.id_unidad_medida 
inner join public.tipo_trabajador v on l.id_tipo_trab = v.id_tipo_trab 
inner join public.fincas f on f.id_finca = f.id_finca
inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab and m.id_material=x.id_material
inner join epp.det_mov_presta_epp_alm p on m.id_material=p.id_material and p.id_finca=f.id_finca and p.folio = x.folio and p.id_finca = x.id_finca and p.id_material = x.id_material 
left join almacen.movimientos g on p.id_movimiento_rec = g.id_movimiento
left join almacen.movimientos h on p.id_movimiento_ini = h.id_movimiento
where p.folio = 'PFM001' ORDER BY FOLI_ALM DESC; 

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- CONSULTA P/GENERAR COBROS POR REPOSICION (EXTRAVIO)
SELECT DISTINCT f.nombre_finca as finca,k.folio,m.id_material,t.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, k.monto as costo,CONCAT('REPOSICION') as referencia,k.fecha,k.tipo_cobro from public.trabajadores t 
    inner join public.fincas f on f.id_finca = f.id_finca
    inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab
    inner join almacen.materiales m on m.id_material = x.id_material 
    inner join epp.det_mov_repo_epp_enf p on p.id_finca=f.id_finca and p.folio = x.folio and p.id_material = m.id_material
    inner join epp.cobros_detalle k on k.id_finca = p.id_finca and k.folio = p.folio and k.id_material = p.id_material and x.id_trab = k.id_trab
    where k.fecha::date between '2020-06-03' and '2020-07-03';
    
FILTRO POR FINCA --> where f.id_finca = 1;

-- CONSULTA P/GENERAR COBROS POR PRESTAMOS NO DEVUELTOS
SELECT p.folio,f.nombre_finca as finca,t.id_trab,m.id_material,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo, m.costo_reposicion_epp AS costo,CONCAT('PRESTAMO') as referencia,p.fecha_fin_presta
FROM public.trabajadores t
inner join public.fincas f on f.id_finca = f.id_finca
inner join epp.movimiento_epp x on f.id_finca = x.id_finca and t.id_trab = x.id_trab
inner join almacen.materiales m on m.id_material = x.id_material 
inner join epp.det_mov_presta_epp_alm p on m.id_material=p.id_material and p.id_finca = f.id_finca and p.folio = x.folio and p.id_material = x.id_material
where p.recepcion = false and est = 3 and p.fecha_fin_presta::date between '2020-06-03' and '2020-07-03'; 

FILTRO POR FINCA --> where f.id_finca = 1;

-- CONSULTA EN COBROS PRESTA REPORTE EPP ENF
SELECT DISTINCT F.NOMBRE_FINCA,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA_FIN_PRESTA::DATE,E.FOLIO
    FROM epp.det_mov_presta_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE E.RECEPCION = FALSE AND EST = 3 AND (E.FECHA_FIN_PRESTA::DATE between '2020-06-03' and '2020-07-03'); -- REPORTE SIN FINCA

-- CONSULTA PARA ACTUALIZAR TAREA PROGRAMADA DE PRESTAMO
SELECT DISTINCT F.NOMBRE_FINCA,T.ID_TRAB,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_t,E.FECHA_FIN_PRESTA::DATE,E.ENTREGADO,E.FOLIO,E.RECEPCION,E.est
    FROM epp.det_mov_presta_epp_alm E
    INNER JOIN epp.movimiento_epp M ON E.FOLIO = M.FOLIO AND E.ID_MATERIAL = M.ID_MATERIAL AND E.ID_FINCA = M.ID_FINCA
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND E.ID_FINCA = F.ID_FINCA
    INNER JOIN PUBLIC.TRABAJADORES T ON M.ID_TRAB = T.ID_TRAB
    WHERE E.entregado = true and E.RECEPCION = FALSE AND (E.FECHA_FIN_PRESTA::DATE <= CURRENT_DATE);

-- CONSULTA P/GENERAR COBROS POR REPO CON COBRO DE GFT VISITANTES
SELECT F.NOMBRE_FINCA as finca,C.FOLIO,C.FECHA::DATE,C.CANTIDAD::integer,X.COSTO_REPOSICION_EPP AS COSTO_UNIT,C.MONTO as costo,W.id_trab,CONCAT(nombre_trab, ' ', ape_paterno, ' ', ape_materno) as nombre_completo
    FROM epp.mov_gft_vst M 
    INNER JOIN epp.cobros_gft_vst C ON C.FOLIO = M.FOLIO AND C.ID_MATERIAL = M.ID_MATERIAL AND C.ID_FINCA = M.ID_FINCA
    INNER JOIN TRABAJADORES W ON W.ID_TRAB = W.ID_TRAB
    INNER JOIN PUBLIC.FINCAS F ON M.ID_FINCA = F.ID_FINCA AND C.ID_FINCA = F.ID_FINCA AND f.id_finca = W.id_finca
    inner join tipo_trabajador p on W.id_tipo_trab = p.id_tipo_trab
    INNER JOIN PUBLIC.AREA_TRABAJO T ON C.ID_AREA_TRABAJO = T.ID_AREA_TRABAJO
    INNER JOIN ALMACEN.MATERIALES X ON C.ID_MATERIAL = X.ID_MATERIAL AND M.ID_MATERIAL = X.ID_MATERIAL
    WHERE c.fecha::date between '2020-05-03' and '2020-07-03' AND W.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES' and w.id_trab = 'FM1322';
    
FILTRO POR FINCA --> where f.id_finca = 1; 
    
select COUNT(*) from trabajadores t inner join tipo_trabajador p on t.id_tipo_trab = p.id_tipo_trab inner join fincas f on f.id_finca = t.id_finca where t.status_trab = 1 and nombre_tipo_trab = 'VIGILANTES' and F.nombre_finca = 'DON ROLANDO';    

-- DETALLE MATERIALES POR LABOR
SELECT DISTINCT D.ID_LABOR,L.NOMBRE_LABOR,M.CLAVE,M.ID_MATERIAL,M.NOMBRE_MATERIAL,D.CANTIDAD::NUMERIC(10,2),U.NOMBRE_UNIDAD_MEDIDA AS UM FROM ALMACEN.DETALLE_MATERIALES_LABOR D INNER JOIN PUBLIC.LABOR L ON L.ID_LABOR = D.ID_LABOR INNER JOIN ALMACEN.MATERIALES M ON M.ID_MATERIAL = D.ID_MATERIAL INNER JOIN ALMACEN.UNIDAD_MEDIDA U ON U.ID_UNIDAD_MEDIDA = M.ID_UNIDAD_MEDIDA WHERE L.NOMBRE_LABOR = 'FERTILIZADOR';

/* /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// */
-- OBTENER FECHA INICIAL DE LA SEMANA (DOMINGO)
SELECT d.fec_ini, EXTRACT('month' from d.fec_ini) FROM
(SELECT generate_series(0,30) + current_date -30 as fec_ini) d
WHERE EXTRACT('month' from d.fec_ini) <= EXTRACT('month' from current_date)
AND EXTRACT('dow'from d.fec_ini) = '0';

-- OBTENER FECHA FINAL DE LA SEMANA (SABADO)
SELECT f.fec_fin, EXTRACT('month' from f.fec_fin) FROM
(SELECT generate_series(0,30) + current_date -25 as fec_fin) f
WHERE EXTRACT('month' from f.fec_fin) <= EXTRACT('month' from current_date)
AND EXTRACT('dow'from f.fec_fin) = '6';
 
-- CONSULTA PARA OBTENER LOS PRIVILEGIOS P/ACTIVAR TRABAJADOR --
select u.id_usuario, u.nombre_usuario, t.id_tipo_usuario, t.nombre_tipo_usuario, p.act_trab from usuarios u inner join tipos_de_usuarios t on u.id_tipo_usuario = t.id_tipo_usuario inner join privilegios_usuarios p on u.id_usuario = p.id_usuario where u.id_tipo_usuario = '0' and p.act_trab = 1 and u.id_usuario = 6;

/** ESO ES TODO AMIGOS  L(0_0L)   **/