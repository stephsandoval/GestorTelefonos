ALTER FUNCTION dbo.CalcularMontoUsoDatos (
      @inIDContrato INT
    , @inFechaOperacion DATE
)
RETURNS MONEY
AS
BEGIN

    -- DECLARAR VARIABLES:
    DECLARE @IDDetalle INT;
    DECLARE @tarifaDatos MONEY = 0;
    DECLARE @cantidadDatos FLOAT = 0;
    DECLARE @cantidadDatosBase FLOAT = 0;
    DECLARE @montoTotal MONEY = 0;

    -- INICIALIZAR VARIABLES:
    SELECT @IDDetalle = D.ID
    FROM dbo.Detalle D
    INNER JOIN Factura F ON D.IDFactura = F.ID
    WHERE @inFechaOperacion = F.FechaFactura AND F.IDContrato = @inIDContrato;

    -- CALCULAR MONTOS:
    SELECT @tarifaDatos = ETT.Valor
    FROM dbo.ElementoDeTipoTarifa ETT
    INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
    WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 6;

    SELECT @cantidadDatosBase = ETT.Valor
    FROM dbo.ElementoDeTipoTarifa ETT
    INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
    WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 5;

    SELECT @cantidadDatos = ISNULL(SUM(UD.CantidadDatos), 0)
	FROM dbo.UsoDatos UD
	WHERE UD.IDDetalle = @IDDetalle;

	SET @montoTotal = (@cantidadDatos - @cantidadDatosBase) * @tarifaDatos;

    RETURN @montoTotal;
END;
