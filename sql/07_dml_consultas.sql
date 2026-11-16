-- ============================================================================
-- 07_dml_consultas.sql : Parte 4 - DML y consultas SQL (base HOTEL, PostgreSQL)
-- COMO USARLO EN pgAdmin (Query Tool):
--   1. Selecciona SOLO el bloque que quieres ejecutar y pulsa F5 (ejecuta la seleccion).
--   2. Los bloques con BEGIN ... ROLLBACK van en la MISMA pestana, paso a paso.
--   3. Si algo queda a medias, ejecuta ROLLBACK; antes de seguir.
-- Nada de este script modifica los datos de forma permanente (todo DML termina en ROLLBACK).
-- ============================================================================

-- ---------- PASO 0: reconocimiento de los datos ----------
-- P0a: Habitaciones por tipo
SELECT tipo, count(*) AS habitaciones FROM habitacion GROUP BY tipo ORDER BY tipo;

-- P0b: Habitaciones por estado
SELECT estado, count(*) AS habitaciones FROM habitacion GROUP BY estado ORDER BY estado;

-- P0c: Reservas por estado
SELECT estado, count(*) AS reservas FROM reserva GROUP BY estado ORDER BY estado;

-- P0d: Clientes por nacionalidad
SELECT nacionalidad, count(*) AS clientes FROM cliente GROUP BY nacionalidad ORDER BY clientes DESC;

-- P0e: Rango de fechas de pagos y de estancias
SELECT (SELECT min(fecha_pago)::date FROM pago)      AS primer_pago,
       (SELECT max(fecha_pago)::date FROM pago)      AS ultimo_pago,
       (SELECT min(fecha_entrada) FROM reserva)      AS primera_entrada,
       (SELECT max(fecha_salida) FROM reserva)       AS ultima_salida;

-- ---------- 15.3 ESCENARIOS DML ----------
-- D1. Cambiar el estado de una habitación
-- Paso 1: abrir la transacción y ver el estado actual [captura D1a]
BEGIN;
SELECT id_habitacion, numero, tipo, estado
FROM habitacion
WHERE numero = '101';

-- Paso 2: actualizar y devolver la fila modificada [captura D1b]
UPDATE habitacion
SET estado = 'Mantenimiento'
WHERE numero = '101'
RETURNING id_habitacion, numero, estado;

-- Paso 3: comprobar el cambio y deshacerlo
SELECT numero, estado FROM habitacion WHERE estado = 'Mantenimiento';
ROLLBACK;

-- D2. Registrar una reserva nueva y su pago
-- Paso 1: crear la reserva (sin observaciones) [captura D2a]
BEGIN;
INSERT INTO reserva
    (id_cliente, id_habitacion, fecha_entrada, fecha_salida, total_reserva)
SELECT c.id_cliente, h.id_habitacion, DATE '2029-01-10', DATE '2029-01-13',
       (DATE '2029-01-13' - DATE '2029-01-10') * h.precio_noche
FROM cliente c CROSS JOIN habitacion h
WHERE c.correo = 'mafe.lopez@example.com' AND h.numero = '301'
RETURNING id_reserva, id_cliente, id_habitacion, total_reserva, estado,
          COALESCE(observaciones, '(sin observaciones)') AS observaciones;

-- Paso 2: la reserva aparece como reserva sin pagos [captura D2b]
SELECT r.id_reserva, r.fecha_entrada, r.fecha_salida, r.total_reserva
FROM reserva r
WHERE NOT EXISTS (SELECT 1 FROM pago p WHERE p.id_reserva = r.id_reserva);

-- Paso 3: registrar el pago de esa reserva [captura D2c]
INSERT INTO pago (id_reserva, monto, metodo)
SELECT r.id_reserva, r.total_reserva, 'Tarjeta'
FROM reserva r JOIN cliente c USING (id_cliente)
WHERE c.correo = 'mafe.lopez@example.com'
  AND r.fecha_entrada = DATE '2029-01-10'
RETURNING id_pago, id_reserva, monto, metodo, fecha_pago;

-- Paso 4: repetir la consulta de reservas sin pagos y deshacer [captura D2d]
SELECT count(*) AS reservas_sin_pago
FROM reserva r
WHERE NOT EXISTS (SELECT 1 FROM pago p WHERE p.id_reserva = r.id_reserva);
ROLLBACK;

-- D3. Cancelar una reserva
-- Paso 1: ver el efecto del NULL (con y sin COALESCE) [captura D3a]
BEGIN;
SELECT id_reserva, estado, observaciones,
       observaciones || 'x'              AS sin_coalesce,
       COALESCE(observaciones, '') || 'x' AS con_coalesce
FROM reserva WHERE id_reserva = 1;

-- Paso 2: cancelar la reserva dejando constancia [captura D3b]
UPDATE reserva
SET estado = 'Cancelada',
    observaciones = COALESCE(observaciones || ' | ', '')
                    || 'Cancelada el ' || CURRENT_DATE
WHERE id_reserva = 1 AND estado <> 'Cancelada'
RETURNING id_reserva, estado, observaciones;

-- Paso 3: los pagos de la reserva siguen intactos; deshacer [captura D3c]
SELECT id_pago, id_reserva, monto, metodo FROM pago WHERE id_reserva = 1;
ROLLBACK;

-- D4. Completar valores nulos en lote
-- Paso 1: contar con IS NULL y con = NULL [captura D4a]
BEGIN;
SELECT count(*) FILTER (WHERE observaciones IS NULL) AS con_is_null,
       count(*) FILTER (WHERE observaciones = NULL)  AS con_igual_null,
       count(*)                                      AS total_reservas
FROM reserva;

-- Paso 2: actualizar solo los nulos y comprobar; deshacer [captura D4b]
UPDATE reserva
SET observaciones = 'Sin peticiones especiales'
WHERE observaciones IS NULL;
SELECT count(*) AS quedan_nulos FROM reserva WHERE observaciones IS NULL;
ROLLBACK;

-- ---------- 15.4 PRUEBAS NEGATIVAS (cada una DEBE fallar; ejecutar solas) ----------
-- T1. Poner estado NULL a una habitación (NOT NULL)
UPDATE habitacion SET estado = NULL WHERE numero = '101';

-- T2. Cancelar con un estado que no existe (CHECK)
UPDATE reserva SET estado = 'Anulada' WHERE id_reserva = 1;

-- T3. Fecha de salida igual a la de entrada (CHECK)
UPDATE reserva SET fecha_salida = fecha_entrada WHERE id_reserva = 1;

-- ---------- CONSULTAS BÁSICAS, FILTROS Y ORDENAMIENTO ----------
-- B1. Listar todas las habitaciones disponibles
SELECT id_habitacion, numero, tipo, precio_noche
FROM habitacion
WHERE estado = 'Disponible'
ORDER BY numero;

-- B2. Mostrar las reservas activas (entre las fechas actuales)
-- Con la fecha de hoy
SELECT r.id_reserva, c.nombre, h.numero AS habitacion,
       r.fecha_entrada, r.fecha_salida, r.estado
FROM reserva r
JOIN cliente c USING (id_cliente)
JOIN habitacion h USING (id_habitacion)
WHERE CURRENT_DATE >= r.fecha_entrada
  AND CURRENT_DATE <  r.fecha_salida
  AND r.estado <> 'Cancelada'
ORDER BY r.fecha_entrada;

-- Variante con fecha fija (resultado reproducible)
-- Igual que la anterior, cambiando CURRENT_DATE por una fecha concreta:
-- WHERE DATE '2026-11-15' >= r.fecha_entrada
--   AND DATE '2026-11-15' <  r.fecha_salida

-- B3. Mostrar las reservas con más de 3 noches de estadía
SELECT r.id_reserva, c.nombre, r.fecha_entrada, r.fecha_salida,
       (r.fecha_salida - r.fecha_entrada) AS noches
FROM reserva r
JOIN cliente c USING (id_cliente)
WHERE (r.fecha_salida - r.fecha_entrada) > 3
ORDER BY noches DESC, r.id_reserva;

-- ---------- JOINS ENTRE TABLAS ----------
-- J1. Listar los clientes que han reservado una habitación tipo «Suite»
SELECT DISTINCT c.id_cliente, c.nombre, c.correo
FROM cliente c
JOIN reserva r USING (id_cliente)
JOIN habitacion h USING (id_habitacion)
WHERE h.tipo = 'Suite'
ORDER BY c.nombre;

-- J2. Mostrar los clientes de una nacionalidad específica que hayan hecho reservas
SELECT c.id_cliente, c.nombre, c.nacionalidad,
       count(r.id_reserva) AS reservas
FROM cliente c
JOIN reserva r USING (id_cliente)
WHERE c.nacionalidad = 'Colombiana'
GROUP BY c.id_cliente, c.nombre, c.nacionalidad
ORDER BY reservas DESC, c.nombre;

-- ---------- AGREGACIÓN Y AGRUPAMIENTO (GROUP BY / HAVING) ----------
-- A1. Total de ingresos generados por mes
-- Por mes de pago
SELECT to_char(fecha_pago, 'YYYY-MM') AS mes,
       count(*)   AS pagos,
       sum(monto) AS ingresos
FROM pago
GROUP BY to_char(fecha_pago, 'YYYY-MM')
ORDER BY mes;

-- Variante: por mes de la estancia (sin reservas canceladas)
SELECT to_char(fecha_entrada, 'YYYY-MM') AS mes_estancia,
       count(*)           AS reservas,
       sum(total_reserva) AS ingresos
FROM reserva
WHERE estado <> 'Cancelada'
GROUP BY to_char(fecha_entrada, 'YYYY-MM')
ORDER BY mes_estancia;

-- A2. Número de reservas realizadas por cada cliente
SELECT c.id_cliente, c.nombre, count(r.id_reserva) AS num_reservas
FROM cliente c
LEFT JOIN reserva r USING (id_cliente)
GROUP BY c.id_cliente, c.nombre
ORDER BY num_reservas DESC, c.nombre;

-- A3. Habitaciones que han sido reservadas más de 5 veces
SELECT h.id_habitacion, h.numero, h.tipo, count(r.id_reserva) AS veces_reservada
FROM habitacion h
JOIN reserva r USING (id_habitacion)
GROUP BY h.id_habitacion, h.numero, h.tipo
HAVING count(r.id_reserva) > 5
ORDER BY veces_reservada DESC;

-- Prueba del HAVING con un umbral menor (si la anterior sale vacía)
-- Cambia la condición para comprobar que el filtro funciona:
-- HAVING count(r.id_reserva) > 2

-- A4. Clientes con el mayor gasto total acumulado
SELECT c.id_cliente, c.nombre, sum(p.monto) AS gasto_total
FROM cliente c
JOIN reserva r USING (id_cliente)
JOIN pago p USING (id_reserva)
WHERE r.estado <> 'Cancelada'
GROUP BY c.id_cliente, c.nombre
ORDER BY gasto_total DESC
LIMIT 5;

-- A5. Clientes que han pagado usando más de un método de pago
SELECT c.id_cliente, c.nombre,
       count(DISTINCT p.metodo) AS metodos,
       string_agg(DISTINCT p.metodo, ', ' ORDER BY p.metodo) AS lista_metodos
FROM cliente c
JOIN reserva r USING (id_cliente)
JOIN pago p USING (id_reserva)
GROUP BY c.id_cliente, c.nombre
HAVING count(DISTINCT p.metodo) > 1
ORDER BY metodos DESC, c.nombre;

-- A6. Tipos de habitación y promedio de noches reservadas por tipo
SELECT h.tipo,
       count(*) AS reservas,
       round(avg(r.fecha_salida - r.fecha_entrada), 2) AS promedio_noches
FROM habitacion h
JOIN reserva r USING (id_habitacion)
WHERE r.estado <> 'Cancelada'
GROUP BY h.tipo
ORDER BY h.tipo;

-- A7. Total de reservas y monto total por tipo de habitación
SELECT h.tipo,
       count(r.id_reserva) AS total_reservas,
       sum(r.total_reserva) AS monto_total
FROM habitacion h
JOIN reserva r USING (id_habitacion)
WHERE r.estado <> 'Cancelada'
GROUP BY h.tipo
ORDER BY monto_total DESC;

-- A8. Los tres clientes con más noches reservadas en total
SELECT c.id_cliente, c.nombre,
       sum(r.fecha_salida - r.fecha_entrada) AS noches_totales
FROM cliente c
JOIN reserva r USING (id_cliente)
WHERE r.estado <> 'Cancelada'
GROUP BY c.id_cliente, c.nombre
ORDER BY noches_totales DESC, c.nombre
LIMIT 3;

-- A9. Ingreso total por cada método de pago
SELECT metodo,
       count(*)   AS pagos,
       sum(monto) AS ingreso_total
FROM pago
GROUP BY metodo
ORDER BY ingreso_total DESC;

-- A10. Clientes que han reservado más de una habitación diferente
SELECT c.id_cliente, c.nombre,
       count(DISTINCT r.id_habitacion) AS habitaciones_distintas
FROM cliente c
JOIN reserva r USING (id_cliente)
GROUP BY c.id_cliente, c.nombre
HAVING count(DISTINCT r.id_habitacion) > 1
ORDER BY habitaciones_distintas DESC, c.nombre;

-- ---------- SUBCONSULTAS Y COMPARACIONES ----------
-- S1. Habitaciones con precio mayor al promedio de todas las habitaciones
SELECT numero, tipo, precio_noche
FROM habitacion
WHERE precio_noche > (SELECT avg(precio_noche) FROM habitacion)
ORDER BY precio_noche DESC, numero;

-- Para verificar: el promedio por separado
SELECT round(avg(precio_noche), 2) AS precio_promedio FROM habitacion;

-- S2. Cliente que ha realizado la reserva más costosa
SELECT c.id_cliente, c.nombre, r.id_reserva, r.total_reserva
FROM reserva r
JOIN cliente c USING (id_cliente)
WHERE r.total_reserva = (SELECT max(total_reserva) FROM reserva);

-- S3. Habitaciones que nunca han sido reservadas
SELECT h.id_habitacion, h.numero, h.tipo, h.estado
FROM habitacion h
WHERE NOT EXISTS (
    SELECT 1 FROM reserva r WHERE r.id_habitacion = h.id_habitacion
)
ORDER BY h.numero;

-- S4. Reservas que no tienen pagos registrados
SELECT r.id_reserva, r.id_cliente, r.fecha_entrada, r.fecha_salida, r.total_reserva
FROM reserva r
WHERE NOT EXISTS (
    SELECT 1 FROM pago p WHERE p.id_reserva = r.id_reserva
)
ORDER BY r.id_reserva;

-- S5. Habitación más cara reservada por cada cliente
SELECT DISTINCT c.id_cliente, c.nombre, h.numero, h.tipo, h.precio_noche
FROM cliente c
JOIN reserva r USING (id_cliente)
JOIN habitacion h USING (id_habitacion)
WHERE h.precio_noche = (
    SELECT max(h2.precio_noche)
    FROM reserva r2
    JOIN habitacion h2 USING (id_habitacion)
    WHERE r2.id_cliente = c.id_cliente
)
ORDER BY c.nombre;

