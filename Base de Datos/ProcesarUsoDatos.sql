-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- PROCESA EL USO DE DATOS DESDE INPUT

-- Descripcion general:
-- El archivo XML de operaciones provee cierta informacion
-- sobre el uso de datos de cada cliente

-- Descripcion de parametros:
	-- @inFechaOperacion: fecha en que se ejecuta el codigo
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXEC dbo.ProcesarUsoDatos 'yyyy-mm-dd', @outResultCode OUTPUT

-- ************************************************************* --

ALTER PROCEDURE dbo.ProcesarUsoDatos
	  @inFechaOperacion DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- ----------------------------------------------------- --
		-- INICIALIZAR VARIABLES

		SET @outResultCode = 0

		-- ----------------------------------------------------- --
		-- REGISTRAR DATOS

		INSERT INTO dbo.UsoDatos (
			  IDDetalle
			, IDUsoDatosInput
			, CantidadDatos
		)
		SELECT D.ID
			, UDI.ID
			, UDI.CantidadDatos
		FROM dbo.UsoDatosInput UDI
		INNER JOIN dbo.Contrato C ON C.NumeroTelefono = UDI.NumeroTelefono
		INNER JOIN (
			SELECT IDContrato, MAX(ID) AS MaxFacturaID
			FROM dbo.Factura
			GROUP BY IDContrato
		) F ON F.IDContrato = C.ID
		INNER JOIN dbo.Detalle D ON D.IDFactura = F.MaxFacturaID
		WHERE CONVERT(DATE, UDI.Fecha) = @inFechaOperacion;

		-- ----------------------------------------------------- --
		-- RETONAR RESULTADOS

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
-- fin del SP para procesar el uso de datos