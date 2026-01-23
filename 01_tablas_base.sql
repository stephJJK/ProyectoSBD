
-- Proyecto: Budget Rent a Car Ecuador

CREATE DATABASE IF NOT EXISTS RENT_A_CAR
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE RENT_A_CAR;

-- 1) CATEGORIA

CREATE TABLE IF NOT EXISTS categoria (
  id_categoria       INT AUTO_INCREMENT,
  nombre             VARCHAR(30) NOT NULL,
  deposito_garantia  DECIMAL(9,2) NOT NULL DEFAULT 0,
  CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
  CONSTRAINT chk_categoria_deposito CHECK (deposito_garantia >= 0)
);


-- 2) SUCURSAL

CREATE TABLE IF NOT EXISTS sucursal (
  id_sucursal  INT AUTO_INCREMENT,
  nombre       VARCHAR(40) NOT NULL,
  direccion    VARCHAR(80) NOT NULL,
  tipo         VARCHAR(15) NOT NULL,
  CONSTRAINT pk_sucursal PRIMARY KEY (id_sucursal),
  CONSTRAINT chk_sucursal_tipo CHECK (tipo IN ('Aeropuerto', 'Ciudad'))
);


-- 3) CLIENTE

CREATE TABLE IF NOT EXISTS cliente (
  id_cliente           INT AUTO_INCREMENT,
  tipo_cliente         VARCHAR(12) NOT NULL,  -- Individual / Corporativo
  identificacion       VARCHAR(13) NOT NULL,  -- cédula o RUC 
  nombre_razon_social  VARCHAR(40) NOT NULL,
  licencia_conducir    VARCHAR(20) NULL,
  vigencia_licencia    DATE NULL,
  contacto             VARCHAR(80) NULL,
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
  CONSTRAINT chk_cliente_tipo CHECK (tipo_cliente IN ('Individual','Corporativo')),
  -- Reglas del modelo: licencia aplica a Individual
  CONSTRAINT chk_cliente_licencia
    CHECK (
      (tipo_cliente = 'Individual' AND licencia_conducir IS NOT NULL AND vigencia_licencia IS NOT NULL)
      OR
      (tipo_cliente = 'Corporativo')
    )
);

-- 4) VEHICULO

CREATE TABLE IF NOT EXISTS vehiculo (
  placa             VARCHAR(10),
  marca             VARCHAR(30) NOT NULL,
  modelo            VARCHAR(30) NOT NULL,
  anio              INT NOT NULL,
  kilometraje       INT NOT NULL DEFAULT 0,
  estado            VARCHAR(20) NOT NULL DEFAULT 'Disponible',
  id_sucursal       INT NOT NULL,
  id_categoria      INT NOT NULL,
  CONSTRAINT pk_vehiculo PRIMARY KEY (placa),
  CONSTRAINT chk_vehiculo_anio CHECK (anio BETWEEN 1980 AND 2100),
  CONSTRAINT chk_vehiculo_km CHECK (kilometraje >= 0),
  CONSTRAINT chk_vehiculo_estado CHECK (estado IN ('Disponible','Alquilado','Mantenimiento','Bloqueado')),
  CONSTRAINT fk_vehiculo_sucursal
    FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal),
  CONSTRAINT fk_vehiculo_categoria
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

-- 5) TARIFA

CREATE TABLE IF NOT EXISTS tarifa (
  id_tarifa     INT AUTO_INCREMENT,
  id_categoria  INT NOT NULL,
  precio_dia    DECIMAL(9,2) NOT NULL,
  fecha_inicio  DATE NOT NULL,
  fecha_fin     DATE NULL,
  CONSTRAINT pk_tarifa PRIMARY KEY (id_tarifa),
  CONSTRAINT chk_tarifa_precio CHECK (precio_dia >= 0),
  CONSTRAINT chk_tarifa_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
  CONSTRAINT fk_tarifa_categoria
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

-- 6) SEGURO

CREATE TABLE IF NOT EXISTS seguro (
  id_seguro     INT AUTO_INCREMENT,
  nombre        VARCHAR(30) NOT NULL,   -- Basico / Full / Premium
  costo_diario  DECIMAL(9,2) NOT NULL,
  cobertura     VARCHAR(80) NOT NULL,
  CONSTRAINT pk_seguro PRIMARY KEY (id_seguro),
  CONSTRAINT chk_seguro_costo CHECK (costo_diario >= 0),
  CONSTRAINT chk_seguro_nombre CHECK (nombre IN ('Basico','Full','Premium'))
);

-- 7) USUARIO

CREATE TABLE IF NOT EXISTS usuario (
  id_usuario   INT AUTO_INCREMENT,
  username     VARCHAR(30) NOT NULL,
  rol          VARCHAR(20) NOT NULL,
  id_sucursal  INT NOT NULL,
  CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
  CONSTRAINT uq_usuario_username UNIQUE (username),
  CONSTRAINT chk_usuario_rol CHECK (rol IN ('Admin','Agente','Gestor')),
  CONSTRAINT fk_usuario_sucursal
    FOREIGN KEY (id_sucursal) REFERENCES sucursal(id_sucursal)
);

-- 8) BITACORA

CREATE TABLE IF NOT EXISTS bitacora (
  id_bitacora     INT AUTO_INCREMENT,
  id_usuario      INT NOT NULL,
  fecha_hora      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  accion          VARCHAR(80) NOT NULL,
  tabla_afectada  VARCHAR(40) NOT NULL,
  CONSTRAINT pk_bitacora PRIMARY KEY (id_bitacora),
  CONSTRAINT fk_bitacora_usuario
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- 9) EXTRA

CREATE TABLE IF NOT EXISTS extra (
  id_extra    INT AUTO_INCREMENT,
  nombre      VARCHAR(40) NOT NULL,
  precio_dia  DECIMAL(9,2) NOT NULL DEFAULT 0,
  CONSTRAINT pk_extra PRIMARY KEY (id_extra),
  CONSTRAINT chk_extra_nombre CHECK (nombre IN ('GPS','SillaBebe')),
  CONSTRAINT chk_extra_precio CHECK (precio_dia >= 0)
);
