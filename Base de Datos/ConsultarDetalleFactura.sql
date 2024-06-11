-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- CONSULTA DEL DETALLE DE FACTURA

-- Descripcion general:
-- desde la interfaz web, el usuario puede consultar las facturas de un numero
-- cada factura esta asociada a un detalle
-- este sp es para llamarse desde la capa logica y obtener la informacion

-- Descripcion de parametros:
	-- @inNumeroTelefono: numero que se quiere consultar
	-- @inFechaFactura: fecha en la cual cierra la factura que cierra que se quiere consultar
	-- @outResultCode: codigo de resultado del codigo

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT;
	-- EXEC dbo.ConsultarDetalleFactura 88888888, 'yyyy-mm-dd, outResultCode OUTPUT

-- ************************************************************* --

ALTER PROCEDURE dbo.ConsultarDetalleFactura
	  @inNumeroTelefono VARCHAR(16)
	, @inFechaFactura DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

		-- ------------------------------------------------------------- --
		-- DECLARAR VARIABLES

        DECLARE @IDContrato INT;                                         -- ID del contrato relacionado con el numero
        DECLARE @IDFactura INT;                                          -- ID de la factura consultada

        DECLARE @minutosBase INT = 0;                                    -- minutos base de la tarifa del cliente
		DECLARE @gigasBase FLOAT = 0;                                    -- gigas base de la tarifa del cliente
		DECLARE @minutosTotales INT;                                     -- minutos totales de las llamadas del cliente
		DECLARE @gigasTotales FLOAT;                                     -- gigas totales del uso de datos del cliente

		DECLARE @monto911 MONEY;                                         -- monto por el servicio 911
		DECLARE @monto110 MONEY;                                         -- costo por minuto del numero 10
		DECLARE @monto900 MONEY;                                         -- costo pro minuto del servicio 900
		DECLARE @cantidadMinutos110 INT;                                 -- cantidad de minutos por llamadas a 110
		DECLARE @cantidadMinutos900 INT;                                 -- cantidad de minutos por llamadas a 900

		DECLARE @tarifaBase MONEY = 0;                                   -- monto de la tarifa base
		DECLARE @minutosExceso INT = 0;                                  -- minutos en exceso a la tarifa base
		DECLARE @gigasExceso FLOAT = 0;                                  -- gigas en exceso a la tarifa base
		DECLARE @minutosFamiliares INT;                                  -- minutos por llamadas familiares

		-- ------------------------------------------------------------- --
		-- INICIALIZAR VARIBALES

		SET @outResultCode = 0;

		SELECT @IDContrato = C.ID
		FROM dbo.Contrato C
		WHERE C.NumeroTelefono = @inNumeroTelefono;
		PRINT @IDContrato

		SELECT @IDFactura = F.ID
		FROM dbo.Factura F
		WHERE F.IDContrato = @IDContrato AND F.FechaFactura = @inFechaFactura;
		PRINT @IDFactura

		SELECT @tarifaBase = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @IDContrato AND ETT.IDTipoElemento = 1;
		PRINT @tarifaBase

		SELECT @minutosBase = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @IDContrato AND ETT.IDTipoElemento = 2;
		PRINT @minutosBase

		SELECT @gigasBase = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @IDContrato AND ETT.IDTipoElemento = 5;
		PRINT @gigasBase

		SELECT @monto911 = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @IDContrato AND ETT.IDTipoElemento = 11;
		PRINT @monto911

		SELECT @monto110 = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @IDContrato AND ETT.IDTipoElemento = 13;
		PRINT @monto110

		SELECT @cantidadMinutos110 = ISNULL(SUM(CF.TotalMinutos110), 0)
		FROM dbo.CobroFijo CF
		INNER JOIN dbo.Detalle D ON CF.IDDetalle = D.ID
		WHERE D.IDFactura = @IDFactura;
		PRINT @cantidadMinutos110

		SELECT @cantidadMinutos900 = ISNULL(SUM(CF.TotalMinutos900), 0)
		FROM dbo.CobroFijo CF
		INNER JOIN dbo.Detalle D ON CF.IDDetalle = D.ID
		WHERE D.IDFactura = @IDFactura;
		PRINT @cantidadMinutos900

		SELECT @monto900 = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		WHERE ETT.IDTipoElemento = 10 AND ETT.IDTipoTarifa = 8;
		PRINT @monto900

		SELECT @minutosTotales = ISNULL(SUM(LL.CantidadMinutos), 0)
		FROM dbo.LlamadaLocal LL
		INNER JOIN dbo.Detalle D ON D.ID = LL.IDDetalle
		WHERE D.IDFactura = @IDFactura;
		PRINT @minutosTotales

		SELECT @gigasTotales = ISNULL(SUM(UD.CantidadDatos), 0)
		FROM dbo.UsoDatos UD
		INNER JOIN dbo.Detalle D ON D.ID = UD.IDDetalle
		WHERE D.IDFactura = @IDFactura;
		PRINT @gigasTotales

		SELECT @minutosFamiliares = ISNULL(SUM(LL.CantidadMinutos), 0)
		FROM dbo.LlamadaLocal LL
		INNER JOIN dbo.Detalle D ON D.ID = LL.IDDetalle
		INNER JOIN dbo.LlamadaInput LI ON LI.ID = LL.IDLlamadaInput
		WHERE D.IDFactura = @IDFactura
			AND (dbo.EsFamiliar (LI.NumeroDesde, LI.NumeroA) = 1)
		PRINT @minutosFamiliares

		IF (@minutosTotales > @minutosBase)
		BEGIN
			SET @minutosExceso = @minutosTotales - @minutosBase;
		END
		PRINT @minutosExceso

		IF (@gigasTotales > @gigasBase)
		BEGIN
			SET @gigasExceso = @gigasTotales - @gigasBase;
		END
		PRINT @gigasExceso

		-- ------------------------------------------------------------- --
		-- RETORNAR RESULTADOS

		SELECT @outResultCode AS outResultCode;

		SELECT @tarifaBase AS 'Tarifa base'
				, @minutosBase AS 'Minutos de tarifa base'
				, @minutosExceso AS 'Minutos en exceso'
				, @minutosFamiliares AS 'Minutos a familiares'
				, @gigasBase AS 'Gigas de tarifa base'
				, @gigasExceso AS 'Gigas en exceso'
				, @monto911 AS 'Cobro por 911'
				, (@cantidadMinutos110 * @monto110) AS 'Cobro por 110'
				, (@cantidadMinutos900 * @monto900) AS 'Cobro por 900'

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
-- fin del procedimiento para consultar el detalle