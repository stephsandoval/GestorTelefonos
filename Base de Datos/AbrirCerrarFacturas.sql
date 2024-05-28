ALTER PROCEDURE dbo.AbrirCerrarFacturas
      @inFechaOperacion DATE
    , @outResultCode INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        -- DECLARAR VARIABLES:
        DECLARE @ClienteCierre TABLE (
              SEC INT IDENTITY(1,1)
            , IDContrato INT
			, MontoAntesIVA MONEY
			, MontoDespuesIVA MONEY
			, MultaFacturaPrevia MONEY
			, MontoTotal MONEY
        );

		DECLARE @ClienteApertura TABLE (
			  SEC INT IDENTITY(1,1)
			, IDContrato INT
		);

		DECLARE @NuevaFactura TABLE (
              IDFactura INT
            , IDContrato INT
        );

		DECLARE @NuevoDetalle TABLE (
			  IDDetalle INT
			, IDFactura INT
		);

        -- INICIALIZAR VARIABLES:
        SET @outResultCode = 0;

        -- INICIALIZAR TABLAS:
		INSERT INTO @ClienteCierre (
			  IDContrato
			, MontoAntesIVA
			, MontoDespuesIVA
			, MultaFacturaPrevia
			, MontoTotal
		)
		SELECT CC.IDContrato
			, MT.MontoAntesIVA
			, MT.MontoDespuesIVA
			, MT.MultaFacturasPendientes
			, MT.MontoTotal
		FROM dbo.ObtenerContratosCierre (@inFechaOperacion) CC
		CROSS APPLY dbo.CalcularMontosFinalesFactura (CC.IDContrato, @inFechaOperacion) MT;

		INSERT INTO @ClienteApertura (IDContrato)
		SELECT C.ID
		FROM dbo.Contrato C
		WHERE C.FechaContrato = @inFechaOperacion;

		INSERT INTO @ClienteApertura (IDContrato)
		SELECT IDContrato
		FROM dbo.ObtenerContratosCierre (@inFechaOperacion);

		--SELECT * FROM @ClienteCierre;

        --SELECT IDContrato
        --FROM @ClienteCierre;

		--SELECT IDContrato
		--FROM @ClienteApertura;

		BEGIN TRANSACTION tOperarFactura

			-- cerrar facturas:
			UPDATE F
			SET 
				TotalPagarAntesIVA = CC.MontoAntesIVA,
				TotalPagarDespuesIVA = CC.MontoDespuesIVA,
				MultaFacturasPrevias = CC.MultaFacturaPrevia,
				TotalPagar = CC.MontoTotal
			FROM dbo.Factura F
			INNER JOIN @ClienteCierre CC ON F.IDContrato = CC.IDContrato;

			-- abrir nuevas facturas:
			INSERT INTO dbo.Factura (IDContrato
				, TotalPagarAntesIVA
				, TotalPagarDespuesIVA
				, MultaFacturasPrevias
				, TotalPagar
				, FechaFactura
				, FechaPago
				, EstaPagada
			)
			OUTPUT INSERTED.ID, INSERTED.IDContrato INTO @NuevaFactura (IDFactura, IDContrato)
			SELECT CA.IDContrato
				, CASE 
					WHEN ETT.Valor = NULL THEN 0 
					WHEN ETT.IDTipoElemento = 9 OR ETT.IDTipoElemento = 10 THEN 0
					ELSE ETT.VALOR 
				  END
				, 0
				, 0
				, 0
				, dbo.GenerarFechaCierreFactura (@inFechaOperacion)
				, dbo.GenerarFechaPagoFactura (@inFechaOperacion, CA.IDContrato)
				, 0
			FROM @ClienteApertura CA
			INNER JOIN dbo.Contrato C ON CA.IDContrato = C.ID
			INNER JOIN dbo.ElementoDeTipoTarifa ETT ON C.IDTipoTarifa = ETT.IDTipoTarifa
			WHERE ETT.IDTipoElemento = 1 OR ETT.IDTipoElemento = 9 OR ETT.IDTipoElemento = 10
			ORDER BY CA.SEC

			INSERT INTO dbo.Detalle (IDFactura)
			OUTPUT Inserted.ID, Inserted.IDFactura INTO @NuevoDetalle (IDDetalle, IDFactura) 
            SELECT NF.IDFactura
            FROM @NuevaFactura NF;

			INSERT INTO dbo.CobroFijo (IDDetalle
				, IDElementoDeTipoTarifa)
            SELECT ND.IDDetalle
				, ETT.ID
            FROM @NuevoDetalle ND
            INNER JOIN dbo.Factura F ON ND.IDFactura = F.ID
            INNER JOIN dbo.Contrato C ON F.IDContrato = C.ID
			INNER JOIN dbo.ElementoDeTipoTarifa ETT ON C.IDTipoTarifa = ETT.IDTipoTarifa
			INNER JOIN dbo.TipoElemento TE ON ETT.IDTipoElemento = TE.ID
            WHERE TE.EsObligatorio = 1;

		COMMIT TRANSACTION tOperarFactura

        SELECT @outResultCode AS outResultCode;

    END TRY
    BEGIN CATCH

		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION tOperarFactura;

        INSERT INTO ErrorBaseDatos VALUES (
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