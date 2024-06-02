ALTER PROCEDURE dbo.ProcesarTelefonos
	  @inFechaOperacion DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		SET @outResultCode = 0;

		IF (DAY(@inFechaOperacion) IN (1, 2, 3, 4) AND MONTH(@inFechaOperacion) = 1)
		BEGIN
			RETURN
		END

		DECLARE @totalNumeros INT;
		DECLARE @numeroActual INT;
		DECLARE @minutosEntrantes INT;
		DECLARE @minutosSalientes INT;
		DECLARE @telefonoActual VARCHAR(16);

		DECLARE @NumeroRegistrado TABLE (
			  NumeroTelefono VARCHAR(16)
		)
		
		DECLARE @NumeroTelefonoRegistrado TABLE (
			  SEC INT IDENTITY(1,1)
			, NumeroTelefono VARCHAR(16)
			, MinutosEntrantes INT
			, MinutosSalientes INT
		)

		DECLARE @NumeroTelefonoNoRegistrado TABLE (
			  SEC INT IDENTITY(1,1)
			, NumeroTelefono VARCHAR(16)
			, MinutosEntrantes INT
			, MinutosSalientes INT
		)

		INSERT INTO @NumeroRegistrado (NumeroTelefono)
		SELECT LI.NumeroDesde
		FROM dbo.LlamadaInput LI
		WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion

		INSERT INTO @NumeroRegistrado (NumeroTelefono)
		SELECT LI.NumeroA
		FROM dbo.LlamadaInput LI
		WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
			AND (LI.NumeroA != '911' AND LI.NumeroA != '110')

		INSERT INTO @NumeroTelefonoRegistrado (
			  NumeroTelefono
			, MinutosEntrantes
			, MinutosSalientes
		)
		SELECT DISTINCT NR.NumeroTelefono
			, 0
			, 0
		FROM @NumeroRegistrado NR
		WHERE EXISTS(SELECT 1 FROM dbo.TelefonoEstadoCuenta TEC WHERE TEC.NumeroTelefono = NR.NumeroTelefono)

		INSERT INTO @NumeroTelefonoNoRegistrado (
			  NumeroTelefono
			, MinutosEntrantes
			, MinutosSalientes
		)
		SELECT DISTINCT NR.NumeroTelefono
			, 0
			, 0
		FROM @NumeroRegistrado NR
		WHERE NOT EXISTS(SELECT 1 FROM dbo.TelefonoEstadoCuenta TEC WHERE TEC.NumeroTelefono = NR.NumeroTelefono)

		SELECT @totalNumeros = MAX(NTR.SEC)
		FROM @NumeroTelefonoRegistrado NTR

		SET @numeroActual = 1;

		WHILE @numeroActual <= @totalNumeros
        BEGIN
            -- Get current phone number
            SELECT @telefonoActual = NumeroTelefono
            FROM @NumeroTelefonoRegistrado
            WHERE SEC = @numeroActual;

            -- Calculate minutes
            SELECT @minutosEntrantes = ISNULL(SUM(DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)), 0)
            FROM dbo.LlamadaInput LI
            WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
              AND LI.NumeroA = @telefonoActual;

            SELECT @minutosSalientes = ISNULL(SUM(DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)), 0)
            FROM dbo.LlamadaInput LI
            WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
              AND LI.NumeroDesde = @telefonoActual;
        
            -- Update the @NumeroTelefono table
            UPDATE @NumeroTelefonoRegistrado
            SET 
                MinutosEntrantes = @minutosEntrantes,
                MinutosSalientes = @minutosSalientes
            WHERE SEC = @numeroActual;

            SET @numeroActual = @numeroActual + 1;
        END

		SELECT @totalNumeros = MAX(NTNR.SEC)
		FROM @NumeroTelefonoNoRegistrado NTNR

		SET @numeroActual = 1;

		WHILE @numeroActual <= @totalNumeros
        BEGIN
            SELECT @telefonoActual = NumeroTelefono
            FROM @NumeroTelefonoNoRegistrado
            WHERE SEC = @numeroActual;

            -- Calculate minutes
            SELECT @minutosEntrantes = ISNULL(SUM(DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)), 0)
            FROM dbo.LlamadaInput LI
            WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
              AND LI.NumeroA = @telefonoActual;

            SELECT @minutosSalientes = ISNULL(SUM(DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)), 0)
            FROM dbo.LlamadaInput LI
            WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
              AND LI.NumeroDesde = @telefonoActual;
        
            -- Update the @NumeroTelefono table
            UPDATE @NumeroTelefonoNoRegistrado
            SET 
                MinutosEntrantes = @minutosEntrantes,
                MinutosSalientes = @minutosSalientes
            WHERE SEC = @numeroActual;

            SET @numeroActual = @numeroActual + 1;
        END

		SELECT * FROM @NumeroTelefonoRegistrado;
		SELECT * FROM @NumeroTelefonoNoRegistrado;

		BEGIN TRANSACTION tProcesarTelefonos

			UPDATE TEC
			SET
				  CantidadMinutosEntrantes = TEC.CantidadMinutosEntrantes + NTR.MinutosEntrantes
				, CantidadMinutosSalientes = TEC.CantidadMinutosSalientes + NTR.MinutosSalientes
			FROM dbo.TelefonoEstadoCuenta TEC
			INNER JOIN @NumeroTelefonoRegistrado NTR ON TEC.NumeroTelefono  = NTR.NumeroTelefono

			INSERT INTO dbo.TelefonoEstadoCuenta (
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
					WHERE EC.FechaCierre > @inFechaOperacion 
						AND (SUBSTRING(NTNR.NumeroTelefono, 1, 1) = O.DigitoPrefijoPrincipal
							OR SUBSTRING(NTNR.NumeroTelefono, 1, 1) = O.DigitoPrefijoSecundario))
				, NTNR.NumeroTelefono
				, NTNR.MinutosEntrantes
				, NTNR.MinutosSalientes
			FROM @NumeroTelefonoNoRegistrado NTNR

		COMMIT TRANSACTION tProcesarTelefonos

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