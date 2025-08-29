use pflanze

/*Auditar cualquier cambio del maestro de Productos. Se debe llevar un registro detallado de
las inserciones, modificaciones y borrados, en todos los casos registrar desde que PC se
hacen los movimientos, la fecha y la hora, el usuario y todos los datos que permitan una
correcta auditoría (si son modificaciones que datos se modificaron, qué datos había antes,
que datos hay ahora, etc). La/s estructura/s necesaria para este punto es libre y queda a
criterio del alumno*/


create Trigger tr_Auditoria
on Productos
After Insert, update, delete
as
begin
----------------------si no existe en la deleted entonces es un insert------------------------------------------
if not exists (select * from deleted)
begin
insert into Auditoria select convert(varchar(30), SERVERPROPERTY('MachineName')), CURRENT_USER, getdate(),null, i.descripcion, null, i.precioGramo from inserted i
end
----------------------si no existe en la inserted entonces es un delete------------------------------------------
else if not exists (select * from inserted)
begin
insert into Auditoria select convert(varchar(30), SERVERPROPERTY('MachineName')), CURRENT_USER, getdate(),d.descripcion, null, d.precioGramo, null from deleted d
end
----------------------si no es ni un inserted ni un deleted entonces es un update--------------------------------
else
begin
insert into Auditoria select convert(varchar(30), SERVERPROPERTY('MachineName')), CURRENT_USER, getdate(),d.descripcion, i.descripcion, d.precioGramo, i.precioGramo from inserted i, deleted d
end
end



/*Controlar que no se pueda dar de alta un mantenimiento cuya fecha-hora es menor que la
fecha de nacimiento de la planta
*/

CREATE TRIGGER tr_AltaMantenimiento
ON Mantenimiento
INSTEAD OF INSERT 
AS
BEGIN

	insert into Mantenimiento select i.idPlanta, i.fecha_hora, i.descripcion from inserted i, planta p
	where i.idPlanta = p.id
	and i.fecha_hora > p.fecha_nacimiento
	 
END




-----------------------------------RNE-------------------------------------------------


--Si la altura de la Planta está registrada la fecha de medición de la misma no puede ser menor ni nula que la de nacimiento.



CREATE TRIGGER tr_PlantaAltura
ON Planta
INSTEAD OF INSERT
AS
BEGIN

	insert into Planta select i.nombre, i.fecha_nacimiento, i.fecha_ultima_medida, i.altura, i.precio from inserted i 
	where i.fecha_nacimiento < i.fecha_ultima_medida 
	and i.altura is not null

	insert into Planta select i.nombre, i.fecha_nacimiento,null,null,i.precio from inserted i 
	where i.altura is null

END



--Al realizar un insert en la tabla MantenimientoOperativo, asegurar que el id_mant no exista en la tabla MantenimientoNutrientes
CREATE TRIGGER tr_MantenimientoOperativo
on MantenimientoOperativo
INSTEAD OF INSERT
AS
begin
	
	insert into MantenimientoOperativo select i.id_mant, i.cantidad_horas, i.costo
	from inserted i
	where i.id_mant not in(select mn.id_mant 
							from MantenimientoNutrientes MN)


end

--Al realizar un insert en la tabla MantenimientoNutrientes, asegurar que el id_mant no exista en la tabla MantenimientoOperativo
CREATE TRIGGER tr_MantenimientoNutrientes
on MantenimientoNutrientes
INSTEAD OF INSERT
AS
begin
	
	insert into MantenimientoNutrientes select i.id_mant
	from inserted i
	where i.id_mant not in(select mo.id_mant 
							from MantenimientoOperativo MO)


end



-------------------------------------------------THE END-------------------------------------------------------------------

--CREDITOS:

--David Las
--Diego Machado
--Francesco Lattuada