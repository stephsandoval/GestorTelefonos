-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Funcion tabular:
-- CALCULA LOS MONTOS POR USO DE DATOS

-- Descripcion general:
-- CALCULA EL MONTO REFERENTE A USO DE DATOS PARA UNA FACTURA

-- Descripcion general:
-- La factura mensual de cada mes de los clientes incluye un cobro por uso de datos
-- Estos datos se necesitan para actualizar la factura al momento de su cierre

-- En esta funcion se calcula ese monto tomando en cuenta que:
	-- existe una cantidad base de gigas asociada a cada tarifa
    -- si la suma total de gigas no supera la tarifa, no se cobran

-- Descripcion de parametros:
	-- @inIDContrato: contrato para el que se calculan los montos
	-- @inFechaOperacion: fecha en la cual se esta ejecutando el procedimiento

-- Ejemplo de ejecucion:
	-- SELECT dbo.CalcularMontoUsoDatos (0, 'yyyy-mm-dd)

-- ************************************************************* --

ALTER FUNCTION dbo.CalcularMontoUsoDatos (
      @inIDContrato INT                                          -- contrato para el que se calculan los montos
    , @inFechaOperacion DATE                                     -- fecha en que se ejecuta la funcion
)
RETURNS MONEY
AS
BEGIN

    -- ----------------------------------------------------- --
    -- DECLARAR VARIABLES

    DECLARE @IDDetalle INT;
    DECLARE @tarifaDatos MONEY = 0;
    DECLARE @cantidadDatos FLOAT = 0;
    DECLARE @cantidadDatosBase FLOAT = 0;
    DECLARE @montoTotal MONEY = 0;

    -- ----------------------------------------------------- --
    -- INICIALIZAR VARIABLES

    SELECT @IDDetalle = D.ID
    FROM dbo.Detalle D
    INNER JOIN Factura F ON D.IDFactura = F.ID
    WHERE @inFechaOperacion = F.FechaFactura AND F.IDContrato = @inIDContrato;

    -- ----------------------------------------------------- --
    -- CALCULAR MONTO

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

    -- si el uso de datos supera la base
	IF (@cantidadDatos > @cantidadDatosBase)
	BEGIN
        -- calcular el monto por datos sobre la base
		SET @montoTotal = (@cantidadDatos - @cantidadDatosBase) * @tarifaDatos;
	END

    RETURN @montoTotal;
END;

-- ************************************************************* --
-- fin de la funcion para calcular el monto de uso de datos