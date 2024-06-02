-- Armando Castro, Stephanie Sandoval | Jun 10. 24
-- Tarea Programada 03 | Base de Datos I

-- Script:
-- CREA LAS TABLAS DE LA BASE DE DATOS

-- Notas adicionales:
-- al final del codigo para crear las tablas hay algunas instrucciones para eliminarlas
-- dichas instrucciones estan ordenadas de tal forma que se puedan eliminar las tablas de un solo
-- es decir, en el orden respectivo para no tener conflictos por llaves foraneas

-- ************************************************************* --

USE Telefonos
GO

-- tabla de tipos de tarifa:
CREATE TABLE TipoTarifa (
	ID INT NOT NULL PRIMARY KEY,
	Nombre VARCHAR(32) NOT NULL
);

-- ---------------------------------------- --

-- tabla de tipos de unidad:
CREATE TABLE TipoUnidad (
	ID INT NOT NULL PRIMARY KEY,
	Nombre VARCHAR(32) NOT NULL
);

-- ---------------------------------------- --

-- tabla de tipos de elementos no fijos:
CREATE TABLE TipoElemento (
	ID INT NOT NULL PRIMARY KEY,
	IDTipoUnidad INT NOT NULL,
	Nombre VARCHAR(32) NOT NULL,
	EsFijo BIT NOT NULL
	FOREIGN KEY (IDTipoUnidad) REFERENCES TipoUnidad(ID)
);

-- ---------------------------------------- --

-- tabla de tipos de elementos no fijos:
CREATE TABLE TipoElementoFijo (
	ID INT NOT NULL PRIMARY KEY,
	IDTipoElemento INT NOT NULL,
	Valor INT NOT NULL
	FOREIGN KEY (IDTipoElemento) REFERENCES TipoElemento(ID)
);

-- ---------------------------------------- --

-- tabla de tipos de relacion familiar:
CREATE TABLE TipoRelacionFamiliar (
	ID INT NOT NULL PRIMARY KEY,
	Nombre VARCHAR(32) NOT NULL
);

-- ---------------------------------------- --

-- tabla de elementos de tipos de tarifa
CREATE TABLE ElementoDeTipoTarifa (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDTipoTarifa INT NOT NULL,
	IDTipoElemento INT NOT NULL,
	Valor INT NOT NULL,
	FOREIGN KEY (IDTipoTarifa) REFERENCES TipoTarifa(ID),          -- FK a tipo tarifa
	FOREIGN KEY (IDTipoElemento) REFERENCES TipoElemento(ID),      -- FK a tipo elemento
);

-- ---------------------------------------- --

-- tabla de clientes
CREATE TABLE Cliente (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Identificacion VARCHAR(16) NOT NULL,
	Nombre VARCHAR(32) NOT NULL
);

-- ---------------------------------------- --

-- tabla de parentesco entre clientes
CREATE TABLE Parentesco (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDTipoRelacion INT NOT NULL,
	IDCliente INT NOT NULL,
	IDPariente INT NOT NULL,
	FOREIGN KEY (IDCliente) REFERENCES Cliente(ID),
	FOREIGN KEY (IDPariente) REFERENCES Cliente(ID),
	FOREIGN KEY (IDTipoRelacion) REFERENCES TipoRelacionFamiliar(ID)
);

-- ---------------------------------------- --

-- tabla de contratos
CREATE TABLE Contrato (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDTipoTarifa INT NOT NULL,
	IDCliente INT NOT NULL,
	NumeroTelefono VARCHAR(16) NOT NULL,
	FechaContrato DATE NOT NULL,
	FOREIGN KEY (IDTipoTarifa) REFERENCES TipoTarifa(ID),          -- FK a tipo tarifa
	FOREIGN KEY (IDCliente) REFERENCES Cliente(ID)                 -- FK a cliente
);

-- ---------------------------------------- --

-- tabla de facturas
CREATE TABLE Factura (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDContrato INT NOT NULL,
	TotalAntesIVA MONEY NOT NULL,
	TotalDespuesIVA MONEY NOT NULL,
	MultaFacturasPrevias MONEY NOT NULL,
	Total MONEY NOT NULL,
	FechaFactura DATE NOT NULL,
	FechaPago DATE NOT NULL,
	EstaPagada BIT NOT NULL,
	FOREIGN KEY (IDContrato) REFERENCES Contrato(ID)
);

-- ---------------------------------------- --

-- tabla de detalles de la factura
CREATE TABLE Detalle (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDFactura INT NOT NULL,
	FOREIGN KEY (IDFactura) REFERENCES Factura(ID)
);

-- ---------------------------------------- --

-- tabla de informacion de llamadas del XML
CREATE TABLE LlamadaInput (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	HoraInicio DATETIME NOT NULL,
	HoraFin DATETIME NOT NULL,
	NumeroDesde VARCHAR(16) NOT NULL,
	NumeroA VARCHAR(16) NOT NULL
);

-- ---------------------------------------- --

-- tabla de llamadas realizadas
CREATE TABLE LlamadaLocal (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDDetalle INT NOT NULL,
	IDLlamadaInput INT NOT NULL,
	CantidadMinutos INT NOT NULL,
	FOREIGN KEY (IDDetalle) REFERENCES Detalle(ID),
	FOREIGN KEY (IDLlamadaInput) REFERENCES LlamadaInput(ID)
);

-- ---------------------------------------- --

-- tabla de informacion de uso de datos del XML
CREATE TABLE UsoDatosInput (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Fecha DATE NOT NULL,
	NumeroTelefono VARCHAR(16) NOT NULL,
	CantidadDatos FLOAT NOT NULL
);

-- ---------------------------------------- --

-- tabla de uso de datos
CREATE TABLE UsoDatos (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDUsoDatosInput INT NOT NULL,
	IDDetalle INT NOT NULL,
	CantidadDatos FLOAT NOT NULL,
	FOREIGN KEY (IDDetalle) REFERENCES Detalle(ID),
	FOREIGN KEY (IDUsoDatosInput) REFERENCES UsoDatosInput(ID)
);

-- ---------------------------------------- --

-- tabla de montos de cobro fijo
CREATE TABLE CobroFijo (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDDetalle INT NOT NULL,
	TotalLlamadas911 INT NOT NULL,
	TotalMinutos110 INT NOT NULL,
	TotalMinutos900 INT NOT NULL,
	FOREIGN KEY (IDDetalle) REFERENCES Detalle(ID)
);

-- ---------------------------------------- --

-- tabla de operadores
CREATE TABLE Operador (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Nombre VARCHAR(64) NOT NULL,
	DigitoPrefijo INT NOT NULL
);

-- ---------------------------------------- --

-- tabla del estado de cuenta de los operadores
CREATE TABLE EstadoCuenta (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDOperador INT NOT NULL,
	TotalLlamadasEntrantes INT NOT NULL,
	TotalLlamadasSalientes INT NOT NULL,
	FOREIGN KEY (IDOperador) REFERENCES Operador(ID)
);

-- ---------------------------------------- --

-- tabla de detalles del estado de cuenta del operador
CREATE TABLE DetalleEstadoCuenta (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDEstadoCuenta INT NOT NULL,
	CantidadMinutos INT NOT NULL,
	FOREIGN KEY (IDEstadoCuenta) REFERENCES EstadoCuenta(ID)
);

-- ---------------------------------------- --

-- tabla del estado de cuenta de los telefonos asociados a los operadores
CREATE TABLE TelefonoEstadoCuenta (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDEstadoCuenta INT NOT NULL,
	NumeroTelefono VARCHAR(16) NOT NULL,
	CantidadMinutosEntrantes INT NOT NULL,
	CantidadMinutosSalientes INT NOT NULL,
	FOREIGN KEY (IDEstadoCuenta) REFERENCES EstadoCuenta(ID)
);

-- ---------------------------------------- --

-- tabla de llamadas no locales realizadas
CREATE TABLE LlamadaNoLocal (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	IDLlamadaInput INT NOT NULL,
	IDTelefonoEstadoCuenta INT NOT NULL,
	CantidadMinutos INT NOT NULL,
	FOREIGN KEY (IDTelefonoEstadoCuenta) REFERENCES TelefonoEstadoCuenta(ID),
	FOREIGN KEY (IDLlamadaInput) REFERENCES LlamadaInput(ID)
);

-- ************************************************************* --
-- fin del codigo para crear las tablas

-- codigo para eliminar las tablas en caso de necesidad

--DROP TABLE LlamadaNoLocal;
--DROP TABLE DetalleEstadoCuenta;
--DROP TABLE UsoDatos;
--DROP TABLE UsoDatosInput;
--DROP TABLE CobroFijo;
--DROP TABLE Parentesco;
--DROP TABLE ElementoDeTipoTarifa;
--DROP TABLE TipoRelacionFamiliar;
--DROP TABLE TipoElementoFijo;
--DROP TABLE TipoElemento;
--DROP TABLE TipoUnidad;
--DROP TABLE TelefonoEstadoCuenta;
--DROP TABLE LlamadaLocal;
--DROP TABLE LlamadaInput;
--DROP TABLE Detalle;
--DROP TABLE Factura;
--DROP TABLE Contrato;
--DROP TABLE Cliente;
--DROP TABLE TipoTarifa;
--DROP TABLE EstadoCuenta;
--DROP TABLE Operador;