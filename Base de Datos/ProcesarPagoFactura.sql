-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- PROCESA LOS PAGOS DE LAS FACTURAS

-- Descripcion general:
-- En el archivo XML aparecen pagos de facturas realizados por diversos clientes
-- Con base al archivo y una fecha de operacion, este SP determina los pagos
-- Ademas, actualiza la informacion de las tablas para que esto se refleje

-- Descripcion de parametros:
	-- @inXMLData: datos del XML
	-- @inFechaOperacion: fecha en que se ejecuta el codigo
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- DECLARE @XMLData XML = 'sssss'
	-- EXEC dbo.ProcesarPagoFactura @XMLData, 'yyyy-mm-dd', @outResultCode OUTPUT

-- ************************************************************* --

ALTER PROCEDURE dbo.ProcesarPagoFactura
	  @inXMLData XML
	, @inFechaOperacion DATE
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY

		-- ----------------------------------------------------- --
		-- DECLARAR VARIABLES

		-- tabla para almacenar las operaciones del dia
		DECLARE @OperacionDiaria TABLE (
			Fecha DATE,
			Operacion XML
		);

		-- tabla para almacenar los pagos de factura
		DECLARE @PagoFactura TABLE (
			SEC INT IDENTITY(1,1),
			FechaFactura DATE,
			NumeroTelefono VARCHAR(32)
		);

		DECLARE @cantidadPagosFacturas INT;
		DECLARE @pagoActual INT;
		DECLARE @numeroActual VARCHAR(32);

		-- ----------------------------------------------------- --
		-- INICIALIZAR VARIABLES

		SET @outResultCode = 0;

		-- ---------------------------------------- --
		-- identificar las operaciones del dia de ejecucion

		INSERT INTO @OperacionDiaria (Fecha, Operacion)
		SELECT 
			FechaOperacion.value('@fecha', 'DATE') AS Fecha,
			FechaOperacion.query('.') AS Operacion
		FROM @inXMLData.nodes('/Operaciones/FechaOperacion') AS T(FechaOperacion)
		WHERE FechaOperacion.value('@fecha', 'DATE') = @inFechaOperacion;

		-- ---------------------------------------- --
		-- identificar la informacion relacionada con el pago de facturas

		INSERT INTO @PagoFactura (NumeroTelefono, FechaFactura)
		SELECT 
			NuevoPago.value('@Numero', 'VARCHAR(32)') AS NumeroTelefono,
			@inFechaOperacion AS FechaFactura
		FROM @OperacionDiaria AS O
		CROSS APPLY O.Operacion.nodes('/FechaOperacion/PagoFactura') AS T(NuevoPago);

		-- ----------------------------------------------------- --
		-- PROCESAR EL PAGO DE FACTURAS

		SELECT @cantidadPagosFacturas = MAX(PF.SEC)              -- cantidad total de pagos realizados
		FROM @PagoFactura PF;

		SELECT @pagoActual = MIN(PF.SEC)                         -- contador para recorrer la tabla en el while
		FROM @PagoFactura PF;

		BEGIN TRANSACTION tProcesarPago

			WHILE @pagoActual <= @cantidadPagosFacturas
			BEGIN

				-- obtener el numero que pago la factura
				SELECT @numeroActual = PF.NumeroTelefono
				FROM @PagoFactura PF
				WHERE PF.SEC = @pagoActual;

				-- --------------------------------------------- --
				-- actualizar la tabla de facturas

				UPDATE TOP (1) F
				SET F.EstaPagada = 1
				FROM dbo.Factura F
				INNER JOIN dbo.Contrato C ON C.ID = F.IDContrato
				WHERE C.NumeroTelefono = @numeroActual AND F.EstaPagada = 0;

				SET @pagoActual = @pagoActual + 1;               -- incrementar contador
			END;

		COMMIT TRANSACTION tProcesarPago

		-- ----------------------------------------------------- --
		-- RETORNAR RESULTADOS

		SELECT @outResultCode AS outResultCode;

    END TRY
    BEGIN CATCH

		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tProcesarPago;

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
-- fin del SP para procesar los pagos de factura