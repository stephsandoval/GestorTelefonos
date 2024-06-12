-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- PROCESA LAS LLAMADAS LOCALES DESDE INPUT

-- Descripcion general:
-- El archivo XML de operaciones provee cierta informacion sobre las llamadas
-- que cada cliente realizo o recibio
-- Estas se debe clasificar segun los numeros involucrados para poder realizar algunas operaciones

-- Descripcion de parametros:
	-- @inFechaOperacion: fecha en que se ejecuta el codigo
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXEC dbo.ProcesarLlamadasLocales 'yyyy-mm-dd', @outResultCode OUTPUT

-- Notas adicionales:
-- Se considera local a toda llamada que salga desde un numero Z
-- y sea recibida por un numero Z

-- ************************************************************* --

ALTER PROCEDURE dbo.ProcesarLlamadasLocales
	@inFechaOperacion DATE,
	@outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- ----------------------------------------------------- --
		-- DECLARAR VARIABLES

		-- tabla para almacenar temporalmente las llamadas registradas
		DECLARE @LlamadaRegistradaLocal TABLE (
			  IDLlamadaInput INT,
			  CantidadMinutos INT,
			  NumeroPaga VARCHAR(16),
			  NumeroA VARCHAR(16),
			  EsGratis BIT
		);

		-- tabla para almacenar las llamadas al 110
		DECLARE @Llamada110 TABLE (
			  IDLlamadaInput INT,
			  NumeroPaga VARCHAR(16),
			  CantidadMinutos INT
		);

		-- tabla para almacenar las llamadas a un numero 900
		DECLARE @Llamada900 TABLE (
			  IDLlamadaInput INT,
			  NumeroPaga VARCHAR(16),
			  CantidadMinutos INT
		);

		-- ----------------------------------------------------- --
		-- INICIALIZAR VARIABLES

		SET @outResultCode = 0;

		-- ---------------------------------------- --
		
		-- identificar las llamadas locales
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

		-- ---------------------------------------- --
		-- identificar las llamadas al 110

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

		-- ---------------------------------------- --
		-- identificar las llamadas a un numero 900

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

		-- ----------------------------------------------------- --
		-- REGISTRAR DATOS DE COBRO FIJO

		-- ingresar la informacion de llamadas a 110, 900 y servicio 911
		;WITH CombinedCalls AS (
			SELECT 
				COALESCE(L110.NumeroPaga, L900.NumeroPaga) AS NumeroPaga,
				1 AS Total911,                                   -- siempre se cobra, una vez, el 911
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

		-- ----------------------------------------------------- --
		-- REGISTRAR LAS LLAMADAS LOCALES

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

		-- ----------------------------------------------------- --
		-- RETORNAR RESULTADOS

		SELECT @outResultCode AS outResultCode;

	END TRY
	BEGIN CATCH

		INSERT INTO ErrorBaseDatos VALUES (
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

-- ************************************************************* --
-- fin del SP para procesar llamadas locales