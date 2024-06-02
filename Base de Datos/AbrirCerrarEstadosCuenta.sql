ALTER PROCEDURE dbo.AbrirCerrarEstadosCuenta
	  @inFechaOperacion DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		SET @outResultCode = 0

		IF (DAY(@inFechaOperacion) != 5)
		BEGIN
			RETURN;
		END

		DECLARE @operadorApertura TABLE (
			  IDOperador INT
			, Nombre VARCHAR(16)
		)

		DECLARE @operadorCierre TABLE (
			  IDOperador INT
			, Nombre VARCHAR(16)
		)

		DECLARE @NuevoEstadoCuenta TABLE (
			  IDEstadoCuenta INT
		)

		INSERT INTO @operadorApertura (IDOperador, Nombre)
		SELECT O.ID, O.Nombre
		FROM dbo.Operador O
		WHERE O.DigitoPrefijo = 8

		IF EXISTS (SELECT 1 FROM dbo.EstadoCuenta)
		BEGIN
			INSERT INTO @operadorCierre (IDOperador, Nombre)
			SELECT O.ID, O.Nombre
			FROM dbo.Operador O
			WHERE O.DigitoPrefijo = 8
		END

		SELECT * FROM @operadorApertura;
		SELECT * FROM @operadorCierre;

		BEGIN TRANSACTION tAbrirCerrarEstadoCuenta

			UPDATE EC
			SET
				  TotalLlamadasEntrantes = -1
				, TotalLlamadasSalientes = -1
			FROM dbo.EstadoCuenta EC
			WHERE EC.FechaCierre = @inFechaOperacion;

			INSERT INTO dbo.EstadoCuenta (
				  IDOperador
				, TotalLlamadasEntrantes
				, TotalLlamadasSalientes
				, FechaApertura
				, FechaCierre
			)
			OUTPUT INSERTED.ID INTO @NuevoEstadoCuenta (IDEstadoCuenta)
			SELECT OA.IDOperador
				, 0
				, 0
				, @inFechaOperacion
				, DATEADD(MONTH, 1, @inFechaOperacion)
			FROM @operadorApertura OA

			INSERT INTO dbo.DetalleEstadoCuenta (
				  IDEstadoCuenta
				, CantidadMinutos
			)
			SELECT NEC.IDEstadoCuenta
				, 0
			FROM @NuevoEstadoCuenta NEC;

		COMMIT TRANSACTION tAbrirCerrarEstadoCuenta

		SELECT @outResultCode AS outResultCode;

    END TRY
    BEGIN CATCH

		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tAbrirCerrarEstadoCuenta;

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