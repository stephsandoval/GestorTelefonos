ALTER PROCEDURE dbo.ProcesarLlamadasNoLocales
	  @inFechaOperacion DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		SET @outResultCode = 0;

	SELECT @outResultCode AS outResultCode;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tProcesarTelefonos;

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