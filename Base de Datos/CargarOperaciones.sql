USE Telefonos;
GO

-- DECLARAR VARIABLES:
DECLARE @xmlData XML;
DECLARE @fechaActual DATE;
DECLARE @FechaOperacion TABLE (Fecha DATE);
DECLARE @outResultCode INT;

-- ------------------------------------------------------------- --
-- INICIALIZAR VARIABLES PARA EL ARCHIVO:

SELECT @xmlData = X
FROM OPENROWSET (BULK 'C:\Users\Stephanie\Documents\SQL Server Management Studio\operaciones.xml', SINGLE_BLOB) AS xmlfile(X);

-- preparar el archivo xml:
DECLARE @value INT;
EXEC sp_xml_preparedocument @value OUTPUT, @xmlData;

-- ------------------------------------------------------------- --
-- INICIALIZAR VARIABLES PARA LA TABLA DE FECHAS DE OPERACION:

INSERT INTO @FechaOperacion (Fecha)
SELECT DISTINCT FechaOperacion.value('@fecha', 'DATE') AS Fecha
FROM @xmlData.nodes('/Operaciones/FechaOperacion') AS T(FechaOperacion);

-- ------------------------------------------------------------- --
-- CARGAR DATOS Y SIMULACION:

WHILE EXISTS (SELECT 1 FROM @FechaOperacion)
BEGIN
    -- DECLARAR VARIABLES:
    DECLARE @OperacionDiaria TABLE (
        Fecha DATE,
        Operacion XML
    );

    -- ------------------------------------------------ --
    -- INICIALIZAR VARIABLES:
    SELECT TOP 1 @fechaActual = Fecha FROM @FechaOperacion ORDER BY Fecha;

    INSERT INTO @OperacionDiaria (Fecha, Operacion)
    SELECT 
        FechaOperacion.value('@fecha', 'DATE') AS Fecha,
        FechaOperacion.query('.') AS Operacion
    FROM @xmlData.nodes('/Operaciones/FechaOperacion') AS T(FechaOperacion)
    WHERE FechaOperacion.value('@fecha', 'DATE') = @fechaActual;

    -- ------------------------------------------------ --
    -- CARGAR DATOS:
    -- Cargar datos de clientes
    INSERT INTO dbo.Cliente (Identificacion, Nombre)
    SELECT 
        ClienteNuevo.value('@Identificacion', 'VARCHAR(16)') AS Identificacion,
        ClienteNuevo.value('@Nombre', 'VARCHAR(64)') AS Nombre
    FROM @OperacionDiaria AS O
    CROSS APPLY O.Operacion.nodes('/FechaOperacion/ClienteNuevo') AS T(ClienteNuevo);

    -- ----------------------------------------
    -- Cargar datos de contratos
    INSERT INTO dbo.Contrato (NumeroTelefono, IDCliente, IDTipoTarifa, FechaContrato)
    SELECT 
        NuevoContrato.value('@Numero', 'VARCHAR(16)') AS Numero,
        C.ID AS IDCliente,
        NuevoContrato.value('@TipoTarifa', 'INT') AS IDTipoTarifa,
        O.Fecha AS FechaContrato
    FROM @OperacionDiaria AS O
    CROSS APPLY O.Operacion.nodes('/FechaOperacion/NuevoContrato') AS T(NuevoContrato)
    JOIN dbo.Cliente C ON NuevoContrato.value('@DocIdCliente', 'VARCHAR(16)') = C.Identificacion;

    -- ----------------------------------------
    -- Abrir o cerrar una nueva factura para los contratos
    EXEC dbo.AbrirCerrarFacturas @fechaActual, @outResultCode OUTPUT;

	-- ----------------------------------------
	-- procesar multas:

	EXEC dbo.AplicarMultas @fechaActual, @outResultCode OUTPUT;

    -- ----------------------------------------
    -- Cargar informacion de los pagos de facturas
    
	EXEC dbo.ProcesarPagoFactura @xmlData, @fechaActual, @outResultCode OUTPUT;

    -- ----------------------------------------
    -- Cargar informacion de llamadas
    INSERT INTO dbo.LlamadaInput (HoraInicio, HoraFin, NumeroDesde, NumeroA)
    SELECT 
        LlamadaTelefonica.value('@Inicio', 'DATETIME') AS Inicio,
        LlamadaTelefonica.value('@Final', 'DATETIME') AS Fin,
        LlamadaTelefonica.value('@NumeroDe', 'VARCHAR(16)') AS NumeroDe,
        LlamadaTelefonica.value('@NumeroA', 'VARCHAR(16)') AS NumeroA
    FROM @OperacionDiaria AS O
    CROSS APPLY O.Operacion.nodes('/FechaOperacion/LlamadaTelefonica') AS T(LlamadaTelefonica);

    -- ----------------------------------------
    -- Procesar llamadas
    EXEC dbo.ProcesarLlamada @fechaActual, @outResultCode OUTPUT;

    -- ----------------------------------------
    -- Cargar informacion de uso de datos
    INSERT INTO dbo.UsoDatosInput (Fecha, NumeroTelefono, CantidadDatos)
    SELECT 
        O.Fecha AS Fecha,
        UsoDatos.value('@Numero', 'VARCHAR(16)') AS Numero,
        UsoDatos.value('@QGigas', 'FLOAT') AS CantidadDatos
    FROM @OperacionDiaria AS O
    CROSS APPLY O.Operacion.nodes('/FechaOperacion/UsoDatos') AS T(UsoDatos);

	-- ----------------------------------------
	-- procesar datos:

	EXEC dbo.ProcesarUsoDatos @fechaActual, @outResultCode OUTPUT;

    DELETE FROM @FechaOperacion WHERE Fecha = @fechaActual;
    DELETE FROM @OperacionDiaria WHERE Fecha = @fechaActual;
END;

-- ------------------------------------------------------------- --
-- FINALIZAR PROCESO:

EXEC sp_xml_removedocument @value;

-- ************************************************************* --
-- fin del codigo de carga de operaciones