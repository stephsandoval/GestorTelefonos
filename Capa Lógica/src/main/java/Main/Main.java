package Main;

import java.sql.Date;

import BaseDatos.DetalleFactura;
import BaseDatos.Factura;
import BaseDatos.FacturaRepositorio;
import BaseDatos.Resultado;

public class Main {
    
    public static void main (String[] args) {
        FacturaRepositorio facturaRepositorio = FacturaRepositorio.getInstance();
        Resultado resultado;
        int codigoResultado;

        String numeroTelefono = "89738908";
        Date fecha = Date.valueOf("2024-02-01");

        resultado = facturaRepositorio.consultarFacturas(numeroTelefono);
        codigoResultado = resultado.getCodigoResultado();
        if (codigoResultado == 0) {
            if (resultado.getDataset().size() == 0) {
                System.out.println("No se encontraron facturas para el cliente.");
            } else {
                System.out.println("| Monto Antes IVA | Monto Despues IVA | Multa |  Total  | Fecha Factura | Fecha Pago |  Estado  |");;
                for (Object factura : resultado.getDataset()){
                    System.out.println(((Factura)(factura)).toString());
                }
            }
        }

        resultado = facturaRepositorio.consultarDetalleFactura(numeroTelefono, fecha);
        codigoResultado = resultado.getCodigoResultado();
        if (codigoResultado == 0) {
            if (resultado.getDataset().size() == 0) {
                System.out.println("No se encontraron facturas para el cliente.");
            } else {
                System.out.println("\n| Tarifa Base | Minutos Base | Minutos Exceso | Minutos Familiares | Gigas Base | Gigas Exceso | Cobro 911 | Cobro 110 | Cobro 900 |");;
                for (Object detalle : resultado.getDataset()){
                    System.out.println(((DetalleFactura)(detalle)).toString());
                }
            }
        }
    }

}