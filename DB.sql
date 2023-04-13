CREATE TABLE cliente (
    dpi_cliente      INTEGER NOT NULL PRIMARY KEY,
    nombre           VARCHAR(30) NOT NULL,
    apellidos        VARCHAR(30) NOT NULL,
    correo           VARCHAR(30) NOT NULL,
    telefono         INTEGER NOT NULL,
    nit              INTEGER,
    fecha_nacimiento DATE NOT NULL
);

CREATE TABLE estado_orden (
    id_estado INTEGER NOT NULL PRIMARY KEY,
    nombre    VARCHAR(20) NOT NULL
);

CREATE TABLE municipio (
    id_municipio INTEGER NOT NULL PRIMARY KEY,
    nombre       VARCHAR(30) NOT NULL
);

CREATE TABLE producto (
    id_producto VARCHAR(3) NOT NULL PRIMARY KEY,
    nombre      VARCHAR(30) NOT NULL,
    precio      DEC(5, 2) NOT NULL
);

CREATE TABLE puesto_trabajo (
    id_puesto   INTEGER NOT NULL PRIMARY KEY,
    nombre      VARCHAR(30) NOT NULL,
    descripcion VARCHAR(75) NOT NULL,
    salario     DEC(5, 2) NOT NULL
);

CREATE TABLE direccion (
    id_direccion           INTEGER NOT NULL,
    direccion              VARCHAR(75) NOT NULL,
    zona                   INTEGER NOT NULL,
    id_municipio           INTEGER NOT NULL,
    CONSTRAINT direccion_pk PRIMARY KEY(id_direccion,id_municipio),
    CONSTRAINT direccion_municipio_fk FOREIGN KEY(id_municipio) REFERENCES municipio ( id_municipio )
);

CREATE TABLE restaurante (
    id_restaurante         VARCHAR(30) NOT NULL PRIMARY KEY,
    telefono               INTEGER NOT NULL,
    personal               INTEGER NOT NULL,
    parqueo                INTEGER NOT NULL,
    id_direccion           INTEGER NOT NULL, 
    id_municipio           INTEGER NOT NULL,
    CONSTRAINT restaurante_direccion_fk FOREIGN KEY(id_direccion,id_municipio) REFERENCES direccion ( id_direccion, id_municipio),
    CONSTRAINT UC_restaurante UNIQUE (id_direccion,id_municipio)
);
CREATE TABLE empleado (
    id_empleado                INTEGER NOT NULL PRIMARY KEY,
    nombre                     VARCHAR(30) NOT NULL,
    apelido                    VARCHAR(30) NOT NULL,
    fecha_nacimiento           DATE NOT NULL,
    correo                     VARCHAR(30) NOT NULL,
    telefono                   INTEGER NOT NULL,
    dpi                        INTEGER NOT NULL,
    fecha_inicio               DATE NOT NULL,
    id_puesto                  INTEGER NOT NULL,
    id_restaurante             VARCHAR(30) NOT NULL,
    CONSTRAINT empleado_restaurante_fk FOREIGN KEY(id_restaurante) REFERENCES restaurante (id_restaurante),
    CONSTRAINT empleado_puesto_trabajo_fk FOREIGN KEY(id_puesto) REFERENCES puesto_trabajo ( id_puesto )
);

CREATE TABLE direccion_entrega (
    dpi_cliente            INTEGER NOT NULL,
    id_direccion           INTEGER NOT NULL, 
    id_municipio           INTEGER NOT NULL,
    CONSTRAINT direccion_entrega_pk PRIMARY KEY(dpi_cliente,id_direccion,id_municipio),
    CONSTRAINT direccion_entrega_cliente_fk FOREIGN KEY ( dpi_cliente ) REFERENCES cliente ( dpi_cliente),
    CONSTRAINT direccion_entrega_direccion_fk FOREIGN KEY ( id_direccion, id_municipio) REFERENCES direccion ( id_direccion, id_municipio )
);

CREATE TABLE orden (
    id_orden                INTEGER NOT NULL PRIMARY KEY,
    canal                   CHAR(1) NOT NULL,
    fecha_inicio            DATE NOT NULL,
    fecha_entrega           DATE,
    id_estado               INTEGER NOT NULL,
    dpi_cliente             INTEGER NOT NULL,
    id_direccion            INTEGER NOT NULL,
    id_municipio            INTEGER NOT NULL,
    CONSTRAINT orden_estado_orden_fk FOREIGN KEY( id_estado ) REFERENCES estado_orden ( id_estado ),
    CONSTRAINT orden_entrega_fk FOREIGN KEY(dpi_cliente,id_direccion,id_municipio) 
              REFERENCES direccion_entrega(dpi_cliente,id_direccion, id_municipio)
);
CREATE TABLE detalle_orden (
    cantidad             INTEGER NOT NULL,
    observacion          VARCHAR(50),
    id_orden             INTEGER NOT NULL,
    id_producto          VARCHAR(3) NOT NULL,
    CONSTRAINT detalle_orden_pk PRIMARY KEY(id_orden,id_producto),
    CONSTRAINT detalle_orden_orden_fk FOREIGN KEY ( id_orden ) REFERENCES orden ( id_orden ),
    CONSTRAINT detalle_orden_producto_fk FOREIGN KEY ( id_producto ) REFERENCES producto ( id_producto )
);


CREATE TABLE factura (
    serie                         VARCHAR(16) NOT NULL PRIMARY KEY,
    total                         DEC(6, 2) NOT NULL,
    id_municipio                  INTEGER NOT NULL,
    fecha                         DATE NOT NULL,
    id_orden                      INTEGER NOT NULL, 
    nit                           INTEGER NOT NULL, 
    forma_pago                    CHAR(1) NOT NULL,
    CONSTRAINT factura_orden_fk FOREIGN KEY(id_orden) REFERENCES orden( id_orden )
);

