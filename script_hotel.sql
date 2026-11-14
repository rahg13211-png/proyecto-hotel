-- Extensión requerida para evitar dobles reservas
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- 1. Tabla: cliente
CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    nacionalidad VARCHAR(50) NOT NULL
);

-- 2. Tabla: habitacion
CREATE TABLE habitacion (
    id_habitacion SERIAL PRIMARY KEY,
    numero VARCHAR(10) UNIQUE NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Sencilla', 'Doble', 'Suite')),
    precio_noche NUMERIC(10,2) NOT NULL CHECK (precio_noche > 0),
    estado VARCHAR(20) NOT NULL DEFAULT 'Disponible' CHECK (estado IN ('Disponible', 'Ocupada', 'Mantenimiento'))
);

-- 3. Tabla: reserva
CREATE TABLE reserva (
    id_reserva SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_habitacion INT NOT NULL,
    fecha_entrada DATE NOT NULL,
    fecha_salida DATE NOT NULL,
    total_reserva NUMERIC(10,2) NOT NULL CHECK (total_reserva >= 0),
    CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_reserva_habitacion FOREIGN KEY (id_habitacion)
        REFERENCES habitacion (id_habitacion)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_fechas_reserva CHECK (fecha_salida > fecha_entrada)
);

-- Restricción de exclusión de fechas cruzadas
ALTER TABLE reserva ADD CONSTRAINT excluye_solapamiento_reservas
    EXCLUDE USING gist (
        id_habitacion WITH =,
        daterange(fecha_entrada, fecha_salida, '[)') WITH &&
    );

-- 4. Tabla: pago
CREATE TABLE pago (
    id_pago SERIAL PRIMARY KEY,
    id_reserva INT NOT NULL,
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    monto NUMERIC(10,2) NOT NULL CHECK (monto > 0),
    metodo VARCHAR(30) NOT NULL CHECK (metodo IN ('Tarjeta', 'Efectivo', 'Transferencia')),
    CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva)
        REFERENCES reserva (id_reserva)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);