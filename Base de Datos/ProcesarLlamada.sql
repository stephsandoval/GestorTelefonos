ALTER PROCEDURE dbo.ProcesarLlamada
	  @inFechaOperacion DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- DECLARAR VARIABLES:
		DECLARE @LlamadaRegistrada TABLE (
			  IDLlamadaInput INT
			, HoraFin DATETIME
			, CantidadMinutos INT
			, NumeroA VARCHAR(32)
			, NumeroPaga VARCHAR(32)
		);

		-- INICIALIZAR TABLAS:
		INSERT INTO @LlamadaRegistrada (
			  IDLlamadaInput
			, HoraFin
			, CantidadMinutos
			, NumeroA
			, NumeroPaga
		)
		SELECT LI.ID
			, LI.HoraFin
			, DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)
			, LI.NumeroA
			, CASE
				WHEN LI.NumeroA LIKE '800%' THEN LI.NumeroA
				ELSE LI.NumeroDesde
				END
		FROM dbo.LlamadaInput LI

		INSERT INTO dbo.Llamada (
			  IDDetalle
			, IDLlamadaInput
			, CantidadMinutos
		)
		SELECT 
			  D.ID
			, LR.IDLlamadaInput
			, LR.CantidadMinutos
		FROM @LlamadaRegistrada LR
		INNER JOIN dbo.Contrato C ON C.NumeroTelefono = LR.NumeroPaga
		INNER JOIN dbo.Factura F ON F.IDContrato = C.ID
		INNER JOIN dbo.Detalle D ON D.IDFactura = F.ID

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