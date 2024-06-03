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

		DECLARE @OperadorApertura TABLE (
			  IDOperador INT
			, Nombre VARCHAR(16)
		)

		DECLARE @OperadorCierre TABLE (
			  IDOperador INT
			, CantidadMinutosEntrantes INT
			, CantidadMinutosSalientes INT
		)

		DECLARE @NuevoEstadoCuenta TABLE (
			  IDEstadoCuenta INT
		)

		INSERT INTO @OperadorApertura (IDOperador, Nombre)
		SELECT O.ID, O.Nombre
		FROM dbo.Operador O

		IF EXISTS (SELECT 1 FROM dbo.EstadoCuenta)
		BEGIN
			INSERT INTO @OperadorCierre (
				  IDOperador
				, CantidadMinutosEntrantes
				, CantidadMinutosSalientes
			)
			SELECT 
				  O.ID
				, ISNULL(SUM(TEC.CantidadMinutosEntrantes), 0)
				, ISNULL(SUM(TEC.CantidadMinutosSalientes), 0)
			FROM dbo.Operador O
			INNER JOIN dbo.EstadoCuenta EC ON EC.IDOperador = O.ID
			INNER JOIN dbo.DetalleEstadoCuenta DE ON DE.IDEstadoCuenta = EC.ID
			INNER JOIN dbo.TelefonoEstadoCuenta TEC ON TEC.IDDetalleEstadoCuenta = DE.ID
			WHERE EC.FechaCierre = @inFechaOperacion
			GROUP BY O.ID;
		END

		BEGIN TRANSACTION tAbrirCerrarEstadoCuenta

			UPDATE EC
			SET
				  TotalMinutosEntrantes = OC.CantidadMinutosEntrantes
				, TotalMinutosSalientes = OC.CantidadMinutosSalientes
				, EstaCerrado = 1
			FROM dbo.EstadoCuenta EC
			INNER JOIN @OperadorCierre OC ON OC.IDOperador = EC.IDOperador
			WHERE EC.FechaCierre = @inFechaOperacion

			INSERT INTO dbo.EstadoCuenta (
				  IDOperador
				, TotalMinutosEntrantes
				, TotalMinutosSalientes
				, FechaApertura
				, FechaCierre
				, EstaCerrado
			)
			OUTPUT INSERTED.ID INTO @NuevoEstadoCuenta (IDEstadoCuenta)
			SELECT OA.IDOperador
				, 0
				, 0
				, @inFechaOperacion
				, DATEADD(MONTH, 1, @inFechaOperacion)
				, 0
			FROM @OperadorApertura OA

			INSERT INTO dbo.DetalleEstadoCuenta (
				  IDEstadoCuenta
			)
			SELECT NEC.IDEstadoCuenta
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