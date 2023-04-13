DELIMITER //
CREATE PROCEDURE registrar_puesto(
    IN nombre VARCHAR(30),
    IN descripcion VARCHAR(75),
    IN salario DECIMAL(8, 2)
)
BEGIN
    INSERT INTO puesto_trabajo(nombre, descripcion, salario)
VALUES(nombre, descripcion, salario);
END;
//
CREATE PROCEDURE registrar_cliente(
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
CREATE PROCEDURE registrar_direccion(
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
CREATE PROCEDURE registrar_empleado(
  IN nombres    VARCHAR(30),
  IN apellidos  VARCHAR(30),
  IN nacimiento DATE,
  IN correo     VARCHAR(30),
  IN telefono   INTEGER,
  IN direccion  VARCHAR(75),
  IN dpi        BIGINT,
  IN puesto     INTEGER,
  IN inicio     DATE
)
BEGIN
  INSERT INTO empleado (nombres,apellidos,fecha_nacimiento,
                        correo,telefono,dpi,fecha_inicio,id_puesto,
                        id_direccion,id_municipio)
    VALUES (nombres,apellidos,nacimiento,correo,telefono,dpi,inicio,
            puesto,1,1);
END;
//
CREATE PROCEDURE registrar_restaurante(
  IN id         VARCHAR(30),
  IN direccion  VARCHAR(75),
  IN municipio  VARCHAR(30),
  IN zona       INTEGER,
  IN telefono   INTEGER,
  IN personal   INTEGER,
  IN parqueo    BOOLEAN,
  IN gerente    INTEGER
)
BEGIN
  DECLARE muni INTEGER;
  INSERT IGNORE INTO municipio (nombre) VALUES (municipio);
  SELECT m.id_municipio into muni FROM municipio m WHERE m.nombre=municipio;
  INSERT INTO direccion (direccion,zona,id_municipio) VALUES (direccion,zona,muni);
  INSERT INTO restaurante VALUES (id,telefono,personal,parqueo,LAST_INSERT_ID(), muni,gerente);
END;

//
CREATE PROCEDURE crear_orden(
  IN dpi        BIGINT,
  IN direccion  INTEGER,
  IN canal      CHAR(2)
)
BEGIN
  DECLARE estado INTEGER;
  DECLARE muni INTEGER;
  SELECT e.id_estado INTO estado FROM estado_orden e WHERE e.nombre="INICIADA";
  SELECT e.id_municipio INTO muni FROM direccion_entrega e WHERE e.id_direccion=direccion;
 INSERT INTO orden (
  canal,fecha_inicio,fecha_entrega,id_estado,dpi_cliente,id_direccion,id_municipio
 ) VALUES 
  ( canal, NOW(), NULL, estado, dpi, direccion, muni); -- Revisar xd 
END;
//
