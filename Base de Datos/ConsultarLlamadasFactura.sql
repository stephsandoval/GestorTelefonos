-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- CONSULTA LAS LLAMADAS DE UNA FACTURA ESPECIFICA

-- Descripcion general:
-- Desde la aplicación web, un funcionario debe poder consultar
-- las facturas de un numero en especifico
-- Ademas, para cada factura debe poder consultar su detalle
-- Este consiste en varios aspectos:
	-- informacion de llamadas
	-- informacion de uso de datos

-- En este sp, se considera la informacion relacionada a las llamadas

-- Descripcion de parametros:
	-- @inNumeroTelefono: numero de telefono que se desea consultar
	-- @inFechaFactura: fecha en la que cierra la factura
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ConsultarLlamadasFactura '88888888', 'yyyy-mm'dd', @outResultCode OUTPUT

-- ************************************************************* --

ALTER PROCEDURE dbo.ConsultarLlamadasFactura
	  @inNumeroTelefono VARCHAR(16)                              -- numero que se desea consultar
	, @inFechaFactura DATE                                       -- fecha de cierre de la factura
	, @outResultCode INT OUTPUT                                  -- resultado de ejecucion del codigo
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

		-- ----------------------------------------------------- --
		-- DECLARAR VARIABLES

        DECLARE @IDDetalle INT;

		-- tabla para almacenar las llamadas del usuario
		DECLARE @LlamadaRegistrada TABLE (
			  Fecha DATE
			, HoraInicio TIME
			, HoraFin TIME
			, NumeroA VARCHAR(16)
			, CantidadMinutos INT
			, EsGratis BIT
		)

		-- ----------------------------------------------------- --
		-- INICIALIZAR VARIABLES

		SELECT @IDDetalle = D.ID
		FROM dbo.Detalle D
		INNER JOIN dbo.Factura F ON F.ID = D.IDFactura
		INNER JOIN dbo.Contrato C ON C.ID = F.IDContrato
		WHERE C.NumeroTelefono = @inNumeroTelefono AND F.FechaFactura = @inFechaFactura;

		-- ----------------------------------------------------- --
		-- OBTENER LAS LLAMADAS DEL USUARIO

		-- insertar las llamadas catalogadas como locales
		INSERT INTO @LlamadaRegistrada (
			  Fecha
			, HoraInicio
			, HoraFin
			, NumeroA
			, CantidadMinutos
			, EsGratis
		)
		SELECT CONVERT(DATE, LI.HoraInicio)
			, CONVERT(TIME, LI.HoraInicio)
			, CONVERT(TIME, LI.HoraFin)
			, LI.NumeroA
			, LL.CantidadMinutos
			, CASE
				WHEN LI.NumeroA = @inNumeroTelefono THEN 0
				WHEN LI.NumeroDesde = @inNumeroTelefono AND (LI.NumeroA NOT LIKE '800%' AND LEN(LI.NumeroA) = 11) THEN 0
				ELSE LL.EsGratis
			  END
		FROM dbo.LlamadaLocal LL
		INNER JOIN dbo.LlamadaInput LI ON LI.ID = LL.IDLlamadaInput
		WHERE LL.IDDetalle = @IDDetalle;

		-- insertar las otras llamadas: de cobro fijo
		INSERT INTO @LlamadaRegistrada (
			  Fecha
			, HoraInicio
			, HoraFin
			, NumeroA
			, CantidadMinutos
			, EsGratis
		)
		SELECT CONVERT(DATE, LI.HoraInicio)
			, CONVERT(TIME, LI.HoraInicio)
			, CONVERT(TIME, LI.HoraFin)
			, LI.NumeroA
			, DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)
			, 0
		FROM dbo.LlamadaInput LI
		WHERE LI.NumeroDesde = @inNumeroTelefono
			AND (LI.NumeroA = '911' OR LI.NumeroA = '110' OR LI.NumeroA LIKE '900%')
			AND (DATEDIFF(MONTH, CONVERT(DATE, LI.HoraInicio), @inFechaFactura) < 2
				AND LI.HoraInicio < @inFechaFactura)

		-- ----------------------------------------------------- --
		-- RETORNAR RESULTADOS

		SELECT @outResultCode AS outResultCode

		SELECT LR.Fecha AS 'Fecha'
			, CONVERT(TIME(3), LR.HoraInicio) AS 'Hora de inicio'
			, CONVERT(TIME(3), LR.HoraFin) AS 'Hora de fin'
			, LR.CantidadMinutos AS 'Duracion'
			, LR.NumeroA AS 'Numero destino'
			, CASE
				WHEN LR.EsGratis = 1 THEN 'Gratis'
				ELSE 'A cobro'
			  END AS 'Condicion cobro'
		FROM @LlamadaRegistrada LR
		ORDER BY LR.Fecha

    END TRY
    BEGIN CATCH

        INSERT INTO ErrorBaseDatos VALUES (
			  SUSER_SNAME()
			, ERROR_NUMBER()
			, ERROR_STATE()
			, ERROR_SEVERITY()
			, ERROR_LINE()
			, ERROR_PROCEDURE()
			, ERROR_MESSAGE()
			, GETDATE()
		);

        SET @outResultCode = 50008;
        SELECT @outResultCode AS outResultCode;

    END CATCH;
    SET NOCOUNT OFF;
END;

-- ************************************************************* --
-- fin del SP para consultar las llamadas de una factura