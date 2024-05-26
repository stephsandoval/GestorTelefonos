ALTER FUNCTION dbo.CalcularMontosFactura (@inIDContrato INT)
RETURNS @MontoFactura TABLE (
	MontoAntesIVA MONEY
	, MontoDespuesIVA MONEY
	, MultaFacturasPendientes MONEY
	, MontoTotal MONEY
)
AS
BEGIN

	-- DECLARAR VARIABLES:

	DECLARE @montoAntesIVA MONEY;
	DECLARE @montoFijo MONEY;

	DECLARE @porcentajeIVA FLOAT;
	DECLARE @montoDespuesIVA MONEY;

	DECLARE @cantidadFacturasPendientes INT;
	DECLARE @multaFacturasPendientes MONEY;
	DECLARE @valorMulta INT;

	DECLARE @montoTotal MONEY;

	-- INICIALIZAR VARIABLES:

	-- calcular el monto antes de aplicar IVA:
	SELECT @montoAntesIVA = F.TotalPagarAntesIVA 
	FROM Factura F
	WHERE F.IDContrato = @inIDContrato

	SELECT @montoFijo = SUM(TE.Valor)
	FROM TipoElemento TE
	WHERE TE.EsFijo = 1 AND TE.ID != 12

	SET @montoAntesIVA = @montoAntesIVA + @montoFijo;

	-- calcular el monto despues de aplicar IVA:
	SELECT @porcentajeIVA = ETT.Valor
	FROM ElementoDeTipoTarifa ETT
	WHERE ETT.IDTipoElemento = 12

	SET @porcentajeIVA = (@porcentajeIVA + 100) / 100
	SET @montoDespuesIVA = @montoAntesIVA * @porcentajeIVA

	-- calcular el monto por facturas pendientes:
	SET @valorMulta = 0;

	SELECT @cantidadFacturasPendientes = COUNT(F.ID)
	FROM Factura F
	WHERE F.IDContrato = @inIDContrato AND F.EstaPagada = 0

	SELECT @valorMulta = ETT.Valor
	FROM ElementoDeTipoTarifa ETT
	INNER JOIN Contrato C ON C.ID = @inIDContrato
	WHERE ETT.IDTipoElemento = 8 AND ETT.IDTipoTarifa = C.IDTipoTarifa

	SET @multaFacturasPendientes = @cantidadFacturasPendientes * @valorMulta;

	-- calcular el monto total:
	SET @montoTotal = @montoDespuesIVA + @multaFacturasPendientes;

	-- INSERTAR DATOS EN TABLA DE RETORNO:
	INSERT INTO @MontoFactura (MontoAntesIVA
		, MontoDespuesIVA
		, MultaFacturasPendientes
		, MontoTotal
	)
	VALUES (@montoAntesIVA
		, @montoDespuesIVA
		, @multaFacturasPendientes
		, @montoTotal
	)

	RETURN;
END;