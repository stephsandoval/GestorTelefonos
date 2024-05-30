ALTER FUNCTION dbo.CalcularMontosFinalesFactura (
	  @inIDContrato INT
	, @inFechaOperacion DATE
)
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
	DECLARE @montoLlamadas MONEY;
	DECLARE @montoDatos MONEY;

	DECLARE @IDFactura INT;
	DECLARE @IDDetalle INT;
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

	SELECT @montoLlamadas = dbo.CalcularMontoLlamadas (@inIDContrato, @inFechaOperacion)
	SELECT @montoDatos = dbo.CalcularMontoUsoDatos (@inIDContrato, @inFechaOperacion)

	SET @montoAntesIVA = @montoAntesIVA + @montoLlamadas + @montoDatos

	SELECT @IDFactura = F.ID
	FROM Factura F
	WHERE F.IDContrato = @inIDContrato AND F.FechaFactura = @inFechaOperacion;

	SELECT @IDDetalle = D.ID
	FROM dbo.Detalle D
	WHERE D.IDFactura = @IDFactura

	SELECT @montoFijo = SUM(ETT.Valor)
	FROM CobroFijo CF
	INNER JOIN ElementoDeTipoTarifa ETT ON ETT.ID = CF.IDElementoDeTipoTarifa
	INNER JOIN TipoElemento TE ON TE.ID = ETT.IDTipoElemento
	WHERE CF.IDDetalle = @IDDetalle AND TE.IDTipoUnidad = 1;

	SET @montoAntesIVA = @montoAntesIVA + @montoFijo;

	-- calcular el monto despues de aplicar IVA:
	SELECT @porcentajeIVA = ETT.Valor
	FROM CobroFijo CF
	INNER JOIN ElementoDeTipoTarifa ETT ON ETT.ID = CF.IDElementoDeTipoTarifa
	INNER JOIN TipoElemento TE ON TE.ID = ETT.IDTipoElemento
	WHERE CF.IDDetalle = @IDDetalle AND TE.IDTipoUnidad = 3;

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