ALTER PROCEDURE dbo.ConsultarDetalleFactura
	  @inNumeroTelefono VARCHAR(16)
	, @inFechaFactura DATE
	, @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @IDContrato INT;
        DECLARE @IDFactura INT;

        DECLARE @minutosBase INT = 0;
		DECLARE @gigasBase FLOAT = 0;
		DECLARE @minutosTotales INT;
		DECLARE @gigasTotales FLOAT;

		DECLARE @monto911 MONEY;
		DECLARE @monto110 MONEY;
		DECLARE @monto900 MONEY;
		DECLARE @cantidadMinutos110 INT;
		DECLARE @cantidadMinutos900 INT;
		DECLARE @cantidadLlamadas911 INT;

		DECLARE @tarifaBase MONEY = 0;
		DECLARE @minutosExceso INT = 0;
		DECLARE @gigasExceso FLOAT = 0;
		DECLARE @minutosFamiliares INT;

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

		SELECT @cantidadLlamadas911 = ISNULL(SUM(CF.TotalLlamadas911), 0)
		FROM dbo.CobroFijo CF
		INNER JOIN dbo.Detalle D ON CF.IDDetalle = D.ID
		WHERE D.IDFactura = @IDFactura;
		PRINT @cantidadLlamadas911

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

		SELECT @outResultCode AS outResultCode;

		SELECT @tarifaBase AS 'Tarifa base'
				, @minutosBase AS 'Minutos de tarifa base'
				, @minutosExceso AS 'Minutos en exceso a tarifa base'
				, @gigasBase AS 'Gigas de tarifa base'
				, @gigasExceso AS 'Gigas en exceso a tarifa base'
				, @minutosFamiliares AS 'Minutos a familiares'
				, (@cantidadLlamadas911 * @monto911) AS 'Cobro por 911'
				, (@cantidadMinutos110 * @monto110) AS 'Cobro por 110'
				, (@cantidadMinutos900 * @monto900) AS 'Cobro por 900'

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