-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Procedimiento:
-- CONSULTA EL USO DE DATOS DE UNA FACTURA ESPECIFICA

-- Descripcion general:
-- Desde la aplicación web, un funcionario debe poder consultar
-- las facturas de un numero en especifico
-- Ademas, para cada factura debe poder consultar su detalle
-- Este consiste en varios aspectos:
	-- informacion de llamadas
	-- informacion de uso de datos

-- En este sp, se considera la informacion relacionada al uso de datos

-- Descripcion de parametros:
	-- @inNumeroTelefono: numero de telefono que se desea consultar
	-- @inFechaFactura: fecha en la que cierra la factura
	-- @outResultCode: resultado de ejecucion del codigo
		-- si el codigo es 0, el codigo se ejecuto correctamente
		-- si es otro valor, ocurrio un error

-- Ejemplo de ejecucion:
	-- DECLARE @outResultCode INT
	-- EXECUTE dbo.ConsultarLlamadasFactura '88888888', 'yyyy-mm'dd', @outResultCode OUTPUT

-- ************************************************************* --

ALTER PROCEDURE dbo.ConsultarUsoDatosFactura
	  @inNumeroTelefono VARCHAR(16)                              -- numero que se desea consultar
	, @inFechaFactura DATE                                       -- fecha de cierre de la factura
	, @outResultCode INT OUTPUT                                  -- resultado de ejecucion del codigo
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

		-- ----------------------------------------------------- --
		-- DECLARAR VARIABLES

        DECLARE @montoUsoDatos MONEY = 0;
		DECLARE @montoUso MONEY;

		DECLARE @gigasBase FLOAT = 0;
		DECLARE @gigasActuales FLOAT = 0;
		DECLARE @gigasTotales FLOAT = 0;

		DECLARE @indiceUsoDatos INT;
		DECLARE @totalUsos INT;
		DECLARE @flagPrimero BIT = 1;

		-- tabla para almacenar el uso de datos relacionado al cliente
		DECLARE @UsoDatosRegistrado TABLE (
			  SEC INT IDENTITY(1,1)
			, Fecha DATE
			, CantidadDatos FLOAT
			, Monto MONEY
		);

		-- ----------------------------------------------------- --
		-- INICIALIZAR VARIABLES

		SELECT @montoUsoDatos = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.NumeroTelefono = @inNumeroTelefono AND ETT.IDTipoElemento = 6;

		SELECT @gigasBase = ETT.Valor
		FROM dbo.ElementoDeTipoTarifa ETT
		INNER JOIN dbo.Contrato C ON C.IDTipoTarifa = ETT.IDTipoTarifa
		WHERE C.NumeroTelefono = @inNumeroTelefono AND ETT.IDTipoElemento = 5;

		-- ----------------------------------------------------- --
		-- OBTENER EL USO DE DATOS

		INSERT INTO @UsoDatosRegistrado (
			  Fecha
			, CantidadDatos
		)
		SELECT
			  UDI.Fecha
			, UDI.CantidadDatos
		FROM dbo.UsoDatosInput UDI
		WHERE UDI.NumeroTelefono = @inNumeroTelefono
			AND (DATEDIFF(MONTH, CONVERT(DATE, UDI.Fecha), @inFechaFactura) < 2
				AND UDI.Fecha < @inFechaFactura)

		-- ----------------------------------------------------- --
		-- CALCULAR EL MONTO POR CANTIDAD TOTAL DE GIGAS USADOS

		SELECT @totalUsos = MAX(UDR.SEC)                         -- total de usos registrados
		FROM @UsoDatosRegistrado UDR;

		SET @indiceUsoDatos = 1                                  -- contador para utilizar el while

		-- mientras no se hayan procesado todos los registros
		WHILE @indiceUsoDatos <= @totalUsos
		BEGIN

			-- obtener la cantidad de gigas asociadas a un uso de datos
			SELECT @gigasActuales = UDR.CantidadDatos
			FROM @UsoDatosRegistrado UDR
			WHERE UDR.SEC = @indiceUsoDatos;

			-- si al sumarle la cantidad a lo ya procesado, sobrepasa la tarifa base
			IF ((@gigasTotales + @gigasActuales) > @gigasBase AND @flagPrimero = 1)
			BEGIN
				-- si es la primera cantidad que sobrepasa la base
				SET @montoUso = (@gigasTotales + @gigasActuales - @gigasBase) * @montoUsoDatos;
				SET @flagPrimero = 0;
			END
			ELSE IF ((@gigasTotales + @gigasActuales) > @gigasBase AND @flagPrimero = 0)
			BEGIN
				-- si no es la primera cantidad que sobrepasa la base
				SET @montoUso = @gigasActuales * @montoUsoDatos;
			END
			ELSE
			BEGIN
				SET @montoUso = 0;
			END

			-- actualizar el monto en la tabla variable
			UPDATE UDR
			SET Monto = @montoUso
			FROM @UsoDatosRegistrado UDR
			WHERE UDR.SEC = @indiceUsoDatos;

			-- actualizar la cantidad total de datos usados
			SET @gigasTotales = @gigasTotales + @gigasActuales;

			-- incrementar contador
			SET @indiceUsoDatos = @indiceUsoDatos + 1;

		END

		-- ----------------------------------------------------- --
		-- RETORNAR RESULTADOS

		SELECT @outResultCode AS outResultCode

		SELECT UDR.Fecha AS 'Fecha'
			, UDR.CantidadDatos AS 'Gigas consumidos'
			, UDR.Monto AS 'Monto por consumo'
		FROM @UsoDatosRegistrado UDR

    END TRY
    BEGIN CATCH

        INSERT INTO ErrorBaseDatos VALUES (
			  SUSER_SNAME()
			, ERROR_NUMBER()
			, ERROR_STATE()
			, ERROR_SEVERITY()
			, ERROR_LINE()
			, ERROR_PROCEDURE()
			, ERROR_MESSAGE()
			, GETDATE()
		);

        SET @outResultCode = 50008;
        SELECT @outResultCode AS outResultCode;

    END CATCH;
    SET NOCOUNT OFF;
END;

-- ************************************************************* --
-- fin del SP para consultar el uso de datos de una factura