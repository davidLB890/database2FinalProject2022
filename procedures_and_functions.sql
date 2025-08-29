use [pflanze]


/*Implementar un procedimiento AumentarCostosPlanta que reciba por parámetro: un Id de
Planta, un porcentaje y un rango de fechas. El procedimiento debe aumentar en el
porcentaje dado, para esa planta, los costos de mantenimiento que se dieron en ese rango
de fechas. Esto tanto para mantenimientos de tipo “OPERATIVO” donde se aumenta el
costo por concepto de mano de obra (no se aumentan las horas, solo el costo) como de
tipo “NUTRIENTES” donde se debe aumentar los costos por concepto de uso de producto
(no se debe aumentar ni los gramos de producto usado ni actualizar nada del maestro de
productos)
El procedimiento debe retornar cuanto fue el aumento total de costo en dólares para la
planta en cuestión.*/
create procedure AumentarCostosPlanta
@idPlan int,
@porcentaje int,
@fecha1 date,
@fecha2 date,

@aumento money output
	as
	begin
		declare @aumentoN money, @aumentoM money
		set @aumento = 0

		select @aumentoN = SUM([dbo].[CalcularSumNutrientes](MN.id_mant))
		from MantenimientoNutrientes MN, Mantenimiento M
		where @idPlan = M.idPlanta
		and MN.id_mant = M.idMant
		and m.fecha_hora between @fecha1 and @fecha2

		---------------------------------------------------

		select @aumentoM = (@aumento + SUM(MO.costo)) * @porcentaje/100
		from MantenimientoOperativo MO, Mantenimiento M2
		where @idPlan = M2.idPlanta 
		and MO.id_mant = M2.idMant
		and m2.fecha_hora between @fecha1 and @fecha2

		IF(@aumentoN is not null)
			BEGIN 
			set @aumento = @aumento + @aumentoN 
			END
		IF(@aumentoM is not null)
			BEGIN
			set @aumento = @aumento + @aumentoM
			END
		---------------------------------------------------
		update MantenimientoOperativo set costo = costo + costo * @porcentaje/100
		from Mantenimiento m, MantenimientoOperativo mo
		where m.idMant = mo.id_mant
		and m.idPlanta = @idPlan
		and m.fecha_hora between @fecha1 and @fecha2

		update Mantemiento_Producto set CostoAplicacion = CostoAplicacion + CostoAplicacion * @porcentaje/100 
		from Mantenimiento m, Mantemiento_Producto mp
		where m.idMant = mp.Id_mantenimiento
		and m.idPlanta = @idPlan
		and m.fecha_hora between @fecha1 and @fecha2


		
	end

	declare @plata money
	EXEC [dbo].[AumentarCostosPlanta] 1,50,'10/04/2020','10/04/2022', @plata OUTPUT
	print 'El aumento fué de: ' + convert(varchar(5000), @plata)



/*Mediante una función que recibe como parámetro un año: retornar el costo promedio de
los mantenimientos de tipo “OPERATIVO” de ese año*/

create FUNCTION [dbo].[CalcPromedioOperativo](@anio int) returns decimal
AS
BEGIN
	Declare @avg decimal;
	Select @avg = AVG(MO.costo) 
	from MantenimientoOperativo MO, Mantenimiento M 
	where M.idMant = MO.id_mant and year(m.fecha_hora) = @anio
	RETURN @avg
END

--Ejemplo ejecion [dbo].[CalcPromedioOperativo](@anio int)
declare @datoanio int
declare @avguwu decimal
set @datoanio = 2022
--229331
set @avguwu = [dbo].[CalcPromedioOperativo](@datoanio);

PRINT 'AVERAGE: ' + convert(varchar(200), @avguwu);
---------------------------------------------------------------------------


--Esta function calcula la suma de los mantenimientos nutrientes filtrando segun el id de planta pasado en la firma.
--el proposito de esta function es ser llamada por otra function mas abajo "calcularSumaMant(@idPlanta int, @anio int)".
CREATE FUNCTION CalcularSumNutrientes(@idMantNutriente int) returns decimal
AS
BEGIN
DECLARE @suma decimal

	IF EXISTS(SELECT * FROM MantenimientoNutrientes where id_mant = @idMantNutriente)
	BEGIN 
		SET @SUMA = ((select SUM(precioGramo) 
						from Productos P, Mantemiento_Producto PM 
							where  @idMantNutriente = PM.Id_mantenimiento and 
							P.codigo = PM.Id_producto) * 
										(select SUM(pm.cantidadGramos)
											from Mantemiento_Producto pm
											where @idMantNutriente = pm.Id_mantenimiento)) + 
														(select SUM(CostoAplicacion) 
															FROM Mantemiento_Producto pm 
															where pm.Id_mantenimiento = @idMantNutriente)
	END
	RETURN @SUMA

END
declare @sumaa decimal;
set @sumaa = [dbo].[CalcularSumNutrientes](10)
print convert(varchar(60), @sumaa);





--Esta funcion retorna la suma de todos los mantenimientos segun el id de planta, tambien recibe como firma un año, lo cual significa
--que va a retornar la suma de todos los matenimientos que correspondan a dicho año.
--Permitimos que @anio reciba un valor null.

--Esta funcion se utiliza en las consultas 2.C, y 2.F


--ATENCION, PARA USAR ESTA FUNCTION, HAY QUE EJECUTAR EL CREATE FUNCTION [CalcularSumNutrientes]().

create function calcularSumaMant(@idPlanta int, @anio int) returns decimal
AS
BEGIN
DECLARE @SUMA decimal;
DECLARE @sumaOpe decimal;
DECLARE @sumaNu decimal;


	IF EXISTS(select * from Mantenimiento M where M.idPlanta = @idPlanta)
	BEGIN
	set @SUMA = 0;
	IF(@anio is not null)
		BEGIN
		set @sumaOpe = (Select SUM(MO.costo)
						from MantenimientoOperativo MO, Mantenimiento M 
						where M.idPlanta = @idPlanta and
						M.idMant = MO.id_mant and
						year(M.fecha_hora) = @anio)

		set @sumaNu = (Select SUM([dbo].[CalcularSumNutrientes](MN.id_mant))
							from MantenimientoNutrientes MN, Mantenimiento M2
							where M2.idPlanta = @idPlanta and
							M2.idMant = MN.id_mant and
							year(M2.fecha_hora) = @anio)
		END
	IF(@anio is null)
		BEGIN 
		set @sumaOpe = (Select SUM(MO.costo)
						from MantenimientoOperativo MO, Mantenimiento M 
						where M.idPlanta = @idPlanta and
						M.idMant = MO.id_mant)

		set @sumaNu = (Select SUM([dbo].[CalcularSumNutrientes](MN.id_mant))
							from MantenimientoNutrientes MN, Mantenimiento M2
							where M2.idPlanta = @idPlanta and
							M2.idMant = MN.id_mant)

		end

			IF(@sumaOpe is not null)
				BEGIN set @SUMA = @SUMA + @sumaOpe END
			IF(@sumaNu is not null)
				BEGIN set @SUMA = @SUMA + @sumaNu END

	END
	return @suma
END

declare @idPlant int
declare @sumaaa decimal

set @idPlant = 2;
set @sumaaa = [dbo].[calcularSumaMant](@idPlant, null)

print 'suma: ' + convert(varchar(100), @sumaaa)

declare @num int
set @num = 500;
set @num = @num + null

print convert(varchar(50),@num);


--NADA MAS PARA MIRAR, ABAJO HAY OTRAS VERSIONES.---------------------------------------


--Creamos un procedure para cargar la columna precio de la tabla MantenimientoOperativo.
--create PROCEDURE AgregarCostoMantenimientoNutrientes
--AS
--BEGIN
--	IF EXISTS (select * from MantenimientoNutrientes)
		
--		BEGIN
--		update MantenimientoNutrientes
--		set precio = (select SUM(precioGramo) 
--						from Productos P, Mantemiento_Producto PM 
--							where  id_mant = PM.Id_mantenimiento and 
--							P.codigo = PM.Id_producto) * (select SUM(pm.cantidadGramos)
--															from Mantemiento_Producto pm
--																where id_mant = pm.Id_mantenimiento)
--		END
--END

--Ejecutamos el procedure
--EXEC AgregarCostoMantenimientoNutrientes