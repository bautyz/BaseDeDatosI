-- CREATE DATABASE ej2;

-- USE ej2;

-- Creamos las tablas

CREATE TABLE Clientes (
    dni VARCHAR(20) PRIMARY KEY,
    nombre VARCHAR(100),
    direccion VARCHAR(255)
);
create table Asuntos(
  numero_expediente int primary key,
  dni_cliente varchar(20),
  fecha_inicio date,
  fecha_fin date,
  estado varchar(20),
  foreign key (dni_cliente) references Clientes(dni)
);
create table Procuradores(
  id_procurador int primary key,
  nombre varchar(100),
  direccion varchar(255)
);
create table Asuntos_Procuradores(
  numero_expediente int,
  id_procurador int,
  foreign key (numero_expediente) references Asuntos(numero_expediente),
  foreign key (id_procurador) references Procuradores(id_procurador)
);