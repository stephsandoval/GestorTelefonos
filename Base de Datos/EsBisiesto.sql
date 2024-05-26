ALTER FUNCTION dbo.EsBisiesto(@inFecha DATE)
RETURNS BIT
AS
BEGIN
    DECLARE @Year INT = YEAR(@inFecha);
    DECLARE @EsBisiesto BIT;

    IF (@Year % 4 = 0 AND @Year % 100 != 0) OR (@Year % 400 = 0)
        SET @EsBisiesto = 1;
    ELSE
        SET @EsBisiesto = 0;

    RETURN @EsBisiesto;
END;