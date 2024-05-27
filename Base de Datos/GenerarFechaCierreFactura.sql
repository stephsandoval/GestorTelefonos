ALTER FUNCTION dbo.GenerarFechaCierreFactura (@inFecha DATE)
RETURNS DATE
AS
BEGIN

	-- DECLARAR VARIABLES:

    DECLARE @esBisiesto BIT;

	DECLARE @dia INT;
	DECLARE @mes INT;
	DECLARE @year INT;

	DECLARE @nuevoDia INT;
    DECLARE @nuevaFecha DATE;

	-- INICIALIZAR VARIABLES:

    SELECT @esBisiesto = dbo.EsBisiesto(@inFecha);
	SELECT @dia = DAY(@inFecha);
	SELECT @mes = MONTH(@inFecha);
	SELECT @year = YEAR(@inFecha); 

	-- DETERMINAR EL DIA DE LA NUEVA FECHA:
	IF (@esBisiesto = 0 AND @mes = 1 AND @dia IN (29, 30, 31))
	BEGIN
		SET @nuevoDia = 28;
	END
	ELSE IF (@esBisiesto = 1 AND @mes = 1 AND @dia IN (30, 31))
	BEGIN
		SET @nuevoDia = 29;
	END
	ELSE IF (@dia = 31 AND @mes IN (4, 6, 9, 11))
	BEGIN
		SET @nuevoDia = 30;
	END
	ELSE
	BEGIN
		SET @nuevoDia = @dia;
	END

	-- CREAR LA NUEVA FECHA:
	SET @nuevaFecha = DATEFROMPARTS(YEAR(DATEADD(MONTH, 1, @inFecha)), MONTH(DATEADD(MONTH, 1, @inFecha)), @nuevoDia);

    RETURN @nuevaFecha;
END;
