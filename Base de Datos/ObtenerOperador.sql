-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Funcion escalar:
-- DETERMINA EL OPERADOR DE UN NUMERO DE TELEFONO

-- Descripcion general:
-- Para algunos calculos a lo largo de la base de datos
-- es importante conocer los operadores de cada numero de telefono
-- Esta funcion permite determinar lo anterior

-- Descripcion de parametros:
	-- @inNumeroTelefono: numero del que se desea conocer el operador

-- Ejemplo de ejecucion:
	-- SELECT dbo.ObtenerOperador ('88888888')

-- ************************************************************* --

ALTER FUNCTION dbo.ObtenerOperador (@inNumeroTelefono VARCHAR(16))
RETURNS INT
AS
BEGIN

	-- ----------------------------------------------------- --
	-- DECLARAR VARIABLES

	DECLARE @IDOperador INT;

	-- ----------------------------------------------------- --
	-- INICIALIZAR VARIABLES

	SELECT @IDOperador = O.ID
	FROM dbo.Operador O
	WHERE O.DigitoPrefijoPrincipal = SUBSTRING(@inNumeroTelefono, 1, 1) 
		OR O.DigitoPrefijoSecundario = SUBSTRING(@inNumeroTelefono, 1, 1)

	RETURN @IDOperador;

END;

-- ************************************************************* --
-- fin de la funcion para determinar el operador