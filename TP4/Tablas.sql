create database banco;
use banco;

create table Clientes(
	numero_cliente INT NOT NULL PRIMARY KEY, 
    dni INT NOT NULL,
    apellido VARCHAR (60) NOT NULL,
    nombre VARCHAR (60)NOT NULL
);

create table Cuentas(
	numero_cuenta INT NOT NULL PRIMARY KEY,
    numero_cliente INT,
    saldo DECIMAL (10,2),
    FOREIGN KEY (numero_cliente)  REFERENCES Clientes(numero_cliente)
);

CREATE TABLE movimientos (
	numero_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    numero_cuenta INT,
    fecha DATE,
    tipo ENUM('CREDITO' , 'DEBITO'),
    importe DECIMAL (10,2),
    FOREIGN KEY (numero_cuenta) REFERENCES Cuentas (numero_cuenta)
);

CREATE TABLE historial_movimientos(
	id INT NOT NULL PRIMARY KEY,
    numero_cuenta INT,
    numero_movimiento INT,
    saldo_anterior DECIMAL (10,2),
    saldo_actual DECIMAL (10,2),
    FOREIGN KEY (numero_cuenta) REFERENCES Cuentas (numero_cuenta),
    FOREIGN KEY (numero_movimiento) REFERENCES movimientos (numero_movimiento)
);