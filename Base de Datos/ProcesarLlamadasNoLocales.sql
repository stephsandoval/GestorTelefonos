ALTER PROCEDURE dbo.ProcesarLlamadasNoLocales
	  @inFechaOperacion DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @LlamadaRegistrada TABLE (
			  IDLlamadaInput INT
			, NumeroDesde VARCHAR(16)
			, NumeroA VARCHAR(16)
			, CantidadMinutos INT
		);

		DECLARE @LlamadaSalida TABLE (
			  IDLlamadaInput INT
			, IDTelefono INT
			, CantidadMinutos INT
		);

		DECLARE @LlamadaEntrada TABLE (
			  IDLlamadaInput INT
			, IDTelefono INT
			, CantidadMinutos INT
		);

		SET @outResultCode = 0;

		INSERT INTO @LlamadaRegistrada (
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
		WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
			AND dbo.ObtenerOperador(LI.NumeroDesde) != dbo.ObtenerOperador(LI.NumeroA);

		INSERT INTO @LlamadaSalida (
			  IDLlamadaInput
			, IDTelefono
			, CantidadMinutos
		)
		SELECT
			  LR.IDLlamadaInput
			, TEC.ID
			, LR.CantidadMinutos
		FROM @LlamadaRegistrada LR
		INNER JOIN dbo.TelefonoEstadoCuenta TEC ON TEC.NumeroTelefono = LR.NumeroDesde

		INSERT INTO @LlamadaEntrada (
			  IDLlamadaInput
			, IDTelefono
			, CantidadMinutos
		)
		SELECT
			  LR.IDLlamadaInput
			, TEC.ID
			, LR.CantidadMinutos
		FROM @LlamadaRegistrada LR
		INNER JOIN dbo.TelefonoEstadoCuenta TEC ON TEC.NumeroTelefono = LR.NumeroA

		BEGIN TRANSACTION tProcesarLlamadasNoLocales

			INSERT INTO dbo.LlamadaNoLocal (
				  IDLlamadaInput
				, IDTelefonoEstadoCuenta
				, IDTipoLlamada
				, CantidadMinutos
			)
			SELECT 
				  LE.IDLlamadaInput
				, LE.IDTelefono 
				, 1
				, LE.CantidadMinutos
			FROM @LlamadaEntrada LE
			ORDER BY LE.IDLlamadaInput

			INSERT INTO dbo.LlamadaNoLocal (
				  IDLlamadaInput
				, IDTelefonoEstadoCuenta
				, IDTipoLlamada
				, CantidadMinutos
			)
			SELECT 
				  LS.IDLlamadaInput
				, LS.IDTelefono 
				, 2
				, LS.CantidadMinutos
			FROM @LlamadaSalida LS
			ORDER BY LS.IDLlamadaInput

		COMMIT TRANSACTION tProcesarLlamadasNoLocales

	SELECT @outResultCode AS outResultCode;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tProcesarLlamadasNoLocales;

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