ALTER PROCEDURE dbo.ProcesarLlamadasLocales
	@inFechaOperacion DATE,
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- DECLARAR VARIABLES:
		DECLARE @LlamadaRegistradaLocal TABLE (
			  IDLlamadaInput INT,
			  CantidadMinutos INT,
			  NumeroPaga VARCHAR(16),
			  NumeroA VARCHAR(16),
			  EsGratis BIT
		);

		DECLARE @Llamada110 TABLE (
			  IDLlamadaInput INT,
			  NumeroPaga VARCHAR(16),
			  CantidadMinutos INT
		);

		DECLARE @Llamada900 TABLE (
			  IDLlamadaInput INT,
			  NumeroPaga VARCHAR(16),
			  CantidadMinutos INT
		);

		-- INICIALIZAR VARIABLES:
		SET @outResultCode = 0;

		INSERT INTO @LlamadaRegistradaLocal (
			  IDLlamadaInput,
			  CantidadMinutos,
			  NumeroA,
			  NumeroPaga,
			  EsGratis
		)
		SELECT LI.ID,
			  DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)
			, LI.NumeroA
			, CASE 
				WHEN (LI.NumeroA LIKE '800%' AND LEN(LI.NumeroA) = 11) THEN LI.NumeroA
				ELSE LI.NumeroDesde
			  END
			, CASE
				WHEN (LI.NumeroA LIKE '800%' AND LEN(LI.NumeroA) = 11) THEN 1
				WHEN (LI.NumeroA LIKE '900%' AND LEN(LI.NumeroA) = 11) THEN 0
				ELSE (SELECT dbo.EsFamiliar (LI.NumeroDesde, LI.NumeroA))
				END
		FROM dbo.LlamadaInput LI
		WHERE (LI.NumeroDesde LIKE '8%' OR LI.NumeroDesde LIKE '9%') 
			AND (LI.NumeroA != '911' AND LI.NumeroA != '110' AND LI.NumeroA NOT LIKE '900%')
			AND CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion;

		INSERT INTO @Llamada110 (
			  IDLlamadaInput,
			  NumeroPaga,
			  CantidadMinutos
		)
		SELECT LI.ID,
			LI.NumeroDesde,
			DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)
		FROM dbo.LlamadaInput LI
		WHERE (LI.NumeroDesde LIKE '8%' OR LI.NumeroDesde LIKE '9%')
			AND CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
			AND (LI.NumeroA = '110');

		INSERT INTO @Llamada900 (
			  IDLlamadaInput,
			  NumeroPaga,
			  CantidadMinutos
		)
		SELECT LI.ID,
			LI.NumeroDesde,
			DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)
		FROM dbo.LlamadaInput LI
		WHERE (LI.NumeroDesde LIKE '8%' OR LI.NumeroDesde LIKE '9%') 
			AND CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
			AND (LI.NumeroA LIKE '900%');

		-- INSERT INTO CobroFijo TABLE:
		;WITH CombinedCalls AS (
			SELECT 
				COALESCE(L110.NumeroPaga, L900.NumeroPaga) AS NumeroPaga,
				1 AS Total911,
				ISNULL(SUM(DISTINCT L110.CantidadMinutos), 0) AS Total110,
				ISNULL(SUM(DISTINCT L900.CantidadMinutos), 0) AS Total900
			FROM @Llamada110 L110
			FULL OUTER JOIN @Llamada900 L900 ON L110.NumeroPaga = L900.NumeroPaga
			GROUP BY COALESCE(L110.NumeroPaga, L900.NumeroPaga)
		)

		INSERT INTO dbo.CobroFijo (
			  IDDetalle,
			  Servicio911,
			  TotalMinutos110,
			  TotalMinutos900
		)
		SELECT 
			(SELECT TOP 1 D.ID
				FROM dbo.Contrato C
				INNER JOIN dbo.Factura F ON F.IDContrato = C.ID
				INNER JOIN dbo.Detalle D ON F.ID = D.IDFactura
				WHERE C.NumeroTelefono = CC.NumeroPaga
				AND F.FechaFactura > @inFechaOperacion)
			, CC.Total911
			, CC.Total110
			, CC.Total900
		FROM CombinedCalls CC
		WHERE CC.Total911 > 0 OR CC.Total110 > 0 OR CC.Total900 > 0;

		INSERT INTO dbo.LlamadaLocal (
			    IDDetalle
			  , IDLlamadaInput
			  , CantidadMinutos
			  , EsGratis
		)
		SELECT 
			(SELECT TOP 1 D.ID
				FROM dbo.Contrato C
				INNER JOIN dbo.Factura F ON F.IDContrato = C.ID
				INNER JOIN dbo.Detalle D ON F.ID = D.IDFactura
				WHERE C.NumeroTelefono = LRL.NumeroPaga
				AND F.FechaFactura > @inFechaOperacion)
			, LRL.IDLlamadaInput
			, LRL.CantidadMinutos
			, LRL.EsGratis
		FROM @LlamadaRegistradaLocal LRL;

		-- Output result code
		SELECT @outResultCode AS outResultCode;

	END TRY
	BEGIN CATCH

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