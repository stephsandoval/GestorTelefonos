ALTER FUNCTION dbo.GenerarFechaPagoFactura (@inFecha DATE, @inIDContrato INT)
RETURNS DATE
AS
BEGIN

	-- DECLARAR VARIABLES:

	DECLARE @tipoTarifa INT;
    DECLARE @cantidadDiasGracia INT;
	DECLARE @nuevaFecha DATE;

	-- INICIALIZAR VARIABLES:

	SET @cantidadDiasGracia = 0;

	SELECT @cantidadDiasGracia = Valor
	FROM ElementoDeTipoTarifa ETT
	INNER JOIN TipoTarifa T ON ETT.IDTipoTarifa = T.ID
	INNER JOIN Contrato C ON T.ID = C.IDTipoTarifa
	WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 7

	-- CREAR LA NUEVA FECHA:

	SET @nuevaFecha = DATEADD(DAY, @cantidadDiasGracia, @inFecha);
	SET @nuevaFecha = DATEADD(MONTH, 1, @nuevaFecha);

    RETURN @nuevaFecha;
END;
