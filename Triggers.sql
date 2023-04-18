CREATE TRIGGER INSERT_puesto_trabajo AFTER INSERT ON puesto_trabajo
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en puesto_trabajo','INSERT');
CREATE TRIGGER INSERT_empleado AFTER INSERT ON empleado
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en empleado','INSERT');
CREATE TRIGGER INSERT_restaurante AFTER INSERT ON restaurante
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en restaurante','INSERT');
CREATE TRIGGER INSERT_direccion AFTER INSERT ON direccion
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en direccion','INSERT');
CREATE TRIGGER INSERT_municipio AFTER INSERT ON municipio
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en municipio','INSERT');
CREATE TRIGGER INSERT_estado_orden AFTER INSERT ON estado_orden
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en estado_orden','INSERT');
CREATE TRIGGER INSERT_orden AFTER INSERT ON orden
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en orden','INSERT');
CREATE TRIGGER INSERT_factura AFTER INSERT ON factura
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en factura','INSERT');
CREATE TRIGGER INSERT_detalle_orden AFTER INSERT ON detalle_orden
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en detalle_orden','INSERT');
CREATE TRIGGER INSERT_producto AFTER INSERT ON producto
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en producto','INSERT');
CREATE TRIGGER INSERT_direccion_entrega AFTER INSERT ON direccion_entrega
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en direccion_entrega','INSERT');
CREATE TRIGGER INSERT_cliente AFTER INSERT ON cliente
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en cliente','INSERT');
CREATE TRIGGER UPDATE_puesto_trabajo AFTER UPDATE ON puesto_trabajo
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en puesto_trabajo','UPDATE');
CREATE TRIGGER UPDATE_empleado AFTER UPDATE ON empleado
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en empleado','UPDATE');
CREATE TRIGGER UPDATE_restaurante AFTER UPDATE ON restaurante
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en restaurante','UPDATE');
CREATE TRIGGER UPDATE_direccion AFTER UPDATE ON direccion
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en direccion','UPDATE');
CREATE TRIGGER UPDATE_municipio AFTER UPDATE ON municipio
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en municipio','UPDATE');
CREATE TRIGGER UPDATE_estado_orden AFTER UPDATE ON estado_orden
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en estado_orden','UPDATE');
CREATE TRIGGER UPDATE_orden AFTER UPDATE ON orden
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en orden','UPDATE');
CREATE TRIGGER UPDATE_factura AFTER UPDATE ON factura
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en factura','UPDATE');
CREATE TRIGGER UPDATE_detalle_orden AFTER UPDATE ON detalle_orden
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en detalle_orden','UPDATE');
CREATE TRIGGER UPDATE_producto AFTER UPDATE ON producto
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en producto','UPDATE');
CREATE TRIGGER UPDATE_direccion_entrega AFTER UPDATE ON direccion_entrega
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en direccion_entrega','UPDATE');
CREATE TRIGGER UPDATE_cliente AFTER UPDATE ON cliente
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en cliente','UPDATE');
CREATE TRIGGER DELETE_puesto_trabajo AFTER DELETE ON puesto_trabajo
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en puesto_trabajo','DELETE');
CREATE TRIGGER DELETE_empleado AFTER DELETE ON empleado
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en empleado','DELETE');
CREATE TRIGGER DELETE_restaurante AFTER DELETE ON restaurante
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en restaurante','DELETE');
CREATE TRIGGER DELETE_direccion AFTER DELETE ON direccion
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en direccion','DELETE');
CREATE TRIGGER DELETE_municipio AFTER DELETE ON municipio
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en municipio','DELETE');
CREATE TRIGGER DELETE_estado_orden AFTER DELETE ON estado_orden
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en estado_orden','DELETE');
CREATE TRIGGER DELETE_orden AFTER DELETE ON orden
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en orden','DELETE');
CREATE TRIGGER DELETE_factura AFTER DELETE ON factura
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en factura','DELETE');
CREATE TRIGGER DELETE_detalle_orden AFTER DELETE ON detalle_orden
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en detalle_orden','DELETE');
CREATE TRIGGER DELETE_producto AFTER DELETE ON producto
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en producto','DELETE');
CREATE TRIGGER DELETE_direccion_entrega AFTER DELETE ON direccion_entrega
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en direccion_entrega','DELETE');
CREATE TRIGGER DELETE_cliente AFTER DELETE ON cliente
FOR EACH ROW INSERT INTO historial VALUES (NOW(),'Se realizó una acción en cliente','DELETE');
