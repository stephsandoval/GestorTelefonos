-- Armando Castro, Stephanie Sandoval | Jun 10. 24
-- Tarea Programada 03 | Base de Datos I

-- Trigger:
-- ASOCIA LOS TIPOS DE TARIFA CON LOS ELEMENTOS DE COBRO FIJO

-- Notas adicionales:
-- el trigger se ejecuta despues de cada insercion en la tabla TipoTarifa
-- se realiza la asociacion entre dos datos si el elemento es de cobro fijo (IVA, 911, 110)
-- los datos de las asociaciones se insertan en la tabla ElementoDeTipoTarifa

-- ************************************************************* --

USE Telefonos
GO

CREATE TRIGGER dbo.TRInsertarElementoDeTipoTarifa
ON dbo.TipoTarifa
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ElementoDeTipoTarifa (
          IDTipoTarifa
        , IDTipoElemento
        , Valor
    )
    SELECT 
          I.ID AS IDTipoTarifa
        , ET.ID AS IDTipoElemento
        , ET.Valor
    FROM 
        inserted I
    JOIN 
        dbo.TipoElemento ET ON ET.EsFijo = 1;

    SET NOCOUNT OFF;
END;
GO

-- ************************************************************* --
-- fin del codigo del trigger
