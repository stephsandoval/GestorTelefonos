ALTER PROCEDURE dbo.ConsultarFacturas
	  @inNumeroTelefono VARCHAR(16)
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @IDContrato INT;

		SET @outResultCode = 0;

		SELECT @IDContrato = C.ID
		FROM dbo.Contrato C
		WHERE C.NumeroTelefono = @inNumeroTelefono;

		SELECT @outResultCode AS outResultCode;

		SELECT F.TotalAntesIVA AS 'Total antes del IVA'
			, F.TotalDespuesIVA AS 'Total despues del IVA'
			, F.MultaFacturasPrevias AS 'Multa por facturas previas pendientes'
			, F.Total AS 'Total'
			, F.FechaFactura AS 'Fecha de la factura'
			, F.FechaPago AS 'Fecha limite de pago'
			, CASE
				WHEN F.EstaPagada = 1 THEN 'Pagada'
				ELSE 'Pendiente'
			  END AS 'Estado'
		FROM dbo.Factura F
		WHERE F.IDContrato = @IDContrato;

	END TRY

	BEGIN CATCH
		INSERT INTO DBError VALUES (
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