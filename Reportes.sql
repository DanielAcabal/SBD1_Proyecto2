DELIMITER //
-- Listar Restaurantes 
CREATE PROCEDURE ListarRestaurantes()
BEGIN
  SELECT r.id_restaurante,
        r.telefono,
        r.personal,
        (CASE WHEN r.parqueo THEN "Si" ELSE "No" END)AS parqueo,
        d.direccion,
        d.zona,
        m.nombre 
    FROM restaurante r
    JOIN direccion d ON r.id_direccion=d.id_direccion
    JOIN municipio m ON d.id_municipio=m.id_municipio;
END
//
-- Consultar Empleado
CREATE PROCEDURE ConsultarEmpleado(
  IN id_empleado INT(8) UNSIGNED
)
empleado:BEGIN
  -- Verificando si existe el empleado
  IF NOT existe_empleado(id_empleado) THEN
    SELECT CONCAT("No existe el empleado ",id_empleado) AS ERROR;
    LEAVE empleado;
  END IF;
  SELECT e.id_empleado,
        CONCAT(e.nombres," ",e.apellidos) AS nombre_completo,
        e.fecha_nacimiento,
        e.correo,
        e.telefono,
        e.direccion,
        e.dpi,
        p.nombre AS puesto,
        e.fecha_inicio,
        p.salario
    FROM empleado e
    JOIN puesto_trabajo p ON p.id_puesto=e.id_puesto
    WHERE e.id_empleado=id_empleado; 
END
//
-- Consultar detalle de pedido
CREATE PROCEDURE ConsultarPedidosCliente(
  IN id_orden INTEGER 
)
pedido:BEGIN
  -- Verificando si existe la orden
  IF NOT existe_orden(id_orden) THEN
    SELECT CONCAT("No existe la orden ",id_empleado) AS ERROR;
    LEAVE pedido;
  END IF;
  SELECT p.nombre,
        (CASE SUBSTRING(p.id_producto,1,1)
        WHEN "C" THEN "Combo"
        WHEN "B" THEN "Bebida"
        WHEN "P" THEN "Postre"
        WHEN "E" THEN "Extra"
        END 
        ) AS tipo,
        p.precio,
        d.cantidad,
        d.observacion
    FROM detalle_orden d
    JOIN producto p ON d.id_producto=p.id_producto
    WHERE d.id_orden=id_orden;  
END
//
-- Consultar el historial de órdenes de un cliente
CREATE PROCEDURE ConsultarHistorialOrdener(
  IN dpi_cliente BIGINT
)
historial:BEGIN
  -- Verificando si existe cliente
  IF NOT existe_cliente(dpi_cliente) THEN
    SELECT CONCAT("No existe el cliente ",id_empleado) AS ERROR;
    LEAVE historial;
  END IF;
  SELECT o.id_orden,
        o.fecha_inicio AS fecha,
        getTotal(o.id_orden) AS monto,
        o.id_restaurante,
        CONCAT(e.nombres," ",e.apellidos) AS repartidor,
        CONCAT(d.direccion,", Zona ",d.zona,", ",m.nombre) AS direccion_entrega,
        (CASE WHEN o.canal="L" THEN "Llamada" ELSE "Aplicación" END) AS canal
    FROM orden o
    JOIN direccion d ON o.id_direccion=d.id_direccion
    JOIN municipio m ON o.id_municipio=m.id_municipio
    JOIN empleado e ON o.repartidor=e.id_empleado
    WHERE o.dpi_cliente=dpi_cliente; 
END
//
-- Consultar direcciones de un cliente
CREATE PROCEDURE ConsultarDirecciones(
  IN dpi_cliente BIGINT
)
direccion:BEGIN
  -- Verificando si existe cliente
  IF NOT existe_cliente(dpi_cliente) THEN
    SELECT CONCAT("No existe el cliente ",id_empleado) AS ERROR;
    LEAVE direccion;
  END IF;
  SELECT d2.direccion,
        m.nombre,
        d2.zona
    FROM direccion_entrega d1
    JOIN direccion d2 ON d1.id_direccion=d2.id_direccion
    JOIN municipio m ON d2.id_municipio=m.id_municipio
    WHERE d1.dpi_cliente=dpi_cliente;
END
//
-- Mostrar ordenes según su estado
CREATE PROCEDURE MostrarOrdenes(
  IN id_estado INTEGER
)
BEGIN
  DECLARE estado VARCHAR(20);
  -- Parseo de estados
  SELECT (CASE id_estado
    WHEN 1 THEN "INICIADA" 
    WHEN 2 THEN "AGREGANDO"
    WHEN 3 THEN "EN CAMINO" 
    WHEN 4 THEN "ENTREGADA" 
    WHEN -1 THEN "SIN COBERTURA" 
    ELSE ""
  END) INTO estado;
  SELECT o.id_orden,
        estado,
        o.fecha_inicio AS fecha,
        o.dpi_cliente,
        CONCAT(d.direccion,", Zona ",d.zona,", ",m.nombre) AS direccion_entrega,
        o.id_restaurante,
        (CASE WHEN o.canal="L" THEN "Llamada" ELSE "Aplicación" END) AS canal
    FROM orden o
    JOIN direccion d ON o.id_direccion=d.id_direccion
    JOIN municipio m ON o.id_municipio=m.id_municipio
    JOIN empleado e ON o.repartidor=e.id_empleado
    WHERE o.id_estado=getEstado(estado);
END
//
-- Consultar Facturas
CREATE PROCEDURE ConsultarFacturas(
  IN dia INTEGER,
  IN mes INTEGER,
  IN anio INTEGER
)
BEGIN
  SELECT f.serie,
        f.total,
        m.nombre,
        f.fecha,
        f.id_orden,
        f.nit,
        (CASE WHEN f.forma_pago="E" THEN "Efectivo" ELSE "Tarjeta" END) AS forma_pago
    FROM factura f 
    JOIN municipio m ON f.id_municipio=m.id_municipio
    WHERE DATE(f.fecha)=CONCAT(anio,"-",mes,"-",dia);
END
//
-- Consultar tiempos de espera
CREATE PROCEDURE ConsultarTiempos(
  IN minutos INTEGER
)
tiempos:BEGIN
  -- Validando minutos positivos
  IF minutos < 0 THEN
    SELECT "Los minutos deben ser positivos" AS ERROR;
    LEAVE tiempos;
  END IF;
  SELECT o.id_orden, 
        CONCAT(d.direccion,", Zona ",d.zona,", ",m.nombre) AS direccion_entrega,
        o.fecha_inicio,
        TIMESTAMPDIFF(MINUTE,o.fecha_inicio,o.fecha_entrega) AS minutos_espera,
        CONCAT(e.nombres," ",e.apellidos) AS repartidor
    FROM orden o
    JOIN direccion d ON o.id_direccion=d.id_direccion
    JOIN municipio m ON o.id_municipio=m.id_municipio
    JOIN empleado e ON o.repartidor=e.id_empleado
    WHERE TIMESTAMPDIFF(MINUTE,o.fecha_inicio,o.fecha_entrega)>=minutos;
END
