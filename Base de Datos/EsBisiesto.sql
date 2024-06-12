-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Funcion escalar:
-- DETERMINA SI UN ANNO ES BISIESTO

-- Descripcion general:
-- Al cerrar una factura, se debe considerar la fecha en que primero se firmo el contrato
-- Por ejemplo, si se firmo el 5 de un mes, entonces cierra los 5 de todos los meses
-- Sin embargo, si se firma el 31 de un mes, se cierra el:
    -- 31 de los meses que llegan hasta ese numero
    -- 30 de los meses que llegan hasta ese numero
    -- 28 o 29 de febrero segun el anno sea bisiesto

-- Por tanto, se observa que determinar si el anno es bisiesto o no es importante
-- Esta funcion se encarga de esto

-- Descripcion de parametros:
	-- @inFecha: fecha de la cual se desea consultar la condicion

-- Ejemplo de ejecucion:
	-- SELECT dbo.EsBisiesto ('yyyy-mm'dd')

-- ************************************************************* --

ALTER FUNCTION dbo.EsBisiesto (@inFecha DATE)
RETURNS BIT
AS
BEGIN

    -- ----------------------------------------------------- --
    -- DECLARAR VARIABLES

    DECLARE @Year INT = YEAR(@inFecha);
    DECLARE @EsBisiesto BIT;
    
    -- ----------------------------------------------------- --
    -- CALCULAR SI ES BISIESTO

    IF (@Year % 4 = 0 AND @Year % 100 != 0) OR (@Year % 400 = 0)
        SET @EsBisiesto = 1;
    ELSE
        SET @EsBisiesto = 0;

    RETURN @EsBisiesto;
END;

-- ************************************************************* --
-- fin de la funcion para determinar si un anno es bisiesto