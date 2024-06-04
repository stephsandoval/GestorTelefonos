ALTER PROCEDURE dbo.ConsultarLlamadasFactura
	  @inNumeroTelefono VARCHAR(16)
	, @inFechaFactura DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        DECLARE @IDDetalle INT;

		DECLARE @LlamadaRegistrada TABLE (
			  Fecha DATE
			, HoraInicio TIME
			, HoraFin TIME
			, NumeroA VARCHAR(16)
			, CantidadMinutos INT
			, EsGratis BIT
		)

		SELECT @IDDetalle = D.ID
		FROM dbo.Detalle D
		INNER JOIN dbo.Factura F ON F.ID = D.IDFactura
		INNER JOIN dbo.Contrato C ON C.ID = F.IDContrato
		WHERE C.NumeroTelefono = @inNumeroTelefono AND F.FechaFactura = @inFechaFactura;

		INSERT INTO @LlamadaRegistrada (
			  Fecha
			, HoraInicio
			, HoraFin
			, NumeroA
			, CantidadMinutos
			, EsGratis
		)
		SELECT CONVERT(DATE, LI.HoraInicio)
			, CONVERT(TIME, LI.HoraInicio)
			, CONVERT(TIME, LI.HoraFin)
			, LI.NumeroA
			, LL.CantidadMinutos
			, CASE
				WHEN LI.NumeroA = @inNumeroTelefono THEN 0
				WHEN LI.NumeroDesde = @inNumeroTelefono AND (LI.NumeroA NOT LIKE '800%' AND LEN(LI.NumeroA) = 11) THEN 0
				ELSE LL.EsGratis
			  END
		FROM dbo.LlamadaLocal LL
		INNER JOIN dbo.LlamadaInput LI ON LI.ID = LL.IDLlamadaInput
		WHERE LL.IDDetalle = @IDDetalle;

		INSERT INTO @LlamadaRegistrada (
			  Fecha
			, HoraInicio
			, HoraFin
			, NumeroA
			, CantidadMinutos
			, EsGratis
		)
		SELECT CONVERT(DATE, LI.HoraInicio)
			, CONVERT(TIME, LI.HoraInicio)
			, CONVERT(TIME, LI.HoraFin)
			, LI.NumeroA
			, DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)
			, 0
		FROM dbo.LlamadaInput LI
		WHERE LI.NumeroDesde = @inNumeroTelefono
			AND (LI.NumeroA = '911' OR LI.NumeroA = '110' OR LI.NumeroA LIKE '900%')
			AND (DATEDIFF(MONTH, CONVERT(DATE, LI.HoraInicio), @inFechaFactura) < 2
				AND LI.HoraInicio < @inFechaFactura)

		SELECT @outResultCode AS outResultCode

		SELECT LR.Fecha AS 'Fecha'
			, CONVERT(TIME(3), LR.HoraInicio) AS 'Hora de inicio'
			, CONVERT(TIME(3), LR.HoraFin) AS 'Hora de fin'
			, LR.NumeroA AS 'Numero destino'
			, LR.CantidadMinutos AS 'Duracion'
			, CASE
				WHEN LR.EsGratis = 1 THEN 'Gratis'
				ELSE 'A cobro'
			  END AS 'Condicion cobro'
		FROM @LlamadaRegistrada LR
		ORDER BY LR.Fecha

    END TRY
    BEGIN CATCH
        INSERT INTO DBError (
              UserName
            , ErrorNumber
            , ErrorState
            , ErrorSeverity
            , ErrorLine
            , ErrorProcedure
            , ErrorMessage
            , ErrorDate
        ) VALUES (
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