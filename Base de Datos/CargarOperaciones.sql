-- Armando Castro, Stephanie Sandoval | Jun 10. 24
-- Tarea Programada 03 | Base de Datos I

-- Script:
-- REALIZA LA LECTURA DEL ARCHIVO XML DE OPERACIONES

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
FROM OPENROWSET (BULK 'C:\Users\Stephanie\Documents\SQL Server Management Studio\operaciones.xml', SINGLE_BLOB) AS xmlfile(X)

-- preparar el archivo xml:
DECLARE @value INT;
EXEC sp_xml_preparedocument @value OUTPUT, @xmlData;

-- ------------------------------------------------------------- --
-- CARGAR DATOS:

-- ingresar informacion a la tabla Cliente
INSERT INTO dbo.Cliente (Identificacion, Nombre)
SELECT 
    ClienteNuevo.value('@Identificacion', 'VARCHAR(16)') AS Identificacion,
    ClienteNuevo.value('@Nombre', 'VARCHAR(64)') AS Nombre
FROM 
    @xmlData.nodes('/Operaciones/FechaOperacion/ClienteNuevo') AS Clientes(ClienteNuevo);

-- ---------------------------------------- --

-- ingresar informacion a la tabla Contrato
DECLARE @TempNuevoContrato TABLE (
    NumeroTelefono BIGINT,
    DocIdCliente INT,
    IDTipoTarifa INT,
    FechaContrato DATE
);

-- extraer datos desde el XML:
INSERT INTO @TempNuevoContrato (NumeroTelefono, DocIdCliente, IDTipoTarifa, FechaContrato)
SELECT 
    NuevoContrato.value('@Numero', 'VARCHAR(32)') AS NumeroTelefono,
    NuevoContrato.value('@DocIdCliente', 'VARCHAR(16)') AS DocIdCliente,
    NuevoContrato.value('@TipoTarifa', 'INT') AS IDTipoTarifa,
    FechaOperacion.value('@fecha', 'DATE') AS FechaContrato
FROM 
    @xmlData.nodes('/Operaciones/FechaOperacion') AS Operaciones(FechaOperacion)
CROSS APPLY 
    FechaOperacion.nodes('NuevoContrato') AS Contratos(NuevoContrato);

-- insertar los datos en la tabla Contrato:
INSERT INTO dbo.Contrato (IDTipoTarifa, IDCliente, NumeroTelefono, FechaContrato)
SELECT
	  TNC.IDTipoTarifa
	, C.ID AS IDCliente
	, TNC.NumeroTelefono
	, TNC.FechaContrato
FROM 
    @TempNuevoContrato TNC
JOIN 
    dbo.Cliente C ON TNC.DocIdCliente = C.Identificacion;

-- ---------------------------------------- --

-- ingresar informacion a la tabla LlamadaInput
INSERT INTO dbo.LlamadaInput (HoraInicio, HoraFin, NumeroDesde, NumeroA)
SELECT 
    LlamadaTelefonica.value('@Inicio', 'DATETIME') AS HoraInicio,
    LlamadaTelefonica.value('@Final', 'DATETIME') AS HoraFin,
	LlamadaTelefonica.value('@NumeroDe', 'VARCHAR(32)') AS NumeroDesde,
	LlamadaTelefonica.value('@NumeroA', 'VARCHAR(32)') AS NumeroA
FROM 
    @xmlData.nodes('/Operaciones/FechaOperacion/LlamadaTelefonica') AS Llamadas(LlamadaTelefonica);

-- ---------------------------------------- --

-- ingresar informacion a la tabla UsoDatosInput
INSERT INTO dbo.UsoDatosInput (Fecha, NumeroTelefono, CantidadGigas)
SELECT 
	FechaOperacion.value('@fecha', 'DATE') AS FechaContrato,
    UsoDatos.value('@Numero', 'VARCHAR(32)') AS NumeroTelefono,
    UsoDatos.value('@QGigas', 'FLOAT') AS CantidadGigas
FROM 
    @xmlData.nodes('/Operaciones/FechaOperacion') AS Operaciones(FechaOperacion)
CROSS APPLY 
    FechaOperacion.nodes('UsoDatos') AS UsoDatos(UsoDatos);

-- ---------------------------------------- --

-- ingresar informacion a la tabla Parentesco
DECLARE @TempRelacionFamiliar TABLE (
    DocIdDe VARCHAR(16),
    DocIdA VARCHAR(16),
    TipoRelacion INT
);

-- extraer datos desde el XML:
INSERT INTO @TempRelacionFamiliar (DocIdDe, DocIdA, TipoRelacion)
SELECT 
    RelacionFamiliar.value('@DocIdDe', 'VARCHAR(16)') AS DocIdDe,
    RelacionFamiliar.value('@DocIdA', 'VARCHAR(16)') AS DocIdA,
    RelacionFamiliar.value('@TipoRelacion', 'INT') AS TipoRelacion
FROM 
    @xmlData.nodes('/Operaciones/FechaOperacion/RelacionFamiliar') AS Relacion(RelacionFamiliar);

-- insertar los datos en la tabla Parentesco:
INSERT INTO dbo.Parentesco (IDTipoRelacion, IDCliente, IDPariente)
SELECT
    TRF.TipoRelacion AS IDTipoRelacion,
    C1.ID AS IDCliente,
    C2.ID AS IDPariente
FROM 
    @TempRelacionFamiliar TRF
INNER JOIN 
    dbo.Cliente C1 ON TRF.DocIdDe = C1.Identificacion
INNER JOIN 
    dbo.Cliente C2 ON TRF.DocIdA = C2.Identificacion;

-- insertar la relacion reciproca
INSERT INTO dbo.Parentesco (IDTipoRelacion, IDCliente, IDPariente)
SELECT
    CASE 
        WHEN PR.IDTipoRelacion = 1 THEN 2  -- hijo o hija -> padre o madre
        WHEN PR.IDTipoRelacion = 2 THEN 1  -- padre o madre -> hijo o hija
        WHEN PR.IDTipoRelacion = 3 THEN 3  -- hermano o hermana -> hermano o hermana
        WHEN PR.IDTipoRelacion = 4 THEN 4  -- conyuge -> conyuge
    END AS IDTipoRelacion,
    PR.IDPariente,
    PR.IDCliente
FROM 
    dbo.Parentesco AS PR;

-- ------------------------------------------------------------- --
-- FINALIZAR CARGA:

EXEC sp_xml_removedocument @value;

--SELECT COUNT(*) AS [Clientes]
--FROM Cliente;

--SELECT COUNT(*) AS [Contratos]
--FROM Contrato;

--SELECT COUNT(*) AS [Llamadas]
--FROM LlamadaInput;

--SELECT COUNT(*) AS [UsoDatos]
--FROM UsoDatosInput;

--SELECT * FROM Parentesco;