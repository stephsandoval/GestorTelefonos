ALTER PROCEDURE dbo.ConsultarLlamadasEstadoCuenta
	  @inEmpresa CHAR
	, @inFechaCierreEstadoCuenta DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		DECLARE @IDOperador INT;
		DECLARE @IDDetalle INT;

		SET @outResultCode = 0;

		SELECT @IDOperador = O.ID
		FROM dbo.Operador O
		WHERE CHARINDEX(@inEmpresa, O.Nombre) > 0;

		SELECT @IDDetalle = DE.ID
		FROM dbo.DetalleEstadoCuenta DE
		INNER JOIN dbo.EstadoCuenta EC ON EC.ID = DE.IDEstadoCuenta
		WHERE EC.FechaCierre = @inFechaCierreEstadoCuenta
			AND EC.IDOperador = @IDOperador;

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
		INSERT INTO DBError VALUES (
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