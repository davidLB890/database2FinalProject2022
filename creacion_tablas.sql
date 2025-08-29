IF EXISTS(SELECT * FROM sys.databases WHERE name='pflanze')
	DROP DATABASE Pflanze
GO
CREATE DATABASE pflanze
GO
use pflanze
GO

create table Planta(
id int identity(1,1) primary key,
nombre varchar(50) not null,
fecha_nacimiento datetime check(fecha_nacimiento <= getdate()) not null,
fecha_ultima_medida datetime check(fecha_ultima_medida <= getdate()),
altura decimal(7,2) check(altura between 0.1 and 12000),
--constraint chck_fecha check (fecha_nacimiento < fecha_ultima_medida),
precio money check (precio > 0)
);

create table TAG(
idPlanta int references Planta(id),
nombre varchar(50),
constraint PK_TAG primary key(idPlanta, nombre)
);

create table Mantenimiento(
idMant int identity(1,1),
idPlanta int references Planta(id),
fecha_hora datetime check(fecha_hora <= getdate()) not null,
descripcion varchar(200) not null
Primary key(idMant)
);

create table MantenimientoOperativo(
id_mant int references Mantenimiento(idMant),
cantidad_horas decimal(3,2) not null,
costo decimal(8,2) check(costo > 0),
constraint pk_MantOperativo primary key(id_mant)
);

create table MantenimientoNutrientes(
id_mant int references Mantenimiento(idMant),
constraint pk_mant_Nutr primary key(id_mant)
)

create table Productos(
codigo char(5) primary key,
descripcion varchar(200) unique not null,
precioGramo money check(precioGramo > 0) not null
);

CREATE TABLE Mantemiento_Producto(
Id_producto char(5) references PRODUCTOS(codigo),
Id_mantenimiento int references MantenimientoNutrientes(id_mant),
cantidadGramos decimal (7,2) check(cantidadGramos > 0) not null,
CostoAplicacion decimal(7,2) check(CostoAplicacion>0)not null,
constraint PK_USA primary key(Id_producto, Id_mantenimiento)
);

create table Auditoria(
pc varchar(30),
usuario varchar(30),
fecha_hora datetime,
descripcionAnteriro varchar(200),
descripcionNueva varchar(200),
precioGramoAnteriro money,
precioGramoNuevo money
)



--INDICES.

CREATE INDEX I1 on Mantenimiento(idPlanta);

CREATE INDEX I2 on Mantemiento_Producto(Id_mantenimiento);



