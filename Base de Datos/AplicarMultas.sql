ALTER PROCEDURE dbo.AplicarMultas
	@inFechaOperacion DATE,
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @FacturaMulta TABLE (
			SEC INT IDENTITY(1,1),
			IDFactura INT,
			MultaFacturaPendiente MONEY
		)

		SET @outResultCode = 0;

		INSERT INTO @FacturaMulta (
			IDFactura,
			MultaFacturaPendiente
		)
		SELECT 
			F.ID,
			COUNT(F.EstaPagada) * ISNULL(ETT.Valor, 0)
		FROM dbo.Factura F
		INNER JOIN dbo.Contrato C ON C.ID = F.IDContrato
		LEFT JOIN dbo.ElementoDeTipoTarifa ETT ON ETT.IDTipoTarifa = C.IDTipoTarifa AND ETT.IDTipoElemento = 8
		WHERE DATEDIFF(DAY, F.FechaPago, @inFechaOperacion) = 1 AND F.EstaPagada = 0
		GROUP BY F.ID, ISNULL(ETT.Valor, 0)

		BEGIN TRANSACTION tAplicarMulta

			UPDATE F
			SET 
				  MultaFacturasPrevias = FM.MultaFacturaPendiente
				, Total = Total + FM.MultaFacturaPendiente
			FROM dbo.Factura F
			INNER JOIN @FacturaMulta FM ON F.ID = FM.IDFactura;

		COMMIT TRANSACTION tAplicarMulta

		SELECT @outResultCode AS outResultCode;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION tAplicarMulta;

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
