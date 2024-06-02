-- Armando Castro, Stephanie Sandoval | Jun 10. 24
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
	-- En dicho mes, la factura cerraria el dia 28 o 29 segun el tipo de año
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

-- ************************************************************* --

ALTER PROCEDURE dbo.AbrirCerrarFacturas
      @inFechaOperacion DATE                                     -- fecha en que se ejecuta el SP
    , @outResultCode INT OUTPUT                                  -- resultado de la ejecucion del SP
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        -- DECLARAR VARIABLES:

        DECLARE @ClienteCierre TABLE (                           -- tabla para los contratos que cierran factura
              SEC INT IDENTITY(1,1)
            , IDContrato INT
			, MontoAntesIVA MONEY
			, MontoDespuesIVA MONEY
			, MontoTotal MONEY
        );

		DECLARE @ClienteApertura TABLE (                         -- tabla para los contratos que abren facturas
			  SEC INT IDENTITY(1,1)
			, IDContrato INT
		);

		DECLARE @NuevaFactura TABLE (                            -- tabla para los IDs de las facturas que se generan
              IDFactura INT
            , IDContrato INT
        );

		DECLARE @NuevoDetalle TABLE (                            -- tabla para los IDs de los detalles que se generan
			  IDDetalle INT
			, IDFactura INT
		);

		-- ------------------------------------------------------------- --
        -- INICIALIZAR VARIABLES:

        SET @outResultCode = 0;

		-- ------------------------------------------------------------- --
        -- INICIALIZAR TABLAS:

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

		-- ingresar la informacion de los contratos que abren factura
		-- estos son aquellos que:
			-- recien firmaron contrato el dia de operacion
			-- cierran factura el dia de operacion

		INSERT INTO @ClienteApertura (IDContrato)
		SELECT C.ID
		FROM dbo.Contrato C
		WHERE C.FechaContrato = @inFechaOperacion;

		INSERT INTO @ClienteApertura (IDContrato)
		SELECT CC.IDContrato
		FROM dbo.ObtenerContratosCierre (@inFechaOperacion) CC;

		-- ------------------------------------------------------------- --
		-- ABRIR Y CERRAR FACTURAS:

		BEGIN TRANSACTION tOperarFactura

			-- cerrar facturas:

			UPDATE F
			SET 
				  TotalAntesIVA = CC.MontoAntesIVA
				, TotalDespuesIVA = CC.MontoDespuesIVA
				, Total = CC.MontoTotal
			FROM dbo.Factura F
			INNER JOIN @ClienteCierre CC ON F.IDContrato = CC.IDContrato
			WHERE F.FechaFactura = @inFechaOperacion;

			-- ------------------------------------------------ --
			-- abrir nuevas facturas:
				-- utiliza el OUTPUT para almacenar los IDs de las facturas que se generan

			INSERT INTO dbo.Factura (IDContrato
				, TotalAntesIVA
				, TotalDespuesIVA
				, MultaFacturasPrevias
				, Total
				, FechaFactura
				, FechaPago
				, EstaPagada
			)
			OUTPUT INSERTED.ID, INSERTED.IDContrato INTO @NuevaFactura (IDFactura, IDContrato)
			SELECT CA.IDContrato
				, CASE                                           -- agregar el monto base de la tarifa
					WHEN ETT.Valor = NULL THEN 0 
					WHEN ETT.IDTipoElemento = 9 OR ETT.IDTipoElemento = 10 THEN 0
					ELSE ETT.VALOR
				  END
				, 0
				, 0
				, 0
				, dbo.GenerarFechaCierreFactura (@inFechaOperacion, CA.IDContrato)
				, dbo.GenerarFechaPagoFactura (@inFechaOperacion, CA.IDContrato)
				, 0
			FROM @ClienteApertura CA
			INNER JOIN dbo.Contrato C ON CA.IDContrato = C.ID
			INNER JOIN dbo.ElementoDeTipoTarifa ETT ON C.IDTipoTarifa = ETT.IDTipoTarifa
			WHERE ETT.IDTipoElemento = 1 OR ETT.IDTipoElemento = 9 OR ETT.IDTipoElemento = 10
			ORDER BY CA.SEC

			-- ------------------------------------------------ --
			-- abrir nuevos detalles:
				-- utiliza los IDs capturados anteriormente para establecer las FKs
				-- utiliza el OUTPUT para almacenar los IDs de los detalles generados

			INSERT INTO dbo.Detalle (IDFactura)
			OUTPUT INSERTED.ID, INSERTED.IDFactura INTO @NuevoDetalle (IDDetalle, IDFactura) 
            SELECT NF.IDFactura
            FROM @NuevaFactura NF;

		COMMIT TRANSACTION tOperarFactura

		-- ------------------------------------------------------------- --

        SELECT @outResultCode AS outResultCode;

    END TRY
    BEGIN CATCH

		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tOperarFactura;

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

-- ************************************************************* --
-- fin del SP para abrir y cerrar facturas