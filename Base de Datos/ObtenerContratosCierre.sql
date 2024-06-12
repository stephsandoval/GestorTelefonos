-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Funcion tabular:
-- OBTIENE LOS CONTRATOS QUE CIERRAN FACTURA

-- Descripcion general:
-- Por cada dia de operacion, pueden existir contratos que deban cerrar factura
-- La siguiente funcion se encarga de determinar todos esos contratos
-- y retorna el ID de cada uno de ellos en una tabla

-- Descripcion de parametros:
	-- @inFecha: fecha en que se ejecuta la operacion

-- Ejemplo de ejecucion:
	-- SELECT * FROM dbo.ObtenerContratosCierre ('yyyy-mm-dd')

-- ************************************************************* --

ALTER FUNCTION dbo.ObtenerContratosCierre (@inFecha DATE)
RETURNS @ContratoCierre TABLE (
    IDContrato INT
)
AS
BEGIN

	-- ----------------------------------------------------- --
	-- DECLARAR VARIABLES

    DECLARE @esBisiesto BIT;
	DECLARE @dia INT;
	DECLARE @mes INT;
	DECLARE @year INT;

	-- ----------------------------------------------------- --
	-- INICIALIZAR VARIABLES

    SELECT @esBisiesto = dbo.EsBisiesto(@inFecha);
	SELECT @dia = DAY(@inFecha);
	SELECT @mes = MONTH(@inFecha);
	SELECT @year = YEAR(@inFecha);

	-- ----------------------------------------------------- --
	-- DETERMINAR LOS CONTRATOS QUE CIERRAN

	-- el 28 de febrero de anno no bisiesto cierran 28, 29, 30, 31
	IF (@dia = 28 AND @mes = 2 AND @esBisiesto = 0)
    BEGIN
        INSERT INTO @ContratoCierre (IDContrato)
        SELECT C.ID
        FROM dbo.Contrato C
        WHERE DAY(C.FechaContrato) IN (28, 29, 30, 31)
			AND MONTH(C.FechaContrato) != @mes
			AND C.FechaContrato < @inFecha;
    END
	-- el 29 de febrero de anno bisiesto cierran 29, 30, 31
	ELSE IF (@dia = 29 AND @mes = 2 AND @esBisiesto = 1)
    BEGIN
        INSERT INTO @ContratoCierre (IDContrato)
        SELECT C.ID
        FROM dbo.Contrato C
        WHERE DAY(C.FechaContrato) IN (29, 30, 31)
			AND MONTH(C.FechaContrato) != @mes
			AND C.FechaContrato < @inFecha;
    END
	-- el 30 de cada mes cierran el 30 y 31
	ELSE IF (@dia = 30 AND @mes IN (4, 6, 9, 11))
    BEGIN
        INSERT INTO @ContratoCierre (IDContrato)
        SELECT C.ID
        FROM dbo.Contrato C
        WHERE DAY(C.FechaContrato) IN (30, 31)
			AND MONTH(C.FechaContrato) != @mes
			AND C.FechaContrato < @inFecha;
    END
	-- para los demas dias, se cierran facturas de contratos que abieron ese mismo dia
	ELSE
	BEGIN
		INSERT INTO @ContratoCierre (IDContrato)
		SELECT C.ID
		FROM dbo.Contrato C
		WHERE DAY(C.FechaContrato) = @dia
			AND MONTH(C.FechaContrato) != @mes
			AND C.FechaContrato < @inFecha;
	END

    RETURN;
END;

-- ************************************************************* --
-- fin de la funcion para determinar contratos para cierre de factura