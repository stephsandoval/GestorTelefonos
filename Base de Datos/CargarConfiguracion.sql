-- Armando Castro, Stephanie Sandoval | Jun 10. 24
-- Tarea Programada 03 | Base de Datos I

-- Script:
-- REALIZA LA LECTURA DEL ARCHIVO XML DE CONFIGURACION

-- Notas adicionales:
-- el archivo se tiene de forma local en una de las computadoras
-- se lee y se mapea la informacion hacia las tablas correspondientes

-- ************************************************************* --

USE Telefonos
GO

-- DECLARAR VARIABLES:

DECLARE @xmlData XML;

-- ------------------------------------------------------------- --
-- INICIALIZAR VARIABLES:

SELECT @xmlData = X
FROM OPENROWSET (BULK 'C:\Users\Stephanie\Documents\SQL Server Management Studio\configuracion.xml', SINGLE_BLOB) AS xmlfile(X)

-- preparar el archivo xml:
DECLARE @value INT;
EXEC sp_xml_preparedocument @value OUTPUT, @xmlData;

-- ------------------------------------------------------------- --
-- CARGAR DATOS:

-- ingresar informacion de la seccion TiposUnidades en la tabla TipoUnidad
INSERT INTO dbo.TipoUnidad (ID, Nombre)
SELECT Id,  Tipo
FROM OPENXML (@value, '/Data/TiposUnidades/TipoUnidad', 1)
WITH (
	  Id INT
	, Tipo VARCHAR(64)
)

-- ---------------------------------------- --

-- ingresar informacion de la seccion TiposElemento en la tabla TipoElemento
INSERT INTO dbo.TipoElemento (ID, IDTipoUnidad, Nombre, EsFijo)
SELECT 
      Id
    , IdTipoUnidad
    , Nombre
    , EsFijo
FROM OPENXML (@value, '/Data/TiposElemento/TipoElemento', 1)
WITH (
      Id INT
    , IdTipoUnidad INT
    , Nombre VARCHAR(64)
    , EsFijo BIT
);

-- ingresar informacion de la seccion TiposElemento en la tabla TipoElementoFijo si EsFijo = 1
INSERT INTO dbo.TipoElementoFijo (ID, IDTipoElemento, Valor)
SELECT 
      Id
    , Id AS IDTipoElemento
    , Valor
FROM OPENXML (@value, '/Data/TiposElemento/TipoElemento', 1)
WITH (
      Id INT
    , Valor INT
    , EsFijo BIT
)
WHERE EsFijo = 1;

-- ---------------------------------------- --

-- ingresar informacion de la seccion TiposTarifa en la tabla TipoTarifa
-- asociado con un trigger para insertar en ElementoDeTipoTarifa
INSERT INTO dbo.TipoTarifa (ID, Nombre)
SELECT Id,  Nombre
FROM OPENXML (@value, '/Data/TiposTarifa/TipoTarifa', 1)
WITH (
	  Id INT
	, Nombre VARCHAR(64)
)

-- ---------------------------------------- --

-- ingresar informacion de la seccion TipoRelacionesFamiliar en la tabla TipoRelacionFamiliar
INSERT INTO dbo.TipoRelacionFamiliar(ID, Nombre)
SELECT Id,  Nombre
FROM OPENXML (@value, '/Data/TipoRelacionesFamiliar/TipoRelacionFamiliar', 1)
WITH (
	  Id INT
	, Nombre VARCHAR(64)
)

-- ---------------------------------------- --

-- ingresar informacion de la seccion ElementosDeTipoTarifa en la tabla ElementoDeTipoTarifa
INSERT INTO dbo.ElementoDeTipoTarifa(IDTipoTarifa, IDTipoElemento, Valor)
SELECT idTipoTarifa, IdTipoElemento, Valor
FROM OPENXML (@value, '/Data/ElementosDeTipoTarifa/ElementoDeTipoTarifa', 1)
WITH (
	  idTipoTarifa INT
	, IdTipoElemento INT
	, Valor INT
)

-- ------------------------------------------------------------- --
-- FINALIZAR CARGA:

EXEC sp_xml_removedocument @value;

-- ************************************************************* --
-- fin del codigo para cargar los datos de configuracion

-- codigo para pruebas
--SELECT * FROM dbo.TipoTarifa
--SELECT * FROM dbo.TipoElemento
--SELECT * FROM dbo.TipoRelacionFamiliar
--SELECT * FROM dbo.TipoUnidad
--SELECT * FROM dbo.ElementoDeTipoTarifa

INSERT INTO Operador (Nombre, DigitoPrefijoPrincipal, DigitoPrefijoSecundario)
VALUES
    ('Empresa Z', '8', '9'),
    ('Empresa X', '7', NULL),
    ('Empresa Y', '6', NULL);

INSERT INTO TipoLlamada (Nombre)
VALUES
	('Entrante'),
	('Saliente');