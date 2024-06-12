-- Armando Castro, Stephanie Sandoval | Jun 11. 24
-- Tarea Programada 03 | Base de Datos I

-- Funcion tabular:
-- CALCULA LA CANTIDAD DE MINUTOS ASOCIADOS A UN NUMERO DE TELEFONO

-- Descripcion general:
-- Los 5 de cada mes se abren y cierran estados de cuenta
-- En la descripcion de cada uno se debe incluir la informacion relacionada con:
    -- cantidad de minutos de entrada
    -- cantidad de minutos de salida

-- Dado que una empresa tiene varios numeros asociados a ella
-- la siguiente funcion se encarga de determinar la cantidad de minutos
-- (entrada y salida) para uno en especifico

-- Descripcion de parametros:
	-- @inNumeroTelefono: numero del que se desea conocer la cantidad de minutos
    -- @inFechaOperacion: fecha en la que se ejecuta el codigo

-- Ejemplo de ejecucion:
	-- SELECT * FROM dbo.ObtenerMinutos ('88888888', 'yyyy-mm-dd')

-- ************************************************************* --

ALTER FUNCTION dbo.ObtenerMinutos (@inNumeroTelefono VARCHAR(16), @inFechaOperacion DATE)
RETURNS @Minutos TABLE (
      MinutosEntrantes INT
    , MinutosSalientes INT
)
AS
BEGIN

    -- ----------------------------------------------------- --
    -- DECLARAR VARIABLES

    DECLARE @minutosEntrantes INT;
    DECLARE @minutosSalientes INT;

    -- ----------------------------------------------------- --
    -- CALCULAR LA CANTIDAD DE MINUTOS DE ENTRADA

    SELECT @minutosEntrantes = ISNULL(SUM(DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)), 0)
    FROM dbo.LlamadaInput LI
    WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
        AND LI.NumeroA = @inNumeroTelefono
        AND (dbo.ObtenerOperador(LI.NumeroA) != dbo.ObtenerOperador(LI.NumeroDesde));

    -- ----------------------------------------------------- --
    -- CALCULAR LA CANTIDAD DE MINUTOS DE SALIDA
    
    SELECT @minutosSalientes = ISNULL(SUM(DATEDIFF(MINUTE, LI.HoraInicio, LI.HoraFin)), 0)
    FROM dbo.LlamadaInput LI
    WHERE CONVERT(DATE, LI.HoraInicio) = @inFechaOperacion
        AND LI.NumeroDesde = @inNumeroTelefono
        AND (dbo.ObtenerOperador(LI.NumeroA) != dbo.ObtenerOperador(LI.NumeroDesde));

    -- ----------------------------------------------------- --
    -- RETONAR RESULTADOS

    INSERT INTO @Minutos (
          MinutosEntrantes
        , MinutosSalientes
    )
    VALUES (
          @minutosEntrantes
        , @minutosSalientes
    );

    RETURN;
END;

-- ************************************************************* --
-- fin de la funcion para determinar la cantidad de minutos