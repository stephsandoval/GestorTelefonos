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

        DECLARE @tarifaBase MONEY = 0;
        DECLARE @minutosExceso INT = 0;
        DECLARE @gigasExceso FLOAT = 0;
		DECLARE @minutosFamiliares INT;

        SET @outResultCode = 0;

        -- Get Contract ID
        SELECT @IDContrato = C.ID
        FROM dbo.Contrato C
        WHERE C.NumeroTelefono = @inNumeroTelefono;

        -- Get Invoice ID
        SELECT @IDFactura = F.ID
        FROM dbo.Factura F
        WHERE F.IDContrato = @IDContrato AND F.FechaFactura = @inFechaFactura;

        -- Get Tarifa base
        SELECT @tarifaBase = ETT.Valor
        FROM dbo.ElementoDeTipoTarifa ETT
        INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
        WHERE C.ID = @IDContrato AND ETT.IDTipoElemento = 1;

        -- Get Minutos base
        SELECT @minutosBase = ETT.Valor
        FROM dbo.ElementoDeTipoTarifa ETT
        INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
        WHERE C.ID = @IDContrato AND ETT.IDTipoElemento = 2;

        -- Get Gigas base
        SELECT @gigasBase = ETT.Valor
        FROM dbo.ElementoDeTipoTarifa ETT
        INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
        WHERE C.ID = @IDContrato AND ETT.IDTipoElemento = 5;

		-- Get monto for 911
        SELECT @monto911 = ETT.Valor
        FROM dbo.ElementoDeTipoTarifa ETT
        INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
        WHERE C.ID = @IDContrato AND ETT.IDTipoElemento = 11;

        -- Get monto for 110
        SELECT @monto110 = ETT.Valor
        FROM dbo.ElementoDeTipoTarifa ETT
        INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
        WHERE C.ID = @IDContrato AND ETT.IDTipoElemento = 13;

        -- Get monto for 900
        SELECT @monto900 = ETT.Valor
        FROM dbo.ElementoDeTipoTarifa ETT
        WHERE ETT.IDTipoElemento = 10 AND ETT.IDTipoTarifa = 8;

        -- Get total minutes used
        SELECT @minutosTotales = ISNULL(SUM(LL.CantidadMinutos), 0)
        FROM dbo.LlamadaLocal LL
        INNER JOIN dbo.Detalle D ON D.ID = LL.IDDetalle
        WHERE D.IDFactura = @IDFactura;

        -- Get total data used
        SELECT @gigasTotales = ISNULL(SUM(UD.CantidadDatos), 0)
        FROM dbo.UsoDatos UD
        INNER JOIN dbo.Detalle D ON D.ID = UD.IDDetalle
        WHERE D.IDFactura = @IDFactura;

		SELECT @minutosFamiliares = ISNULL(SUM(LL.CantidadMinutos), 0)
		FROM dbo.LlamadaLocal LL
		INNER JOIN dbo.Detalle D ON D.ID = LL.IDDetalle
		INNER JOIN dbo.LlamadaInput LI ON LI.ID = LL.IDLlamadaInput
		WHERE D.IDFactura = @IDFactura
			AND LL.EsGratis = 1
			AND (EXISTS (SELECT 1 FROM dbo.Parentesco P WHERE P.IDCliente = @IDClienteNumeroDesde AND P.IDPariente = @IDClienteNumeroA)
				OR EXISTS (SELECT 1 FROM dbo.Parentesco P WHERE P.IDPariente = @IDClienteNumeroDesde AND P.IDCliente = @IDClienteNumeroA))

        -- Calculate excess minutes and data
        IF (@minutosTotales > @minutosBase)
        BEGIN
            SET @minutosExceso = @minutosTotales - @minutosBase;
        END

        IF (@gigasTotales > @gigasBase)
        BEGIN
            SET @gigasExceso = @gigasTotales - @gigasBase;
        END

        -- Return result code and billing details
        SELECT @outResultCode AS outResultCode;

        SELECT @tarifaBase AS 'Tarifa base'
             , @minutosBase AS 'Minutos de tarifa base'
             , @minutosExceso AS 'Minutos en exceso a tarifa base'
             , @gigasBase AS 'Gigas de tarifa base'
             , @gigasExceso AS 'Gigas en exceso a tarifa base'
             , @minutosFamiliares AS 'Minutos a familiares'
             , (CF.TotalLlamadas911 * @monto911) AS 'Cobro por 911'
             , (CF.TotalMinutos110 * @monto110) AS 'Cobro por 110'
             , (CF.TotalMinutos900 * @monto900) AS 'Cobro por 900'
        FROM dbo.CobroFijo CF
        INNER JOIN dbo.Detalle D ON D.ID = CF.IDDetalle
        WHERE D.IDFactura = @IDFactura;

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