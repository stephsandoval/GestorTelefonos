ALTER PROCEDURE dbo.ProcesarPagoFactura
	  @inXMLData XML
	, @inFechaOperacion DATE
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @OperacionDiaria TABLE (
			Fecha DATE,
			Operacion XML
		);

		DECLARE @PagoFactura TABLE (
			SEC INT IDENTITY(1,1),
			FechaFactura DATE,
			NumeroTelefono VARCHAR(32)
		);

		DECLARE @cantidadPagosFacturas INT;
		DECLARE @pagoActual INT;
		DECLARE @numeroActual VARCHAR(32);

		SET @outResultCode = 0;

		INSERT INTO @OperacionDiaria (Fecha, Operacion)
		SELECT 
			FechaOperacion.value('@fecha', 'DATE') AS Fecha,
			FechaOperacion.query('.') AS Operacion
		FROM @inXMLData.nodes('/Operaciones/FechaOperacion') AS T(FechaOperacion)
		WHERE FechaOperacion.value('@fecha', 'DATE') = @inFechaOperacion;

		INSERT INTO @PagoFactura (NumeroTelefono, FechaFactura)
		SELECT 
			NuevoPago.value('@Numero', 'VARCHAR(32)') AS NumeroTelefono,
			@inFechaOperacion AS FechaFactura
		FROM @OperacionDiaria AS O
		CROSS APPLY O.Operacion.nodes('/FechaOperacion/PagoFactura') AS T(NuevoPago);

		SELECT @cantidadPagosFacturas = MAX(PF.SEC)
		FROM @PagoFactura PF;

		SELECT @pagoActual = MIN(PF.SEC)
		FROM @PagoFactura PF;

		BEGIN TRANSACTION tProcesarPago

			WHILE @pagoActual <= @cantidadPagosFacturas
			BEGIN
				SELECT @numeroActual = PF.NumeroTelefono
				FROM @PagoFactura PF
				WHERE PF.SEC = @pagoActual;

				UPDATE TOP (1) F
				SET F.EstaPagada = 1
				FROM dbo.Factura F
				INNER JOIN dbo.Contrato C ON C.ID = F.IDContrato
				WHERE C.NumeroTelefono = @numeroActual AND F.EstaPagada = 0;

				SET @pagoActual = @pagoActual + 1;
			END;

		COMMIT TRANSACTION tProcesarPago

    END TRY
    BEGIN CATCH

		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tProcesarPago;

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
