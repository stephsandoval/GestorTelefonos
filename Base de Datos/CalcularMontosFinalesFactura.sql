-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Funcion tabular:
-- CALCULA LOS MONTOS FINALES DE UNA FACTURA

-- Descripcion general:
-- cuando se cierra una factura, se deben actualizar varios campos
-- entre ellos: valor antes del IVA, valor despues del IVA y total
-- esta funcion se encarga de determinar dichos valores para un contrato especifico
-- se utiliza la fecha para delimitar la factura que esta abierta actualmente

-- Descripcion de parametros:
	-- @inIDContrato: contrato para el que se calculan los montos
	-- @inFechaOperacion: fecha en la cual se esta ejecutando el procedimiento

-- Ejemplo de ejecucion:
	-- SELECT dbo.CalcularMontosFinalesFactura (0, 'yyyy-mm-dd)

-- Notas adicionales:
-- esta funcion se apoya de otras dos para calcular algunos montos
-- las otras funciones se encargan de:
	-- 1. determinar el monto sobre tarifa base por llamadas
	-- 2. determinar el monto sobre tarifa base por uso de datos

-- una factura tiene asociado un monto por facturas pendientes no pagadas
-- ese monto no se calcula ni se retorna en esta funcion
-- de dicho calculo se encarga un procedimiento aparte

-- ************************************************************* --

ALTER FUNCTION dbo.CalcularMontosFinalesFactura (
	  @inIDContrato INT                                          -- contrato para el que se calculan montos
	, @inFechaOperacion DATE                                     -- fecha en que se ejecuta la funcion
)
RETURNS @MontoFactura TABLE (
	  MontoAntesIVA MONEY
	, MontoDespuesIVA MONEY
	, MontoTotal MONEY
)
AS
BEGIN

	-- ------------------------------------------------------------- --
	-- DECLARAR VARIABLES

	DECLARE @montoAntesIVA MONEY;
	DECLARE @montoLlamadas MONEY;
	DECLARE @montoDatos MONEY;

	DECLARE @IDFactura INT;
	DECLARE @IDDetalle INT;

	DECLARE @porcentajeIVA FLOAT;
	DECLARE @montoDespuesIVA MONEY;

	-- ------------------------------------------------------------- --
	-- INICIALIZAR VARIABLES

	-- obtener datos generales
	SELECT @IDFactura = F.ID
	FROM Factura F
	WHERE F.IDContrato = @inIDContrato AND F.FechaFactura = @inFechaOperacion;

	SELECT @IDDetalle = D.ID
	FROM dbo.Detalle D
	WHERE D.IDFactura = @IDFactura

	-- calcular el monto antes de aplicar IVA
	SELECT @montoAntesIVA = F.TotalAntesIVA 
	FROM Factura F
	WHERE F.IDContrato = @inIDContrato

	-- ---------------------------------------- --
	-- calcular montos de la factura

	-- monto por llamadas
	SELECT @montoLlamadas = dbo.CalcularMontoLlamadas (@inIDContrato, @inFechaOperacion)

	-- monto por uso de datos
	SELECT @montoDatos = dbo.CalcularMontoUsoDatos (@inIDContrato, @inFechaOperacion)

	-- nuevo monto antes de aplicar el IVA
	SET @montoAntesIVA = @montoAntesIVA + @montoLlamadas + @montoDatos

	-- ---------------------------------------- --
	-- calcular el monto despues de aplicar IVA

	SELECT @porcentajeIVA = ETT.Valor
	FROM dbo.ElementoDeTipoTarifa ETT
	INNER JOIN dbo.Contrato C ON C.ID = @inIDContrato
	WHERE C.IDTipoTarifa = ETT.IDTipoTarifa AND ETT.IDTipoElemento = 12

	SET @porcentajeIVA = (@porcentajeIVA + 100) / 100
	SET @montoDespuesIVA = @montoAntesIVA * @porcentajeIVA

	-- ---------------------------------------- --
	-- INSERTAR DATOS EN TABLA DE RETORNO

	INSERT INTO @MontoFactura (
		  MontoAntesIVA
		, MontoDespuesIVA
		, MontoTotal
	)
	VALUES (@montoAntesIVA
		, @montoDespuesIVA
		, @montoDespuesIVA
	)

	RETURN;
END;

-- ************************************************************* --
-- fin de la funcion para calcular los montos finales