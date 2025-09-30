-- CREATE DATABASE ej1;
-- use ej1;
-- Creamos las tablas.
create table Socios(
    id_socio int primary key,
    nombre varchar(100),
    direccion varchar(255)
);
create table barcos(

  matricula VARCHAR(20) primary key,
  nombre VARCHAR(100),
  numero_amarre INT,
  cuota DECIMAL(10, 2),
  id_socio INT,
  foreign key (id_socio) references Socios(id_socio)
);
CREATE TABLE salidas(

  id_salida INT PRIMARY KEY,
  matricula VARCHAR(20),
  fecha_salida DATE,
  hora_salida TIME,
  destino VARCHAR(100),
  patron_nombre VARCHAR(100),
  patron_direccion VARCHAR(255),
  foreign key (matricula) references barcos(matricula)
);
