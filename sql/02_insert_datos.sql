-- Tabla reserva

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
