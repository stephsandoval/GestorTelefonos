-- Armando Castro, Stephanie Sandoval | Jun 10. 24
-- Tarea Programada 03 | Base de Datos I

-- Funcion escalar:
-- CALCULA EL MONTO REFERENTE A LLAMADAS PARA UNA FACTURA

-- Descripcion general:
-- La factura mensual de cada mes de los clientes incluye un cobro por llamadas
-- Estos datos se necesitan para actualizar la factura al momento de su cierre

-- En esta funcion se calcula ese monto tomando en cuenta que:
	-- el cliente realiza una cierta cantidad de llamadas locales
	-- el cliente realiza una cierta cantidad de llamadas no locales
	-- existe una tarifa noctura y una diurna para llamadas locales
	-- existen montos especificos para cobrar llamadas no locales
	-- existen ciertos montos fijos

-- Entre los montos fijos se considera:
	-- el cobro por minuto de llamada al 110
	-- el cobro por minuto de llamada a un numero 900
	-- el cobro por el servicio 911

-- Descripcion de parametros:
	-- @inIDContrato: contrato para el que se calculan los montos
	-- @inFechaOperacion: fecha en la cual se esta ejecutando el procedimiento

-- Ejemplo de ejecucion:
	-- SELECT dbo.CalcularMontoLlamadas (0, 'yyyy-mm-dd)

-- Notas adicionales:
-- notese que si la cantidad de minutos de todas las llamadas
-- no sobrepasa el valor base, la funcion retornaria 0
-- esto porque la funcion se encarga de determinar el monto sobre la tarifa base
-- (por minutos que sobrepasaron la cantidad base del cliente)

-- ademas, los minutos de llamadas relacionadas con montos fijos,
-- no se consideran dentro de la tarifa basica
-- estos siempre se cobran

-- respecto al monto por llamadas no locales:
	-- este valor se aplica cuando la cantidad de minutos de la llamada
	-- hace que se sobrepase la cantidad base de minutos del tipo de tarifa
	-- entonces, los minutos extras se cobran con estos montos

-- respecto a los montos fijos:
	-- los montos por 110 y 900 se utilizan solo si el cliente llama a esos numeros
	-- en cambio, el monto por el servicio 911 se aplica a todos
	-- es decir, independientemente de si utilizaron el servicio o no durante ese mes

-- ************************************************************* --

ALTER FUNCTION dbo.CalcularMontoLlamadas (
	  @inIDContrato INT                                          -- contrato para el que se calculan montos
	, @inFechaOperacion DATE                                     -- fecha en que se ejecuta la funcion
)
RETURNS INT
AS
BEGIN

	-- ------------------------------------------------------------- --
	-- DECLARAR VARIABLES

	DECLARE @numeroTelefono VARCHAR(32);                         -- numero de telefono del contrato
	DECLARE @IDDetalle INT;                                      -- numero del detalle asociado a la factura actual

	DECLARE @monto911 MONEY;                                     -- valor del monto por el servicio 911
	DECLARE @cantidadLlamadas911 INT;                            -- +++

	DECLARE @monto110 MONEY;                                     -- valor del monto por llamadas 110
	DECLARE @cantidadMinutos110 INT;                             -- cantidad de minutos por llamadas a 110

	DECLARE @monto800 MONEY;                                     -- valor del monto por llamadas 800
	DECLARE @cantidadMinutos800 INT;                             -- cantidad de llamadas recibidas por un numero 800
	
	DECLARE @monto900 MONEY;                                     -- valor del monto por llamadas 900
	DECLARE @cantidadMinutos900 INT;                             -- cantidad de minutos por llamadas a 900
	
	DECLARE @tarifaNocturno MONEY;                               -- monto del horario nocturno segun tarifa
	DECLARE @tarifaDiurno MONEY;                                 -- monto del horario diurno segun tarifa
	DECLARE @montoMinuto6 MONEY;                                 -- monto por llamadas a empresa Y (numeros 6)
	DECLARE @montoMinuto7 MONEY;                                 -- monto por llamadas a empresa X (numeros 7)

	DECLARE @horaFin DATETIME;                                   -- hora en que termina la llamada
	DECLARE @numeroA VARCHAR(16);                                -- numero que recibe la llamada
	DECLARE @llamadaGratis BIT;                                  -- indicador de si la llamada se cobra o no
	DECLARE @cantidadLlamadas INT;                               -- cantidad de llamadas locales realizadas
	DECLARE @llamadaActual INT;                                  -- variable para iterar sobre las llamadas
	DECLARE @cantidadActualMinutos INT;                          -- cantidad de minutos que se han procesado
	DECLARE @cantidadMinutos INT;                                -- cantidad de minutos de la llamada actual
	DECLARE @cantidadMinutosBase INT;                            -- cantidad de minutos de la tarifa
	DECLARE @flagPrimera BIT = 1;                                -- bandera para el while loop

	DECLARE @montoTotal INT;                                     -- monto total por llamadas realizadas

	-- tabla para almacenar las llamadas realizadas
	DECLARE @LlamadaRegistrada TABLE (
		  SEC INT IDENTITY(1,1)
		, NumeroA VARCHAR(16)
		, HoraFin DATETIME
		, CantidadMinutos INT
		, EsGratis BIT
	)

	-- ------------------------------------------------------------- --
	-- INICIALIZAR VARIABLES

	-- valores generales

	-- numero de telefono de cliente
	SELECT @numeroTelefono = C.NumeroTelefono
	FROM dbo.Contrato C
	WHERE C.ID = @inIDContrato

	-- ID del detalle activo (factura abierta)
	SELECT @IDDetalle = D.ID
	FROM Detalle D
	INNER JOIN Factura F ON D.IDFactura = F.ID
	WHERE @inFechaOperacion = F.FechaFactura AND F.IDContrato = @inIDContrato

	-- ---------------------------------------- --
	-- montos fijos

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

	-- ------------------------------------------------------------- --
	-- CALCULAR PRIMER MONTO

	-- calcular monto por llamadas relacionadas con montos fijos
	SET @montoTotal = (@cantidadLlamadas911 * @monto911) + (@cantidadMinutos110 * @monto110) + (@cantidadMinutos900 * @monto900)

	-- ------------------------------------------------------------- --
	-- CALCULAR MONTOS SEGUN TIPO DE NUMERO DEL CLIENTE

	-- si es un numero 800 +++
	IF (@numeroTelefono LIKE '800%' AND LEN(@numeroTelefono) = 11)
	BEGIN
		-- al numero 800 se le cobran todas las llamadas relacionadas con el
		-- (independientemente de si las realizo o las recibio)
		-- sin embargo, se excluyen aquellas llamadas realizadas a otro numero 800
		-- puesto que estas serian gratis para el numero actual

		SELECT @cantidadMinutos800 = ISNULL(SUM(LL.CantidadMinutos), 0)
		FROM dbo.LlamadaLocal LL
		INNER JOIN dbo.LlamadaInput LI ON LI.ID = LL.IDLlamadaInput
		WHERE LL.IDDetalle = @IDDetalle 
			AND ((LI.NumeroA = @numeroTelefono)
			OR (LI.NumeroDesde = @numeroTelefono AND LI.NumeroA NOT LIKE '800%'))

		SET @montoTotal = @montoTotal + (@monto800 * @cantidadMinutos800)
	END

	-- si es un numero 900
	ELSE IF (@numeroTelefono LIKE '900%' AND LEN(@numeroTelefono) = 11)
	BEGIN
		-- se cobran las llamadas realizadas
		-- se utiliza el monto fijo por llamadas 900 para el calculo
		SELECT @cantidadMinutos = ISNULL(SUM(LL.CantidadMinutos), 0)
		FROM dbo.LlamadaLocal LL
		WHERE LL.IDDetalle = @IDDetalle

		SET @montoTotal = @montoTotal + (@monto900 * @cantidadMinutos)
	END

	-- si es un numero con formato 8XXX-XXXX
	ELSE IF (@numeroTelefono LIKE '8%' AND LEN(@numeroTelefono) = 8)
	BEGIN
		-- obtener los montos necesarios para los calculos

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

		SELECT @montoMinuto7 = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 14

		SELECT @montoMinuto6 = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.ID = @inIDContrato AND ETT.IDTipoElemento = 15

		-- guardar las llamadas realizadas por el usuario en el periodo actual de cobro
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

		-- ---------------------------------------- --
		-- CALCULAR MONTO SOBRE TARIFA BASE (WHILE)

		-- cantidad de llamdas realizadas
		SELECT @cantidadLlamadas = COUNT(SEC) FROM @LlamadaRegistrada

		-- inicializar contadores
		SET @llamadaActual = 1
		SET @cantidadActualMinutos = 0;

		-- mientras no se hayan revisado todas las llamadas en la tabla
		WHILE @llamadaActual <= @cantidadLlamadas
		BEGIN
			SELECT @llamadaGratis = LR.EsGratis                      -- determinar si la llamada es gratis
			FROM @LlamadaRegistrada LR
			WHERE LR.SEC = @llamadaActual;

			SELECT @cantidadMinutos = LR.CantidadMinutos             -- obtener duracion de la llamada
			FROM @LlamadaRegistrada LR
			WHERE LR.SEC = @llamadaActual

			-- si la llamada no es gratis y al sumar los minutos,
			-- se sobrepasa la cantidad base establecida por el tipo de tarifa
			IF (@llamadaGratis = 0 AND @cantidadActualMinutos + @cantidadMinutos > @cantidadMinutosBase)
			BEGIN
				SELECT @horaFin = LR.HoraFin                         -- determinar a que hora termina la llamada
				FROM @LlamadaRegistrada LR
				WHERE LR.SEC = @llamadaActual

				SELECT @numeroA = LR.NumeroA                         -- determinar quien recibe la llamada
				FROM @LlamadaRegistrada LR
				WHERE LR.SEC = @llamadaActual

				-- si la llamada va hacia la empresa X
				IF (@numeroA LIKE '7%')
				BEGIN
					-- si es la primera llamada que sobrepasa la cantidad base de minutos
					IF (@flagPrimera = 1)
					BEGIN
						-- calcular monto por minutos que sobrepasan y apagar bandera
						SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @montoMinuto7;
						SET @flagPrimera = 0;
					END
					ELSE
					-- si no es la primera llamada que sobrepasa la cantidad base de minutos
					BEGIN
						-- calcular monto (todos los minutos estan sobre la cantidad base)
						SET @montoTotal = @montoTotal + (@cantidadMinutos * @montoMinuto7);
					END
				END
				-- si la llamada va hacia la empresa Y
				ELSE IF (@numeroA LIKE '6%')
				BEGIN
					-- si es la primera llamada que sobrepasa la cantidad base de minutos
					IF (@flagPrimera = 1)
					BEGIN
						-- calcular monto por minutos que sobrepasan y apagar bandera
						SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @montoMinuto6;
						SET @flagPrimera = 0;
					END
					ELSE
					-- si no es la primera llamada que sobrepasa la cantidad base de minutos
					BEGIN
						-- calcular monto (todos los minutos estan sobre la cantidad base)
						SET @montoTotal = @montoTotal + (@cantidadMinutos * @montoMinuto6);
					END
				END
				ELSE
				-- si la llamada va hacia la empresa Z
				BEGIN
					IF (DATEPART(HOUR, @horaFin) >= 23 OR DATEPART(HOUR, @horaFin) < 5)
					-- si la llamada sucede en horario nocturno
					BEGIN
						-- si es la primera llamada que sobrepasa la cantidad base de minutos
						IF (@flagPrimera = 1)
						BEGIN
							-- calcular monto por minutos que sobrepasan y apagar bandera
							SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @tarifaNocturno;
							SET @flagPrimera = 0;
						END
						ELSE
						-- si no es la primera llamada que sobrepasa la cantidad base de minutos
						BEGIN
							-- calcular monto (todos los minutos estan sobre la cantidad base)
							SET @montoTotal = @montoTotal + (@cantidadMinutos * @tarifaNocturno);
						END
					END
					ELSE
					-- si la llamada sucede en horario diurno
					BEGIN
						-- si es la primera llamada que sobrepasa la cantidad base de minutos
						IF (@flagPrimera = 1)
						BEGIN
							-- calcular monto por minutos que sobrepasan y apagar bandera
							SET @montoTotal = @montoTotal + (@cantidadActualMinutos + @cantidadMinutos - @cantidadMinutosBase) * @tarifaDiurno;
							SET @flagPrimera = 0;
						END
						ELSE
						-- si no es la primera llamada que sobrepasa la cantidad base de minutos
						BEGIN
							-- calcular monto (todos los minutos estan sobre la cantidad base)
							SET @montoTotal = @montoTotal + (@cantidadMinutos * @tarifaDiurno);
						END
					END
				END
			END

			-- actualizar la cantidad de minutos procesados actualmente
			SET @cantidadActualMinutos = @cantidadActualMinutos + @cantidadMinutos

			-- actualizar el contador que itera sobre la tabla
			SET @llamadaActual = @llamadaActual + 1

		END
	END

	RETURN @montoTotal;
END

-- ************************************************************* --
-- fin de la funcion para calcular montos por llamadas