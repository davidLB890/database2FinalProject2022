use [pflanze]


/*a. Mostrar Nombre de Planta y Descripción del Mantenimiento para el último(s)
mantenimiento hecho en el año actual*/



select P.nombre, M.descripcion
from Planta P, Mantenimiento M
where P.id = M.idPlanta 
and YEAR(M.fecha_hora) = year(GETDATE())
and M.fecha_hora >= (select MAX(M1.fecha_hora)
							from Mantenimiento M1)


/*b. Mostrar la(s) plantas que recibieron más cantidad de mantenimientos*/

select P.nombre, P.id
from Planta P, Mantenimiento M
where P.id = M.idPlanta
group by P.nombre, P.id
having count(*) >= all(select count(*)
								from Mantenimiento M2, Planta P1
								where M2.idPlanta = P1.id
								group by P1.nombre)



/*c. Mostrar las plantas que este año ya llevan más de un 20% de costo de mantenimiento
que el costo de mantenimiento de todo el año anterior para la misma planta ( solo
considerar plantas nacidas en el año 2019 o antes)*/

SELECT P.id,P.nombre
FROM Planta P
where year(p.fecha_nacimiento) <= 2019 and
[dbo].[calcularSumaMant](P.id, year(GETDATE())) >= --IR AL CREATE DE DICHA FUNTION.
([dbo].[calcularSumaMant](P.id, year(getdate())-1)*0.2)


/*d. Mostrar las plantas que tienen el tag “FRUTAL”, a la vez tienen el tag “PERFUMA” y no
tienen el tag “TRONCOROTO”. Y que adicionalmente miden medio metro de altura o
más y tienen un precio de venta establecido*/

select p.nombre
from Planta p
where p.altura >= 50
and p.precio is not null
and p.id in (select t.idplanta
				from tag t
				where t.nombre = 'FRUTAL')
and p.id in(select t.idplanta
				from tag t
				where t.nombre = 'PERFUMA')
and p.id not in(select t.idplanta
				from tag t
				where t.nombre = 'TRONCOROTO')



/*e. Mostrar las Plantas que recibieron mantenimientos que en su conjunto incluyen todos
los productos existentes*/

select distinct p.id, p.nombre, m.idMant
from Planta p, Mantenimiento M
where p.id = M.idPlanta
and M.idMant in (select MN.id_mant
					from MantenimientoNutrientes MN, Mantemiento_Producto MP
					where MN.id_mant = MP.Id_mantenimiento
					group by MN.id_mant
					having count(MP.Id_mantenimiento) >= all(select count(*)
															from Productos))



/*f. Para cada Planta con 2 años de vida o más y con un precio menor a 200 dólares:
sumarizar su costo de Mantenimiento total ( contabilizando tanto mantenimientos de
tipo “OPERATIVO” como de tipo “NUTRIENTES”) y mostrar solamente las plantas que
su costo sumarizado es mayor que 100 dólares.*/

select P.nombre, P.id
from Planta P
where ( YEAR(getdate()) - year(P.fecha_nacimiento) >= 2) and
P.precio < 200 and
[dbo].[calcularSumaMant](P.id, null) > 100