CREATE TABLE cliente (
    dpi_cliente      BIGINT NOT NULL PRIMARY KEY,
    nombres           VARCHAR(30) NOT NULL,
    apellidos        VARCHAR(30) NOT NULL,
    correo           VARCHAR(30) NOT NULL,
    telefono         INTEGER NOT NULL,
    nit              VARCHAR(12),
    fecha_nacimiento DATE NOT NULL
);

CREATE TABLE estado_orden (
    id_estado INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre    VARCHAR(20) NOT NULL,
    UNIQUE UC_estado (nombre)
);

CREATE TABLE municipio (
    id_municipio INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre       VARCHAR(30) NOT NULL,
    UNIQUE UC_muni (nombre)
);

CREATE TABLE producto (
    id_producto VARCHAR(3) NOT NULL PRIMARY KEY,
    nombre      VARCHAR(30) NOT NULL,
    precio      DEC(5, 2) NOT NULL,
    CHECK ( precio>0 ),
    UNIQUE UC_producto (nombre)
);

CREATE TABLE puesto_trabajo (
    id_puesto   INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre      VARCHAR(30) NOT NULL,
    descripcion VARCHAR(75) NOT NULL,
    salario     DEC(8, 2) NOT NULL,
    CHECK ( salario > 0 ),
    UNIQUE UC_puesto (nombre)
);

CREATE TABLE direccion (
    id_direccion           INTEGER NOT NULL AUTO_INCREMENT,
    direccion              VARCHAR(75) NOT NULL,
    zona                   INTEGER NOT NULL,
    CHECK ( zona>0 ),
    id_municipio           INTEGER NOT NULL,
    CONSTRAINT direccion_pk PRIMARY KEY(id_direccion,id_municipio),
    CONSTRAINT direccion_municipio_fk FOREIGN KEY(id_municipio) REFERENCES municipio ( id_municipio )
);

CREATE TABLE restaurante (
    id_restaurante         VARCHAR(30) NOT NULL PRIMARY KEY,
    telefono               INTEGER NOT NULL,
    personal               INTEGER NOT NULL,
    parqueo                BOOLEAN NOT NULL,
    id_direccion           INTEGER NOT NULL, 
    id_municipio           INTEGER NOT NULL,
    CHECK ( personal > 0 ),
    CONSTRAINT restaurante_direccion_fk FOREIGN KEY(id_direccion,id_municipio) REFERENCES direccion ( id_direccion, id_municipio),
    CONSTRAINT UC_restaurante UNIQUE (id_direccion,id_municipio)
);

CREATE TABLE empleado (
    id_empleado                INTEGER NOT NULL  AUTO_INCREMENT,
    nombres                    VARCHAR(30) NOT NULL,
    apellidos                  VARCHAR(30) NOT NULL,
    fecha_nacimiento           DATE NOT NULL,
    correo                     VARCHAR(30) NOT NULL,
    telefono                   INTEGER NOT NULL,
    direccion                  VARCHAR(75) NOT NULL,
    dpi                        BIGINT NOT NULL,
    fecha_inicio               DATE NOT NULL,
    id_puesto                  INTEGER NOT NULL,
    id_restaurante             VARCHAR(30) NOT NULL,
    CONSTRAINT empleado_pk PRIMARY KEY(id_empleado,id_restaurante),
    CONSTRAINT empleado_puesto_trabajo_fk FOREIGN KEY(id_puesto) REFERENCES puesto_trabajo ( id_puesto ),
    CONSTRAINT empleado_restaurante_fk FOREIGN KEY(id_restaurante) REFERENCES restaurante( id_restaurante )
);

CREATE TABLE direccion_entrega (
    dpi_cliente            BIGINT NOT NULL,
    id_direccion           INTEGER NOT NULL, 
    id_municipio           INTEGER NOT NULL,
    CONSTRAINT direccion_entrega_pk PRIMARY KEY(dpi_cliente,id_direccion,id_municipio),
    CONSTRAINT direccion_entrega_cliente_fk FOREIGN KEY ( dpi_cliente ) REFERENCES cliente ( dpi_cliente),
    CONSTRAINT direccion_entrega_direccion_fk FOREIGN KEY ( id_direccion, id_municipio) REFERENCES direccion ( id_direccion, id_municipio )
);

CREATE TABLE orden (
    id_orden                INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    canal                   CHAR(1) NOT NULL,
    fecha_inicio            DATETIME NOT NULL,
    fecha_entrega           DATETIME,
    id_estado               INTEGER NOT NULL,
    repartidor              INTEGER,
    id_restaurante          VARCHAR(30),
    dpi_cliente             BIGINT NOT NULL,
    id_direccion            INTEGER ,
    id_municipio            INTEGER ,
    CONSTRAINT orden_estado_orden_fk FOREIGN KEY( id_estado ) REFERENCES estado_orden ( id_estado ),
    CONSTRAINT orden_entrega_fk FOREIGN KEY(dpi_cliente,id_direccion,id_municipio) 
              REFERENCES direccion_entrega(dpi_cliente,id_direccion, id_municipio),
    CONSTRAINT orden_empleado_fk FOREIGN KEY(repartidor,id_restaurante) REFERENCES empleado(id_empleado,id_restaurante)
);
CREATE TABLE detalle_orden (
    cantidad             INTEGER NOT NULL,
    observacion          VARCHAR(100),
    id_orden             INTEGER NOT NULL,
    id_producto          VARCHAR(3) NOT NULL,
    CHECK ( cantidad >=0 ), -- Atención a esto xd
    CONSTRAINT detalle_orden_pk PRIMARY KEY(id_orden,id_producto),
    CONSTRAINT detalle_orden_orden_fk FOREIGN KEY ( id_orden ) REFERENCES orden ( id_orden ),
    CONSTRAINT detalle_orden_producto_fk FOREIGN KEY ( id_producto ) REFERENCES producto ( id_producto )
);


CREATE TABLE factura (
    serie                         VARCHAR(16) NOT NULL PRIMARY KEY,
    total                         DEC(8, 2) NOT NULL,
    id_municipio                  INTEGER NOT NULL,
    fecha                         DATETIME NOT NULL,
    id_orden                      INTEGER NOT NULL, 
    nit                           VARCHAR(12) NOT NULL, 
    forma_pago                    CHAR(1) NOT NULL,
    CONSTRAINT factura_orden_fk FOREIGN KEY(id_orden) REFERENCES orden( id_orden )
);
CREATE TABLE historial (
  fecha DATETIME,
  descripcion VARCHAR(75),
  tipo VARCHAR(10)
);
-- Insert Products
INSERT INTO producto 
 VALUES 
  ("C1","Cheeseburger",41.00),
  ("C2","Chicken Sandwinch",32.00),
  ("C3","BBQ Ribs",54.00),
  ("C4","Pasta Alfredo",47.00),
  ("C5","Pizza Espinator",85.00),
  ("C6","Buffalo Wings",36.00),
  ("E1","Papas fritas",15.00),
  ("E2","Aros de cebolla",17.00),
  ("E3","Coleslaw",12.00),
  ("B1","Coca-Cola",12.00),
  ("B2","Fanta",12.00),
  ("B3","Sprite",12.00),
  ("B4","Té frío",12.00),
  ("B5","Cerveza de barril",18.00),
  ("P1","Copa de helado",13.00),
  ("P2","Cheesecake",15.00),
  ("P3","Cupcake de chocolate",8.00),
  ("P4","Flan",10.00)
;
-- Insert estado_orden
INSERT INTO estado_orden (nombre)
VALUES 
( "INICIADA" ),
( "AGREGANDO" ),
( "EN CAMINO" ),
( "ENTREGADA" ),
( "SIN COBERTURA" )
;
