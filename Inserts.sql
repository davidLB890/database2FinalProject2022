use pflanze


--agrego datos a la tabla Planta

insert into Planta (nombre,fecha_nacimiento,altura,fecha_ultima_medida,precio)--DD/MM/AAAA
values
('Aspiristra','09/03/2021',11.9 ,'01/05/2022',700),
('Calathea','07/09/2020',66 ,'12/12/2020',350),
('Cinta','07/06/2005',12.0 ,'12/05/2009',150),
('Crotón','10/06/1998',6.2,'12/01/2000',455),
('Nephrolepsis','12/10/2009',10.3,'12/08/2011',1500),
('higuera','12/10/2018',null,null,477),
('Santa Rita','12/10/2020',null,'12/11/2020',2000),
('Calendula','12/10/2019',1,'12/11/2020',120),
('Pensamiento','03/10/2020',140,'12/11/2020',199)


--estos no deberían poder ingresarse----------------------------------------------------------------
insert into Planta (nombre,fecha_nacimiento,altura,fecha_ultima_medida,precio) 
values('Helecho','09/03/2023',11.9 ,'01/05/2022',700),
('Nephrolepsis','12/10/2009',null,'12/08/2023',1500)



select * from Planta
------



-----
--agrego datos a la tabla TAG

insert into TAG
values(1,'HIERBA'),
(2,'PERFUMA'),
(3,'FRUTAL'),
(4,'CONFLOR'),
(5,'TRONCOROTO'),
(4,'TRONCOROTO'),
(2,'FRUTAL'),
(6,'FRUTAL'),
(7,'PERFUMA'),
(8,'CONFLOR'),
(9,'PERFUMA'),
(9,'FRUTAL'),
(8,'TRONCOTORO'),
(6,'CONFLOR'),
(6,'PERFUMA')

select * from TAG

--agrego datos a la tabla Mantenimiento
insert into Mantenimiento(idPlanta, fecha_hora,descripcion) --MM/DD/AAAA
values
(1,'10/07/2021','descripcion1'),--
(2,'12/20/2021','descripcion2'),
(3,'12/11/2011','descripcion3'),
(4,'12/07/2021','descripcion4'),
(5,'11/12/2010','descripcion5'),
(4,'05/03/2007','descripcion6'),
(2,'10/04/2020','descripcion7'),
(1,'10/12/2021','descripcion8'),
(4,'02/02/2022','descripcion9'),
(2,'03/02/2022','descripcion10'),
(9,'12/07/2021','descripcion11'),
(7,'10/07/2020','descripcion12'),
(8,'10/07/2020','descripcion13'),
(8,'06/08/2021','descripcion14'),
(3,'03/02/2022', 'descripcion15'),
--estos no deberían poder ingresarse----------------------------------------------------------------
insert into Mantenimiento(idPlanta, fecha_hora,descripcion)
values
(3,'03/02/2023','descripcion10'),
(1,'07/02/2022','descripcion10'),
(4,'09/02/2022','descripcion10')
--Este no deberia poder ingresarse por el trigger que condiciona las fechas.
insert into Mantenimiento(idPlanta, fecha_hora,descripcion)
values
(5, '03/02/2000','desc1')--La fecha del mantenimiento es menor que la fecha del nacimiento de la planta
select * from [dbo].[Mantenimiento]

--agrego datos a la tabla MantenimientoOperativo

insert into MantenimientoOperativo
values
(3,8,250.50),
(6,2,300.80),
(8,5,250.50),
(9,3,90.22),
(11, 3, 60),
(13, 5, 100),
(14,1.5,50),
(15,5.7,130)




select * from MantenimientoOperativo

--agrego datos a la tabla MantenimientoNutrientes

insert into MantenimientoNutrientes(id_mant)
values
(1),
(4),
(5),
(7),
(10),
(12)

select * from MantenimientoNutrientes

--insert que no deberian funcionar debido al trigger.
insert into MantenimientoOperativo
values
(1,4,200)
-----------------------Lo mismo pero para Nutrientes.---------------------------------
insert into MantenimientoNutrientes(id_mant)
values
(15)



--agrego datos a la tabla Producto

insert into Productos(codigo,descripcion,precioGramo)
values
('001AB','Potásicos',150),
('002AB','Nitrogenados',125),
('003AB','Agua',500),
('004AB','Fosfatados',200),
('005AB','Estiércol',70),
('006AB','lombrices',150)


select * from Productos
--agrego datos a la tabla Mantenimiento_Producto

insert into Mantemiento_Producto(Id_producto,Id_mantenimiento,cantidadGramos,CostoAplicacion)
values
('001AB',1,100,30),
('002AB',1,200,15),
('003AB',4,20,90),
('004AB',5,50,55),
('005AB',1,50,45),
('004AB',4,60,66),
('003AB',1,100,74),
('004AB',1,200,77),
('003AB',7,50,60),
('002AB',12,200,15),
('001AB',10,90,100),
('006AB',1,50,2),
('004AB', 10, 5, 75),
('003AB', 12,32,55)

--inserts que no funcionarian:
insert into Mantemiento_Producto(Id_producto,Id_mantenimiento,cantidadGramos,CostoAplicacion)
values
('005AB', 10, 23, -5),
('002AB', 7, 0, 900)

select * from Mantemiento_Producto





--probando auditoria.---------------------
delete from Productos where codigo = '006ABC'
update Productos set precioGramo = 30 where Productos.codigo = '002ABC'
update Productos set precioGramo = 40, descripcion = 'nueva descripcion' where Productos.codigo = '002ABC'

select * from Productos
select * from auditoria
------------------------------------------