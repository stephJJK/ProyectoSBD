USE RENT_A_CAR;

-- 1) CATEGORIA

INSERT INTO categoria (nombre, deposito_garantia) VALUES
('Económico', 300),
('Compacto', 350),
('Sedán', 400),
('SUV', 600),
('SUV Premium', 800),
('Pickup', 700),
('Minivan', 900),
('Eléctrico', 500),
('Híbrido', 550),
('Luxury', 1200);

-- 2) SUCURSAL (Budget Ecuador)

INSERT INTO sucursal (nombre, direccion, tipo) VALUES
('Quito Aeropuerto', 'Av. Amazonas s/n', 'Aeropuerto'),
('Quito Centro', 'Av. 10 de Agosto', 'Ciudad'),
('Guayaquil Aeropuerto', 'Av. de las Américas', 'Aeropuerto'),
('Guayaquil Centro', 'Av. Francisco de Orellana', 'Ciudad'),
('Cuenca Centro', 'Av. Solano', 'Ciudad'),
('Manta Aeropuerto', 'Via Aeropuerto', 'Aeropuerto'),
('Manta Centro', 'Av. Malecón', 'Ciudad'),
('Loja Centro', 'Av. Universitaria', 'Ciudad'),
('Ambato Centro', 'Av. Cevallos', 'Ciudad'),
('Salinas Aeropuerto', 'Base Aérea', 'Aeropuerto');

-- 3) CLIENTE

INSERT INTO cliente (tipo_cliente, identificacion, nombre_razon_social, licencia_conducir, vigencia_licencia, contacto) VALUES
('Individual','0102345678','Juan Pérez','L-12345','2027-05-10','juan@gmail.com'),
('Individual','0912345678','María López','L-54321','2026-11-20','maria@yahoo.com'),
('Individual','0923456789','Carlos Torres','L-67890','2028-03-15','carlos@hotmail.com'),
('Corporativo','1790012345001','Petroecuador',NULL,NULL,'contacto@petroecuador.ec'),
('Corporativo','0999999999001','Pronaca',NULL,NULL,'info@pronaca.com'),
('Individual','1103456789','Ana Ruiz','L-11223','2026-08-01','ana@gmail.com'),
('Individual','1204567890','Luis Vega','L-33445','2027-01-12','luis@gmail.com'),
('Corporativo','1792121212001','CNT EP',NULL,NULL,'ventas@cnt.gob.ec'),
('Individual','1305678901','Sofía Molina','L-99887','2028-09-30','sofia@gmail.com'),
('Individual','1406789012','Diego Andrade','L-77665','2027-12-05','diego@gmail.com');

-- 4) VEHICULO

INSERT INTO vehiculo (placa, marca, modelo, anio, kilometraje, estado, id_sucursal, id_categoria) VALUES
('ABC-1234','Toyota','Yaris',2022,25000,'Disponible',1,1),
('DEF-5678','Chevrolet','Spark',2021,30000,'Disponible',2,1),
('GHI-9012','Hyundai','Accent',2023,15000,'Disponible',3,3),
('JKL-3456','Kia','Sportage',2022,28000,'Disponible',4,4),
('MNO-7890','Toyota','Fortuner',2023,12000,'Disponible',1,5),
('PQR-1122','Mazda','CX-5',2021,35000,'Disponible',5,4),
('STU-3344','Nissan','Frontier',2022,40000,'Disponible',6,6),
('VWX-5566','Toyota','Hiace',2020,60000,'Disponible',7,7),
('YZA-7788','Tesla','Model 3',2023,10000,'Disponible',1,8),
('BCD-9900','BMW','X5',2022,22000,'Disponible',3,10);

-- 5) TARIFA

INSERT INTO tarifa (id_categoria, precio_dia, fecha_inicio, fecha_fin) VALUES
(1,35,'2024-01-01',NULL),
(2,40,'2024-01-01',NULL),
(3,50,'2024-01-01',NULL),
(4,70,'2024-01-01',NULL),
(5,90,'2024-01-01',NULL),
(6,80,'2024-01-01',NULL),
(7,95,'2024-01-01',NULL),
(8,85,'2024-01-01',NULL),
(9,88,'2024-01-01',NULL),
(10,150,'2024-01-01',NULL);

-- 6) SEGURO

INSERT INTO seguro (nombre, costo_diario, cobertura) VALUES
('Basico',10,'Daños a terceros'),
('Full',20,'Daños + robo'),
('Premium',30,'Cobertura total'),
('Basico',10,'Uso urbano'),
('Full',20,'Uso nacional'),
('Premium',30,'Cobertura internacional'),
('Basico',12,'Daños menores'),
('Full',22,'Asistencia vial'),
('Premium',35,'Auto sustituto'),
('Full',25,'Cobertura extendida');

-- 7) USUARIO

INSERT INTO usuario (username, rol, id_sucursal) VALUES
('admin1','Admin',1),
('agente_q1','Agente',1),
('agente_gye1','Agente',3),
('agente_cuenca','Agente',5),
('gestor1','Gestor',2),
('agente_manta','Agente',6),
('agente_loja','Agente',8),
('gestor2','Gestor',4),
('admin2','Admin',3),
('agente_salinas','Agente',10);

-- 8) BITACORA
-- Registra acciones realizadas por usuarios del sistema

INSERT INTO bitacora (id_usuario, accion, tabla_afectada) VALUES
(1,'Creación de reserva','reserva'),
(2,'Apertura de contrato','contrato'),
(3,'Registro de pago','pago'),
(4,'Cierre de contrato','contrato'),
(5,'Actualización de vehículo','vehiculo'),
(6,'Registro de inspección','inspeccion'),
(7,'Generación de factura','factura'),
(8,'Registro de sanción','sancion'),
(9,'Ingreso a mantenimiento','mantenimiento'),
(10,'Traslado de vehículo','historial_movimiento');

-- 9) EXTRA

INSERT INTO extra (nombre, precio_dia) VALUES
('GPS',5),
('SillaBebe',7),
('GPS',6),
('SillaBebe',8),
('GPS',5),
('SillaBebe',7),
('GPS',6),
('SillaBebe',8),
('GPS',5),
('SillaBebe',7);

-- 10) RESERVA

INSERT INTO reserva (id_cliente, id_categoria, id_sucursal_retiro, id_sucursal_devolucion, fecha_retiro, fecha_devolucion, estado) VALUES
(1,1,1,2,'2024-06-01 10:00','2024-06-05 10:00','Confirmada'),
(2,3,3,3,'2024-06-03 09:00','2024-06-07 09:00','Confirmada'),
(3,4,4,5,'2024-06-05 08:00','2024-06-10 08:00','Pendiente'),
(4,6,1,1,'2024-06-01 12:00','2024-06-15 12:00','Confirmada'),
(5,7,3,7,'2024-06-02 14:00','2024-06-09 14:00','Confirmada'),
(6,2,2,2,'2024-06-04 10:00','2024-06-06 10:00','Cancelada'),
(7,5,5,5,'2024-06-07 09:00','2024-06-14 09:00','Confirmada'),
(8,1,6,6,'2024-06-08 11:00','2024-06-12 11:00','Confirmada'),
(9,8,1,1,'2024-06-09 08:00','2024-06-13 08:00','Confirmada'),
(10,10,3,3,'2024-06-10 10:00','2024-06-15 10:00','Pendiente');

-- 11) DETALLE_RESERVA_EXTRA
-- Extras asociados a reservas (GPS / SillaBebe)

INSERT INTO detalle_reserva_extra (id_reserva, id_extra, cantidad, precio_unitario) VALUES
(1,1,1,5.00), 
(1,2,1,7.00),  
(2,1,1,5.00),  
(3,2,2,7.00),  
(4,1,1,6.00),
(5,2,1,8.00),
(6,1,1,5.00),
(7,2,2,7.00),
(8,1,1,6.00),
(9,2,1,7.00);

-- 12) CONTRATO

INSERT INTO contrato (id_reserva, placa_vehiculo, id_agente, id_seguro, km_salida, km_llegada, total_pagar, estado) VALUES
(1,'ABC-1234',2,2,25000,25500,300,'Cerrado'),
(2,'GHI-9012',3,3,15000,15600,420,'Cerrado'),
(3,'JKL-3456',4,1,28000,NULL,500,'Abierto'),
(4,'STU-3344',2,2,40000,41000,800,'Cerrado'),
(5,'VWX-5566',3,3,60000,61000,950,'Cerrado'),
(6,'DEF-5678',5,1,30000,NULL,120,'Abierto'),
(7,'MNO-7890',4,3,12000,13000,700,'Cerrado'),
(8,'PQR-1122',6,2,35000,36000,450,'Cerrado'),
(9,'YZA-7788',2,3,10000,NULL,600,'Abierto'),
(10,'BCD-9900',3,3,22000,23000,1500,'Cerrado');

-- 13) PAGO

INSERT INTO pago (id_contrato, monto, tipo, fecha) VALUES
(1,150,'Anticipo','2024-06-01'),
(1,150,'Liquidacion','2024-06-05'),
(2,200,'Anticipo','2024-06-03'),
(2,220,'Liquidacion','2024-06-07'),
(4,400,'Anticipo','2024-06-01'),
(4,400,'Liquidacion','2024-06-15'),
(5,500,'Anticipo','2024-06-02'),
(5,450,'Liquidacion','2024-06-09'),
(7,350,'Anticipo','2024-06-07'),
(10,1500,'Liquidacion','2024-06-15');

-- 14) FACTURA
-- Valores coherentes: subtotal + iva = total
-- IVA asumido 12% (Ecuador)

INSERT INTO factura (id_contrato, id_cliente, numero_autorizacion, subtotal, iva, total, fecha_emision) VALUES
(1,1,'AUT-001',267.86,32.14,300.00,'2024-06-05'),
(2,2,'AUT-002',375.00,45.00,420.00,'2024-06-07'),
(4,4,'AUT-003',714.29,85.71,800.00,'2024-06-15'),
(5,5,'AUT-004',848.21,101.79,950.00,'2024-06-09'),
(7,7,'AUT-005',625.00,75.00,700.00,'2024-06-14'),
(8,8,'AUT-006',401.79,48.21,450.00,'2024-06-12'),
(10,10,'AUT-007',1339.29,160.71,1500.00,'2024-06-15'),
(1,1,'AUT-008',250.00,30.00,280.00,'2024-06-06'),
(2,2,'AUT-009',300.00,36.00,336.00,'2024-06-08'),
(5,5,'AUT-010',500.00,60.00,560.00,'2024-06-10');

-- 18) INSPECCION
-- Check-Out: al entregar el vehículo
-- Check-In: al devolver el vehículo

INSERT INTO inspeccion (id_contrato, tipo, url_fotos, observaciones, nivel_gasolina) VALUES
(1,'Check-Out','http://budget.ec/fotos/cont1_out','Vehículo en buen estado',95),
(1,'Check-In','http://budget.ec/fotos/cont1_in','Rayón leve en puerta',90),

(2,'Check-Out','http://budget.ec/fotos/cont2_out','Sin novedades',100),
(2,'Check-In','http://budget.ec/fotos/cont2_in','Entrega normal',85),

(4,'Check-Out','http://budget.ec/fotos/cont4_out','Vehículo limpio',98),
(4,'Check-In','http://budget.ec/fotos/cont4_in','Olor a tabaco',80),

(5,'Check-Out','http://budget.ec/fotos/cont5_out','Estado óptimo',100),
(5,'Check-In','http://budget.ec/fotos/cont5_in','Golpe leve en parachoques',75),

(7,'Check-Out','http://budget.ec/fotos/cont7_out','Sin observaciones',95),
(7,'Check-In','http://budget.ec/fotos/cont7_in','Entrega puntual',90);


-- 16) MANTENIMIENTO
-- Preventivo y correctivo, fechas válidas

INSERT INTO mantenimiento (placa_vehiculo, tipo, costo, fecha_entrada, fecha_salida) VALUES
('DEF-5678','Preventivo',120,'2024-05-01','2024-05-03'),
('JKL-3456','Correctivo',350,'2024-04-10','2024-04-15'),
('STU-3344','Preventivo',180,'2024-05-20','2024-05-22'),
('VWX-5566','Correctivo',600,'2024-03-01','2024-03-10'),
('ABC-1234','Preventivo',150,'2024-06-01','2024-06-02'),
('PQR-1122','Preventivo',200,'2024-04-05','2024-04-07'),
('YZA-7788','Correctivo',500,'2024-02-15','2024-02-20'),
('BCD-9900','Preventivo',300,'2024-03-12','2024-03-14'),
('GHI-9012','Preventivo',140,'2024-05-10','2024-05-11'),
('MNO-7890','Correctivo',450,'2024-01-20','2024-01-25');

-- 17) HISTORIAL_MOVIMIENTO
-- Registra traslados, alquileres y envíos a taller

INSERT INTO historial_movimiento (placa_vehiculo, id_sucursal_origen, id_sucursal_destino, motivo) VALUES
('ABC-1234',1,2,'Alquiler'),
('DEF-5678',2,3,'Taller'),
('GHI-9012',3,5,'Traslado'),
('JKL-3456',4,1,'Alquiler'),
('STU-3344',6,4,'Taller'),
('VWX-5566',7,3,'Traslado'),
('PQR-1122',5,2,'Alquiler'),
('YZA-7788',1,3,'Alquiler'),
('BCD-9900',3,5,'Alquiler'),
('MNO-7890',1,4,'Traslado');

-- 18) SANCION

INSERT INTO sancion (id_contrato, motivo, monto_penalidad, estado) VALUES
(1,'MultaTransito',50,'Pagada'),
(2,'Danios',120,'Pagada'),
(4,'OlorTabaco',80,'Pendiente'),
(5,'Danios',200,'Pagada'),
(7,'MultaTransito',60,'Pendiente'),
(10,'Danios',300,'Pendiente'),
(1,'OlorTabaco',70,'Pagada'),
(2,'MultaTransito',40,'Pagada'),
(5,'Danios',150,'Pendiente'),
(7,'OlorTabaco',90,'Pagada');
