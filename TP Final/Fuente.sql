-- Crear DB
CREATE DATABASE biblioteca;
USE biblioteca;

-- Tablas
CREATE TABLE socio (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  email VARCHAR(150),
  dni VARCHAR(30) NOT NULL UNIQUE,
  telefono VARCHAR(40),
  fecha_alta DATE NOT NULL
);

CREATE TABLE libro (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(255) NOT NULL,
  autor VARCHAR(150),
  isbn VARCHAR(30) UNIQUE,
  ejemplares_totales INT NOT NULL DEFAULT 1,
  ejemplares_disponibles INT NOT NULL DEFAULT 1
);

CREATE TABLE prestamo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  socio_id INT NOT NULL,
  libro_id INT NOT NULL,
  fecha_prestamo DATE NOT NULL,
  fecha_vencimiento DATE NOT NULL,
  fecha_devolucion DATE,
  estado ENUM('ACTIVO','DEVUELTO') NOT NULL DEFAULT 'ACTIVO',
  FOREIGN KEY (socio_id) REFERENCES socio(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (libro_id) REFERENCES libro(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE cuota (
  id INT AUTO_INCREMENT PRIMARY KEY,
  socio_id INT NOT NULL,
  mes TINYINT NOT NULL,
  anio SMALLINT NOT NULL,
  monto DECIMAL(8,2) NOT NULL,
  pagada BOOLEAN NOT NULL DEFAULT FALSE,
  fecha_pago DATE,
  FOREIGN KEY (socio_id) REFERENCES socio(id) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE (socio_id, mes, anio)
);


-- Datos de prueba (10 socios, 10 libros)
INSERT INTO socio (nombre, email, dni, telefono, fecha_alta) VALUES
('Ana Gómez','ana.gomez@mail.com','DNI10000001','341-155-0001','2025-02-01'),
('Luis García','luis.garcia@mail.com','DNI10000002','341-155-0002','2025-03-10'),
('María Fernández','maria.fern@mail.com','DNI10000003','341-155-0003','2025-01-20'),
('Carlos Ruiz','carlos.ruiz@mail.com','DNI10000004','341-155-0004','2025-04-15'),
('Lucía Díaz','lucia.diaz@mail.com','DNI10000005','341-155-0005','2025-06-05'),
('Martín López','martin.lopez@mail.com','DNI10000006','341-155-0006','2025-05-12'),
('Sofía Torres','sofia.torres@mail.com','DNI10000007','341-155-0007','2025-07-20'),
('Diego Alvarez','diego.alvarez@mail.com','DNI10000008','341-155-0008','2025-08-01'),
('Laura Romero','laura.romero@mail.com','DNI10000009','341-155-0009','2025-09-10'),
('Pablo Sánchez','pablo.sanchez@mail.com','DNI10000010','341-155-0010','2025-10-01');

INSERT INTO libro (titulo, autor, isbn, ejemplares_totales, ejemplares_disponibles) VALUES
('Introducción a Bases de Datos','J. Date','ISBN0001',3,3),
('Programación en Python','M. Lutz','ISBN0002',2,2),
('Algoritmos y Estructuras de Datos','T. Cormen','ISBN0003',4,4),
('Redes de Computadoras','A. Tanenbaum','ISBN0004',5,5),
('Sistemas Operativos','A. Silberschatz','ISBN0005',3,3),
('Machine Learning','T. Mitchell','ISBN0006',2,2),
('Inteligencia Artificial','S. Russell','ISBN0007',3,3),
('Compiladores','A. Aho','ISBN0008',2,2),
('Programación Web','R. Nixon','ISBN0009',4,4),
('Matemática Discreta','R. Johnsonbaugh','ISBN0010',5,5);


-- Calcular Multa
DELIMITER //
CREATE FUNCTION fn_calcular_multa(monto_base DECIMAL(8,2), dias INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  IF dias <= 0 THEN
    RETURN 0.00;
  END IF;
  RETURN ROUND(monto_base * 0.03 * dias, 2);
END//
DELIMITER ;

-- CRUD Socio

-- Crear Socio
DELIMITER //
CREATE PROCEDURE sp_crear_socio(
  IN p_nombre VARCHAR(120),
  IN p_email VARCHAR(150),
  IN p_dni VARCHAR(30),
  IN p_tel VARCHAR(40),
  IN p_fecha DATE
)
BEGIN
  INSERT INTO socio(nombre,email,dni,telefono,fecha_alta)
  VALUES(p_nombre,p_email,p_dni,p_tel,p_fecha);
END//
DELIMITER ;

-- Ver Socio
DELIMITER //
CREATE PROCEDURE sp_ver_socio(IN p_id INT)
BEGIN
  SELECT * FROM socio WHERE id = p_id;
END//
DELIMITER ;

-- Actualizar Socio
DELIMITER //
CREATE PROCEDURE sp_actualizar_socio(
  IN p_id INT,
  IN p_nombre VARCHAR(120),
  IN p_email VARCHAR(150),
  IN p_tel VARCHAR(40)
)
BEGIN
  UPDATE socio
  SET nombre = p_nombre,
      email = p_email,
      telefono = p_tel
  WHERE id = p_id;
END//
DELIMITER ;

-- Eliminar Socio
DELIMITER //
CREATE PROCEDURE sp_eliminar_socio(IN p_id INT)
BEGIN
  DELETE FROM socio WHERE id = p_id;
END//
DELIMITER ;


-- CRUD Libro

-- Crear Libro
DELIMITER //
CREATE PROCEDURE sp_crear_libro(
  IN p_titulo VARCHAR(255),
  IN p_autor VARCHAR(150),
  IN p_isbn VARCHAR(30),
  IN p_total INT
)
BEGIN
  INSERT INTO libro(titulo,autor,isbn,ejemplares_totales,ejemplares_disponibles)
  VALUES(p_titulo,p_autor,p_isbn,p_total,p_total);
END//
DELIMITER ;

-- Ver Libro
DELIMITER //
CREATE PROCEDURE sp_ver_libro(IN p_id INT)
BEGIN
  SELECT * FROM libro WHERE id = p_id;
END//
DELIMITER ;

-- Actualizar Libro
DELIMITER //
CREATE PROCEDURE sp_actualizar_libro(
  IN p_id INT,
  IN p_titulo VARCHAR(255),
  IN p_autor VARCHAR(150)
)
BEGIN
  UPDATE libro
  SET titulo = p_titulo,
      autor = p_autor
  WHERE id = p_id;
END//
DELIMITER ;

-- Eliminar Libro
DELIMITER //
CREATE PROCEDURE sp_eliminar_libro(IN p_id INT)
BEGIN
  DELETE FROM libro WHERE id = p_id;
END//
DELIMITER ;


-- Manejo Prestamos

-- Prestar Libro
DELIMITER //
CREATE PROCEDURE sp_prestar_libro(
  IN p_socio INT,
  IN p_libro INT,
  OUT p_ok BOOLEAN,
  OUT p_msg TEXT
)
proc_prestar: BEGIN
  DECLARE v_disp INT;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_ok = FALSE;
    SET p_msg = 'Error interno al prestar.';
  END;

  START TRANSACTION;

  SELECT ejemplares_disponibles INTO v_disp
    FROM libro WHERE id = p_libro FOR UPDATE;

  IF v_disp IS NULL THEN
    SET p_ok = FALSE;
    SET p_msg = 'Libro no encontrado';
    ROLLBAR: BEGIN END; -- no-op label to satisfy structure (no extra logic)
    ROLLBACK;
    LEAVE proc_prestar;
  END IF;

  IF v_disp <= 0 THEN
    SET p_ok = FALSE;
    SET p_msg = 'No hay ejemplares disponibles';
    ROLLBACK;
    LEAVE proc_prestar;
  END IF;

  INSERT INTO prestamo (socio_id, libro_id, fecha_prestamo, fecha_vencimiento)
    VALUES (p_socio, p_libro, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));

  UPDATE libro SET ejemplares_disponibles = ejemplares_disponibles - 1 WHERE id = p_libro;

  SET p_ok = TRUE;
  SET p_msg = 'Préstamo registrado';
  COMMIT;
END//
DELIMITER ;

-- Devolver Libro
DELIMITER //
CREATE PROCEDURE sp_devolver_libro(
  IN p_prestamo INT,
  OUT p_ok BOOLEAN,
  OUT p_msg TEXT
)
proc_devolver: BEGIN
  DECLARE v_libro INT;
  DECLARE v_socio INT;
  DECLARE v_fecha_venc DATE;
  DECLARE v_fecha_dev DATE;
  DECLARE v_dias INT;
  DECLARE v_monto_cuota DECIMAL(8,2);
  DECLARE v_multa DECIMAL(10,2);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_ok = FALSE;
    SET p_msg = 'Error interno al devolver.';
  END;

  START TRANSACTION;

  SELECT libro_id, socio_id, fecha_vencimiento, fecha_devolucion
    INTO v_libro, v_socio, v_fecha_venc, v_fecha_dev
  FROM prestamo
  WHERE id = p_prestamo
  FOR UPDATE;

  IF v_libro IS NULL THEN
    SET p_ok = FALSE;
    SET p_msg = 'Préstamo no encontrado';
    ROLLBACK;
    LEAVE proc_devolver;
  END IF;

  IF v_fecha_dev IS NOT NULL THEN
    SET p_ok = FALSE;
    SET p_msg = 'Préstamo ya devuelto';
    ROLLBACK;
    LEAVE proc_devolver;
  END IF;

  -- marcar devolución
  UPDATE prestamo
    SET fecha_devolucion = CURDATE(), estado = 'DEVUELTO'
  WHERE id = p_prestamo;

  -- aumentar ejemplar
  UPDATE libro
    SET ejemplares_disponibles = ejemplares_disponibles + 1
  WHERE id = v_libro;

  -- calcular dias de atraso
  SET v_dias = DATEDIFF(CURDATE(), v_fecha_venc);

  IF v_dias > 0 THEN
    -- obtener cuota más reciente del socio (si no existe, monto por defecto 100.00)
    SELECT monto INTO v_monto_cuota
      FROM cuota
      WHERE socio_id = v_socio
      ORDER BY anio DESC, mes DESC
      LIMIT 1;

    IF v_monto_cuota IS NULL THEN
      SET v_monto_cuota = 100.00;
    END IF;

    SET v_multa = fn_calcular_multa(v_monto_cuota, v_dias);

    -- registrar multa como cuota extraordinaria (mes = 0)
    INSERT INTO cuota (socio_id, mes, anio, monto, pagada, fecha_pago)
      VALUES (v_socio, 0, YEAR(CURDATE()), v_multa, FALSE, NULL);

    SET p_msg = CONCAT('Devolución registrada. Multa: ', v_multa);
  ELSE
    SET p_msg = 'Devolución registrada. Sin multa.';
  END IF;

  SET p_ok = TRUE;
  COMMIT;
END//
DELIMITER ;


-- Buscar Socio
DELIMITER //
CREATE PROCEDURE sp_buscar_socio(IN p_texto VARCHAR(150))
BEGIN
  SELECT * FROM socio
  WHERE nombre LIKE CONCAT('%', p_texto, '%')
     OR dni LIKE CONCAT('%', p_texto, '%')
     OR email LIKE CONCAT('%', p_texto, '%');
END//
DELIMITER ;

-- Buscar Libro
DELIMITER //
CREATE PROCEDURE sp_buscar_libro(IN p_texto VARCHAR(150))
BEGIN
  SELECT * FROM libro
  WHERE titulo LIKE CONCAT('%', p_texto, '%')
     OR autor LIKE CONCAT('%', p_texto, '%')
     OR isbn LIKE CONCAT('%', p_texto, '%');
END//
DELIMITER ;


-- Reporte Morosos
DELIMITER //
CREATE PROCEDURE sp_reporte_morosos(OUT p_promedio DECIMAL(6,2))
BEGIN
  SELECT AVG(cnt) INTO p_promedio FROM (
    SELECT COUNT(*) AS cnt
    FROM cuota
    WHERE pagada = FALSE AND mes > 0
    GROUP BY socio_id
  ) AS t;
END//
DELIMITER ;

-- Modificar Cuota
DELIMITER //
CREATE PROCEDURE sp_modificar_cuota(
  IN p_socio INT,
  IN p_mes TINYINT,
  IN p_anio SMALLINT,
  IN p_monto DECIMAL(8,2),
  OUT p_ok BOOLEAN,
  OUT p_msg TEXT
)
proc_mod_cuota: BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    SET p_ok = FALSE; SET p_msg = 'Error interno al modificar cuota';
  END;

  START TRANSACTION;
    UPDATE cuota
      SET monto = p_monto
      WHERE socio_id = p_socio AND mes = p_mes AND anio = p_anio;

    IF ROW_COUNT() = 0 THEN
      INSERT INTO cuota (socio_id, mes, anio, monto, pagada) VALUES (p_socio, p_mes, p_anio, p_monto, FALSE);
      SET p_ok = TRUE; SET p_msg = 'Cuota creada';
    ELSE
      SET p_ok = TRUE; SET p_msg = 'Cuota actualizada';
    END IF;
  COMMIT;
END//
DELIMITER ;

-- Triggers

-- Validar Disponibilidad
DELIMITER //
CREATE TRIGGER trg_prestamo_before_insert
BEFORE INSERT ON prestamo
FOR EACH ROW
BEGIN
  DECLARE v_disp INT;
  SELECT ejemplares_disponibles INTO v_disp FROM libro WHERE id = NEW.libro_id;
  IF v_disp IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Libro no encontrado';
  ELSEIF v_disp <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay ejemplares disponibles';
  END IF;
END//
DELIMITER ;

-- Disminuir Ejemplares
DELIMITER //
CREATE TRIGGER trg_prestamo_after_insert
AFTER INSERT ON prestamo
FOR EACH ROW
BEGIN
  UPDATE libro SET ejemplares_disponibles = ejemplares_disponibles - 1 WHERE id = NEW.libro_id;
END//
DELIMITER ;

-- Devolver Ejemplar
DELIMITER //
CREATE TRIGGER trg_prestamo_after_delete
AFTER DELETE ON prestamo
FOR EACH ROW
BEGIN
  IF OLD.estado = 'ACTIVO' THEN
    UPDATE libro SET ejemplares_disponibles = ejemplares_disponibles + 1 WHERE id = OLD.libro_id;
  END IF;
END//
DELIMITER ;

-- Índices

-- Busqueda Socio
CREATE INDEX idx_socio_nombre ON socio(nombre);
CREATE INDEX idx_socio_email ON socio(email);

-- Busqueda Libro
CREATE INDEX idx_libro_titulo ON libro(titulo);
CREATE INDEX idx_libro_autor ON libro(autor);

-- Consultas Prestamos
CREATE INDEX idx_prestamo_socio ON prestamo(socio_id);
CREATE INDEX idx_prestamo_libro ON prestamo(libro_id);
CREATE INDEX idx_prestamo_estado ON prestamo(estado);

-- Indice Cuotas
CREATE INDEX idx_cuota_socio ON cuota(socio_id);
