ALTER FUNCTION dbo.CalcularMontosFinalesFactura (
	  @inIDContrato INT
	, @inFechaOperacion DATE
)
RETURNS @MontoFactura TABLE (
	  MontoAntesIVA MONEY
	, MontoDespuesIVA MONEY
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

	DECLARE @porcentajeIVA FLOAT;
	DECLARE @montoDespuesIVA MONEY;

	-- INICIALIZAR VARIABLES:

	-- calcular el monto antes de aplicar IVA:
	SELECT @montoAntesIVA = F.TotalAntesIVA 
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

	-- calcular el monto despues de aplicar IVA:
	SELECT @porcentajeIVA = ETT.Valor
	FROM dbo.ElementoDeTipoTarifa ETT
	INNER JOIN dbo.Contrato C ON C.ID = @inIDContrato
	WHERE C.IDTipoTarifa = ETT.IDTipoTarifa AND ETT.IDTipoElemento = 12

	SET @porcentajeIVA = (@porcentajeIVA + 100) / 100
	SET @montoDespuesIVA = @montoAntesIVA * @porcentajeIVA

	-- INSERTAR DATOS EN TABLA DE RETORNO:
	INSERT INTO @MontoFactura (
		  MontoAntesIVA
		, MontoDespuesIVA
		, MontoTotal
	)
	VALUES (@montoAntesIVA
		, @montoDespuesIVA
		, @montoDespuesIVA
	)

	RETURN;
END;