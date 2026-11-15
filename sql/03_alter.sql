SELECT 'cliente' AS tabla, count(*) AS filas FROM cliente
UNION ALL SELECT 'habitacion', count(*) FROM habitacion
UNION ALL SELECT 'reserva',    count(*) FROM reserva
UNION ALL SELECT 'pago',       count(*) FROM pago;
