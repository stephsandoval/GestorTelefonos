-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- PROCESA LOS TELEFONOS PARA LOS ESTADOS DE CUENTA

-- Descripcion general:
-- Los 5 de cada mes se abren y cierran estados de cuenta
-- Cada uno de estos esta relacionado con llamadas de entrada y salida
-- y, por tanto, con numeros telefonicos
-- El siguiente sp se encarga de:
    -- registrar el telefono en la tabla de telefonos si es la primera vez que aparece
    -- actualizar la cantidad de minutos asociada a este si no es la primera vez que se lee

-- Descripcion de parametros:
	-- @inFechaOperacion: fecha en que se ejecuta el codigo
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXEC dbo.ProcesarTelefonos 'yyyy-mm-dd', @outResultCode OUTPUT

-- Notas adicionales:
    -- el sp verifica que solo corra el 5 de cada mes
    -- los primeros cuatro dias de enero no se cuenta en ningun estado de cuenta

-- ************************************************************* --

ALTER PROCEDURE dbo.ProcesarTelefonos
    @inFechaOperacion DATE,
    @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        -- ----------------------------------------------------- --
        -- INICIALIZAR VARIABLES

        SET @outResultCode = 0;

        -- ----------------------------------------------------- --
        -- VALIDAR QUE SOLO CORRA EN LA FECHA ESTABLECIDA

        IF (DAY(@inFechaOperacion) IN (1, 2, 3, 4) AND MONTH(@inFechaOperacion) = 1)
        BEGIN
            RETURN;
        END

        -- ----------------------------------------------------- --
        -- DECLARAR VARIABLES

        DECLARE @totalNumeros INT;
        DECLARE @numeroActual INT;
        DECLARE @minutosEntrantes INT;
        DECLARE @minutosSalientes INT;
        DECLARE @telefonoActual VARCHAR(16);

        -- tabla para almacenar los numeros de estados de cuenta
        DECLARE @NumeroRegistrado TABLE (
            NumeroTelefono VARCHAR(16)
        );

        -- tabla para almacenar los numeros ya registrados
        DECLARE @NumeroTelefonoRegistrado TABLE (
            SEC INT IDENTITY(1,1),
            NumeroTelefono VARCHAR(16),
            MinutosEntrantes INT,
            MinutosSalientes INT
        );

        -- tabla para almacenar los numeros no registrados
        DECLARE @NumeroTelefonoNoRegistrado TABLE (
            SEC INT IDENTITY(1,1),
            NumeroTelefono VARCHAR(16),
            MinutosEntrantes INT,
            MinutosSalientes INT
        );

        -- ----------------------------------------------------- --
        -- INICIALIZAR TABLAS

        INSERT INTO @NumeroRegistrado (NumeroTelefono)
        SELECT LI.NumeroDesde
        FROM dbo.LlamadaInput LI
        WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion;

        INSERT INTO @NumeroRegistrado (NumeroTelefono)
        SELECT LI.NumeroA
        FROM dbo.LlamadaInput LI
        WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
            AND (LI.NumeroA != '911' AND LI.NumeroA != '110');

        INSERT INTO @NumeroTelefonoRegistrado (
            NumeroTelefono,
            MinutosEntrantes,
            MinutosSalientes
        )
        SELECT DISTINCT NR.NumeroTelefono, 0, 0
        FROM @NumeroRegistrado NR
        WHERE EXISTS (SELECT 1 FROM dbo.TelefonoEstadoCuenta TEC WHERE TEC.NumeroTelefono = NR.NumeroTelefono);

        INSERT INTO @NumeroTelefonoNoRegistrado (
            NumeroTelefono,
            MinutosEntrantes,
            MinutosSalientes
        )
        SELECT DISTINCT NR.NumeroTelefono, 0, 0
        FROM @NumeroRegistrado NR
        WHERE NOT EXISTS (SELECT 1 FROM dbo.TelefonoEstadoCuenta TEC WHERE TEC.NumeroTelefono = NR.NumeroTelefono);

        -- ----------------------------------------------------- --
        -- OBTENER LOS MINUTOS DE CADA TELEFONO

        -- calcular minutos de telefonos registrados
        
        SELECT @totalNumeros = MAX(NTR.SEC)                      -- total de numeros registrados
        FROM @NumeroTelefonoRegistrado NTR;

        SET @numeroActual = 1;                                   -- contador para iterar sobre la tabla

        -- mientras no se hayan procesado todos los numeros
        WHILE @numeroActual <= @totalNumeros
        BEGIN
            -- obtener el numero de telefono actual
            SELECT @telefonoActual = NumeroTelefono
            FROM @NumeroTelefonoRegistrado
            WHERE SEC = @numeroActual;

            -- actualizar la informacion en la tabla variable
            UPDATE @NumeroTelefonoRegistrado
            SET 
                MinutosEntrantes = M.MinutosEntrantes,
                MinutosSalientes = M.MinutosSalientes
			FROM dbo.ObtenerMinutos(@telefonoActual, @inFechaOperacion) M
			CROSS APPLY @NumeroTelefonoRegistrado
            WHERE SEC = @numeroActual;

            SET @numeroActual = @numeroActual + 1;               -- incrementar contador
        END

        -- ---------------------------------------- --
        -- calcular minutos de telefonos no registrados

        SELECT @totalNumeros = MAX(NTNR.SEC)                     -- total de numeros registrados
        FROM @NumeroTelefonoNoRegistrado NTNR;
 
        SET @numeroActual = 1;                                   -- contador para iterar sobre la tabla

        WHILE @numeroActual <= @totalNumeros
        BEGIN
            -- obtener el numero de telefono actual
            SELECT @telefonoActual = NumeroTelefono
            FROM @NumeroTelefonoNoRegistrado
            WHERE SEC = @numeroActual;

            -- actualizar la informacion en la tabla variable
            UPDATE @NumeroTelefonoNoRegistrado
            SET
                MinutosEntrantes = M.MinutosEntrantes,
                MinutosSalientes = M.MinutosSalientes
			FROM dbo.ObtenerMinutos(@telefonoActual, @inFechaOperacion) M
			CROSS APPLY @NumeroTelefonoNoRegistrado
            WHERE SEC = @numeroActual;

            SET @numeroActual = @numeroActual + 1;               -- incrementar contador
        END

        -- ----------------------------------------------------- --
        -- ACTUALIZAR LA INFORMACION DE LA BASE DE DATOS

        BEGIN TRANSACTION tProcesarTelefonos

            -- si el numero ya estaba registrado en la BD, actualizar
            UPDATE TEC
            SET
                CantidadMinutosEntrantes = TEC.CantidadMinutosEntrantes + NTR.MinutosEntrantes,
                CantidadMinutosSalientes = TEC.CantidadMinutosSalientes + NTR.MinutosSalientes
            FROM dbo.TelefonoEstadoCuenta TEC
            INNER JOIN @NumeroTelefonoRegistrado NTR ON TEC.NumeroTelefono  = NTR.NumeroTelefono;

            -- si es la primera vez que se lee el numero, abrir registro
            INSERT INTO dbo.TelefonoEstadoCuenta (
                IDDetalleEstadoCuenta,
                NumeroTelefono,
                CantidadMinutosEntrantes,
                CantidadMinutosSalientes
            )
            SELECT 
                (SELECT TOP 1 DE.ID
                 FROM dbo.DetalleEstadoCuenta DE
                 INNER JOIN dbo.EstadoCuenta EC ON DE.IDEstadoCuenta = EC.ID
                 INNER JOIN dbo.Operador O ON O.ID = EC.IDOperador
                 WHERE EC.FechaCierre > @inFechaOperacion 
                 AND (SUBSTRING(NTNR.NumeroTelefono, 1, 1) = O.DigitoPrefijoPrincipal
                  OR SUBSTRING(NTNR.NumeroTelefono, 1, 1) = O.DigitoPrefijoSecundario)),
                NTNR.NumeroTelefono,
                NTNR.MinutosEntrantes,
                NTNR.MinutosSalientes
            FROM @NumeroTelefonoNoRegistrado NTNR;

        COMMIT TRANSACTION tProcesarTelefonos;

        -- ----------------------------------------------------- --
        -- RETORNAR RESULTADO

        SELECT @outResultCode AS outResultCode;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tProcesarTelefonos;

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
-- fin del SP para procesar telefonos