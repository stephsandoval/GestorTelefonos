ALTER PROCEDURE dbo.ProcesarLlamadaNoLocal
	  @inFechaOperacion DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @LlamadaEntranteTelefonoRegistrado TABLE (
			  IDLlamadaInput INT
			, NumeroDesde VARCHAR(16)
			, NumeroA VARCHAR(16)
			, CantidadMinutos INT
		)

		DECLARE @LlamadaEntranteTelefonoNoRegistrado TABLE (
			  IDLlamadaInput INT
			, NumeroDesde VARCHAR(16)
			, NumeroA VARCHAR(16)
			, CantidadMinutos INT
		)

		DECLARE @LlamadaNoLocalV TABLE (
			  IDTelefonoEC INT
			, IDLlamadaInput INT
			, IDTipoLlamada INT
			, CantidadMinutos INT
		)

		SET @outResultCode = 0;

		INSERT INTO @LlamadaEntranteTelefonoRegistrado (
			  IDLlamadaInput
			, NumeroDesde
			, NumeroA
			, CantidadMinutos
		)
		SELECT LI.ID
			, LI.NumeroDesde
			, LI.NumeroA
			, DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)
		FROM dbo.LlamadaInput LI
		WHERE ((LI.NumeroDesde LIKE '6%' OR LI.NumeroDesde LIKE '7%')
			OR (LI.NumeroA LIKE '6%' OR LI.NumeroA LIKE '7%'))
			AND (LI.NumeroA != '911' AND LI.NumeroA != '110')
			AND CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
			AND EXISTS (SELECT 1 FROM dbo.TelefonoEstadoCuenta TEC WHERE TEC.NumeroTelefono = LI.NumeroDesde);

		INSERT INTO @LlamadaEntranteTelefonoNoRegistrado (
			  IDLlamadaInput
			, NumeroDesde
			, NumeroA
			, CantidadMinutos
		)
		SELECT LI.ID
			, LI.NumeroDesde
			, LI.NumeroA
			, DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)
		FROM dbo.LlamadaInput LI
		WHERE ((LI.NumeroDesde LIKE '6%' OR LI.NumeroDesde LIKE '7%')
			OR (LI.NumeroA LIKE '6%' OR LI.NumeroA LIKE '7%'))
			AND (LI.NumeroA != '911' AND LI.NumeroA != '110')
			AND CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
			AND NOT EXISTS (SELECT 1 FROM dbo.TelefonoEstadoCuenta TEC WHERE TEC.NumeroTelefono = LI.NumeroDesde);

		SELECT * FROM @LlamadaEntranteTelefonoRegistrado
		SELECT * FROM @LlamadaEntranteTelefonoNoRegistrado

		INSERT INTO dbo.TelefonoEstadoCuenta(
			  IDDetalleEstadoCuenta
			, NumeroTelefono
			, CantidadMinutosEntrantes
			, CantidadMinutosSalientes
		)
		SELECT 
			(SELECT TOP 1 DE.ID
				FROM dbo.DetalleEstadoCuenta DE
				INNER JOIN dbo.EstadoCuenta EC ON DE.IDEstadoCuenta = EC.ID
				INNER JOIN dbo.Operador O ON O.ID = EC.IDOperador
				WHERE EC.FechaCierre > @inFechaOperacion AND SUBSTRING(LETNR.NumeroDesde, 1, 1) = O.DigitoPrefijo)
			, LETNR.NumeroDesde
			, 0
			, SUM(LETNR.CantidadMinutos)
		FROM @LlamadaEntranteTelefonoNoRegistrado LETNR
		GROUP BY LETNR.NumeroDesde

		;WITH AggregatedMinutes AS (
            SELECT NumeroDesde, SUM(CantidadMinutos) AS TotalMinutos
            FROM @LlamadaEntranteTelefonoRegistrado
            GROUP BY NumeroDesde
        )
        UPDATE TEC
        SET CantidadMinutosSalientes = TEC.CantidadMinutosSalientes + AM.TotalMinutos
        FROM dbo.TelefonoEstadoCuenta TEC
        INNER JOIN AggregatedMinutes AM ON AM.NumeroDesde = TEC.NumeroTelefono;

		SELECT @outResultCode AS outResultCode;

	END TRY
	BEGIN CATCH

		-- Error handling
		INSERT INTO ErrorBaseDatos VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
		);

		SET @outResultCode = 50008;
		SELECT @outResultCode AS outResultCode;

	END CATCH;
	SET NOCOUNT OFF;
END;