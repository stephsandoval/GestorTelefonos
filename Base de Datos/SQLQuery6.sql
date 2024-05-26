DECLARE @outResultCode INT;

EXEC dbo.AbrirCerrarFacturas '2024-02-01', @outResultCode OUTPUT;

SELECT * FROM Factura;
SELECT * FROM Detalle;
SELECT * FROM CobroFijo;
SELECT * FROM ElementoDeTipoTarifa;
--DELETE FROM Factura;

SELECT * FROM ErrorBaseDatos
ORDER BY ErrorDateTime 


--SELECT *
--FROM dbo.Contrato C
--INNER JOIN dbo.ElementoDeTipoTarifa ETT ON C.IDTipoTarifa = ETT.IDTipoTarifa
--INNER JOIN dbo.TipoElemento TE ON ETT.IDTipoElemento = TE.ID
--WHERE TE.EsFijo = 1 AND C.ID = 1;

--DECLARE @IDFactura INT;
--DECLARE @IDDetalle INT;
--DECLARE @montoFijo MONEY;

--SELECT @IDFactura = F.ID
--FROM Factura F
--WHERE F.IDContrato = 1 AND F.FechaFactura = '2024-02-01'

--SELECT @IDDetalle = D.ID
--FROM Detalle D
--WHERE D.IDFactura = @IDFactura

--SELECT @montoFijo = ETT.Valor
--FROM CobroFijo CF
--INNER JOIN ElementoDeTipoTarifa ETT ON ETT.ID = CF.IDElementoDeTipoTarifa
--INNER JOIN TipoElemento TE ON TE.ID = ETT.IDTipoElemento
--WHERE CF.IDDetalle = @IDDetalle AND TE.IDTipoUnidad = 3;

--PRINT @montoFijo

--SELECT dbo.GenerarNuevaFechaPago('2024-01-01', 5);

--SELECT * FROM dbo.CalcularMontosFactura(5);

--SELECT * FROM Contrato;

--DECLARE @montoFijo MONEY;
--SELECT @montoFijo = SUM(TE.Valor)
--FROM TipoElemento TE
--WHERE TE.EsFijo = 1 AND TE.ID != 12
--PRINT @montoFijo

--DECLARE @inIDContrato INT;

--DECLARE @montoAntesIVA MONEY;
--DECLARE @monto911 MONEY;

--DECLARE @porcentajeIVA FLOAT;
--DECLARE @montoDespuesIVA MONEY;

--DECLARE @cantidadFacturasPendientes INT;
--DECLARE @multaFacturasPendientes MONEY;
--DECLARE @valorMulta INT;

--DECLARE @montoTotal MONEY;



--SET @inIDContrato = 2;

--SELECT @montoAntesIVA = F.TotalPagarAntesIVA 
--FROM Factura F
--WHERE F.IDContrato = @inIDContrato

--SELECT @monto911 = ETT.Valor
--FROM ElementoDeTipoTarifa ETT
--WHERE ETT.IDTipoElemento = 11

--SET @montoAntesIVA = @montoAntesIVA + @monto911;

--SELECT @porcentajeIVA = ETT.Valor
--FROM ElementoDeTipoTarifa ETT
--WHERE ETT.IDTipoElemento = 12

--SET @porcentajeIVA = (@porcentajeIVA + 100) / 100

--SET @montoDespuesIVA = @montoAntesIVA * @porcentajeIVA

--SELECT @cantidadFacturasPendientes = COUNT(F.ID)
--FROM Factura F
--WHERE F.IDContrato = @inIDContrato AND F.EstaPagada = 0

--SELECT @valorMulta = ETT.Valor
--FROM ElementoDeTipoTarifa ETT
--INNER JOIN Contrato C ON C.ID = @inIDContrato
--WHERE ETT.IDTipoElemento = 8 AND ETT.IDTipoTarifa = C.IDTipoTarifa

--SET @multaFacturasPendientes = @cantidadFacturasPendientes * @valorMulta;

--SET @montoTotal = @montoDespuesIVA + @multaFacturasPendientes;


--PRINT @montoAntesIVA;
--PRINT @montoDespuesIVA;
--PRINT @multaFacturasPendientes;
--PRINT @montoTotal;