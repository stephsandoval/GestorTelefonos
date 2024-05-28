ALTER FUNCTION dbo.CalcularMontoLlamadas (
	  @inIDContrato INT
	, @inFechaOperacion DATE
)
RETURNS INT
AS
BEGIN

	-- DECLARAR VARIABLES:

	DECLARE @numeroTelefono VARCHAR(32);
	DECLARE @IDDetalle INT;

	DECLARE @monto800 INT;
	DECLARE @cantidadLlamadasRecibidas INT;
	
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

	DECLARE @montoTotal INT;

	DECLARE @LlamadaRegistradaZ TABLE (
		  SEC INT IDENTITY(1,1)
		, HoraFin DATETIME
		, CantidadMinutos INT
	)

	-- ------------------------------------------------------------- --
	-- INICIALIZAR VARIABLES:

	-- identificar el numero de telefono que se esta revisando
	SELECT @numeroTelefono = C.NumeroTelefono
	FROM dbo.Contrato C
	WHERE C.ID = @inIDContrato

	-- obtener el id del detalle asociado con el numero para la factura actual
	SELECT @IDDetalle = D.ID
	FROM Detalle D
	INNER JOIN Factura F ON D.IDFactura = F.ID
	WHERE @inFechaOperacion = F.FechaFactura AND F.IDContrato = @inIDContrato

	-- ------------------------------------------------------------- --
	-- CALCULAR MONTOS:

	-- si el numero es de tipo 800 (paga todas las llamadas, recibidas y hechas)
	IF (@numeroTelefono LIKE '800%')
	BEGIN
		-- encontrar el monto para las llamadas 800
		SELECT @monto800 = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		WHERE ETT.IDTipoTarifa = 7 AND ETT.IDTipoElemento = 9

		-- encontrar la cantidad de llamadas asociadas al numero
		SELECT @cantidadLlamadasRecibidas = SUM(L.CantidadMinutos)
		FROM dbo.Llamada L WHERE L.IDDetalle = @IDDetalle

		-- calcular el monto total para las llamadas
		SET @montoTotal = @monto800 * @cantidadLlamadasRecibidas;
	END
	ELSE
	-- si el numero no es de tipo 800
	BEGIN
		-- PARA LLAMADAS LOCALES:
		-- 1. obtener valores para calcular los montos por llamadas a 90

		-- obtener la cantidad de llamadas a numero 900
		SELECT @cantidadLlamada900 = COUNT(L.ID)
		FROM dbo.Llamada L
		INNER JOIN dbo.LlamadaInput LI ON LI.ID = L.IDLlamadaInput
		WHERE L.IDDetalle = @IDDetalle AND LI.NumeroA LIKE '900%'

		-- obtener el monto para las llamadas hacia numero 900
		SELECT @monto900 = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		WHERE ETT.IDTipoElemento = 10 AND ETT.IDTipoTarifa = 8

		-- agregar el monto por llamadas a 900 al monto total
		SET @montoTotal = @cantidadLlamada900 * @monto900

		-- ---------------------------------------- --
		-- 2. obtener valores para calcular los montos por llamadas a 8XXX-XXXX

		-- obtener la tarifa para horario diurno segun tipo de tarifa
		SELECT @tarifaDiurno = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 3

		-- obtener la tarifa para horario nocturno segun tipo de tarifa
		SELECT @tarifaNocturno = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 4

		-- obtener la cantidad de minutos base
		SELECT @cantidadMinutosBase = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 2

		-- ---------------------------------------- --
	 
		-- obtener la cantidad de llamadas locales realizadas
		INSERT INTO @LlamadaRegistradaZ (
			  HoraFin
			, CantidadMinutos
		)
		SELECT LI.HoraFin
			, L.CantidadMinutos
		FROM dbo.LlamadaInput LI
		INNER JOIN dbo.Llamada L ON L.IDLlamadaInput = LI.ID
		INNER JOIN dbo.LlamadaLocal LL ON LL.IDLlamada = L.ID
		WHERE L.IDDetalle = @IDDetalle

		-- obtener la cantidad de llamadas realizadas para poder iterar
		SELECT @cantidadLlamadas = COUNT(SEC) FROM @LlamadaRegistradaZ

		-- ---------------------------------------- --

		SET @llamadaActual = 1
		SET @cantidadActualMinutos = 0;

		-- mientras no se hayan procesado todas las llamadas
		WHILE @llamadaActual <= @cantidadLlamadas
		BEGIN
			-- obtener la cantidad de minutos que duro la llamada actual
			SELECT @cantidadMinutos = LRZ.CantidadMinutos
			FROM @LlamadaRegistradaZ LRZ
			WHERE LRZ.SEC = @llamadaActual

			-- si al sumar la cantidad de minutos se pasa de los minutos base
			IF (@cantidadActualMinutos + @cantidadMinutos > @cantidadMinutosBase)
			BEGIN
				-- determinar el horario de la llamada
				SELECT @horaFin = LRZ.HoraFin
				FROM @LlamadaRegistradaZ LRZ
				WHERE LRZ.SEC = @llamadaActual

				-- si la llamada sucede en horario nocturno (aplica tarifa nocturna)
				IF (DATEPART(HOUR, @horaFin) >= 23 OR DATEPART(HOUR, @horaFin) < 5)
				BEGIN
					-- agregar al monto total el cobro por los minutos adicionales segun tarifa nocturna
					SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @tarifaNocturno;
				END
				ELSE
				-- si la llamada sucede en horario diurno
				BEGIN
					-- agregar al monto total el cobro por los minutos adicionales segun tarifa diurna
					SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @tarifaDiurno;
				END
			END
		
			-- sumar los minutos de la llamada a la cantidad de minutos que se han registrado
			SET @cantidadActualMinutos = @cantidadActualMinutos + @cantidadMinutos
			SET @llamadaActual = @llamadaActual + 1
		END;
	END

	RETURN @montoTotal;
END