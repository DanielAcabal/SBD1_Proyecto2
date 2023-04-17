DELIMITER //
CREATE PROCEDURE RegistrarPuesto(
    IN nombre VARCHAR(30),
    IN descripcion VARCHAR(75),
    IN salario DECIMAL(8, 2)
)
puesto:BEGIN
  IF salario < 0 THEN
    SELECT "El salario debe ser positivo" AS ERROR;
    LEAVE puesto;
  END IF;
    INSERT INTO puesto_trabajo(nombre, descripcion, salario)
VALUES(nombre, descripcion, salario);
END;
//
CREATE PROCEDURE RegistrarCliente(
  IN dpi BIGINT,
  IN nombre VARCHAR(30),
  IN apellidos VARCHAR(30),
  IN nacimiento DATE,
  IN correo VARCHAR(30),
  IN telefono INTEGER,
  IN nit INTEGER
)
cliente:BEGIN
  IF check_with_regex('danchiacabal@gmail.com','^[a-zA-Z0-9_!#$%&*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+') != 0 THEN
    SELECT "Correo no válido" AS ERROR;
    LEAVE cliente;
  END IF;
  INSERT INTO cliente 
  VALUES ( dpi,nombre,apellidos,correo,telefono,nit,nacimiento );
END;
//
CREATE PROCEDURE RegistrarDireccion(
  IN dpi BIGINT,
  IN direccion VARCHAR(75),
  IN municipio VARCHAR(30),
  IN zona INTEGER
)
direccion:BEGIN
  DECLARE muni INTEGER;
  IF NOT existe_cliente(dpi) THEN
    SELECT CONCAT("No existe el cliente ",dpi) AS ERROR;
    LEAVE direccion;
  END IF;
  IF zona < 0 THEN
    SELECT "La zona debe ser positiva" AS ERROR;
    LEAVE direccion;
  END IF;

  INSERT IGNORE INTO municipio (nombre) VALUES (municipio);
  SELECT m.id_municipio into muni FROM municipio m WHERE m.nombre=municipio;
  INSERT INTO direccion (direccion,zona,id_municipio) VALUES (direccion,zona,muni);
  INSERT INTO direccion_entrega (dpi_cliente,id_direccion,id_municipio)
    VALUES (dpi,LAST_INSERT_ID(), muni);
END;
//
CREATE PROCEDURE CrearEmpleado(
  IN nombres    VARCHAR(30),
  IN apellidos  VARCHAR(30),
  IN nacimiento DATE,
  IN correo     VARCHAR(30),
  IN telefono   INTEGER,
  IN direccion  VARCHAR(75),
  IN dpi        BIGINT,
  IN puesto     INTEGER,
  IN inicio     DATE,
  IN restaurante VARCHAR(30)
)
empleado:BEGIN
  IF check_with_regex('danchiacabal@gmail.com','^[a-zA-Z0-9_!#$%&*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+') != 0 THEN
    SELECT "Correo no válido" AS ERROR;
    LEAVE empleado;
  END IF;
  INSERT INTO empleado (nombres,apellidos,fecha_nacimiento,
                        correo,telefono,direccion,dpi,fecha_inicio,id_puesto,
                        id_restaurante)
    VALUES (nombres,apellidos,nacimiento,correo,telefono,direccion,dpi,inicio,
            puesto,restaurante);
END;
//
CREATE PROCEDURE RegistrarRestaurante(
  IN id         VARCHAR(30),
  IN direccion  VARCHAR(75),
  IN municipio  VARCHAR(30),
  IN zona       INTEGER,
  IN telefono   INTEGER,
  IN personal   INTEGER,
  IN parqueo    BOOLEAN
)
restaurante:BEGIN
  DECLARE muni INTEGER;
  IF zona < 0 THEN
    SELECT "La zona debe ser positiva" AS ERROR;
    LEAVE restaurante;
  END IF;
  IF personal < 0 THEN
    SELECT "La cantidad de personal debe ser positiva" AS ERROR;
    LEAVE restaurante;
  END IF;
  INSERT IGNORE INTO municipio (nombre) VALUES (municipio);
  SELECT m.id_municipio into muni FROM municipio m WHERE m.nombre=municipio;
  INSERT INTO direccion (direccion,zona,id_municipio) VALUES (direccion,zona,muni);
  INSERT INTO restaurante VALUES (id,telefono,personal,parqueo,LAST_INSERT_ID(), muni);
END;

//
CREATE FUNCTION getEstado(estado VARCHAR(20))
RETURNS INTEGER
BEGIN
  RETURN (
  SELECT e.id_estado FROM estado_orden e WHERE e.nombre=estado);
END
//
CREATE PROCEDURE CrearOrden(
  IN dpi        BIGINT,
  IN direccion  INTEGER,
  IN canal      CHAR(1)
)
orden:BEGIN
  DECLARE muni,direc INTEGER;
  DECLARE res VARCHAR(30);
  IF NOT existe_cliente(dpi) THEN
    SELECT CONCAT('No existe el cliente ',dpi) AS ERROR;
    LEAVE orden;
  END IF;
  IF check_with_regex(canal,'L|A') THEN
    SELECT 'Solamente puede usar canal L o A' AS ERROR;
    LEAVE orden;
  END IF;
  CALL datos_cobertura(dpi,res);
  IF res IS NULL THEN
    SELECT 'Sin cobertura' AS ERROR;
  INSERT INTO orden (
  canal,fecha_inicio,fecha_entrega,id_estado,dpi_cliente,id_direccion,id_municipio,id_restaurante
 ) VALUES 
  ( canal, NOW(), NULL, getEstado("SIN COBERTURA"), dpi, direccion, muni, res); -- Revisar xd 
  LEAVE orden;
  END IF;
  SELECT id_direccion,id_municipio INTO direc,muni FROM direccion_entrega WHERE dpi_cliente=dpi AND id_direccion=direccion;
  IF direc IS NULL OR muni IS NULL THEN
    SELECT 'Esta direccion no la tiene registrada' AS ERROR;
    LEAVE orden;
  END IF;
 INSERT INTO orden (
  canal,fecha_inicio,fecha_entrega,id_estado,dpi_cliente,id_direccion,id_municipio,id_restaurante
 ) VALUES 
  ( canal, NOW(), NULL, getEstado("INICIADA"), dpi, direc, muni, res); -- Revisar xd 
END;
//
DELIMITER //
CREATE PROCEDURE datos_cobertura(dpi BIGINT, OUT res VARCHAR(30))
BEGIN
SELECT t.id_restaurante INTO res FROM ( SELECT r.id_restaurante,d.zona,d.id_municipio FROM restaurante r
  JOIN direccion d ON r.id_direccion=d.id_direccion) t
  JOIN (
  SELECT d1.*,d.dpi_cliente FROM direccion_entrega d 
  JOIN direccion d1 ON d.id_direccion=d1.id_direccion
  WHERE d.dpi_cliente=dpi) t1
  ON t.zona=t1.zona AND t.id_municipio=t1.id_municipio
  LIMIT 1;
END
//
DROP PROCEDURE IF EXISTS datos_cobertura;
DROP PROCEDURE IF EXISTS CrearOrden;
DELIMITER //
CREATE FUNCTION check_with_regex( txt VARCHAR(100), regex VARCHAR(100))
RETURNS BOOLEAN
BEGIN
	DECLARE ok BOOLEAN DEFAULT FALSE;
    IF (SELECT REGEXP_INSTR(txt,regex)=0) THEN
     SELECT TRUE INTO ok;
    END IF;
    RETURN (ok);
END
//
DELIMITER //
CREATE FUNCTION existe_cliente( dpi BIGINT )
RETURNS BOOLEAN
BEGIN
	RETURN  (SELECT EXISTS(SELECT 1  FROM cliente WHERE dpi_cliente=dpi));
END
//
CREATE FUNCTION existe_empleado( id INTEGER )
RETURNS BOOLEAN
BEGIN
	RETURN  (SELECT EXISTS(SELECT 1  FROM empleado WHERE id_empleado=id));
END
//
CREATE FUNCTION existe_orden( id_orden INTEGER )
RETURNS BOOLEAN
BEGIN
	RETURN  (SELECT EXISTS(SELECT 1  FROM orden o WHERE o.id_orden=id_orden));
END
//
CREATE FUNCTION existe_detalle_orden( id_orden INTEGER, producto VARCHAR(3))
RETURNS BOOLEAN
BEGIN
	RETURN  (SELECT EXISTS(SELECT 1  FROM detalle_orden o WHERE o.id_orden=id_orden AND o.id_producto=producto));
END
//
-- SELECT check_with_regex('danchiacabal@gmail.com','^[a-zA-Z0-9_!#$%&*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+') AS REG;
CREATE PROCEDURE AgregarItem(
  IN id_orden INTEGER,
  IN tipo_producto CHAR(1),
  IN producto   INTEGER,
  IN cantidad INTEGER,
  IN observacion VARCHAR(100)
)
item:BEGIN
  DECLARE estado_orden INTEGER;
  DECLARE id_producto VARCHAR(3);
  IF cantidad < 0 THEN
    SELECT "La cantidad debe ser positiva" AS ERROR;
    LEAVE item;
  END IF;
  IF NOT existe_orden(id_orden) THEN
    SELECT CONCAT("La orden ",id_orden," no existe") AS ERROR;
    LEAVE item;
  END IF;
  SELECT o.id_estado INTO estado_orden FROM orden o WHERE o.id_orden=id_orden;
  IF estado_orden!=getEstado("INICIADA") AND estado_orden!=getEstado("AGREGANDO")  THEN
    SELECT "La orden debe estar iniciada o agregando item" AS ERROR;
    LEAVE item;
  END IF;
  SELECT CONCAT(tipo_producto,producto) INTO id_producto;
  IF NOT EXISTS(SELECT 1 FROM producto p WHERE p.id_producto = id_producto) THEN
    SELECT CONCAT("No existe el producto ",id_producto) AS ERROR;
    LEAVE item;
  END IF;
  IF estado_orden=getEstado("INICIADA") THEN
    UPDATE orden o
      SET o.id_estado = getEstado("AGREGANDO")
      WHERE o.id_orden= id_orden;
  END IF;
  IF existe_detalle_orden(id_orden,id_producto) THEN
    UPDATE detalle_orden d
      SET d.cantidad=d.cantidad + cantidad,
          d.observacion = observacion
      WHERE d.id_producto=id_producto AND d.id_orden=id_orden;
  ELSE
    INSERT INTO detalle_orden
    VALUES ( cantidad,observacion,id_orden,id_producto ); 
  END IF;
END
//
CREATE FUNCTION getTotal(id_orden INTEGER)
RETURNS DECIMAL(8,2)
BEGIN
  RETURN (
    SELECT SUM(p.precio*d.cantidad) FROM detalle_orden d 
    JOIN producto p ON d.id_producto=p.id_producto
    WHERE d.id_orden=id_orden
  );
END
//
CREATE PROCEDURE ConfirmarOrden(
  IN id_orden   INTEGER,
  IN forma_pago CHAR(1),
  IN repartidor INTEGER
)
confirmar:BEGIN
  DECLARE estado_orden,muni INTEGER;
  DECLARE dpi BIGINT;
  DECLARE total DECIMAL(8,2);
  DECLARE nit VARCHAR(12);
  IF forma_pago!="E" AND forma_pago!="T" THEN
    SELECT "Forma de pago no válida" AS ERROR;
    LEAVE confirmar;
  END IF;
   IF NOT existe_empleado(repartidor) THEN
    SELECT CONCAT("No existe el empleado ",repartidor) AS ERROR;
    LEAVE confirmar;
  END IF;
   IF NOT existe_orden(id_orden) THEN
    SELECT CONCAT("La orden ",id_orden," no existe") AS ERROR;
    LEAVE confirmar;
  END IF;
  SELECT o.id_estado,o.id_municipio,o.dpi_cliente INTO estado_orden,muni,dpi FROM orden o WHERE o.id_orden=id_orden;
  IF estado_orden!=getEstado("AGREGANDO")  THEN
    SELECT "La orden debe tener items" AS ERROR;
    LEAVE confirmar;
  END IF;
  UPDATE orden o
    SET o.id_estado=getEstado("EN CAMINO") 
    WHERE o.id_orden=id_orden;  
  SELECT getTotal(id_orden) INTO total;
  SELECT nit INTO nit FROM cliente WHERE dpi_cliente=dpi;
  IF nit IS NULL THEN
    SELECT "C/F" INTO nit;
  END IF;
  INSERT INTO factura 
  VALUES ( CONCAT(YEAR(NOW()),id_orden), total+total*0.12 , muni , NOW(), id_orden, nit , forma_pago );
END
//
CREATE PROCEDURE FinalizarOrden (
  IN id_orden INTEGER
)
fin:BEGIN
  DECLARE estado INTEGER;
  IF NOT existe_orden(id_orden) THEN
    SELECT CONCAT("No existe la orden ",id_orden) AS ERROR;
    LEAVE fin;
  END IF;
  SELECT o.id_estado INTO estado FROM orden o WHERE o.id_orden=id_orden;
  IF estado!=getEstado("EN CAMINO") THEN
    SELECT "Para finalizar, la orden debe estar en camino" AS ERROR;
    LEAVE fin;
  END IF;
  UPDATE orden o
    SET o.id_estado=getEstado("ENTREGADA"),
        o.fecha_entrega= NOW()
    WHERE o.id_orden=id_orden;
END
