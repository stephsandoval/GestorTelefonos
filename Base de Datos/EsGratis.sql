-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Funcion escalar:
-- DETERMINA SI LA LLAMADA ES GRATIS

-- Descripcion general:
-- Al calcular los montos por llamadas de las facturas, 
-- se puede dar que alguna duracion no se tome en cuenta por ser gratis
-- La condicion de gratis se da si:
	-- la llamada es entre familiares
	
-- esta funcion se encarga de determinar si entre A y B existe:
	-- relacion familiar de A a B
	-- relacion familiar de B a A

-- Descripcion de parametros:
	-- @inNumeroDesde: primer contrato de la relacion
	-- @inNumeroA: segundo contrato de la relacion

-- Ejemplo de ejecucion:
	-- SELECT dbo.EsFamiliar ('88888888', '88889999')

-- ************************************************************* --

ALTER FUNCTION dbo.EsFamiliar (@inNumeroDesde VARCHAR(16), @inNumeroA VARCHAR(16))
RETURNS BIT
AS
BEGIN

	-- ----------------------------------------------------- --
	-- DECLARAR VARIABLES

	DECLARE @condicionFamiliar BIT = 0;
	DECLARE @IDClienteNumeroDesde INT;
	DECLARE @IDClienteNumeroA INT;

	-- ----------------------------------------------------- --
	-- INICIALIZAR VARIABLES

	SELECT @IDClienteNumeroDesde = C.IDCliente
	FROM dbo.Contrato C
	WHERE C.NumeroTelefono = @inNumeroDesde;

	SELECT @IDClienteNumeroA = C.IDCliente
	FROM dbo.Contrato C
	WHERE C.NumeroTelefono = @inNumeroA;

	-- ----------------------------------------------------- --
	-- DETERMINAR SI EXISTE PARENTESCO

	IF (EXISTS (SELECT 1 FROM dbo.Parentesco P WHERE P.IDCliente = @IDClienteNumeroDesde AND P.IDPariente = @IDClienteNumeroA)
		OR EXISTS (SELECT 1 FROM dbo.Parentesco P WHERE P.IDPariente = @IDClienteNumeroDesde AND P.IDCliente = @IDClienteNumeroA))
	BEGIN
		SET @condicionFamiliar = 1;
	END

	RETURN @condicionFamiliar;

END;

-- ************************************************************* --
-- fin de la funcion para determinar parentesco