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

		DECLARE @NuevaLlamada TABLE (
			  IDLlamada INT
			, IDLlamadaInput INT
		);

		-- INICIALIZAR VARIABLES:

		SET @outResultCode = 0

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
		WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion

		
		INSERT INTO dbo.Llamada (
				IDDetalle
			, IDLlamadaInput
			, CantidadMinutos
		)
		OUTPUT INSERTED.ID, INSERTED.IDLlamadaInput INTO @NuevaLlamada (IDLlamada, IDLlamadaInput)
		SELECT 
			  (SELECT TOP(1) D.ID
				FROM @LlamadaRegistrada LR
				INNER JOIN dbo.Contrato C ON C.NumeroTelefono = LR.NumeroPaga
				INNER JOIN dbo.Factura F ON F.IDContrato = C.ID
				INNER JOIN dbo.Detalle D ON D.IDFactura = F.ID
				WHERE F.FechaFactura > @inFechaOperacion) AS IDDetalle
			, LR.IDLlamadaInput
			, LR.CantidadMinutos
		FROM @LlamadaRegistrada LR

		INSERT INTO dbo.LlamadaLocal (
			  IDLlamada
			, IDContrato
		)
		SELECT NL.IDLlamada
			, C.ID
		FROM @NuevaLlamada NL
		INNER JOIN @LlamadaRegistrada LR ON LR.IDLlamadaInput = NL.IDLlamadaInput
		INNER JOIN dbo.Contrato C ON C.NumeroTelefono = LR.NumeroPaga
		WHERE LR.NumeroA NOT LIKE '6%' AND LR.NumeroA NOT LIKE '7%';

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