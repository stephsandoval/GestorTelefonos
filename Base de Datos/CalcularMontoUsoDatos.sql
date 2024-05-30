CREATE FUNCTION dbo.CalcularMontoUsoDatos (
      @inIDContrato INT
    , @inFechaOperacion DATE
)
RETURNS MONEY
AS
BEGIN

    -- DECLARAR VARIABLES:
    DECLARE @IDDetalle INT;
    DECLARE @tarifaDatos MONEY;
    DECLARE @cantidadDatos FLOAT;
    DECLARE @cantidadUsoDatos INT;
    DECLARE @usoDatosActual INT;
    DECLARE @cantidadActualDatos FLOAT;
    DECLARE @cantidadDatosBase FLOAT;
    DECLARE @montoTotal MONEY = 0;  -- Initialize @montoTotal to 0

    DECLARE @UsoDatosRegistrado TABLE (
          SEC INT IDENTITY(1,1)
        , CantidadDatos FLOAT
    );

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

    INSERT INTO @UsoDatosRegistrado (CantidadDatos)
    SELECT UD.CantidadDatos
    FROM dbo.UsoDatos UD
    WHERE UD.IDDetalle = @IDDetalle;

    SELECT @cantidadUsoDatos = COUNT(SEC) FROM @UsoDatosRegistrado;

    SET @usoDatosActual = 1;
    SET @cantidadActualDatos = 0;

    WHILE @usoDatosActual <= @cantidadUsoDatos
    BEGIN
        SELECT @cantidadDatos = UDR.CantidadDatos
        FROM @UsoDatosRegistrado UDR
        WHERE UDR.SEC = @usoDatosActual;

        IF (@cantidadActualDatos + @cantidadDatos > @cantidadDatosBase)
        BEGIN
            -- Calculate excess usage amount
            SET @montoTotal = @montoTotal + (@cantidadActualDatos + @cantidadDatos - @cantidadDatosBase) * @tarifaDatos;
        END

        -- Update the total actual data used so far
        SET @cantidadActualDatos = @cantidadActualDatos + @cantidadDatos;
        SET @usoDatosActual = @usoDatosActual + 1;
    END;

    RETURN @montoTotal;
END;
