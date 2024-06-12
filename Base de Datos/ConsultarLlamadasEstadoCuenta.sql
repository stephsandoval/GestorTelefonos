-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- CONSULTA DE LAS LLAMADAS DE UN ESTADO DE CUENTA ESPECIFICO

-- Descripcion general:
-- Desde la aplicación web, un funcionario debe poder consultar
-- los estados de cuenta de una empresa en especifico
-- Ademas, debe poder consultar el detalle de cualquier estado
-- Dicho detalle consiste en la lista de llamadas asociadas a su empresa
-- Ya se de entrada o de salida

-- Descripcion de parametros:
	-- @inNumeroTelefono: numero de telefono que se desea consultar
	-- @inFechaCierreEstadoCuenta: fecha en la que cierra el estado de cuenta consultado
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ConsultarLlamadasEstadoCuenta '88888888', 'yyyy-mm-dd', @outResultCode OUTPUT

-- ************************************************************* --

ALTER PROCEDURE dbo.ConsultarLlamadasEstadoCuenta
	  @inEmpresa CHAR                                            -- empresa que se desea consultar
	, @inFechaCierreEstadoCuenta DATE                            -- fecha en la que cierra el estado de cuenta
	, @outResultCode INT OUTPUT                                  -- resultado de ejecucion del codigo
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		-- ----------------------------------------------------- --
		-- DECLARAR VARIABLES

		DECLARE @IDOperador INT;
		DECLARE @IDDetalle INT;

		-- ----------------------------------------------------- --
		-- INICIALIZAR VARIABLES

		SET @outResultCode = 0;

		SELECT @IDOperador = O.ID
		FROM dbo.Operador O
		WHERE CHARINDEX(@inEmpresa, O.Nombre) > 0;

		SELECT @IDDetalle = DE.ID
		FROM dbo.DetalleEstadoCuenta DE
		INNER JOIN dbo.EstadoCuenta EC ON EC.ID = DE.IDEstadoCuenta
		WHERE EC.FechaCierre = @inFechaCierreEstadoCuenta
			AND EC.IDOperador = @IDOperador;

		-- ----------------------------------------------------- --
		-- RETORNAR RESULTADOS

		SELECT @outResultCode AS outResultCode;

		SELECT CONVERT(DATE, LI.HoraInicio) AS 'Fecha'
			, CONVERT(TIME(3), LI.HoraInicio) AS 'Hora de inicio'
			, CONVERT(TIME(3), LI.HoraFin) AS 'Hora de fin'
			, LNL.CantidadMinutos AS 'Duracion'
			, LI.NumeroDesde AS 'Numero origen'
			, LI.NumeroA AS 'Numero destino'
			, CASE
				WHEN LNL.IDTipoLlamada = 1 THEN 'Entrada'
				ELSE 'Salida'
			  END AS 'Tipo de llamada'
		FROM dbo.LlamadaNoLocal LNL
		INNER JOIN dbo.LlamadaInput LI ON LI.ID = LNL.IDLlamadaInput
		INNER JOIN dbo.TelefonoEstadoCuenta TEC ON TEC.ID = LNL.IDTelefonoEstadoCuenta
		INNER JOIN dbo.DetalleEstadoCuenta DE ON DE.ID = TEC.IDDetalleEstadoCuenta
		WHERE DE.ID = @IDDetalle
			AND (DATEDIFF(MONTH, CONVERT(DATE, LI.HoraInicio), @inFechaCierreEstadoCuenta) < 2
				AND LI.HoraInicio < @inFechaCierreEstadoCuenta);

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
-- fin del SP para consultar las llamadas de un estado de cuenta