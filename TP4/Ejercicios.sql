-- PUNTO 3 -----------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE VerCuentas()
BEGIN
	SELECT numero_cuenta, saldo FROM Cuentas;
END$$
DELIMITER ;



-- PUNTO 4 -----------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE CuentasConSaldoMayorQue(IN limite DECIMAL (10,2))
BEGIN
	SELECT
		numero_cuenta,saldo
	FROM cuentas
    WHERE saldo > limite;
END$$
DELIMITER ;



-- PUNTO 5 -----------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE TotalMovimientosDelMes(IN CUENTA INT, OUT total DECIMAL (10,2))
BEGIN
	SELECT 	IFNULL(SUM(CASE WHEN tipo = 'CREDITO' THEN importe WHEN tipo = 'DEBITO' THEN -importe END), 00)
	INTO total
    FROM movimientos
    WHERE numero_cuenta  = cuenta
		AND month(fecha) = month(CURDATE())
        AND YEAR (fecha) = YEAR (CURDATE());
END$$
DELIMITER ;



-- PUNTO 6 -----------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE Depositar (IN cuenta INT , IN monto DECIMAL (10,2))
BEGIN 
	INSERT INTO movimientos (numero_cuenta , fecha , tipo , importe)
    VALUES (cuenta , CURDATE() , 'CREDITO' , monto);
END $$
DELIMITER ;



-- PUNTO 7 -----------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE Extraer(IN cuenta INT, IN monto DECIMAL(10,2))
BEGIN
    DECLARE saldo_actual DECIMAL(10,2);

    SELECT saldo INTO saldo_actual
    FROM Cuentas
    WHERE numero_cuenta = cuenta;

    IF saldo_actual IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La cuenta no existe.';
    END IF;

    IF saldo_actual < monto THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fondos insuficientes para realizar la extracción';
    ELSE
        INSERT INTO movimientos (numero_cuenta, fecha, tipo, importe)
        VALUES (cuenta, CURDATE(), 'DEBITO', monto);
    END IF;
END$$

DELIMITER ;



-- PUNTO 8 -----------------------------------------------------------------------
DELIMITER $$

CREATE TRIGGER actualizar_saldo
AFTER INSERT ON movimientos
FOR EACH ROW
BEGIN
    IF UPPER(NEW.tipo) = 'CREDITO' THEN
        UPDATE Cuentas
        SET saldo = saldo + NEW.importe
        WHERE numero_cuenta = NEW.numero_cuenta;

    ELSEIF UPPER(NEW.tipo) = 'DEBITO' THEN
        UPDATE Cuentas
        SET saldo = saldo - NEW.importe
        WHERE numero_cuenta = NEW.numero_cuenta;
    END IF;
END$$

DELIMITER ;


-- PUNTO 9 -----------------------------------------------------------------------
DROP TRIGGER IF EXISTS actualizar_saldo;

DELIMITER $$

CREATE TRIGGER actualizar_saldo
AFTER INSERT ON movimientos
FOR EACH ROW
BEGIN
    DECLARE saldo_anterior DECIMAL(10,2);
    DECLARE saldo_actual DECIMAL(10,2);

    SELECT saldo INTO saldo_anterior
    FROM Cuentas
    WHERE numero_cuenta = NEW.numero_cuenta;

    IF UPPER(NEW.tipo) = 'CREDITO' THEN
        UPDATE Cuentas
        SET saldo = saldo + NEW.importe
        WHERE numero_cuenta = NEW.numero_cuenta;
    ELSEIF UPPER(NEW.tipo) = 'DEBITO' THEN
        UPDATE Cuentas
        SET saldo = saldo - NEW.importe
        WHERE numero_cuenta = NEW.numero_cuenta;
    END IF;

    SELECT saldo INTO saldo_actual
    FROM Cuentas
    WHERE numero_cuenta = NEW.numero_cuenta;

    INSERT INTO historial_movimientos (numero_cuenta, numero_movimiento, saldo_anterior, saldo_actual)
    VALUES (NEW.numero_cuenta, NEW.numero_movimiento, saldo_anterior, saldo_actual);
END$$

DELIMITER ;


-- PUNTO 10 -----------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE TotalMovimientosDelMes(IN cuenta INT, OUT total DECIMAL(10,2))
BEGIN
    DECLARE fin INT DEFAULT 0;
    DECLARE tipo_mov VARCHAR(10);
    DECLARE importe_mov DECIMAL(10,2);
    DECLARE suma DECIMAL(10,2) DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT tipo, importe
        FROM movimientos
        WHERE numero_cuenta = cuenta
        AND MONTH(fecha) = MONTH(CURDATE())
        AND YEAR(fecha) = YEAR(CURDATE());

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fin = 1;

    OPEN cur;

    bucle: LOOP
        FETCH cur INTO tipo_mov, importe_mov;
        IF fin = 1 THEN
            LEAVE bucle;
        END IF;

        IF UPPER(tipo_mov) = 'CREDITO' THEN
            SET suma = suma + importe_mov;
        ELSEIF UPPER(tipo_mov) = 'DEBITO' THEN
            SET suma = suma - importe_mov;
        END IF;
    END LOOP bucle;

    CLOSE cur;

    SET total = suma;
END$$

DELIMITER ;


-- PUNTO 11 -----------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE AplicarInteres(IN porcentaje DECIMAL(5,2),IN minimo DECIMAL(10,2))
BEGIN
    UPDATE Cuentas
    SET saldo = saldo + (saldo * (porcentaje / 100))
    WHERE saldo > minimo;
END$$

DELIMITER ;


