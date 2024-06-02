ALTER PROCEDURE dbo.ProcesarUsoDatos
	  @inFechaOperacion DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- INICIALIZAR VARIABLES:

		SET @outResultCode = 0

		-- REGISTRAR DATOS:

		INSERT INTO dbo.UsoDatos (
			  IDDetalle
			, IDUsoDatosInput
			, CantidadDatos
		)
		SELECT D.ID
			, UDI.ID
			, UDI.CantidadDatos
		FROM dbo.UsoDatosInput UDI
		INNER JOIN dbo.Contrato C ON C.NumeroTelefono = UDI.NumeroTelefono
		INNER JOIN (
			SELECT IDContrato, MAX(ID) AS MaxFacturaID
			FROM dbo.Factura
			GROUP BY IDContrato
		) F ON F.IDContrato = C.ID
		INNER JOIN dbo.Detalle D ON D.IDFactura = F.MaxFacturaID
		WHERE CONVERT(DATE, UDI.Fecha) = @inFechaOperacion;

		SELECT @outResultCode AS outResultCode;

	END TRY
	BEGIN CATCH

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