-- Armando Castro, Stephanie Sandoval | Jun 10. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- ABRE Y CIERRA ESTADOS DE CUENTA PARA LAS EMPRESAS

-- Descripcion general:
-- Los cinco de cada mes se abren o cierran estados de cuenta para las diferentes empresas
-- Esto implica, para la empresa X (numeros 6), Y (numeros 7) y Z (numeros 8 y 9)
-- En estos estados se contabiliza la cantidad de minutos entrantes y salientes
-- relacionados con los numeros telefonicos de cada empresa para el mes correspondiente

-- Descripcion de parametros:
	-- @inFechaOperacion: fecha en la cual se esta ejecutando el procedimiento
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.AbrirCerrarEstadosCuenta 'yyyy-mm-dd', @outResultCode OUTPUT

-- ************************************************************* --

ALTER PROCEDURE dbo.AbrirCerrarEstadosCuenta
	  @inFechaOperacion DATE                                     -- fecha en que se ejecuta el SP
	, @outResultCode INT OUTPUT                                  -- resultado de ejecucion del SP
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- ------------------------------------------------------------- --
		-- VALIDAR EL DIA DE OPERACION

		IF (DAY(@inFechaOperacion) != 5)
		BEGIN
			RETURN;
		END

		-- ------------------------------------------------------------- --
		-- DECLARAR VARIABLES

		-- tabla para almacenar los operadores a los que se les abre estado de cuenta
		DECLARE @OperadorApertura TABLE (
			  IDOperador INT
			, Nombre VARCHAR(16)
		)

		-- tabla para almacenar los operadores a los que se les cierra estado de cuenta
		DECLARE @OperadorCierre TABLE (
			  IDOperador INT
			, CantidadMinutosEntrantes INT
			, CantidadMinutosSalientes INT
		)

		-- tabla para almacenar los IDs de los estados de cuenta creados
		DECLARE @NuevoEstadoCuenta TABLE (
			  IDEstadoCuenta INT
		)

		-- ------------------------------------------------------------- --
		-- INICIALIZAR VARIABLES

		SET @outResultCode = 0

		-- ------------------------------------------------------------- --
		-- CARGAR DATOS NECESARIOS PARA TRANSACCION	

		-- cargar los operadores para apertura de estados
		INSERT INTO @OperadorApertura (IDOperador, Nombre)
		SELECT O.ID, O.Nombre
		FROM dbo.Operador O                                              -- se le abre a todos los registrados

		-- ---------------------------------------- --
		-- cargar los operadores para cierre de estados

		-- nota: si dbo.EstadoCuenta aun no tiene filas,
		-- es la primera vez que se abren estados de cuenta
		-- por tanto, no se debe cerrar ninguno

		IF EXISTS (SELECT 1 FROM dbo.EstadoCuenta)                       -- si ya hay registro de estados:
		BEGIN                                                            -- entonces si hay que cerrar estados
			INSERT INTO @OperadorCierre (
				  IDOperador
				, CantidadMinutosEntrantes
				, CantidadMinutosSalientes
			)
			SELECT                                                       -- se cargan los datos del operador:
				  O.ID                                                   -- ID del operador
				, ISNULL(SUM(TEC.CantidadMinutosEntrantes), 0)           -- cantidad minutos entrantes del mes
				, ISNULL(SUM(TEC.CantidadMinutosSalientes), 0)           -- cantidad minutos salientes del mes
			FROM dbo.Operador O
			INNER JOIN dbo.EstadoCuenta EC ON EC.IDOperador = O.ID
			INNER JOIN dbo.DetalleEstadoCuenta DE ON DE.IDEstadoCuenta = EC.ID
			INNER JOIN dbo.TelefonoEstadoCuenta TEC ON TEC.IDDetalleEstadoCuenta = DE.ID
			WHERE EC.FechaCierre = @inFechaOperacion
			GROUP BY O.ID;
		END

		-- ------------------------------------------------------------- --
		-- ABRIR Y CERRAR ESTADOS DE CUENTA

		BEGIN TRANSACTION tAbrirCerrarEstadoCuenta

			-- actualizar los estados de cuenta que cierran
			UPDATE EC
			SET
				  TotalMinutosEntrantes = OC.CantidadMinutosEntrantes    -- establecer minutos entrantes
				, TotalMinutosSalientes = OC.CantidadMinutosSalientes    -- establecer minutos salientes
				, EstaCerrado = 1                                        -- marcar el estado como cerrado
			FROM dbo.EstadoCuenta EC
			INNER JOIN @OperadorCierre OC ON OC.IDOperador = EC.IDOperador
			WHERE EC.FechaCierre = @inFechaOperacion

			-- ---------------------------------------- --
			-- insertar los nuevos estados de cuenta

			INSERT INTO dbo.EstadoCuenta (
				  IDOperador
				, TotalMinutosEntrantes
				, TotalMinutosSalientes
				, FechaApertura
				, FechaCierre
				, EstaCerrado
			)
			OUTPUT INSERTED.ID INTO @NuevoEstadoCuenta (IDEstadoCuenta)  -- registrar los IDs generados
			SELECT OA.IDOperador
				, 0                                                      -- contador comienza en cero
				, 0                                                      -- contador comienza en cero
				, @inFechaOperacion
				, DATEADD(MONTH, 1, @inFechaOperacion)                   -- fecha cierre: actual + 1 mes
				, 0                                                      -- marcar el estado como abierto
			FROM @OperadorApertura OA

			-- ---------------------------------------- --
			-- insertar los nuevos detalles

			INSERT INTO dbo.DetalleEstadoCuenta (
				  IDEstadoCuenta
			)
			SELECT NEC.IDEstadoCuenta
			FROM @NuevoEstadoCuenta NEC;

		COMMIT TRANSACTION tAbrirCerrarEstadoCuenta

		-- ------------------------------------------------------------- --
		-- RETORNAR RESULTADOS

		SELECT @outResultCode AS outResultCode;

    END TRY
    BEGIN CATCH

		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tAbrirCerrarEstadoCuenta;

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
-- fin del SP para abrir y cerrar estados de cuenta