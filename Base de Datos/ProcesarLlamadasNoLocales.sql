-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- PROCESA LAS LLAMADAS NO LOCALES DESDE INPUT

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
-- Se considera no local a cualquier llamada que involucre un numero de X o Y
	-- es decir, que empieza en 7 o 6

-- ************************************************************* --

ALTER PROCEDURE dbo.ProcesarLlamadasNoLocales
	  @inFechaOperacion DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- ----------------------------------------------------- --
		-- DECLARAR VARIABLES

		-- tabla para almacenar las llamadas registradas
		DECLARE @LlamadaRegistrada TABLE (
			  IDLlamadaInput INT
			, NumeroDesde VARCHAR(16)
			, NumeroA VARCHAR(16)
			, CantidadMinutos INT
		);

		-- tabla para almacenar las llamadas de salida
		DECLARE @LlamadaSalida TABLE (
			  IDLlamadaInput INT
			, IDTelefono INT
			, CantidadMinutos INT
		);

		-- tabla para almacenar las llamadas de entrada
		DECLARE @LlamadaEntrada TABLE (
			  IDLlamadaInput INT
			, IDTelefono INT
			, CantidadMinutos INT
		);

		-- ----------------------------------------------------- --
		-- INICIALIZAR VARIABLES

		SET @outResultCode = 0;

		-- ---------------------------------------- --
		-- identificar las llamadas no locales
		
		INSERT INTO @LlamadaRegistrada (
			  IDLlamadaInput
			, NumeroDesde
			, NumeroA
			, CantidadMinutos
		)
		SELECT LI.ID
			, LI.NumeroDesde
			, LI.NumeroA
			, DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)
		FROM dbo.LlamadaInput LI
		WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
			AND dbo.ObtenerOperador(LI.NumeroDesde) != dbo.ObtenerOperador(LI.NumeroA);

		-- ---------------------------------------- --
		-- clasificar llamadas por salida

		INSERT INTO @LlamadaSalida (
			  IDLlamadaInput
			, IDTelefono
			, CantidadMinutos
		)
		SELECT
			  LR.IDLlamadaInput
			, TEC.ID
			, LR.CantidadMinutos
		FROM @LlamadaRegistrada LR
		INNER JOIN dbo.TelefonoEstadoCuenta TEC ON TEC.NumeroTelefono = LR.NumeroDesde

		-- ---------------------------------------- --
		-- clasificar llamadas por entrada

		INSERT INTO @LlamadaEntrada (
			  IDLlamadaInput
			, IDTelefono
			, CantidadMinutos
		)
		SELECT
			  LR.IDLlamadaInput
			, TEC.ID
			, LR.CantidadMinutos
		FROM @LlamadaRegistrada LR
		INNER JOIN dbo.TelefonoEstadoCuenta TEC ON TEC.NumeroTelefono = LR.NumeroA

		-- ----------------------------------------------------- --
		-- ACTUALIZAR LAS TABLAS DE LLAMADAS NO LOCALES

		BEGIN TRANSACTION tProcesarLlamadasNoLocales

			-- insertar las llamadas de entrada
			INSERT INTO dbo.LlamadaNoLocal (
				  IDLlamadaInput
				, IDTelefonoEstadoCuenta
				, IDTipoLlamada
				, CantidadMinutos
			)
			SELECT 
				  LE.IDLlamadaInput
				, LE.IDTelefono 
				, 1
				, LE.CantidadMinutos
			FROM @LlamadaEntrada LE
			ORDER BY LE.IDLlamadaInput

			-- insertar las llamadas de salida

			INSERT INTO dbo.LlamadaNoLocal (
				  IDLlamadaInput
				, IDTelefonoEstadoCuenta
				, IDTipoLlamada
				, CantidadMinutos
			)
			SELECT 
				  LS.IDLlamadaInput
				, LS.IDTelefono 
				, 2
				, LS.CantidadMinutos
			FROM @LlamadaSalida LS
			ORDER BY LS.IDLlamadaInput

		COMMIT TRANSACTION tProcesarLlamadasNoLocales

	-- ----------------------------------------------------- --
	-- RETONAR RESULTADOS

	SELECT @outResultCode AS outResultCode;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tProcesarLlamadasNoLocales;

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
-- fin del SP para procesar llamadas no locales