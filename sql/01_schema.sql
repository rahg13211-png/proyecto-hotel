-- 01_schema.sql : esquema fisico de la base de datos HOTEL (PostgreSQL)
-- Limpieza para que el script sea re-ejecutable (solo entornos de taller)
DROP TABLE IF EXISTS pago, reserva, habitacion, cliente CASCADE;

-- Extension requerida para combinar igualdad (=) y solapamiento (&&)
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- 1. Tabla: cliente
CREATE TABLE cliente (
    id_cliente    INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre        VARCHAR(100) NOT NULL,
    correo        VARCHAR(150) NOT NULL,
    telefono      VARCHAR(20)  NOT NULL,
    nacionalidad  VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
    CONSTRAINT chk_cliente_correo
        CHECK (correo ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$')
);

-- Correo unico sin distinguir mayusculas/minusculas
CREATE UNIQUE INDEX uq_cliente_correo ON cliente (lower(correo));

-- 2. Tabla: habitacion
CREATE TABLE habitacion (
    id_habitacion  INTEGER GENERATED ALWAYS AS IDENTITY,
    numero         VARCHAR(10)   NOT NULL,
    tipo           VARCHAR(20)   NOT NULL,
    precio_noche   NUMERIC(10,2) NOT NULL,
    estado         VARCHAR(20)   NOT NULL DEFAULT 'Disponible',
    CONSTRAINT pk_habitacion PRIMARY KEY (id_habitacion),
    CONSTRAINT uq_habitacion_numero UNIQUE (numero),
    CONSTRAINT chk_habitacion_tipo
        CHECK (tipo IN ('Sencilla', 'Doble', 'Suite')),
    CONSTRAINT chk_habitacion_precio CHECK (precio_noche > 0),
    CONSTRAINT chk_habitacion_estado
        CHECK (estado IN ('Disponible', 'Ocupada', 'Mantenimiento'))
);

-- 3. Tabla: reserva
CREATE TABLE reserva (
    id_reserva     INTEGER GENERATED ALWAYS AS IDENTITY,
    id_cliente     INTEGER       NOT NULL,
    id_habitacion  INTEGER       NOT NULL,
    fecha_entrada  DATE          NOT NULL,
    fecha_salida   DATE          NOT NULL,
    total_reserva  NUMERIC(10,2) NOT NULL,
    CONSTRAINT pk_reserva PRIMARY KEY (id_reserva),
    CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_reserva_habitacion FOREIGN KEY (id_habitacion)
        REFERENCES habitacion (id_habitacion)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_reserva_fechas CHECK (fecha_salida > fecha_entrada),
    CONSTRAINT chk_reserva_total CHECK (total_reserva >= 0),
    -- Evita overbooking: misma habitacion con rangos de fechas cruzados
    CONSTRAINT ex_reserva_solapamiento EXCLUDE USING gist (
        id_habitacion WITH =,
        daterange(fecha_entrada, fecha_salida, '[)') WITH &&
    )
);

-- 4. Tabla: pago
CREATE TABLE pago (
    id_pago     INTEGER GENERATED ALWAYS AS IDENTITY,
    id_reserva  INTEGER       NOT NULL,
    fecha_pago  TIMESTAMPTZ   NOT NULL DEFAULT now(),
    monto       NUMERIC(10,2) NOT NULL,
    metodo      VARCHAR(30)   NOT NULL,
    CONSTRAINT pk_pago PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva)
        REFERENCES reserva (id_reserva)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_pago_monto CHECK (monto > 0),
    CONSTRAINT chk_pago_metodo
        CHECK (metodo IN ('Tarjeta', 'Efectivo', 'Transferencia'))
);

-- Indices sobre llaves foraneas (PostgreSQL no los crea automaticamente)
CREATE INDEX idx_reserva_id_cliente ON reserva (id_cliente);
CREATE INDEX idx_pago_id_reserva    ON pago (id_reserva);
