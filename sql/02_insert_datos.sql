-- --------------------------------------------------------------------------------------------------------------
-- 10)Tabla reserva

USE RENT_A_CAR;
CREATE TABLE IF NOT EXISTS reserva (
  id_reserva            INT AUTO_INCREMENT,
  id_cliente            INT NOT NULL,
  id_categoria          INT NOT NULL,
  id_sucursal_retiro     INT NOT NULL,
  id_sucursal_devolucion INT NOT NULL,
  fecha_retiro          DATETIME NOT NULL,
  fecha_devolucion      DATETIME NOT NULL,
  estado                VARCHAR(15) NOT NULL DEFAULT 'Pendiente',

  CONSTRAINT pk_reserva PRIMARY KEY (id_reserva),

  CONSTRAINT chk_reserva_estado
    CHECK (estado IN ('Pendiente','Confirmada','Cancelada','Vencida','Convertida')),

  CONSTRAINT chk_reserva_fechas
    CHECK (fecha_devolucion > fecha_retiro),

  CONSTRAINT fk_reserva_cliente
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),

  CONSTRAINT fk_reserva_categoria
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria),

  CONSTRAINT fk_reserva_sucursal_retiro
    FOREIGN KEY (id_sucursal_retiro) REFERENCES sucursal(id_sucursal),

  CONSTRAINT fk_reserva_sucursal_devolucion
    FOREIGN KEY (id_sucursal_devolucion) REFERENCES sucursal(id_sucursal)
);


-- ------------------------------------------------------------------------------------------------------------------------------
-- 11) DETALLE_RESERVA_EXTRA
CREATE TABLE IF NOT EXISTS detalle_reserva_extra (
  id_reserva      INT NOT NULL,
  id_extra        INT NOT NULL,
  cantidad        INT NOT NULL,
  precio_unitario DECIMAL(9,2) NOT NULL,

  CONSTRAINT pk_detalle_reserva_extra PRIMARY KEY (id_reserva, id_extra),

  CONSTRAINT chk_dre_cantidad CHECK (cantidad >= 1),
  CONSTRAINT chk_dre_precio CHECK (precio_unitario >= 0),

  CONSTRAINT fk_dre_reserva
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),

  CONSTRAINT fk_dre_extra
    FOREIGN KEY (id_extra) REFERENCES extra(id_extra)
);


-- ----------------------------------------------------------------------------------------------------------------------------
-- 12) CONTRATO 
CREATE TABLE IF NOT EXISTS contrato (
  id_contrato    INT AUTO_INCREMENT,
  id_reserva     INT NOT NULL,
  placa_vehiculo VARCHAR(10) NOT NULL,
  id_agente      INT NOT NULL,
  id_seguro      INT NOT NULL,
  fecha_apertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_cierre   DATETIME NULL,
  km_salida      INT NOT NULL,
  km_llegada     INT NULL,
  total_pagar    DECIMAL(9,2) NOT NULL,
  estado         VARCHAR(10) NOT NULL DEFAULT 'Abierto',

  CONSTRAINT pk_contrato PRIMARY KEY (id_contrato),

  CONSTRAINT uq_contrato_reserva UNIQUE (id_reserva),

  CONSTRAINT chk_contrato_estado CHECK (estado IN ('Abierto','Cerrado')),
  CONSTRAINT chk_contrato_km CHECK (
    km_salida >= 0 AND (km_llegada IS NULL OR km_llegada >= km_salida)
  ),
  CONSTRAINT chk_contrato_total CHECK (total_pagar >= 0),
  CONSTRAINT chk_contrato_fechas CHECK (
    fecha_cierre IS NULL OR fecha_cierre >= fecha_apertura
  ),

  CONSTRAINT fk_contrato_reserva
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),

  CONSTRAINT fk_contrato_vehiculo
    FOREIGN KEY (placa_vehiculo) REFERENCES vehiculo(placa),

  CONSTRAINT fk_contrato_agente
    FOREIGN KEY (id_agente) REFERENCES usuario(id_usuario),

  CONSTRAINT fk_contrato_seguro
    FOREIGN KEY (id_seguro) REFERENCES seguro(id_seguro)
);


-- ----------------------------------------------------------------------------------------------------------
-- 13) PAGO
CREATE TABLE IF NOT EXISTS pago (
  id_pago     INT AUTO_INCREMENT,
  id_contrato INT NOT NULL,
  monto       DECIMAL(9,2) NOT NULL,
  tipo        VARCHAR(15) NOT NULL,
  fecha       DATE NOT NULL,

  CONSTRAINT pk_pago PRIMARY KEY (id_pago),

  CONSTRAINT chk_pago_monto CHECK (monto > 0),
  CONSTRAINT chk_pago_tipo CHECK (tipo IN ('Anticipo','Liquidacion')),

  CONSTRAINT fk_pago_contrato
    FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato)
);


-- -----------------------------------------------------------------------------------------------------------------
--14) FACTURA

CREATE TABLE IF NOT EXISTS factura (
  id_factura           INT AUTO_INCREMENT,
  id_contrato          INT NOT NULL,
  id_cliente           INT NOT NULL,
  numero_autorizacion  VARCHAR(30) NOT NULL,
  subtotal             DECIMAL(9,2) NOT NULL,
  iva                  DECIMAL(9,2) NOT NULL,
  total                DECIMAL(9,2) NOT NULL,
  fecha_emision        DATE NOT NULL,

  CONSTRAINT pk_factura PRIMARY KEY (id_factura),

  CONSTRAINT chk_factura_montos CHECK (
    subtotal >= 0 AND iva >= 0 AND total >= 0
  ),
  CONSTRAINT chk_factura_total CHECK (
    ABS(total - (subtotal + iva)) < 0.01
  ),

  CONSTRAINT fk_factura_contrato
    FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato),

  CONSTRAINT fk_factura_cliente
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

CREATE TABLE IF NOT EXISTS factura (
  id_factura           INT AUTO_INCREMENT,
  id_contrato          INT NOT NULL,
  id_cliente           INT NOT NULL,
  numero_autorizacion  VARCHAR(30) NOT NULL,
  subtotal             DECIMAL(9,2) NOT NULL,
  iva                  DECIMAL(9,2) NOT NULL,
  total                DECIMAL(9,2) NOT NULL,
  fecha_emision        DATE NOT NULL,

  CONSTRAINT pk_factura PRIMARY KEY (id_factura),

  CONSTRAINT chk_factura_montos CHECK (
    subtotal >= 0 AND iva >= 0 AND total >= 0
  ),
  CONSTRAINT chk_factura_total CHECK (
    ABS(total - (subtotal + iva)) < 0.01
  ),

  CONSTRAINT fk_factura_contrato
    FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato),

  CONSTRAINT fk_factura_cliente
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);



-- ---------------------------------------------------------------------------------------
--15) INSPECCION 
CREATE TABLE IF NOT EXISTS inspeccion (
  id_inspeccion   INT AUTO_INCREMENT,
  id_contrato     INT NOT NULL,
  tipo            VARCHAR(12) NOT NULL,
  url_fotos       VARCHAR(255) NULL,
  observaciones   VARCHAR(255) NULL,
  nivel_gasolina  DECIMAL(5,2) NOT NULL,

  CONSTRAINT pk_inspeccion PRIMARY KEY (id_inspeccion),

  CONSTRAINT chk_inspeccion_tipo CHECK (tipo IN ('Check-Out','Check-In')),
  CONSTRAINT chk_inspeccion_gas CHECK (nivel_gasolina BETWEEN 0 AND 100),

  CONSTRAINT fk_inspeccion_contrato
    FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato)
);


-- ---------------------------------------------------------------------------------------------------------------------------
-- 16) MANTENIMIENTO 
CREATE TABLE IF NOT EXISTS mantenimiento (
  id_mantenimiento INT AUTO_INCREMENT,
  placa_vehiculo   VARCHAR(10) NOT NULL,
  tipo             VARCHAR(20) NOT NULL,
  costo            DECIMAL(9,2) NOT NULL,
  fecha_entrada    DATE NOT NULL,
  fecha_salida     DATE NULL,

  CONSTRAINT pk_mantenimiento PRIMARY KEY (id_mantenimiento),

  CONSTRAINT chk_mant_tipo CHECK (tipo IN ('Preventivo','Correctivo')),
  CONSTRAINT chk_mant_costo CHECK (costo >= 0),
  CONSTRAINT chk_mant_fechas CHECK (fecha_salida IS NULL OR fecha_salida >= fecha_entrada),

  CONSTRAINT fk_mantenimiento_vehiculo
    FOREIGN KEY (placa_vehiculo) REFERENCES vehiculo(placa)
);

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 17) HISTORIAL_MOVIMIENTO 

CREATE TABLE IF NOT EXISTS historial_movimiento (
  id_movimiento      INT AUTO_INCREMENT,
  placa_vehiculo     VARCHAR(10) NOT NULL,
  id_sucursal_origen  INT NOT NULL,
  id_sucursal_destino INT NOT NULL,
  fecha_movimiento   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  motivo             VARCHAR(20) NOT NULL,

  CONSTRAINT pk_historial_movimiento PRIMARY KEY (id_movimiento),

  CONSTRAINT chk_hist_motivo CHECK (motivo IN ('Traslado','Alquiler','Taller')),

  CONSTRAINT fk_hist_vehiculo
    FOREIGN KEY (placa_vehiculo) REFERENCES vehiculo(placa),

  CONSTRAINT fk_hist_sucursal_origen
    FOREIGN KEY (id_sucursal_origen) REFERENCES sucursal(id_sucursal),

  CONSTRAINT fk_hist_sucursal_destino
    FOREIGN KEY (id_sucursal_destino) REFERENCES sucursal(id_sucursal),

  CONSTRAINT chk_hist_sucursales CHECK (id_sucursal_origen <> id_sucursal_destino)
);


-- -------------------------------------------------------------------------------------------------------
-- 18) SANCION 

CREATE TABLE IF NOT EXISTS sancion (
  id_sancion      INT AUTO_INCREMENT,
  id_contrato     INT NOT NULL,
  motivo          VARCHAR(25) NOT NULL,
  monto_penalidad DECIMAL(9,2) NOT NULL,
  estado          VARCHAR(12) NOT NULL DEFAULT 'Pendiente',

  CONSTRAINT pk_sancion PRIMARY KEY (id_sancion),

  CONSTRAINT chk_sancion_motivo CHECK (motivo IN ('MultaTransito','Danios','OlorTabaco')),
  CONSTRAINT chk_sancion_monto CHECK (monto_penalidad > 0),
  CONSTRAINT chk_sancion_estado CHECK (estado IN ('Pendiente','Pagada')),

  CONSTRAINT fk_sancion_contrato
    FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato)
);

