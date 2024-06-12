-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Funcion escalar:
-- GENERA LA FECHA DE CIERRE DE UNA FACTURA

-- Descripcion general:
-- Al generar una nueva entrada para la tabla de facturas,
-- a cada una se le debe colocar una fecha de cierre
-- Esta se basa en la fecha en la que se abre el contrato del cliente

-- Descripcion de parametros:
	-- @inFecha: fecha en que se ejecuta la operacion
	-- @inIDContrato: contrato del que se quiere generar la fecha de cierre

-- Ejemplo de ejecucion:
	-- SELECT dbo.GenerarFechaCierreFactura ('yyyy-mm-dd', 0)

-- ************************************************************* --

ALTER FUNCTION dbo.GenerarFechaCierreFactura (@inFecha DATE, @inIDContrato INT)
RETURNS DATE
AS
BEGIN

	-- ----------------------------------------------------- --
	-- DECLARAR VARIABLES

    DECLARE @diferenciaMeses INT;
	DECLARE @fechaContrato DATE;
	DECLARE @nuevaFecha DATE;

	-- ----------------------------------------------------- --
	-- INICIALIZAR VARIABLES

	SELECT @fechaContrato = C.FechaContrato
	FROM dbo.Contrato C
	WHERE C.ID = @inIDContrato

    SET @diferenciaMeses = DATEDIFF(MONTH, @fechaContrato, @inFecha) + 1;

	-- ----------------------------------------------------- --
	-- CREAR LA NUEVA FECHA
	SET @nuevaFecha = DATEADD(MONTH, @diferenciaMeses, @fechaContrato);

    RETURN @nuevaFecha;
END;

-- ************************************************************* --
-- fin de la funcion para generar la fecha de cierre