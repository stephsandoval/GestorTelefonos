-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- APLICA MULTA A FACTURAS SEGUN FECHA DE OPERACION

-- Descripcion general:
-- A cada factura le corresponde una fecha de cierre
-- Ademas, se le establece una fecha limite para pago
-- Esto se realiza segun la cantidad de dias de gracia del tipo de tarifa
-- Si la fecha de pago pasa y la factura aun esta pendiente, se aplica una multa
-- El valor de la multa varia segun el tipo de tarifa del contrato del cliente

-- Descripcion de parametros:
	-- @inFechaOperacion: fecha en la cual se esta ejecutando el procedimiento
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.AplicarMultas 'yyyy-mm-dd', @outResultCode OUTPUT

-- Notas adicionales:
-- Los numeros 800 y 900 no tienen dias de gracia ni monto de multas asociados
-- Por tanto, si el cliente sobrepasa la fecha de pago (mismo dia de cierre de factura)
-- el monto de la multa se reflejaria como 0 (no se aplica ninguna)

-- ************************************************************* --

ALTER PROCEDURE dbo.AplicarMultas
	  @inFechaOperacion DATE                                     -- fecha en que se ejecuta el SP
	, @outResultCode INT OUTPUT                                  -- resultado de ejecucion del SP
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- ----------------------------------------------------- --
		-- DECLARAR VARIABLES

		-- tabla para almacenar las facturas a las que se les aplica una multa
		DECLARE @FacturaMulta TABLE (
			  SEC INT IDENTITY(1,1)
			, IDFactura INT
			, MultaFacturaPendiente MONEY
		)

		-- ----------------------------------------------------- --
		-- INICIALIZAR VARIABLES

		SET @outResultCode = 0;

		-- ----------------------------------------------------- --
		-- CARGAR DATOS NECESARIOS PARA TRANSACCION

		-- ingresar la informacion de las facturas pendientes que pasaron su fecha de pago
		INSERT INTO @FacturaMulta (
			  IDFactura
			, MultaFacturaPendiente
		)
		SELECT F.ID
			, COUNT(F.EstaPagada) * ISNULL(ETT.Valor, 0)                 -- cantidad pendientes * monto multa
		FROM dbo.Factura F
		INNER JOIN dbo.Contrato C ON C.ID = F.IDContrato
		LEFT JOIN dbo.ElementoDeTipoTarifa ETT ON ETT.IDTipoTarifa = C.IDTipoTarifa AND ETT.IDTipoElemento = 8
		WHERE DATEDIFF(DAY, F.FechaPago, @inFechaOperacion) = 1 AND F.EstaPagada = 0
		GROUP BY F.ID, ISNULL(ETT.Valor, 0)

		-- ----------------------------------------------------- --
		-- APLICAR MULTAS

		BEGIN TRANSACTION tAplicarMulta

			-- actualizar la informacion de las facturas
			UPDATE F
			SET 
				  MultaFacturasPrevias = FM.MultaFacturaPendiente        -- registrar la multa
				, Total = Total + FM.MultaFacturaPendiente               -- actualizar el monto total
			FROM dbo.Factura F
			INNER JOIN @FacturaMulta FM ON F.ID = FM.IDFactura;

		COMMIT TRANSACTION tAplicarMulta

		-- ----------------------------------------------------- --
		-- RETORNAR RESULTADOS

		SELECT @outResultCode AS outResultCode;

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION tAplicarMulta;

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
-- fin del SP para aplicar las multas