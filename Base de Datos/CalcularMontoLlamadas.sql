ALTER FUNCTION dbo.CalcularMontoLlamadas (
	  @inIDContrato INT
	, @inFechaOperacion DATE
)
RETURNS INT
AS
BEGIN

	-- DECLARAR VARIABLES:

	DECLARE @montoTotal INT;
	DECLARE @IDDetalle INT;
	DECLARE @cantidadLlamada900 INT;
	DECLARE @monto900 MONEY;
	DECLARE @cantidadLlamadas INT;
	DECLARE @llamadaActual INT;
	DECLARE @cantidadActualMinutos INT;
	DECLARE @tarifaNocturno MONEY;
	DECLARE @tarifaDiurno MONEY;
	DECLARE @cantidadMinutos INT;
	DECLARE @cantidadMinutosBase INT;
	DECLARE @horaFin DATETIME;

	DECLARE @LlamadaRegistradaZ TABLE (
		  SEC INT IDENTITY(1,1)
		, HoraFin DATETIME
		, CantidadMinutos INT
	)

	-- INICIALIZAR VARIABLES:

	SELECT @tarifaDiurno = ETT.Valor
	FROM dbo.ElementoDeTipoTarifa ETT
	INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
	WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 3

	SELECT @tarifaNocturno = ETT.Valor
	FROM dbo.ElementoDeTipoTarifa ETT
	INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
	WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 4

	SELECT @cantidadMinutosBase = ETT.Valor
	FROM dbo.ElementoDeTipoTarifa ETT
	INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
	WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 2

	SELECT @IDDetalle = D.ID
	FROM Detalle D
	INNER JOIN Factura F ON D.IDFactura = F.ID
	WHERE @inFechaOperacion = F.FechaFactura AND F.IDContrato = @inIDContrato

	SELECT @cantidadLlamada900 = COUNT(L.ID)
	FROM dbo.Llamada L
	INNER JOIN dbo.LlamadaInput LI ON LI.ID = L.IDLlamadaInput
	WHERE L.IDDetalle = @IDDetalle AND LI.NumeroA LIKE '900%'

	SELECT @monto900 = ETT.Valor
	FROM dbo.ElementoDeTipoTarifa ETT
	WHERE ETT.IDTipoElemento = 10 AND ETT.IDTipoTarifa = 8
	 
	INSERT INTO @LlamadaRegistradaZ (
		  HoraFin
		, CantidadMinutos
	)
	SELECT LI.HoraFin
		, L.CantidadMinutos
	FROM dbo.LlamadaInput LI
	INNER JOIN dbo.Llamada L ON L.IDLlamadaInput = LI.ID
	WHERE L.IDDetalle = @IDDetalle AND LI.NumeroA LIKE '8%' AND LEN(LI.NumeroA) = 8

	SET @llamadaActual = 1
	SELECT @cantidadLlamadas = COUNT(SEC) FROM @LlamadaRegistradaZ

	SET @montoTotal = @cantidadLlamada900 * @monto900
	SET @cantidadActualMinutos = 0;

	WHILE @llamadaActual <= @cantidadLlamadas
	BEGIN
		SELECT @cantidadMinutos = LRZ.CantidadMinutos
		FROM @LlamadaRegistradaZ LRZ
		WHERE LRZ.SEC = @llamadaActual

		DECLARE @x INT;
		SET @x = @cantidadActualMinutos + @cantidadMinutos;

		IF (@cantidadActualMinutos + @cantidadMinutos > @cantidadMinutosBase)
		BEGIN
			SELECT @horaFin = LRZ.HoraFin
			FROM @LlamadaRegistradaZ LRZ
			WHERE LRZ.SEC = @llamadaActual

			IF (DATEPART(HOUR, @horaFin) >= 23 OR DATEPART(HOUR, @horaFin) < 5)
			BEGIN
				SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @tarifaNocturno;
			END
			ELSE
			BEGIN
				SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @tarifaDiurno;
			END
		END
		
		SET @cantidadActualMinutos = @cantidadActualMinutos + @cantidadMinutos
		SET @llamadaActual = @llamadaActual + 1
	END;

	RETURN @montoTotal;
END