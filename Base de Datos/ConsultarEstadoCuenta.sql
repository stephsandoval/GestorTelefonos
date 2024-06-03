ALTER PROCEDURE dbo.ConsultarEstadoCuenta
	  @inEmpresa CHAR
	, @outResultCode INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY;

		DECLARE @IDOperador INT;

		SET @outResultCode = 0;

		SELECT @IDOperador = O.ID
		FROM dbo.Operador O
		WHERE CHARINDEX(@inEmpresa, O.Nombre) > 0

		SELECT @outResultCode AS outResultCode;

		SELECT EC.TotalMinutosEntrantes AS 'Total de minutos de llamadas entrantes'
			, EC.TotalMinutosSalientes AS 'Total de minutos de llamadas salientes'
			, EC.FechaApertura AS 'Fecha apertura'
			, EC.FechaCierre AS 'Fecha de cierre'
			, CASE
				WHEN EC.EstaCerrado = 1 THEN 'Cerrado'
				ELSE 'En proceso'
			  END AS 'Estado'
		FROM dbo.EstadoCuenta EC
		WHERE EC.IDOperador = @IDOperador;

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