-- 4.1 Coherencia de totales: las dos columnas deben coincidir en todas las filas
SELECT r.id_reserva,
       r.total_reserva,
       (r.fecha_salida - r.fecha_entrada) * h.precio_noche AS total_calculado
FROM reserva r
JOIN habitacion h USING (id_habitacion)
ORDER BY r.id_reserva;

-- 4.2 Solapamiento: DEBE FALLAR (la habitacion 3 ya esta reservada 1-5 dic)
INSERT INTO reserva
    (id_cliente, id_habitacion, fecha_entrada, fecha_salida, total_reserva)
VALUES (2, 3, '2026-12-03', '2026-12-06', 660000.00);
-- Esperado: ERROR: conflicting key value violates exclusion constraint
--           "ex_reserva_solapamiento"

-- 4.3 Fechas invalidas: DEBE FALLAR (salida igual a entrada)
INSERT INTO reserva
    (id_cliente, id_habitacion, fecha_entrada, fecha_salida, total_reserva)
VALUES (2, 1, '2026-12-20', '2026-12-20', 0);
-- Esperado: ERROR: ... violates check constraint "chk_reserva_fechas"

-- 4.4 Una reserva cancelada libera las fechas (se deshace con ROLLBACK)
BEGIN;
UPDATE reserva SET estado = 'Cancelada' WHERE id_reserva = 1;
INSERT INTO reserva
    (id_cliente, id_habitacion, fecha_entrada, fecha_salida, total_reserva)
VALUES (2, 3, '2026-12-03', '2026-12-06', 660000.00);  -- ahora SI se permite
ROLLBACK;

-- 4.5 Integridad referencial: DEBE FALLAR (reserva depende de cliente)
DROP TABLE cliente;
-- Esperado: ERROR: cannot drop table cliente because other objects depend on it

-- 4.6 DROP TABLE: eliminar una tabla que ya no forma parte del modelo
CREATE TABLE tmp_importacion_clientes (
    id_tmp INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    linea  TEXT
);
DROP TABLE IF EXISTS tmp_importacion_clientes;

-- 4.7 TRUNCATE TABLE: vaciar datos conservando la estructura.
--     Se incluyen pago y reserva en el mismo comando por la llave foranea.
--     En PostgreSQL es transaccional: aqui se revierte para no perder datos.
BEGIN;
TRUNCATE TABLE pago, reserva RESTART IDENTITY;
SELECT (SELECT count(*) FROM pago)    AS pagos,
       (SELECT count(*) FROM reserva) AS reservas;   -- 0 y 0
ROLLBACK;
SELECT count(*) AS reservas_restauradas FROM reserva;  -- 5
