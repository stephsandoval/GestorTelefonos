package Main;

import BaseDatos.Factura;
import BaseDatos.FacturaRepositorio;
import BaseDatos.Resultado;

public class Main {
    
    public static void main (String[] args) {
        FacturaRepositorio facturaRepositorio = FacturaRepositorio.getInstance();
        Resultado resultado;
        int codigoResultado;

        resultado = facturaRepositorio.consultarFacturas("89738908");
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
    }

}