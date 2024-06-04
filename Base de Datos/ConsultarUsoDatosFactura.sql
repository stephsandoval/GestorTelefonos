ALTER PROCEDURE dbo.ConsultarUsoDatosFactura
	  @inNumeroTelefono VARCHAR(16)
	, @inFechaFactura DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        DECLARE @montoUsoDatos MONEY = 0;
		DECLARE @montoUso MONEY;

		DECLARE @gigasBase FLOAT = 0;
		DECLARE @gigasActuales FLOAT = 0;
		DECLARE @gigasTotales FLOAT = 0;

		DECLARE @indiceUsoDatos INT;
		DECLARE @totalUsos INT;
		DECLARE @flagPrimero BIT = 1;

		DECLARE @UsoDatosRegistrado TABLE (
			  SEC INT IDENTITY(1,1)
			, Fecha DATE
			, CantidadDatos FLOAT
			, Monto MONEY
		);

		SELECT @montoUsoDatos = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.NumeroTelefono = @inNumeroTelefono AND ETT.IDTipoElemento = 6;

		SELECT @gigasBase = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.NumeroTelefono = @inNumeroTelefono AND ETT.IDTipoElemento = 5;

		INSERT INTO @UsoDatosRegistrado (
			  Fecha
			, CantidadDatos
		)
		SELECT
			  UDI.Fecha
			, UDI.CantidadDatos
		FROM dbo.UsoDatosInput UDI
		WHERE UDI.NumeroTelefono = @inNumeroTelefono
			AND (DATEDIFF(MONTH, CONVERT(DATE, UDI.Fecha), @inFechaFactura) < 2
				AND UDI.Fecha < @inFechaFactura)

		SELECT @totalUsos = MAX(UDR.SEC)
		FROM @UsoDatosRegistrado UDR;

		SET @indiceUsoDatos = 1

		WHILE @indiceUsoDatos <= @totalUsos
		BEGIN

			SELECT @gigasActuales = UDR.CantidadDatos
			FROM @UsoDatosRegistrado UDR
			WHERE UDR.SEC = @indiceUsoDatos;

			IF ((@gigasTotales + @gigasActuales) > @gigasBase AND @flagPrimero = 1)
			BEGIN
				SET @montoUso = (@gigasTotales + @gigasActuales - @gigasBase) * @montoUsoDatos;
				SET @flagPrimero = 0;
			END
			ELSE IF ((@gigasTotales + @gigasActuales) > @gigasBase AND @flagPrimero = 0)
			BEGIN
				SET @montoUso = @gigasActuales * @montoUsoDatos;
			END
			ELSE
			BEGIN
				SET @montoUso = 0;
			END

			UPDATE UDR
			SET Monto = @montoUso
			FROM @UsoDatosRegistrado UDR
			WHERE UDR.SEC = @indiceUsoDatos;

			SET @gigasTotales = @gigasTotales + @gigasActuales;
			SET @indiceUsoDatos = @indiceUsoDatos + 1;

		END

		SELECT @outResultCode AS outResultCode

		SELECT UDR.Fecha AS 'Fecha'
			, UDR.CantidadDatos AS 'Gigas consumidos'
			, UDR.Monto AS 'Monto por gigas consumidos'
		FROM @UsoDatosRegistrado UDR

    END TRY
    BEGIN CATCH
        INSERT INTO DBError (
              UserName
            , ErrorNumber
            , ErrorState
            , ErrorSeverity
            , ErrorLine
            , ErrorProcedure
            , ErrorMessage
            , ErrorDate
        ) VALUES (
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