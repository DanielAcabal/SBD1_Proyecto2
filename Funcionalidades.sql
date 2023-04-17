DELIMITER //
CREATE PROCEDURE RegistrarPuesto(
    IN nombre VARCHAR(30),
    IN descripcion VARCHAR(75),
    IN salario DECIMAL(8, 2)
)
BEGIN
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
BEGIN
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
BEGIN
  DECLARE muni INTEGER;
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
BEGIN
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
BEGIN
  DECLARE muni INTEGER;
  INSERT IGNORE INTO municipio (nombre) VALUES (municipio);
  SELECT m.id_municipio into muni FROM municipio m WHERE m.nombre=municipio;
  INSERT INTO direccion (direccion,zona,id_municipio) VALUES (direccion,zona,muni);
  INSERT INTO restaurante VALUES (id,telefono,personal,parqueo,LAST_INSERT_ID(), muni);
END;

//
CREATE FUNCTION getEstado(estado VARCHAR(20))
RETURNS INTEGER
BEGIN
  RETURN
  SELECT e.id_estado FROM estado_orden e WHERE e.nombre=estado;
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
