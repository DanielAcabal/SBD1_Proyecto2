DELIMITER //
CREATE PROCEDURE RegistrarPuesto(
    IN nombre VARCHAR(30),
    IN descripcion VARCHAR(75),
    IN salario DECIMAL(8, 2)
)
puesto:BEGIN
  -- Validando salario
  IF salario < 0 THEN
    SELECT "El salario debe ser positivo" AS ERROR;
    LEAVE puesto;
  END IF;
  -- Validando si existe 
  IF (SELECT p.id_puesto FROM puesto_trabajo p WHERE p.nombre=UPPER(nombre)) IS NOT NULL THEN
    SELECT CONCAT("El puesto ", nombre, " ya existe") AS ERROR;
    LEAVE puesto;
  END IF;
  -- Se guarda en mayúsculas para no repetir puesto
    INSERT INTO puesto_trabajo(nombre, descripcion, salario)
VALUES(UPPER(nombre), descripcion, salario);
  SELECT "Puesto registrado" AS MESSAGE;
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
  -- Validando correo
  IF check_with_regex(correo,'^[a-zA-Z0-9_!#$%&*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+') != 0 THEN
    SELECT "Correo no válido" AS ERROR;
    LEAVE cliente;
  END IF;
  -- Si existe cliente
  IF existe_cliente(dpi) THEN
    SELECT CONCAT("El cliente ", dpi, " ya existe") AS ERROR;
    LEAVE cliente;
  END IF;
  -- Registrando cliente
  INSERT INTO cliente 
  VALUES ( dpi,nombre,apellidos,correo,telefono,nit,nacimiento );
  SELECT "Cliente registrado" AS MESSAGE;
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
  -- Buscando el cliente
  IF NOT existe_cliente(dpi) THEN
    SELECT CONCAT("No existe el cliente ",dpi) AS ERROR;
    LEAVE direccion;
  END IF;
  -- Validando zona positiva
  IF zona < 0 THEN
    SELECT "La zona debe ser positiva" AS ERROR;
    LEAVE direccion;
  END IF;
  -- Ingresando municipio en mayúsculas
  INSERT IGNORE INTO municipio (nombre) VALUES (UPPER(municipio));
  -- Obteniendo id del municipio
  SELECT m.id_municipio into muni FROM municipio m WHERE m.nombre=municipio;
  -- Registrando dirección
  INSERT INTO direccion (direccion,zona,id_municipio) VALUES (direccion,zona,muni);
  -- Asociando dirección a un cliente
  INSERT INTO direccion_entrega (dpi_cliente,id_direccion,id_municipio)
    VALUES (dpi,LAST_INSERT_ID(), muni);
  SELECT "Direccion registrada" AS MESSAGE;
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
  DECLARE empleados,maximo INTEGER;
  -- Validando correo
  IF check_with_regex(correo,'^[a-zA-Z0-9_!#$%&*+/=?`{|}~^.-]+@[a-zA-Z0-9.-]+') != 0 THEN
    SELECT "Correo no válido" AS ERROR;
    LEAVE empleado;
  END IF;
  -- Si existe dpi empleado
  IF existe_dpi_empleado(dpi) THEN
    SELECT CONCAT("El empleado ", dpi, " ya existe") AS ERROR;
    LEAVE empleado;
  END IF;
  -- Si no existe puesto
  IF NOT existe_puesto(puesto) THEN
    SELECT CONCAT("El puesto ", puesto, " no existe") AS ERROR;
    LEAVE empleado;
  END IF;
  -- Si no existe restaurante 
  IF NOT existe_restaurante(restaurante) THEN
    SELECT CONCAT("El restaurante ", restaurante, " no existe") AS ERROR;
    LEAVE empleado;
  END IF;
  -- Obteniendo empleados del restaurante
  SELECT COUNT(*) INTO empleados FROM empleado e WHERE e.id_restaurante=restaurante;
  -- Obteniendo capacidad máxima de personal
  SELECT r.personal INTO maximo FROM restaurante r WHERE r.id_restaurante=restaurante;
  -- Validando contratación
  IF empleados=maximo THEN
    SELECT "Cantidad de empleados máxima" AS ERROR;
    LEAVE empleado;
  END IF;
  -- Registrando empleado
  INSERT INTO empleado (nombres,apellidos,fecha_nacimiento,
                        correo,telefono,direccion,dpi,fecha_inicio,id_puesto,
                        id_restaurante)
    VALUES (nombres,apellidos,nacimiento,correo,telefono,direccion,dpi,inicio,
            puesto,restaurante);
  SELECT "Empleado registrado" AS MESSAGE;
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
  -- Validando zona positiva
  IF zona < 0 THEN
    SELECT "La zona debe ser positiva" AS ERROR;
    LEAVE restaurante;
  END IF;
  -- Validando personal positivo
  IF personal < 0 THEN
    SELECT "La cantidad de personal debe ser positiva" AS ERROR;
    LEAVE restaurante;
  END IF;
  -- Validando parámetro parqueo
  IF parqueo!=0 AND parqueo!=1 THEN
    SELECT "El parqueo debe ser 0(No) o 1(Si)" AS ERROR;
    LEAVE restaurante;
  END IF;
  -- Si existe restaurante
  IF existe_restaurante(id) THEN
    SELECT CONCAT("El restaurante ", id, " ya existe") AS ERROR;
    LEAVE restaurante;
  END IF;
  -- Ingresando municipio
  INSERT IGNORE INTO municipio (nombre) VALUES (UPPER(municipio));
  -- Obteniendo id municipio
  SELECT m.id_municipio into muni FROM municipio m WHERE m.nombre=municipio;
  -- Registramos dirección
  INSERT INTO direccion (direccion,zona,id_municipio) VALUES (direccion,zona,muni);
  -- Creamos restaurante
  INSERT INTO restaurante VALUES (id,telefono,personal,parqueo,LAST_INSERT_ID(), muni);
  SELECT "Restaurante registrado" AS MESSAGE;
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
  DECLARE muni,direc,repartidor INTEGER;
  DECLARE res VARCHAR(30);
  -- Buscando cliente
  IF NOT existe_cliente(dpi) THEN
    SELECT CONCAT('No existe el cliente ',dpi) AS ERROR;
    LEAVE orden;
  END IF;
  -- Verificando el canal
  IF check_with_regex(canal,'L|A') THEN
    SELECT 'Solamente puede usar canal L o A' AS ERROR;
    LEAVE orden;
  END IF;
   -- Verificando si el cliente tiene registrada la dirección
  SELECT id_direccion,id_municipio INTO direc,muni FROM direccion_entrega WHERE dpi_cliente=dpi AND id_direccion=direccion;
  IF direc IS NULL OR muni IS NULL THEN
    SELECT 'Esta direccion no la tiene registrada' AS ERROR;
    LEAVE orden;
  END IF;
  -- Si hay un restaurante en la misma zona y municipio
  CALL datos_cobertura(dpi,direccion,res);
  IF res IS NULL THEN
    SELECT 'Sin cobertura' AS ERROR;
    -- Se guarda la orden como sin cobertura
  INSERT INTO orden (
  canal,fecha_inicio,fecha_entrega,id_estado,dpi_cliente,id_direccion,id_municipio,id_restaurante
 ) VALUES 
  ( canal, NOW(), NULL, getEstado("SIN COBERTURA"), dpi, direccion, muni, res); -- Revisar xd 
  LEAVE orden;
  END IF;
  -- Creando la orden
 INSERT INTO orden (
  canal,fecha_inicio,id_estado,dpi_cliente,id_direccion,id_municipio,id_restaurante
 ) VALUES 
  ( canal, NOW(), getEstado("INICIADA"), dpi, direc, muni, res);
  SELECT "Orden creada" AS MESSAGE;
END;
//
DELIMITER //
CREATE PROCEDURE datos_cobertura(dpi BIGINT, direc INTEGER, OUT res VARCHAR(30))
BEGIN
SELECT t.id_restaurante INTO res FROM ( SELECT r.id_restaurante,d.zona,d.id_municipio FROM restaurante r
  JOIN direccion d ON r.id_direccion=d.id_direccion) t
  JOIN (
  SELECT d1.*,d.dpi_cliente FROM direccion_entrega d 
  JOIN direccion d1 ON d.id_direccion=d1.id_direccion
  WHERE d.dpi_cliente=dpi AND d.id_direccion=direc) t1
  ON t.zona=t1.zona AND t.id_municipio=t1.id_municipio
  LIMIT 1;
END
//
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
CREATE FUNCTION existe_dpi_empleado( dpi BIGINT )
RETURNS BOOLEAN
BEGIN
	RETURN  (SELECT EXISTS(SELECT 1  FROM empleado e WHERE e.dpi=dpi));
END
//
CREATE FUNCTION existe_puesto( id INTEGER )
RETURNS BOOLEAN
BEGIN
	RETURN  (SELECT EXISTS(SELECT 1  FROM puesto_trabajo WHERE id_puesto=id));
END
//
CREATE FUNCTION existe_restaurante( id VARCHAR(30) )
RETURNS BOOLEAN
BEGIN
	RETURN  (SELECT EXISTS(SELECT 1  FROM restaurante WHERE id_restaurante=id));
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
CREATE PROCEDURE AgregarItem(
  IN id_orden INT(8),
  IN tipo_producto CHAR(1),
  IN producto   INTEGER,
  IN cantidad INTEGER,
  IN observacion VARCHAR(100)
)
item:BEGIN
  DECLARE estado_orden INTEGER;
  DECLARE id_producto VARCHAR(3);
  -- Validando cantidad
  IF cantidad < 0 THEN
    SELECT "La cantidad debe ser positiva" AS ERROR;
    LEAVE item;
  END IF;
  -- Validando producto
  IF producto < 0 THEN
    SELECT "No existe un producto negativo" AS ERROR;
    LEAVE item;
  END IF;
  -- Validando tipo de producto
  IF check_with_regex(tipo_producto,"[CEBP]") THEN
    SELECT "Los tipos de producto son 'C','E','B' o 'P'" AS ERROR;
    LEAVE item; 
  END IF;
  -- Verificando si existe la orden
  IF NOT existe_orden(id_orden) THEN
    SELECT CONCAT("La orden ",id_orden," no existe") AS ERROR;
    LEAVE item;
  END IF;
  -- Verificando si el estado de la orden es INICIADA o AGREGANDO
  SELECT o.id_estado INTO estado_orden FROM orden o WHERE o.id_orden=id_orden;
  IF estado_orden!=getEstado("INICIADA") AND estado_orden!=getEstado("AGREGANDO")  THEN
    SELECT "La orden debe estar iniciada o agregando item" AS ERROR;
    LEAVE item;
  END IF;
  -- Creando ID del producto
  SELECT CONCAT(tipo_producto,producto) INTO id_producto;
  -- Verificando si existe el producto
  IF NOT EXISTS(SELECT 1 FROM producto p WHERE p.id_producto = id_producto) THEN
    SELECT CONCAT("No existe el producto ",id_producto) AS ERROR;
    LEAVE item;
  END IF;
  -- Si el estado es INICIADA, cambia el estado de la orden a AGREGANDO
  IF estado_orden=getEstado("INICIADA") THEN
    UPDATE orden o
      SET o.id_estado = getEstado("AGREGANDO")
      WHERE o.id_orden= id_orden;
  END IF;
  -- En el caso de agregar un producto que ya fue agregado, aumentará la cantidad
  IF existe_detalle_orden(id_orden,id_producto) THEN
    UPDATE detalle_orden d
      SET d.cantidad=d.cantidad + cantidad,
          d.observacion = observacion
      WHERE d.id_producto=id_producto AND d.id_orden=id_orden;
  -- En caso contrario se añade el producto a la orden
  ELSE
    INSERT INTO detalle_orden
    VALUES ( cantidad,observacion,id_orden,id_producto ); 
  END IF;
  SELECT CONCAT("Item ",id_producto," añadido") AS MESSAGE;
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
CREATE FUNCTION getPuesto(nombre VARCHAR(30))
RETURNS INTEGER
BEGIN
  RETURN (SELECT id_puesto FROM puesto_trabajo p WHERE p.nombre=nombre);
END
//
CREATE PROCEDURE ConfirmarOrden(
  IN id_orden   INT(8),
  IN forma_pago CHAR(1),
  IN repartidor INTEGER
)
confirmar:BEGIN
  DECLARE estado_orden,muni INTEGER;
  DECLARE dpi BIGINT;
  DECLARE total DECIMAL(8,2);
  DECLARE nit VARCHAR(12);
  -- Validando forma de pago
  IF forma_pago!="E" AND forma_pago!="T" THEN
    SELECT "Forma de pago no válida" AS ERROR;
    LEAVE confirmar;
  END IF;
  -- Verificando que exista la orden
   IF NOT existe_orden(id_orden) THEN
    SELECT CONCAT("La orden ",id_orden," no existe") AS ERROR;
    LEAVE confirmar;
  END IF;
  -- Validando que el empleado exista
   IF NOT existe_empleado(repartidor) THEN
    SELECT CONCAT("No existe el empleado ",repartidor) AS ERROR;
    LEAVE confirmar;
  END IF;
  -- Obteniendo datos de la orden
  SELECT o.id_estado,o.id_municipio,o.dpi_cliente INTO estado_orden,muni,dpi FROM orden o WHERE o.id_orden=id_orden;
  -- Verificando si el estado de orden es AGREGANDO
  IF estado_orden!=getEstado("AGREGANDO")  THEN
    SELECT "La orden debe tener items o con estado AGREGANDO" AS ERROR;
    LEAVE confirmar;
  END IF;
  -- Se actualiza la orden a EN CAMINO
  UPDATE orden o
    SET o.id_estado=getEstado("EN CAMINO"),
        o.repartidor= repartidor
    WHERE o.id_orden=id_orden;  
  -- Obteniendo el monto de la orden
  SELECT getTotal(id_orden) INTO total;
  -- Obteniendo el nit del cliente, si es null entonces nit = C/F
  SELECT nit INTO nit FROM cliente WHERE dpi_cliente=dpi;
  IF nit IS NULL THEN
    SELECT "C/F" INTO nit;
  END IF;
  -- Creando factura, el total se añade el 12% del IVA
  INSERT INTO factura 
  VALUES ( CONCAT(YEAR(NOW()),id_orden), total+total*0.12 , muni , NOW(), id_orden, nit , forma_pago );
  SELECT CONCAT("La orden ", id_orden, " está en camino") AS MESSAGE;
END
//
CREATE PROCEDURE FinalizarOrden (
  IN id_orden INTEGER
)
fin:BEGIN
  DECLARE estado INTEGER;
  -- Verificando si la orden existe
  IF NOT existe_orden(id_orden) THEN
    SELECT CONCAT("No existe la orden ",id_orden) AS ERROR;
    LEAVE fin;
  END IF;
  -- Verificando si el estado es EN CAMINO
  SELECT o.id_estado INTO estado FROM orden o WHERE o.id_orden=id_orden;
  IF estado!=getEstado("EN CAMINO") THEN
    SELECT "Para finalizar, la orden debe estar en camino" AS ERROR;
    LEAVE fin;
  END IF;
  -- Actualizando estado de orden a ENTREGADA y fecha de entrega
  UPDATE orden o
    SET o.id_estado=getEstado("ENTREGADA"),
        o.fecha_entrega= NOW()
    WHERE o.id_orden=id_orden;
  SELECT "Orden finalizada" AS MESSAGE;
END
