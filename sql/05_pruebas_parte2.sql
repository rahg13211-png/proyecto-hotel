-- 05_pruebas_parte2.sql : pruebas positivas y negativas de restricciones
-- Ejecutar cada prueba por separado en pgAdmin (Query Tool).
-- Datos de partida: 5 clientes, 5 habitaciones, 5 reservas, 5 pagos.

-- =====================================================================
-- PRUEBAS POSITIVAS (una transaccion que se revierte al final)
-- =====================================================================

-- P1: cliente valido
BEGIN;
INSERT INTO cliente (nombre, correo, telefono, nacionalidad)
VALUES ('Laura Martinez', 'laura.martinez@example.com',
        '+573155550101', 'Colombiana');
SELECT id_cliente, nombre, correo
FROM cliente
WHERE correo = 'laura.martinez@example.com';

-- P2: reserva valida (habitacion 5, del 20 al 23 de dic: 3 x 450.000)
INSERT INTO reserva
    (id_cliente, id_habitacion, fecha_entrada, fecha_salida, total_reserva)
SELECT id_cliente, 5, '2026-12-20', '2026-12-23', 1350000.00
FROM cliente
WHERE correo = 'laura.martinez@example.com';
SELECT id_reserva, id_cliente, id_habitacion, fecha_entrada, fecha_salida,
       total_reserva, estado
FROM reserva
WHERE id_habitacion = 5
ORDER BY id_reserva;

-- P3: pago valido asociado a la reserva nueva
INSERT INTO pago (id_reserva, monto, metodo)
SELECT id_reserva, 1350000.00, 'Tarjeta'
FROM reserva
WHERE id_habitacion = 5 AND fecha_entrada = '2026-12-20';
SELECT p.id_pago, p.id_reserva, p.monto, p.metodo, p.fecha_pago
FROM pago p
JOIN reserva r USING (id_reserva)
WHERE r.id_habitacion = 5 AND r.fecha_entrada = '2026-12-20';

-- Deshacer las tres pruebas positivas
ROLLBACK;

-- =====================================================================
-- PRUEBAS NEGATIVAS (cada una DEBE fallar)
-- =====================================================================

-- N1: CHECK monto > 0
INSERT INTO pago (id_reserva, monto, metodo)
VALUES (1, 0, 'Efectivo');
-- Esperado: viola la restriccion check "chk_pago_monto" (SQLSTATE 23514)

-- N2: FOREIGN KEY con un cliente que no existe
INSERT INTO reserva
    (id_cliente, id_habitacion, fecha_entrada, fecha_salida, total_reserva)
VALUES (999, 1, '2027-01-10', '2027-01-12', 240000.00);
-- Esperado: viola la llave foranea "fk_reserva_cliente" (SQLSTATE 23503)

-- N3: UNIQUE, correo repetido escrito con otras mayusculas
INSERT INTO cliente (nombre, correo, telefono, nacionalidad)
VALUES ('Carlos Duplicado', 'CARLOS.GOMEZ@EXAMPLE.COM',
        '+573100000000', 'Colombiana');
-- Esperado: viola la unicidad "uq_cliente_correo" (SQLSTATE 23505)

-- N4: NOT NULL (se omite el telefono)
INSERT INTO cliente (nombre, correo, nacionalidad)
VALUES ('Sin Telefono', 'sin.telefono@example.com', 'Colombiana');
-- Esperado: valor nulo en la columna "telefono" (SQLSTATE 23502)

-- N5: ON DELETE RESTRICT (el cliente 1 tiene reservas)
DELETE FROM cliente WHERE id_cliente = 1;
-- Esperado: viola la llave foranea "fk_reserva_cliente" (SQLSTATE 23503)
