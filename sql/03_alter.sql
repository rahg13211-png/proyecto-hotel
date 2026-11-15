-- 03_alter.sql : evolucion del esquema (ya con datos cargados)
BEGIN;

-- 3.1 Nueva columna opcional para peticiones especiales del huesped
ALTER TABLE reserva ADD COLUMN observaciones VARCHAR(255);

-- 3.2 Estado de la reserva (las filas existentes quedan 'Confirmada')
ALTER TABLE reserva
    ADD COLUMN estado VARCHAR(20) NOT NULL DEFAULT 'Confirmada',
    ADD CONSTRAINT chk_reserva_estado
        CHECK (estado IN ('Confirmada', 'Cancelada', 'Finalizada'));

-- 3.3 Una reserva cancelada ya no debe bloquear las fechas
ALTER TABLE reserva DROP CONSTRAINT ex_reserva_solapamiento;
ALTER TABLE reserva ADD CONSTRAINT ex_reserva_solapamiento
    EXCLUDE USING gist (
        id_habitacion WITH =,
        daterange(fecha_entrada, fecha_salida, '[)') WITH &&
    ) WHERE (estado <> 'Cancelada');

COMMIT;
