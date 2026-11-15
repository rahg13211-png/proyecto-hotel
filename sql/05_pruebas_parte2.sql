-- 05_pruebas_parte2.sql : pruebas positivas y negativas de restricciones (Parte 2)
-- Ejecutar cada prueba por separado en pgAdmin: Query Tool se detiene en el
-- primer error. Las pruebas positivas van dentro de una transaccion que se
-- deshace al final para no alterar los datos.

-- =====================================================================
-- PRUEBAS POSITIVAS (inserciones validas)
-- =====================================================================
BEGIN;

-- P1: cliente valido
INSERT INTO cliente (nombre, correo, telefono, nacionalidad)
VALUES ('Laura Martinez', 'laura.martinez@example.com',
        '+573155550101', 'Colombiana');
SELECT id_cliente, nombre, correo
FROM cliente
WHERE correo = 'laura.martinez@example.com';

-- P2: reserva valida (habitacion 5, 3 noches x 450.000 = 1.350.000)
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

-- P3: pago valido para esa reserva (fecha_pago se genera con DEFAULT now())
INSERT INTO pago (id_reserva, monto, metodo)
SELECT id_reserva, 1350000.00, 'Tarjeta'
FROM reserva
WHERE id_habitacion = 5 AND fecha_entrada = '2026-12-20';
SELECT p.id_pago, p.id_reserva, p.monto, p.metodo, p.fecha_pago
FROM pago p
JOIN reserva r USING (id_reserva)
WHERE r.id_habitacion = 5 AND r.fecha_entrada = '2026-12-20';

ROLLBACK;

-- =====================================================================
-- PRUEBAS NEGATIVAS (TODAS DEBEN FALLAR: N1 a N5)
-- =====================================================================

-- N1: pago con monto = 0 -> viola CHECK chk_pago_monto (SQLSTATE 23514)
INSERT INTO pago (id_reserva, monto, metodo)
VALUES (1, 0, 'Tarjeta');

-- N2: reserva con cliente inexistente -> viola FK fk_reserva_cliente (23503)
INSERT INTO reserva
    (id_cliente, id_habitacion, fecha_entrada, fecha_salida, total_reserva)
VALUES (999, 1, '2027-01-10', '2027-01-12', 300000.00);

-- N3: correo duplicado -> viola el indice unico uq_cliente_correo (23505)
INSERT INTO cliente (nombre, correo, telefono, nacionalidad)
SELECT 'Duplicado Prueba', correo, '+573000000000', 'Colombiana'
FROM cliente
ORDER BY id_cliente
LIMIT 1;

-- N4: borrar un cliente con reservas -> ON DELETE RESTRICT (23001)
DELETE FROM cliente WHERE id_cliente = 1;

-- N5: borrar una reserva que tiene pagos -> ON DELETE RESTRICT (23001)
-- Responde que pasa con los pagos de una reserva que se elimina: no se puede.
DELETE FROM reserva WHERE id_reserva = 1;
