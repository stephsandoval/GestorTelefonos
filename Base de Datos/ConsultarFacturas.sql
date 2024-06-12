-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- CONSULTA LAS FACTURAS DE UN NUMERO EN ESPECIFICO

-- Descripcion general:
-- Desde la aplicación web, un funcionario debe poder consultar
-- las facturas de un numero en especifico

-- Descripcion de parametros:
	-- @inNumeroTelefono: numero de telefono que se desea consultar
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ConsultarFacturas '88888888', @outResultCode OUTPUT

-- Notas adicionales:
-- El sp retorna unicamente la informacion de las facturas cerradas
-- Aquellas que aun estan en proceso se exluyen del resultado

-- ************************************************************* --

ALTER PROCEDURE dbo.ConsultarFacturas
	  @inNumeroTelefono VARCHAR(16)                              -- numero que se desea consultar
	, @outResultCode INT OUTPUT                                  -- resultado de ejecucion del codigo
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- ----------------------------------------------------- --
		-- DECLARAR VARIABLES

		DECLARE @IDContrato INT;

		-- ----------------------------------------------------- --
		-- INICIALIZAR VARIABLES

		SET @outResultCode = 0;

		SELECT @IDContrato = C.ID
		FROM dbo.Contrato C
		WHERE C.NumeroTelefono = @inNumeroTelefono;

		-- ----------------------------------------------------- --
		-- RETORNAR RESULTADOS

		SELECT @outResultCode AS outResultCode;

		SELECT F.TotalAntesIVA AS 'Total antes del IVA'
			, F.TotalDespuesIVA AS 'Total despues del IVA'
			, F.MultaFacturasPrevias AS 'Multa por facturas previas pendientes'
			, F.Total AS 'Total'
			, F.FechaFactura AS 'Fecha de la factura'
			, F.FechaPago AS 'Fecha limite de pago'
			, CASE
				WHEN F.EstaPagada = 1 THEN 'Pagada'
				ELSE 'Pendiente'
			  END AS 'Estado'
		FROM dbo.Factura F
		WHERE F.IDContrato = @IDContrato AND F.EstaCerrada = 1;

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
-- fin del SP para consultar facturas