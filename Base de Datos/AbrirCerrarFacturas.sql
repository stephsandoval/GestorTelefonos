-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- ABRE Y CIERRA FACTURAS SEGUN FECHA DE OPERACION

-- Descripcion general:
-- Por cada dia de operacion se deben procesar contratos que cierran y abren facturas
-- Cerrar una factura implica consolidar los montos finales que el usuario debe pagar por el mes
-- Abrir una factura implica abrir una nueva instancia para comenzar a sumar los montos del mes
-- Se abre y cierra factura con base en el dia en que se firma el contrato
	-- Por ejemplo, un contrato firmado el 30 de enero, cierra los dias 30
	-- Se toma cierta precaucion para meses que tienen menos de 30 dias (febrero)
	-- En dicho mes, la factura cerraria el dia 28 o 29 segun el tipo de a�o
	-- Una logica similar se aplica para los demas dias
-- Abrir una factura tambien implica abrir un nuevo detalle e instancias de cobro fijo

-- Descripcion de parametros:
	-- @inFechaOperacion: fecha en la cual se esta ejecutando el procedimiento
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.AbrirCerrarFacturas 'yyyy-mm-dd', @outResultCode OUTPUT

-- Notas adicionales:
-- el SP se apoya de funciones adicionales para realizar algunos calculos
-- estas se encargan de:
	-- encontrar los contratos a los que se les debe cerrar una factura
	-- calcular los montos finales para las facturas que cierran
	-- generar las fechas de cierre y de pago

-- por otro lado, para las facturas que abren, se les suma la tarifa base
-- esto porque, independientemente de lo que pase, eventualmente se les tiene que sumar
-- resulta mas facil hacerlo justo cuando se abren

-- la logica para aplicar multas por facturas pendientes no se incluye aqui
-- esto porque el cliente tiene ciertos dias de gracia para pagar
-- por tanto, la multa no se aplica el mismo dia que cierra la factura
-- en consecuencia, existe un sp por aparte que se encarga de esto

-- ************************************************************* --

ALTER PROCEDURE dbo.AbrirCerrarFacturas
      @inFechaOperacion DATE                                     -- fecha en que se ejecuta el SP
    , @outResultCode INT OUTPUT                                  -- resultado de ejecucion del SP
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

		-- ------------------------------------------------------------- --
        -- DECLARAR VARIABLES

		-- tabla para los contratos que cierran factura
        DECLARE @ClienteCierre TABLE (
              SEC INT IDENTITY(1,1)
            , IDContrato INT
			, MontoAntesIVA MONEY
			, MontoDespuesIVA MONEY
			, MontoTotal MONEY
        );

		-- tabla para los contratos que abren facturas
		DECLARE @ClienteApertura TABLE (
			  SEC INT IDENTITY(1,1)
			, IDContrato INT
		);

		-- tabla para los IDs de las facturas que se generan
		DECLARE @NuevaFactura TABLE (
              IDFactura INT
            , IDContrato INT
        );

		-- ------------------------------------------------------------- --
        -- INICIALIZAR VARIABLES

        SET @outResultCode = 0;

		-- ------------------------------------------------------------- --
        -- CARGAR DATOS NECESARIOS PARA TRANSACCION

		-- ingresar la informacion de los contratos que cierran factura
		-- se apoya de dos funciones, las cuales:
			-- 1. determina los IDs de los contratos
			-- 2. calcula los montos finales para la factura de un contrato especifico

		INSERT INTO @ClienteCierre (
			  IDContrato
			, MontoAntesIVA
			, MontoDespuesIVA
			, MontoTotal
		)
		SELECT CC.IDContrato
			, MT.MontoAntesIVA
			, MT.MontoDespuesIVA
			, MT.MontoTotal
		FROM dbo.ObtenerContratosCierre (@inFechaOperacion) CC
		CROSS APPLY dbo.CalcularMontosFinalesFactura (CC.IDContrato, @inFechaOperacion) MT;

		-- ---------------------------------------- --
		-- ingresar la informacion de los contratos que abren factura

		-- se considera que un contrato abre si:
			-- 1. se firmo el dia de operacion
			-- 2. cierran factura el dia de operacion

		INSERT INTO @ClienteApertura (IDContrato)
		SELECT C.ID
		FROM dbo.Contrato C
		WHERE C.FechaContrato = @inFechaOperacion;                       -- contratos que se firmaron hoy

		INSERT INTO @ClienteApertura (IDContrato)
		SELECT CC.IDContrato
		FROM dbo.ObtenerContratosCierre (@inFechaOperacion) CC;          -- facturas que cierran hoy

		-- ------------------------------------------------------------- --
		-- ABRIR Y CERRAR FACTURAS

		BEGIN TRANSACTION tAbrirCerrarFacturas

			-- actualizar los datos de las facturas que cierran
			UPDATE F
			SET 
				  TotalAntesIVA = CC.MontoAntesIVA
				, TotalDespuesIVA = CC.MontoDespuesIVA
				, Total = CC.MontoTotal
			FROM dbo.Factura F
			INNER JOIN @ClienteCierre CC ON F.IDContrato = CC.IDContrato
			WHERE F.FechaFactura = @inFechaOperacion;

			-- ------------------------------------------------ --
			-- insertar las nuevas facturas

			INSERT INTO dbo.Factura (IDContrato
				, TotalAntesIVA
				, TotalDespuesIVA
				, MultaFacturasPrevias
				, Total
				, FechaFactura
				, FechaPago
				, EstaPagada
			)                                                   -- OUTPUT: guarda los IDs generados
			OUTPUT INSERTED.ID, INSERTED.IDContrato INTO @NuevaFactura (IDFactura, IDContrato)
			SELECT CA.IDContrato
				, CASE                                           -- agregar el monto base de la tarifa
					WHEN ETT.Valor = NULL THEN 0 
					WHEN ETT.IDTipoElemento = 9 OR ETT.IDTipoElemento = 10 THEN 0
					ELSE ETT.VALOR
				  END
				, 0                                              -- contador comienza en cero
				, 0                                              -- contador comienza en cero
				, 0                                              -- contador comienza en cero
				, dbo.GenerarFechaCierreFactura (@inFechaOperacion, CA.IDContrato)
				, dbo.GenerarFechaPagoFactura (@inFechaOperacion, CA.IDContrato)
				, 0                                              -- marcar como pendiente
			FROM @ClienteApertura CA
			INNER JOIN dbo.Contrato C ON CA.IDContrato = C.ID
			INNER JOIN dbo.ElementoDeTipoTarifa ETT ON C.IDTipoTarifa = ETT.IDTipoTarifa
			WHERE ETT.IDTipoElemento = 1 OR ETT.IDTipoElemento = 9 OR ETT.IDTipoElemento = 10
			ORDER BY CA.SEC

			-- ------------------------------------------------ --
			-- abrir nuevos detalles

			INSERT INTO dbo.Detalle (IDFactura)
            SELECT NF.IDFactura
            FROM @NuevaFactura NF;

		COMMIT TRANSACTION tAbrirCerrarFacturas

		-- ------------------------------------------------------------- --
		-- RETORNAR RESULTADOS

        SELECT @outResultCode AS outResultCode;

    END TRY
    BEGIN CATCH

		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tAbrirCerrarFacturas;

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
-- fin del SP para abrir y cerrar facturas