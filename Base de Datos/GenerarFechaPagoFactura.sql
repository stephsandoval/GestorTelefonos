-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Funcion escalar:
-- GENERA LA FECHA DE PAGO DE UNA FACTURA

-- Descripcion general:
-- Al generar una nueva entrada para la tabla de facturas,
-- a cada una se le debe colocar una fecha de pago
-- Esta se basa en la fecha en la que se abre el contrato del cliente
-- y en la cantidad de dias de gracia de la tarifa

-- Descripcion de parametros:
	-- @inFecha: fecha en que se ejecuta la operacion
	-- @inIDContrato: contrato del que se quiere generar la fecha de cierre

-- Ejemplo de ejecucion:
	-- SELECT dbo.GenerarFechaPagoFactura ('yyyy-mm-dd', 0)

-- ************************************************************* --

ALTER FUNCTION dbo.GenerarFechaPagoFactura (@inFecha DATE, @inIDContrato INT)
RETURNS DATE
AS
BEGIN

	-- ----------------------------------------------------- --
	-- DECLARAR VARIABLES

	DECLARE @tipoTarifa INT;
    DECLARE @cantidadDiasGracia INT;
	DECLARE @nuevaFecha DATE;

	-- ----------------------------------------------------- --
	-- INICIALIZAR VARIABLES

	SET @cantidadDiasGracia = 0;

	SELECT @cantidadDiasGracia = Valor
	FROM ElementoDeTipoTarifa ETT
	INNER JOIN TipoTarifa T ON ETT.IDTipoTarifa = T.ID
	INNER JOIN Contrato C ON T.ID = C.IDTipoTarifa
	WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 7

	-- ----------------------------------------------------- --
	-- CREAR LA NUEVA FECHA

	SET @nuevaFecha = DATEADD(DAY, @cantidadDiasGracia, @inFecha);
	SET @nuevaFecha = DATEADD(MONTH, 1, @nuevaFecha);

    RETURN @nuevaFecha;
END;

-- ************************************************************* --
-- fin de la funcion para generar la fecha de pago