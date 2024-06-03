ALTER FUNCTION dbo.CalcularMontoLlamadas (
	  @inIDContrato INT
	, @inFechaOperacion DATE
)
RETURNS INT
AS
BEGIN

	DECLARE @numeroTelefono VARCHAR(32);                         -- numero de telefono del contrato
	DECLARE @IDDetalle INT;                                      -- numero del detalle asociado a la factura actual

	DECLARE @monto911 MONEY;
	DECLARE @cantidadLlamadas911 INT;

	DECLARE @monto110 MONEY;
	DECLARE @cantidadMinutos110 INT;

	DECLARE @monto800 MONEY;                                     -- monto por llamadas 800
	DECLARE @cantidadMinutos800 INT;                             -- cantidad de llamadas recibidas por un numero 800
	
	DECLARE @monto900 MONEY;                                     -- monto por llamadas 900
	DECLARE @cantidadMinutos900 INT;                             -- cantidad de llamadas realizadas a numero 900
	
	DECLARE @tarifaNocturno MONEY;                               -- monto del horario nocturno segun tarifa
	DECLARE @tarifaDiurno MONEY;                                 -- monto del horario diurno segun tarifa
	DECLARE @montoMinuto6 MONEY;
	DECLARE @montoMinuto7 MONEY;

	DECLARE @horaFin DATETIME;                                   -- hora en que termina la llamada
	DECLARE @numeroA VARCHAR(16);
	DECLARE @llamadaGratis BIT;
	DECLARE @cantidadLlamadas INT;                               -- cantidad de llamadas locales realizadas
	DECLARE @llamadaActual INT;                                  -- variable para iterar sobre las llamadas
	DECLARE @cantidadActualMinutos INT;                          -- cantidad de minutos que se han procesado
	DECLARE @cantidadMinutos INT;                                -- cantidad de minutos de la llamada actual
	DECLARE @cantidadMinutosBase INT;                            -- cantidad de minutos de la tarifa

	DECLARE @montoTotal INT; 

	DECLARE @LlamadaRegistrada TABLE (
		  SEC INT IDENTITY(1,1)
		, NumeroA VARCHAR(16)
		, HoraFin DATETIME
		, CantidadMinutos INT
		, EsGratis BIT
	)

	SELECT @numeroTelefono = C.NumeroTelefono
	FROM dbo.Contrato C
	WHERE C.ID = @inIDContrato

	SELECT @IDDetalle = D.ID
	FROM Detalle D
	INNER JOIN Factura F ON D.IDFactura = F.ID
	WHERE @inFechaOperacion = F.FechaFactura AND F.IDContrato = @inIDContrato

	SELECT @monto911 = ETT.Valor
	FROM dbo.ElementoDeTipoTarifa ETT
	INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
	WHERE C.NumeroTelefono = @numeroTelefono AND ETT.IDTipoElemento = 11

	SELECT @cantidadLlamadas911 = ISNULL(SUM(CF.TotalLlamadas911), 0)
	FROM dbo.CobroFijo CF
	WHERE CF.IDDetalle = @IDDetalle

	SELECT @monto110 = ETT.Valor
	FROM dbo.ElementoDeTipoTarifa ETT
	INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
	WHERE C.NumeroTelefono = @numeroTelefono AND ETT.IDTipoElemento = 13

	SELECT @cantidadMinutos110 = ISNULL(SUM(CF.TotalMinutos110), 0)
	FROM dbo.CobroFijo CF
	WHERE CF.IDDetalle = @IDDetalle

	SELECT @monto900 = ETT.Valor
	FROM dbo.ElementoDeTipoTarifa ETT
	WHERE ETT.IDTipoElemento = 10 AND ETT.IDTipoTarifa = 8

	SELECT @cantidadMinutos900 = ISNULL(SUM(CF.TotalMinutos900), 0)
	FROM dbo.CobroFijo CF
	WHERE CF.IDDetalle = @IDDetalle

	SELECT @monto800 = ETT.Valor
	FROM dbo.ElementoDeTipoTarifa ETT
	WHERE ETT.IDTipoTarifa = 7 AND ETT.IDTipoElemento = 9

	------------------

	SET @montoTotal = (@cantidadLlamadas911 * @monto911) + (@cantidadMinutos110 * @monto110) + (@cantidadMinutos900 * @monto900)

	------------------

	IF (@numeroTelefono LIKE '800%' AND LEN(@numeroTelefono) = 11)
	BEGIN
		SELECT @cantidadMinutos800 = ISNULL(SUM(LL.CantidadMinutos), 0)
		FROM dbo.LlamadaLocal LL
		WHERE LL.IDDetalle = @IDDetalle

		SET @montoTotal = @montoTotal + (@monto800 * @cantidadMinutos800)
	END
	ELSE IF (@numeroTelefono LIKE '900%' AND LEN(@numeroTelefono) = 11)
	BEGIN
		SELECT @cantidadMinutos = ISNULL(SUM(LL.CantidadMinutos), 0)
		FROM dbo.LlamadaLocal LL
		WHERE LL.IDDetalle = @IDDetalle

		SET @montoTotal = @montoTotal + (@monto900 * @cantidadMinutos)
	END
	ELSE IF (@numeroTelefono LIKE '8%' AND LEN(@numeroTelefono) = 8)
	BEGIN
		SELECT @cantidadMinutosBase = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 2

		SELECT @tarifaDiurno = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 3

		SELECT @tarifaNocturno = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 4

		SELECT @montoMinuto7 = ETT.Valor --empresa X
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 14

		SELECT @montoMinuto6 = ETT.Valor --empresa Y
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 15

		INSERT INTO @LlamadaRegistrada (
			  NumeroA
			, HoraFin
			, CantidadMinutos
			, EsGratis
		)
		SELECT LI.NumeroA
			, LI.HoraFin
			, LL.CantidadMinutos
			, LL.EsGratis
		FROM dbo.LlamadaInput LI
		INNER JOIN dbo.LlamadaLocal LL ON LL.IDLlamadaInput = LI.ID
		WHERE LL.IDDetalle = @IDDetalle

		SELECT @cantidadLlamadas = COUNT(SEC) FROM @LlamadaRegistrada

		SET @llamadaActual = 1
		SET @cantidadActualMinutos = 0;

		WHILE @llamadaActual <= @cantidadLlamadas
		BEGIN
			SELECT @llamadaGratis = LR.EsGratis
			FROM @LlamadaRegistrada LR
			WHERE LR.SEC = @llamadaActual;

			SELECT @cantidadMinutos = LR.CantidadMinutos
			FROM @LlamadaRegistrada LR
			WHERE LR.SEC = @llamadaActual

			IF (@llamadaGratis = 0 AND @cantidadActualMinutos + @cantidadMinutos > @cantidadMinutosBase)
			BEGIN
				SELECT @horaFin = LR.HoraFin
				FROM @LlamadaRegistrada LR
				WHERE LR.SEC = @llamadaActual

				SELECT @numeroA = LR.NumeroA
				FROM @LlamadaRegistrada LR
				WHERE LR.SEC = @llamadaActual

				IF (@numeroA LIKE '7%')
				BEGIN
					SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @montoMinuto7;
				END
				ELSE IF (@numeroA LIKE '6%')
				BEGIN
					SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @montoMinuto6;
				END
				ELSE
				BEGIN
					IF (DATEPART(HOUR, @horaFin) >= 23 OR DATEPART(HOUR, @horaFin) < 5)
					BEGIN
						SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @tarifaNocturno;
					END
					ELSE
					BEGIN
						SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @tarifaDiurno;
					END
				END
			END

			SET @cantidadActualMinutos = @cantidadActualMinutos + @cantidadMinutos
			SET @llamadaActual = @llamadaActual + 1

		END
	END

	RETURN @montoTotal;
END