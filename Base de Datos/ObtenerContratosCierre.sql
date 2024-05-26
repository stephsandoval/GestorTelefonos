CREATE FUNCTION dbo.ObtenerContratosCierre (@inFecha DATE)
RETURNS @ContratoCierre TABLE (
    IDContrato INT
)
AS
BEGIN

	-- DECLARAR VARIABLES:

    DECLARE @esBisiesto BIT;
	DECLARE @dia INT;
	DECLARE @mes INT;
	DECLARE @year INT;

	-- INICIALIZAR VARIABLES:

    SELECT @esBisiesto = dbo.EsBisiesto(@inFecha);
	SELECT @dia = DAY(@inFecha);
	SELECT @mes = MONTH(@inFecha);
	SELECT @year = YEAR(@inFecha);

	-- DETERMINAR LOS CONTRATOS QUE CIERRAN:

	-- el 28 de febrero de anno no bisiesto cierran 28, 29, 30, 31 del mes previo
	IF (@dia = 28 AND @mes = 2 AND @esBisiesto = 0)
    BEGIN
        INSERT INTO @ContratoCierre (IDContrato)
        SELECT C.ID
        FROM dbo.Contrato C
        WHERE ((DAY(C.FechaContrato) = 28 AND MONTH(C.FechaContrato) = 1)
            OR (DAY(C.FechaContrato) = 29 AND MONTH(C.FechaContrato) = 1)
            OR (DAY(C.FechaContrato) = 30 AND MONTH(C.FechaContrato) = 1)
            OR (DAY(C.FechaContrato) = 31 AND MONTH(C.FechaContrato) = 1));
    END
	-- el 29 de febrero de anno bisiesto cierran 29, 30, 31 del previo
	ELSE IF (@dia = 29 AND @mes = 2 AND @esBisiesto = 1)
    BEGIN
        INSERT INTO @ContratoCierre (IDContrato)
        SELECT C.ID
        FROM dbo.Contrato C
        WHERE ((DAY(C.FechaContrato) = 29 AND MONTH(C.FechaContrato) = 1)
            OR (DAY(C.FechaContrato) = 30 AND MONTH(C.FechaContrato) = 1)
            OR (DAY(C.FechaContrato) = 31 AND MONTH(C.FechaContrato) = 1));
    END
	-- el 30 de cada mes cierran el 30 y 31 del mes anterior
	ELSE IF (@dia = 30)
    BEGIN
        INSERT INTO @ContratoCierre (IDContrato)
        SELECT C.ID
        FROM dbo.Contrato C
        WHERE ((DAY(C.FechaContrato) = 30 AND MONTH(C.FechaContrato) = MONTH(DATEADD(MONTH, -1, @inFecha)))
            OR (DAY(C.FechaContrato) = 31 AND MONTH(C.FechaContrato) = MONTH(DATEADD(MONTH, -1, @inFecha))));
    END
	-- para los demas dias, se cierran facturas de contratos que abieron ese mismo dia
	ELSE
	BEGIN
		INSERT INTO @ContratoCierre (IDContrato)
		SELECT C.ID
		FROM dbo.Contrato C
		WHERE ((DAY(C.FechaContrato) = @dia AND MONTH(C.FechaContrato) = MONTH(DATEADD(MONTH, -1, @inFecha))));
	END

    RETURN;
END;
