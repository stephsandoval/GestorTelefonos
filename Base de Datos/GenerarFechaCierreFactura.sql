ALTER FUNCTION dbo.GenerarFechaCierreFactura (@inFecha DATE, @inIDContrato INT)
RETURNS DATE
AS
BEGIN

	-- DECLARAR VARIABLES:

    DECLARE @diferenciaMeses INT;
	DECLARE @fechaContrato DATE;
	DECLARE @nuevaFecha DATE;

	-- INICIALIZAR VARIABLES:

	SELECT @fechaContrato = C.FechaContrato
	FROM dbo.Contrato C
	WHERE C.ID = @inIDContrato

    SET @diferenciaMeses = DATEDIFF(MONTH, @fechaContrato, @inFecha) + 1;

	-- CREAR LA NUEVA FECHA:
	SET @nuevaFecha = DATEADD(MONTH, @diferenciaMeses, @fechaContrato);

    RETURN @nuevaFecha;
END;
