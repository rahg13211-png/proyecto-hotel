-- ============================================================================
-- 06_carga_masiva.sql : Carga sintética validada (20 clientes, 10 hab, 30 res, 30 pagos)
-- ============================================================================
BEGIN;

-- 1. INSERTAR 20 CLIENTES NUEVOS (Total en tabla: 25)
INSERT INTO cliente (nombre, correo, telefono, nacionalidad) VALUES
('Sofia Ramirez',          'sofia.ramirez@example.com',      '+573114501001', 'Colombiana'),
('Mateo Ospina',           'mateo.ospina@example.com',       '+573124501002', 'Colombiana'),
('Valentina Rojas',        'valentina.rojas@example.com',    '+573134501003', 'Colombiana'),
('Lucas Fernandez',        'lucas.fernandez@example.com',    '+549114501004', 'Argentina'),
('Camila Herrera',         'camila.herrera@example.com',     '+573144501005', 'Colombiana'),
('Sebastian Vargas',       'sebastian.vargas@example.com',   '+573154501006', 'Colombiana'),
('Isabella Morales',       'isabella.morales@example.com',   '+52554501007',  'Mexicana'),
('Daniel Castro',          'daniel.castro@example.com',      '+573164501008', 'Colombiana'),
('Mariana Ortiz',          'mariana.ortiz@example.com',      '+573174501009', 'Colombiana'),
('Alejandro Silva',        'alejandro.silva@example.com',    '+346124501010', 'Española'),
('Gabriela Mendoza',       'gabriela.mendoza@example.com',   '+573184501011', 'Colombiana'),
('Nicolas Navarro',        'nicolas.navarro@example.com',    '+5694501012',   'Chilena'),
('Paula Gutierrez',        'paula.gutierrez@example.com',    '+573194501013', 'Colombiana'),
('Camilo Restrepo',        'camilo.restrepo@example.com',    '+573204501014', 'Colombiana'),
('Lucia Romero',           'lucia.romero@example.com',       '+519874501015', 'Peruana'),
('Andres Medina',          'andres.medina@example.com',      '+573214501016', 'Colombiana'),
('Natalia Aguirre',        'natalia.aguirre@example.com',    '+573224501017', 'Colombiana'),
('Julian Paredes',         'julian.paredes@example.com',     '+593994501018', 'Ecuatoriana'),
('Valeria Salazar',        'valeria.salazar@example.com',    '+573004501019', 'Colombiana'),
('Emilio Benitez',         'emilio.benitez@example.com',     '+13055551020',  'Estadounidense');

-- 2. INSERTAR 10 HABITACIONES NUEVAS (Total en tabla: 15)
-- Precios base del hotel: Sencilla = 120000.00 | Doble = 220000.00 | Suite = 450000.00
INSERT INTO habitacion (numero, tipo, precio_noche, estado) VALUES
('103', 'Sencilla', 120000.00, 'Disponible'),
('104', 'Sencilla', 120000.00, 'Disponible'),
('203', 'Doble',    220000.00, 'Disponible'),
('204', 'Doble',    220000.00, 'Disponible'),
('205', 'Doble',    220000.00, 'Mantenimiento'),
('302', 'Suite',    450000.00, 'Disponible'),
('303', 'Suite',    450000.00, 'Disponible'),
('401', 'Sencilla', 130000.00, 'Disponible'),
('402', 'Doble',    240000.00, 'Disponible'),
('403', 'Suite',    480000.00, 'Disponible');

-- 3. INSERTAR 30 RESERVAS NUEVAS (Total en tabla: 35)
-- Fechas ubicadas en 2027 (enero a mayo) sin solapamientos en rangos [)
INSERT INTO reserva (id_cliente, id_habitacion, fecha_entrada, fecha_salida, total_reserva, observaciones, estado) VALUES
-- Enero 2027
((SELECT id_cliente FROM cliente WHERE correo='sofia.ramirez@example.com'),    (SELECT id_habitacion FROM habitacion WHERE numero='103'), '2027-01-05', '2027-01-08',  360000.00, 'Llegada en la tarde', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='mateo.ospina@example.com'),     (SELECT id_habitacion FROM habitacion WHERE numero='104'), '2027-01-06', '2027-01-10',  480000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='valentina.rojas@example.com'),  (SELECT id_habitacion FROM habitacion WHERE numero='203'), '2027-01-07', '2027-01-12', 1100000.00, 'Cama adicional solicitada', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='lucas.fernandez@example.com'),  (SELECT id_habitacion FROM habitacion WHERE numero='204'), '2027-01-10', '2027-01-13',  660000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='camila.herrera@example.com'),   (SELECT id_habitacion FROM habitacion WHERE numero='302'), '2027-01-12', '2027-01-15', 1350000.00, 'Vista panoramica', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='sebastian.vargas@example.com'), (SELECT id_habitacion FROM habitacion WHERE numero='303'), '2027-01-15', '2027-01-19', 1800000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='isabella.morales@example.com'), (SELECT id_habitacion FROM habitacion WHERE numero='401'), '2027-01-18', '2027-01-21',  390000.00, 'Alergia al polvo', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='daniel.castro@example.com'),    (SELECT id_habitacion FROM habitacion WHERE numero='402'), '2027-01-20', '2027-01-25', 1200000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='mariana.ortiz@example.com'),    (SELECT id_habitacion FROM habitacion WHERE numero='403'), '2027-01-22', '2027-01-24',  960000.00, 'Aniversario', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='alejandro.silva@example.com'),  (SELECT id_habitacion FROM habitacion WHERE numero='101'), '2027-01-25', '2027-01-29',  480000.00, NULL, 'Confirmada'),

-- Febrero 2027 (incluye reservas contiguas para probar rango semiabierto [))
((SELECT id_cliente FROM cliente WHERE correo='gabriela.mendoza@example.com'), (SELECT id_habitacion FROM habitacion WHERE numero='103'), '2027-02-10', '2027-02-14',  480000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='nicolas.navarro@example.com'),  (SELECT id_habitacion FROM habitacion WHERE numero='103'), '2027-02-14', '2027-02-18',  480000.00, 'Check-in exacto a las 15:00', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='paula.gutierrez@example.com'),  (SELECT id_habitacion FROM habitacion WHERE numero='104'), '2027-02-11', '2027-02-15',  480000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='camilo.restrepo@example.com'),  (SELECT id_habitacion FROM habitacion WHERE numero='203'), '2027-02-14', '2027-02-17',  660000.00, 'San Valentin', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='lucia.romero@example.com'),     (SELECT id_habitacion FROM habitacion WHERE numero='204'), '2027-02-16', '2027-02-20',  880000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='andres.medina@example.com'),    (SELECT id_habitacion FROM habitacion WHERE numero='302'), '2027-02-18', '2027-02-21', 1350000.00, 'Factura a nombre de empresa', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='natalia.aguirre@example.com'),  (SELECT id_habitacion FROM habitacion WHERE numero='303'), '2027-02-20', '2027-02-25', 2250000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='julian.paredes@example.com'),   (SELECT id_habitacion FROM habitacion WHERE numero='401'), '2027-02-22', '2027-02-24',  260000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='valeria.salazar@example.com'),  (SELECT id_habitacion FROM habitacion WHERE numero='402'), '2027-02-25', '2027-02-28',  720000.00, 'Mascota pequeña autorizada', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='emilio.benitez@example.com'),   (SELECT id_habitacion FROM habitacion WHERE numero='403'), '2027-02-26', '2027-03-02', 1920000.00, NULL, 'Confirmada'),

-- Marzo y Abril 2027 (incluye 2 reservas canceladas para reflejar operación real)
((SELECT id_cliente FROM cliente WHERE correo='carlos.gomez@example.com'),     (SELECT id_habitacion FROM habitacion WHERE numero='102'), '2027-03-05', '2027-03-09',  480000.00, 'Cliente frecuente', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='mafe.lopez@example.com'),       (SELECT id_habitacion FROM habitacion WHERE numero='201'), '2027-03-10', '2027-03-14',  880000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='john.smith@example.com'),       (SELECT id_habitacion FROM habitacion WHERE numero='301'), '2027-03-12', '2027-03-15', 1350000.00, 'Transporte aeropuerto', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='ana.rodriguez@example.com'),    (SELECT id_habitacion FROM habitacion WHERE numero='103'), '2027-03-15', '2027-03-18',  360000.00, 'Cancelada por cambio de vuelo', 'Cancelada'),
((SELECT id_cliente FROM cliente WHERE correo='pierre.dubois@example.com'),    (SELECT id_habitacion FROM habitacion WHERE numero='103'), '2027-03-16', '2027-03-19',  360000.00, 'Toma fechas liberadas por cancelacion', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='sofia.ramirez@example.com'),    (SELECT id_habitacion FROM habitacion WHERE numero='204'), '2027-04-02', '2027-04-06',  880000.00, 'Semana Santa', 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='mateo.ospina@example.com'),     (SELECT id_habitacion FROM habitacion WHERE numero='302'), '2027-04-05', '2027-04-10', 2250000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='valentina.rojas@example.com'),  (SELECT id_habitacion FROM habitacion WHERE numero='401'), '2027-04-12', '2027-04-15',  390000.00, 'Cancelada por el huesped', 'Cancelada'),
((SELECT id_cliente FROM cliente WHERE correo='lucas.fernandez@example.com'),  (SELECT id_habitacion FROM habitacion WHERE numero='402'), '2027-04-18', '2027-04-22',  960000.00, NULL, 'Confirmada'),
((SELECT id_cliente FROM cliente WHERE correo='isabella.morales@example.com'), (SELECT id_habitacion FROM habitacion WHERE numero='403'), '2027-04-25', '2027-04-30', 2400000.00, 'Estancia prolongada', 'Confirmada');

-- 4. INSERTAR 30 PAGOS NUEVOS (Total en tabla: 35)
-- Se asocian dinámicamente a las 30 reservas recién insertadas (fecha_entrada >= '2027-01-01')
INSERT INTO pago (id_reserva, fecha_pago, monto, metodo)
SELECT 
    r.id_reserva,
    (r.fecha_entrada - INTERVAL '5 days') + TIME '10:30:00',
    r.total_reserva,
    CASE (r.id_reserva % 3)
        WHEN 0 THEN 'Tarjeta'
        WHEN 1 THEN 'Transferencia'
        ELSE 'Efectivo'
    END
FROM reserva r
WHERE r.fecha_entrada >= '2027-01-01'
ORDER BY r.id_reserva;

COMMIT;