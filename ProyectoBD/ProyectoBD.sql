-- ==========================================================
-- PROYECTO: BUDGET RENT A CAR ECUADOR (MASTER FINAL CON MULTAS)
-- ==========================================================

DROP DATABASE IF EXISTS RENT_A_CAR;
CREATE DATABASE RENT_A_CAR;
USE RENT_A_CAR;

-- ==========================================================
-- 1. CREACIÓN DE TABLAS
-- ==========================================================

CREATE TABLE categoria (
  id_categoria INT AUTO_INCREMENT,
  nombre VARCHAR(30) NOT NULL,
  deposito_garantia DECIMAL(9,2) NOT NULL DEFAULT 0,
  CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
  CONSTRAINT chk_categoria_deposito CHECK (deposito_garantia >= 0)
);

CREATE TABLE sucursal (
  id_sucursal INT AUTO_INCREMENT,
  nombre VARCHAR(40) NOT NULL,
  direccion VARCHAR(80) NOT NULL,
  tipo VARCHAR(15) NOT NULL,
  CONSTRAINT pk_sucursal PRIMARY KEY (id_sucursal),
  CONSTRAINT chk_sucursal_tipo CHECK (tipo IN ('Aeropuerto', 'Ciudad'))
);

CREATE TABLE cliente (
  id_cliente INT AUTO_INCREMENT,
  tipo_cliente VARCHAR(12) NOT NULL,
  identificacion VARCHAR(13) NOT NULL,
  nombre_razon_social VARCHAR(40) NOT NULL,
  fecha_nacimiento DATE NULL, 
  licencia_conducir VARCHAR(20) NULL,
  vigencia_licencia DATE NULL,
  contacto VARCHAR(80) NULL,
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
  CONSTRAINT chk_cliente_tipo CHECK (tipo_cliente IN ('Individual','Corporativo')),
  CONSTRAINT chk_cliente_licencia CHECK (
      (tipo_cliente = 'Individual' AND licencia_conducir IS NOT NULL)
      OR (tipo_cliente = 'Corporativo')
  )
);

CREATE TABLE vehiculo (
  placa VARCHAR(10),
  marca VARCHAR(30) NOT NULL,
  modelo VARCHAR(30) NOT NULL,
  anio INT NOT NULL,
  kilometraje INT NOT NULL DEFAULT 0,
  estado VARCHAR(20) NOT NULL DEFAULT 'Disponible',
  id_sucursal INT NOT NULL,
  id_categoria INT NOT NULL,
  CONSTRAINT pk_vehiculo PRIMARY KEY (placa),
  CONSTRAINT chk_vehiculo_estado CHECK (estado IN ('Disponible','Alquilado','Mantenimiento','Bloqueado','Reservado')),
  CONSTRAINT fk_vehiculo_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),
  CONSTRAINT fk_vehiculo_categoria FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

CREATE TABLE tarifa (
  id_tarifa INT AUTO_INCREMENT,
  id_categoria INT NOT NULL,
  precio_dia DECIMAL(9,2) NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NULL,
  CONSTRAINT pk_tarifa PRIMARY KEY (id_tarifa),
  CONSTRAINT fk_tarifa_categoria FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

CREATE TABLE seguro (
  id_seguro INT AUTO_INCREMENT,
  nombre VARCHAR(30) NOT NULL,
  costo_diario DECIMAL(9,2) NOT NULL,
  cobertura VARCHAR(80) NOT NULL,
  CONSTRAINT pk_seguro PRIMARY KEY (id_seguro),
  CONSTRAINT chk_seguro_nombre CHECK (nombre IN ('Basico','Full','Premium'))
);

CREATE TABLE usuario (
  id_usuario INT AUTO_INCREMENT,
  username VARCHAR(30) NOT NULL,
  rol VARCHAR(20) NOT NULL,
  id_sucursal INT NOT NULL,
  CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
  CONSTRAINT uq_usuario_username UNIQUE (username),
  CONSTRAINT chk_usuario_rol CHECK (rol IN ('Admin','Agente','Gestor')),
  CONSTRAINT fk_usuario_sucursal FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal)
);

CREATE TABLE bitacora (
  id_bitacora INT AUTO_INCREMENT,
  usuario_sistema VARCHAR(50) DEFAULT NULL,
  id_usuario INT NULL, 
  fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
  accion VARCHAR(255) NOT NULL,
  tabla_afectada VARCHAR(40) NOT NULL,
  CONSTRAINT pk_bitacora PRIMARY KEY (id_bitacora)
);

CREATE TABLE extra (
  id_extra INT AUTO_INCREMENT,
  nombre VARCHAR(40) NOT NULL,
  precio_dia DECIMAL(9,2) NOT NULL DEFAULT 0,
  CONSTRAINT pk_extra PRIMARY KEY (id_extra)
);

CREATE TABLE reserva (
  id_reserva INT AUTO_INCREMENT,
  id_cliente INT NOT NULL,
  id_categoria INT NOT NULL,
  id_sucursal_retiro INT NOT NULL,
  id_sucursal_devolucion INT NOT NULL,
  fecha_retiro DATETIME NOT NULL,
  fecha_devolucion DATETIME NOT NULL,
  placa_vehiculo VARCHAR(10) NULL,
  estado VARCHAR(15) NOT NULL DEFAULT 'Pendiente',
  CONSTRAINT pk_reserva PRIMARY KEY (id_reserva),
  CONSTRAINT chk_reserva_estado CHECK (estado IN ('Pendiente','Confirmada','Cancelada','Vencida')),
  CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  CONSTRAINT fk_reserva_categoria FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),
  CONSTRAINT fk_reserva_suc_ret FOREIGN KEY (id_sucursal_retiro) REFERENCES sucursal(id_sucursal),
  CONSTRAINT fk_reserva_suc_dev FOREIGN KEY (id_sucursal_devolucion) REFERENCES sucursal(id_sucursal),
  CONSTRAINT fk_reserva_placa FOREIGN KEY (placa_vehiculo) REFERENCES vehiculo(placa)
);

CREATE TABLE detalle_reserva_extra (
  id_reserva INT NOT NULL,
  id_extra INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(9,2) NOT NULL,
  CONSTRAINT pk_dre PRIMARY KEY (id_reserva, id_extra),
  CONSTRAINT fk_dre_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
  CONSTRAINT fk_dre_extra FOREIGN KEY (id_extra) REFERENCES extra(id_extra)
);

CREATE TABLE contrato (
  id_contrato INT AUTO_INCREMENT,
  id_reserva INT NOT NULL,
  placa_vehiculo VARCHAR(10) NOT NULL,
  id_agente INT NOT NULL,
  id_seguro INT NOT NULL,
  fecha_apertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_cierre DATETIME NULL,
  km_salida INT NOT NULL,
  km_llegada INT NULL,
  total_pagar DECIMAL(9,2) NOT NULL,
  estado VARCHAR(10) NOT NULL DEFAULT 'Abierto',
  CONSTRAINT pk_contrato PRIMARY KEY (id_contrato),
  CONSTRAINT uq_contrato_reserva UNIQUE (id_reserva),
  CONSTRAINT chk_contrato_estado CHECK (estado IN ('Abierto','Cerrado','Cancelado')), 
  CONSTRAINT fk_contrato_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
  CONSTRAINT fk_contrato_vehiculo FOREIGN KEY (placa_vehiculo) REFERENCES vehiculo(placa),
  CONSTRAINT fk_contrato_agente FOREIGN KEY (id_agente) REFERENCES usuario(id_usuario),
  CONSTRAINT fk_contrato_seguro FOREIGN KEY (id_seguro) REFERENCES seguro(id_seguro)
);

CREATE TABLE pago (
  id_pago INT AUTO_INCREMENT,
  id_contrato INT NOT NULL,
  monto DECIMAL(9,2) NOT NULL,
  tipo VARCHAR(15) NOT NULL,
  fecha DATE NOT NULL,
  CONSTRAINT pk_pago PRIMARY KEY (id_pago),
  CONSTRAINT chk_pago_tipo CHECK (tipo IN ('Anticipo','Liquidacion')),
  CONSTRAINT fk_pago_contrato FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato)
);

CREATE TABLE factura (
  id_factura INT AUTO_INCREMENT,
  id_contrato INT NOT NULL,
  id_cliente INT NOT NULL,
  numero_autorizacion VARCHAR(30) NOT NULL,
  subtotal DECIMAL(9,2) NOT NULL,
  iva DECIMAL(9,2) NOT NULL,
  total DECIMAL(9,2) NOT NULL,
  fecha_emision DATE NOT NULL,
  CONSTRAINT pk_factura PRIMARY KEY (id_factura),
  CONSTRAINT fk_factura_contrato FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato),
  CONSTRAINT fk_factura_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

CREATE TABLE inspeccion (
  id_inspeccion INT AUTO_INCREMENT,
  id_contrato INT NOT NULL,
  tipo VARCHAR(12) NOT NULL,
  url_fotos VARCHAR(255) NULL,
  observaciones VARCHAR(255) NULL,
  nivel_gasolina DECIMAL(5,2) NOT NULL,
  CONSTRAINT pk_inspeccion PRIMARY KEY (id_inspeccion),
  CONSTRAINT chk_inspeccion_tipo CHECK (tipo IN ('Check-Out','Check-In')),
  CONSTRAINT fk_inspeccion_contrato FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato)
);

CREATE TABLE mantenimiento (
  id_mantenimiento INT AUTO_INCREMENT,
  placa_vehiculo VARCHAR(10) NOT NULL,
  tipo VARCHAR(20) NOT NULL,
  costo DECIMAL(9,2) NOT NULL,
  fecha_entrada DATE NOT NULL,
  fecha_salida DATE NULL,
  CONSTRAINT pk_mantenimiento PRIMARY KEY (id_mantenimiento),
  CONSTRAINT chk_mant_tipo CHECK (tipo IN ('Preventivo','Correctivo')),
  CONSTRAINT fk_mant_vehiculo FOREIGN KEY (placa_vehiculo) REFERENCES vehiculo(placa)
);

CREATE TABLE historial_movimiento (
  id_movimiento INT AUTO_INCREMENT,
  placa_vehiculo VARCHAR(10) NOT NULL,
  id_sucursal_origen INT NOT NULL,
  id_sucursal_destino INT NOT NULL,
  fecha_movimiento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  motivo VARCHAR(20) NOT NULL,
  CONSTRAINT pk_hm PRIMARY KEY (id_movimiento),
  CONSTRAINT fk_hm_vehiculo FOREIGN KEY (placa_vehiculo) REFERENCES vehiculo(placa),
  CONSTRAINT fk_hm_orig FOREIGN KEY (id_sucursal_origen) REFERENCES sucursal(id_sucursal),
  CONSTRAINT fk_hm_dest FOREIGN KEY (id_sucursal_destino) REFERENCES sucursal(id_sucursal)
);

CREATE TABLE sancion (
  id_sancion INT AUTO_INCREMENT,
  id_contrato INT NOT NULL,
  motivo VARCHAR(25) NOT NULL,
  monto_penalidad DECIMAL(9,2) NOT NULL,
  estado VARCHAR(12) NOT NULL DEFAULT 'Pendiente',
  CONSTRAINT pk_sancion PRIMARY KEY (id_sancion),
  CONSTRAINT fk_sancion_contrato FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato)
);

-- ==========================================================
-- 2. VISTAS (REPORTES)
-- ==========================================================

CREATE OR REPLACE VIEW vw_flota_disponible AS
SELECT 
    v.placa, 
    CONCAT(v.marca, ' ', v.modelo) AS vehiculo, 
    c.nombre AS categoria, 
    v.id_categoria,  -- Necesario para Python
    s.nombre AS ubicacion
FROM vehiculo v
JOIN categoria c ON v.id_categoria = c.id_categoria
JOIN sucursal s ON v.id_sucursal = s.id_sucursal
WHERE v.estado = 'Disponible';

-- ==========================================================
-- 3. POBLADO DE DATOS (ORDENADO PARA EVITAR ERRORES)
-- ==========================================================

-- 1) CATEGORIA
INSERT INTO categoria (nombre, deposito_garantia) VALUES
('Económico', 300),('Compacto', 350),('Sedán', 400),('SUV', 600),('SUV Premium', 800),('Pickup', 700),('Minivan', 900),('Eléctrico', 500),('Híbrido', 550),('Luxury', 1200);

-- 2) SUCURSAL
INSERT INTO sucursal (nombre, direccion, tipo) VALUES
('Quito Aeropuerto', 'Av. Amazonas s/n', 'Aeropuerto'),('Quito Centro', 'Av. 10 de Agosto', 'Ciudad'),('Guayaquil Aeropuerto', 'Av. de las Américas', 'Aeropuerto'),('Guayaquil Centro', 'Av. Francisco de Orellana', 'Ciudad'),('Cuenca Centro', 'Av. Solano', 'Ciudad'),('Manta Aeropuerto', 'Via Aeropuerto', 'Aeropuerto'),('Manta Centro', 'Av. Malecón', 'Ciudad'),('Loja Centro', 'Av. Universitaria', 'Ciudad'),('Ambato Centro', 'Av. Cevallos', 'Ciudad'),('Salinas Aeropuerto', 'Base Aérea', 'Aeropuerto');

-- 3) CLIENTE
INSERT INTO cliente (tipo_cliente, identificacion, nombre_razon_social, fecha_nacimiento, licencia_conducir, vigencia_licencia, contacto) VALUES
('Individual','0102345678','Juan Pérez', '1990-05-15', 'L-12345','2027-05-10','juan@gmail.com'),
('Individual','0912345678','María López', '1995-10-20', 'L-54321','2026-11-20','maria@yahoo.com'),
('Individual','0923456789','Carlos Torres', '1985-03-01', 'L-67890','2028-03-15','carlos@hotmail.com'),
('Corporativo','1790012345001','Petroecuador', NULL, NULL,NULL,'contacto@petroecuador.ec'),
('Corporativo','0999999999001','Pronaca', NULL, NULL,NULL,'info@pronaca.com'),
('Individual','1103456789','Ana Ruiz', '1992-08-08', 'L-11223','2026-08-01','ana@gmail.com'),
('Individual','1204567890','Luis Vega', '1998-01-12', 'L-33445','2027-01-12','luis@gmail.com'),
('Corporativo','1792121212001','CNT EP', NULL, NULL,NULL,'ventas@cnt.gob.ec'),
('Individual','1305678901','Sofía Molina', '2000-09-30', 'L-99887','2028-09-30','sofia@gmail.com'),
('Individual','1406789012','Diego Andrade', '1980-12-05', 'L-77665','2027-12-05','diego@gmail.com');

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
(1,35,'2024-01-01',NULL), (2,40,'2024-01-01',NULL), (3,50,'2024-01-01',NULL), (4,70,'2024-01-01',NULL), (5,90,'2024-01-01',NULL), (6,80,'2024-01-01',NULL), (7,95,'2024-01-01',NULL), (8,85,'2024-01-01',NULL), (9,88,'2024-01-01',NULL), (10,150,'2024-01-01',NULL);

-- 6) SEGURO
INSERT INTO seguro (nombre, costo_diario, cobertura) VALUES
('Basico',10,'Daños a terceros'), ('Full',20,'Daños + robo'), ('Premium',30,'Cobertura total'), ('Basico',10,'Uso urbano'), ('Full',20,'Uso nacional'), ('Premium',30,'Cobertura internacional'), ('Basico',12,'Daños menores'), ('Full',22,'Asistencia vial'), ('Premium',35,'Auto sustituto'), ('Full',25,'Cobertura extendida');

-- 7) USUARIO
INSERT INTO usuario (username, rol, id_sucursal) VALUES
('admin1','Admin',1), ('agente_q1','Agente',1), ('agente_gye1','Agente',3), ('agente_cuenca','Agente',5), ('gestor1','Gestor',2), ('agente_manta','Agente',6), ('agente_loja','Agente',8), ('gestor2','Gestor',4), ('admin2','Admin',3), ('agente_salinas','Agente',10);

-- 8) BITACORA
INSERT INTO bitacora (id_usuario, accion, tabla_afectada) VALUES
(1,'Creación de reserva','reserva'), (2,'Apertura de contrato','contrato'), (3,'Registro de pago','pago'), (4,'Cierre de contrato','contrato'), (5,'Actualización de vehículo','vehiculo'), (6,'Registro de inspección','inspeccion'), (7,'Generación de factura','factura'), (8,'Registro de sanción','sancion'), (9,'Ingreso a mantenimiento','mantenimiento'), (10,'Traslado de vehículo','historial_movimiento');

-- 9) EXTRA
INSERT INTO extra (nombre, precio_dia) VALUES
('GPS',5), ('SillaBebe',7), ('GPS',6), ('SillaBebe',8), ('GPS',5), ('SillaBebe',7), ('GPS',6), ('SillaBebe',8), ('GPS',5), ('SillaBebe',7);

-- 10) RESERVA
INSERT INTO reserva (id_reserva, id_cliente, id_categoria, id_sucursal_retiro, id_sucursal_devolucion, fecha_retiro, fecha_devolucion, placa_vehiculo, estado) VALUES
(1, 1, 1, 1, 2, '2024-06-01 10:00', '2024-06-05 10:00', 'ABC-1234', 'Confirmada'),
(2, 2, 3, 3, 3, '2024-06-03 09:00', '2024-06-07 09:00', 'GHI-9012', 'Confirmada'),
(3, 3, 4, 4, 1, '2024-06-10 08:00', '2024-06-15 08:00', 'JKL-3456', 'Confirmada'),
(4, 4, 6, 2, 2, '2024-06-05 12:00', '2024-06-08 12:00', 'STU-3344', 'Confirmada'),
(5, 5, 7, 3, 3, '2024-06-12 14:00', '2024-06-14 14:00', 'VWX-5566', 'Confirmada'),
(6, 6, 1, 5, 1, '2024-06-15 09:00', '2024-06-20 09:00', 'DEF-5678', 'Confirmada'),
(7, 7, 5, 1, 4, '2024-06-18 11:00', '2024-06-22 11:00', 'MNO-7890', 'Confirmada'),
(8, 8, 4, 6, 2, '2024-06-20 08:00', '2024-06-25 08:00', 'PQR-1122', 'Confirmada'),
(9, 9, 8, 1, 3, '2024-06-22 10:00', '2024-06-24 10:00', 'YZA-7788', 'Confirmada'),
(10, 10, 10, 3, 3, '2024-06-25 09:00', '2024-06-30 09:00', 'BCD-9900', 'Confirmada');

-- 11) DETALLE RESERVA EXTRA
INSERT INTO detalle_reserva_extra (id_reserva, id_extra, cantidad, precio_unitario) VALUES
(1,1,1,5.00), (1,2,1,7.00), (2,1,1,5.00), (3,2,2,7.00), (4,1,1,6.00), (5,2,1,8.00), (6,1,1,5.00), (7,2,2,7.00), (8,1,1,6.00), (9,2,1,7.00);

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

-- IMPORTANTE: Actualizar estado de vehículos que tienen contrato ABIERTO (3, 6, 9)
UPDATE vehiculo SET estado = 'Alquilado' WHERE placa IN ('JKL-3456', 'DEF-5678', 'YZA-7788');

-- 13) PAGO
INSERT INTO pago (id_contrato, monto, tipo, fecha) VALUES
(1,150,'Anticipo','2024-06-01'), (1,150,'Liquidacion','2024-06-05'),
(2,200,'Anticipo','2024-06-03'), (2,220,'Liquidacion','2024-06-07'),
(4,400,'Anticipo','2024-06-01'), (4,400,'Liquidacion','2024-06-15'),
(5,500,'Anticipo','2024-06-02'), (5,450,'Liquidacion','2024-06-09'),
(7,350,'Anticipo','2024-06-07'), (10,1500,'Liquidacion','2024-06-15');

-- 14) FACTURA
INSERT INTO factura (id_contrato, id_cliente, numero_autorizacion, subtotal, iva, total, fecha_emision) VALUES
(1,1,'AUT-001',267.86,32.14,300.00,'2024-06-05'), (2,2,'AUT-002',375.00,45.00,420.00,'2024-06-07'),
(4,4,'AUT-003',714.29,85.71,800.00,'2024-06-15'), (5,5,'AUT-004',848.21,101.79,950.00,'2024-06-09'),
(7,7,'AUT-005',625.00,75.00,700.00,'2024-06-14'), (8,8,'AUT-006',401.79,48.21,450.00,'2024-06-12'),
(10,10,'AUT-007',1339.29,160.71,1500.00,'2024-06-15'), (1,1,'AUT-008',250.00,30.00,280.00,'2024-06-06'),
(2,2,'AUT-009',300.00,36.00,336.00,'2024-06-08'), (5,5,'AUT-010',500.00,60.00,560.00,'2024-06-10');

-- 15) INSPECCION
INSERT INTO inspeccion (id_contrato, tipo, url_fotos, observaciones, nivel_gasolina) VALUES
(1,'Check-Out','http://budget.ec/fotos/cont1_out','Vehículo en buen estado',95), (1,'Check-In','http://budget.ec/fotos/cont1_in','Rayón leve en puerta',90),
(2,'Check-Out','http://budget.ec/fotos/cont2_out','Sin novedades',100), (2,'Check-In','http://budget.ec/fotos/cont2_in','Entrega normal',85),
(4,'Check-Out','http://budget.ec/fotos/cont4_out','Vehículo limpio',98), (4,'Check-In','http://budget.ec/fotos/cont4_in','Olor a tabaco',80),
(5,'Check-Out','http://budget.ec/fotos/cont5_out','Estado óptimo',100), (5,'Check-In','http://budget.ec/fotos/cont5_in','Golpe leve en parachoques',75),
(7,'Check-Out','http://budget.ec/fotos/cont7_out','Sin observaciones',95), (7,'Check-In','http://budget.ec/fotos/cont7_in','Entrega puntual',90);

-- 16) MANTENIMIENTO
INSERT INTO mantenimiento (placa_vehiculo, tipo, costo, fecha_entrada, fecha_salida) VALUES
('DEF-5678','Preventivo',120,'2024-05-01','2024-05-03'), ('JKL-3456','Correctivo',350,'2024-04-10','2024-04-15'),
('STU-3344','Preventivo',180,'2024-05-20','2024-05-22'), ('VWX-5566','Correctivo',600,'2024-03-01','2024-03-10'),
('ABC-1234','Preventivo',150,'2024-06-01','2024-06-02'), ('PQR-1122','Preventivo',200,'2024-04-05','2024-04-07'),
('YZA-7788','Correctivo',500,'2024-02-15','2024-02-20'), ('BCD-9900','Preventivo',300,'2024-03-12','2024-03-14'),
('GHI-9012','Preventivo',140,'2024-05-10','2024-05-11'), ('MNO-7890','Correctivo',450,'2024-01-20','2024-01-25');

-- 17) HISTORIAL_MOVIMIENTO
INSERT INTO historial_movimiento (placa_vehiculo, id_sucursal_origen, id_sucursal_destino, motivo) VALUES
('ABC-1234',1,2,'Alquiler'), ('DEF-5678',2,3,'Taller'), ('GHI-9012',3,5,'Traslado'), ('JKL-3456',4,1,'Alquiler'),
('STU-3344',6,4,'Taller'), ('VWX-5566',7,3,'Traslado'), ('PQR-1122',5,2,'Alquiler'), ('YZA-7788',1,3,'Alquiler'),
('BCD-9900',3,5,'Alquiler'), ('MNO-7890',1,4,'Traslado');

-- 18) SANCION
INSERT INTO sancion (id_contrato, motivo, monto_penalidad, estado) VALUES
(1,'MultaTransito',50,'Pagada'), (2,'Danios',120,'Pagada'), (4,'OlorTabaco',80,'Pendiente'), (5,'Danios',200,'Pagada'),
(7,'MultaTransito',60,'Pendiente'), (10,'Danios',300,'Pendiente'), (1,'OlorTabaco',70,'Pagada'),
(2,'MultaTransito',40,'Pagada'), (5,'Danios',150,'Pendiente'), (7,'OlorTabaco',90,'Pagada');

-- =========================================================================
-- 4. LOGICA AVANZADA (TRIGGERS Y PROCEDIMIENTOS)
-- =========================================================================

DELIMITER //

-- TRIGGER 1: Validaciones
CREATE TRIGGER validar_cliente_antes_reserva
BEFORE INSERT ON reserva
FOR EACH ROW
BEGIN
    DECLARE v_fecha_nac DATE;
    DECLARE v_vigencia_lic DATE;
    DECLARE v_edad INT;
    
    SELECT fecha_nacimiento, vigencia_licencia 
    INTO v_fecha_nac, v_vigencia_lic
    FROM cliente WHERE id_cliente = NEW.id_cliente;

    IF v_fecha_nac IS NOT NULL THEN
        SET v_edad = TIMESTAMPDIFF(YEAR, v_fecha_nac, CURDATE());
        IF v_edad < 21 THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Error RN01: El cliente debe ser mayor de 21 años para reservar.';
        END IF;
    END IF;

    IF v_vigencia_lic IS NOT NULL AND v_vigencia_lic < CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error RN02: La licencia de conducir del cliente ha caducado.';
    END IF;
    
    IF NEW.fecha_retiro >= NEW.fecha_devolucion THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: La fecha de devolución debe ser posterior al retiro.';
    END IF;
END //

-- TRIGGER 2: Auditoría
CREATE TRIGGER auditoria_reserva_insert
AFTER INSERT ON reserva
FOR EACH ROW
BEGIN
    INSERT INTO bitacora (usuario_sistema, accion, tabla_afectada, fecha_hora)
    VALUES (CURRENT_USER(), CONCAT('Nueva reserva creada ID: ', NEW.id_reserva, ' Cliente: ', NEW.id_cliente), 'reserva', NOW());
END //

-- PROCEDIMIENTO 1: Crear Reserva con PLACA
CREATE PROCEDURE CrearReserva(
    IN p_id_cliente INT,
    IN p_id_categoria INT,
    IN p_id_sucursal_retiro INT,
    IN p_id_sucursal_devolucion INT,
    IN p_fecha_retiro DATETIME,
    IN p_fecha_devolucion DATETIME,
    IN p_placa VARCHAR(10)
)
BEGIN
    INSERT INTO reserva (
        id_cliente, id_categoria, id_sucursal_retiro, id_sucursal_devolucion, 
        fecha_retiro, fecha_devolucion, placa_vehiculo, estado
    )
    VALUES (
        p_id_cliente, p_id_categoria, p_id_sucursal_retiro, p_id_sucursal_devolucion, 
        p_fecha_retiro, p_fecha_devolucion, p_placa, 'Confirmada'
    );

    UPDATE vehiculo 
    SET estado = 'Reservado' 
    WHERE placa = p_placa;
END //

-- PROCEDIMIENTO 2: Cerrar Contrato 
CREATE PROCEDURE CerrarContrato(
    IN p_id_contrato INT,
    IN p_km_llegada INT,
    IN p_nivel_gasolina DECIMAL(5,2),
    IN p_observaciones TEXT,        
    IN p_monto_adicional DECIMAL(9,2) 
)
BEGIN
    DECLARE v_fecha_apertura DATETIME;
    DECLARE v_precio_dia DECIMAL(9,2);
    DECLARE v_dias_reales INT;
    DECLARE v_costo_total DECIMAL(9,2);
    DECLARE v_costo_extras DECIMAL(9,2);
    
    -- 1. Obtenemos datos base
    SELECT c.fecha_apertura, t.precio_dia
    INTO v_fecha_apertura, v_precio_dia
    FROM contrato c
    JOIN vehiculo v ON c.placa_vehiculo = v.placa
    JOIN categoria cat ON v.id_categoria = cat.id_categoria
    JOIN tarifa t ON cat.id_categoria = t.id_categoria
    WHERE c.id_contrato = p_id_contrato
    LIMIT 1;

    -- 2. Cálculos básicos
    SET v_dias_reales = DATEDIFF(NOW(), v_fecha_apertura);
    IF v_dias_reales = 0 THEN SET v_dias_reales = 1; END IF;

    SET v_costo_total = v_dias_reales * v_precio_dia;

    SET v_costo_extras = (
        SELECT COALESCE(SUM(dre.cantidad * dre.precio_unitario * v_dias_reales), 0)
        FROM detalle_reserva_extra dre
        JOIN contrato con ON dre.id_reserva = con.id_reserva
        WHERE con.id_contrato = p_id_contrato
    );

    -- 3. SUMAMOS LA MULTA AL TOTAL
    SET v_costo_total = v_costo_total + v_costo_extras + p_monto_adicional;

    -- 4. Guardamos la Inspección
    INSERT INTO inspeccion (id_contrato, tipo, observaciones, nivel_gasolina)
    VALUES (p_id_contrato, 'Check-In', p_observaciones, p_nivel_gasolina);

    -- 5. Si hay multa, guardamos sanción
    IF p_monto_adicional > 0 THEN
        INSERT INTO sancion (id_contrato, motivo, monto_penalidad, estado)
        VALUES (p_id_contrato, 'Cargos Adicionales/Daños', p_monto_adicional, 'Pagada');
    END IF;

    -- 6. Cerramos el contrato
    UPDATE contrato 
    SET fecha_cierre = NOW(),
        km_llegada = p_km_llegada,
        total_pagar = v_costo_total,
        estado = 'Cerrado'
    WHERE id_contrato = p_id_contrato;

    -- 7. Liberamos el vehículo
    UPDATE vehiculo 
    SET estado = 'Disponible', kilometraje = p_km_llegada
    WHERE placa = (SELECT placa_vehiculo FROM contrato WHERE id_contrato = p_id_contrato);

END //

-- TRIGGER 3: Control Mantenimiento
CREATE TRIGGER verificar_mantenimiento_al_cierre
AFTER UPDATE ON contrato
FOR EACH ROW
BEGIN
    DECLARE v_ultimo_km_manto INT;
    DECLARE v_km_actual INT;
    
    IF OLD.estado = 'Abierto' AND NEW.estado = 'Cerrado' THEN
        SET v_km_actual = NEW.km_llegada;
        
        SELECT COALESCE(MAX(v.kilometraje), 0) INTO v_ultimo_km_manto
        FROM mantenimiento m
        RIGHT JOIN vehiculo v ON m.placa_vehiculo = v.placa
        WHERE v.placa = NEW.placa_vehiculo AND m.tipo = 'Preventivo';

        IF (v_km_actual - v_ultimo_km_manto) >= 10000 THEN
            UPDATE vehiculo SET estado = 'Mantenimiento' 
            WHERE placa = NEW.placa_vehiculo;
            
            INSERT INTO bitacora (usuario_sistema, accion, tabla_afectada, fecha_hora)
            VALUES (CURRENT_USER(), CONCAT('Vehículo ', NEW.placa_vehiculo, ' bloqueado por mantenimiento (RN06)'), 'vehiculo', NOW());
        END IF;
    END IF;
END //

DELIMITER ;