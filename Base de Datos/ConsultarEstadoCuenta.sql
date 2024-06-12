-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- CONSULTA LOS ESTADOS DE CUENTA PARA UNA EMPRESA

-- Descripcion general:
-- Desde la aplicación web, un funcionario debe poder consultar
-- la información de los estados de cuenta
-- Al haber tres entes distintas, se debe poder seleccionar la empresa
-- Este sp, al indicar la empresa (char), retorna los estados de cuenta asociados

-- Descripcion de parametros:
	-- @inEmpresa: empresa de la que se consulta la informacion
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ConsultarEstadoCuenta 'Z', @outResultCode OUTPUT

-- Notas adicionales:
-- El sp retorna unicamente la informacion de estados cerrados
-- Aquellos que aun estan en proceso se excluyen de la tabla

-- ************************************************************* --

ALTER PROCEDURE dbo.ConsultarEstadoCuenta
	  @inEmpresa CHAR                                            -- empresa que se desea consultar
	, @outResultCode INT OUTPUT                                  -- resultado de ejecucion del codigo
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY;

		-- ----------------------------------------------------- --
		-- DECLARAR VARIABLES

		DECLARE @IDOperador INT;                                 -- ID del operador indicado

		-- ----------------------------------------------------- --
		-- INICIALIZAR VARIABLES

		SET @outResultCode = 0;

		SELECT @IDOperador = O.ID
		FROM dbo.Operador O
		WHERE CHARINDEX(@inEmpresa, O.Nombre) > 0

		-- ----------------------------------------------------- --
		-- RETONAR RESULTADOS

		SELECT @outResultCode AS outResultCode;

		SELECT EC.TotalMinutosEntrantes AS 'Total de minutos entrantes'
			, EC.TotalMinutosSalientes AS 'Total de minutos salientes'
			, EC.FechaApertura AS 'Fecha apertura'
			, EC.FechaCierre AS 'Fecha de cierre'
			, CASE
				WHEN EC.EstaCerrado = 1 THEN 'Cerrado'
				ELSE 'En proceso'
			  END AS 'Estado'
		FROM dbo.EstadoCuenta EC
		WHERE EC.IDOperador = @IDOperador AND EC.EstaCerrado = 1;

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
-- fin del SP para consultar estados de cuenta