-- 02_seed.sql : datos de ejemplo (correos ficticios en dominio example.com)

INSERT INTO cliente (nombre, correo, telefono, nacionalidad) VALUES
('Carlos Andres Gomez',  'carlos.gomez@example.com',  '+573104567890', 'Colombiana'),
('Maria Fernanda Lopez', 'mafe.lopez@example.com',    '+573209876543', 'Colombiana'),
('John Smith',           'john.smith@example.com',    '+14155552671',  'Estadounidense'),
('Ana Sofia Rodriguez',  'ana.rodriguez@example.com', '+573001234567', 'Colombiana'),
('Pierre Dubois',        'pierre.dubois@example.com', '+33612345678',  'Francesa');

INSERT INTO habitacion (numero, tipo, precio_noche, estado) VALUES
('101', 'Sencilla', 120000.00, 'Disponible'),
('102', 'Sencilla', 120000.00, 'Disponible'),
('201', 'Doble',    220000.00, 'Disponible'),
('202', 'Doble',    220000.00, 'Ocupada'),
('301', 'Suite',    450000.00, 'Disponible');

-- total_reserva = (fecha_salida - fecha_entrada) * precio_noche
INSERT INTO reserva
    (id_cliente, id_habitacion, fecha_entrada, fecha_salida, total_reserva)
VALUES
(1, 3, '2026-12-01', '2026-12-05',  880000.00),  -- 4 noches x 220.000
(2, 5, '2026-12-10', '2026-12-15', 2250000.00),  -- 5 noches x 450.000
(3, 1, '2026-12-02', '2026-12-04',  240000.00),  -- 2 noches x 120.000
(4, 2, '2026-12-15', '2026-12-20',  600000.00),  -- 5 noches x 120.000
(5, 4, '2026-11-10', '2026-11-16', 1320000.00);  -- 6 noches x 220.000 (en curso)

INSERT INTO pago (id_reserva, monto, metodo) VALUES
(1,  880000.00, 'Tarjeta'),
(2, 2250000.00, 'Transferencia'),
(3,  240000.00, 'Efectivo'),
(4,  600000.00, 'Tarjeta'),
(5, 1320000.00, 'Transferencia');
