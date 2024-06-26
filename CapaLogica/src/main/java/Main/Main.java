//package Main;
//
//import java.sql.Date;
//
//import BaseDatos.RepositorioEstadoCuenta;
//import BaseDatos.RepositorioFactura;
//import BaseDatos.Resultado;
//import Elementos.Llamada;
//import Elementos.UsoDatos;
//import EstadosCuenta.EstadoCuenta;
//import Facturas.DetalleFactura;
//import Facturas.Factura;
//
//public class Main {
//    
//    public static void main (String[] args) {
//        RepositorioFactura repositorioFactura = RepositorioFactura.getInstance();
//        RepositorioEstadoCuenta repositorioEstadoCuenta = RepositorioEstadoCuenta.getInstance();
//        Resultado resultado;
//        int codigoResultado;
//
//        String numeroTelefono = "89738908";
//        Date fechaFactura = Date.valueOf("2024-02-01");
//        Date fechaEmpresa = Date.valueOf("2024-02-05");
//        char empresa = 'X';
//
//        System.out.println("*** FACTURAS ***");
//        resultado = repositorioFactura.consultarFacturas(numeroTelefono);
//        codigoResultado = resultado.getCodigoResultado();
//        if (codigoResultado == 0) {
//            if (resultado.getDataset().size() == 0) {
//                System.out.println("No se encontraron facturas para el cliente.");
//            } else {
//                System.out.println("| Monto Antes IVA | Monto Despues IVA | Multa |  Total  | Fecha Factura | Fecha Pago |  Estado  |");;
//                for (Object factura : resultado.getDataset()){
//                    System.out.println(((Factura)(factura)).toString());
//                }
//            }
//        }
//
//        resultado = repositorioFactura.consultarDetalleFactura(numeroTelefono, fechaFactura);
//        codigoResultado = resultado.getCodigoResultado();
//        if (codigoResultado == 0) {
//            if (resultado.getDataset().size() == 0) {
//                System.out.println("No se encontraron facturas para el cliente.");
//            } else {
//                System.out.println("\n| Tarifa Base | Minutos Base | Minutos Exceso | Minutos Familiares | Gigas Base | Gigas Exceso | Cobro 911 | Cobro 110 | Cobro 900 |");;
//                for (Object detalle : resultado.getDataset()){
//                    System.out.println(((DetalleFactura)(detalle)).toString());
//                }
//            }
//        }
//
//        resultado = repositorioFactura.consultarLlamadasFactura(numeroTelefono, fechaFactura);
//        codigoResultado = resultado.getCodigoResultado();
//        if (codigoResultado == 0) {
//            if (resultado.getDataset().size() == 0) {
//                System.out.println("No se encontraron facturas para el cliente.");
//            } else {
//                System.out.println("\n|   Fecha   | Hora de inicio | Hora de fin | Duracion | Numero destino | Condicion cobro |");;
//                for (Object llamada : resultado.getDataset()){
//                    System.out.println(((Llamada)(llamada)).toStringShort());
//                }
//            }
//        }
//
//        resultado = repositorioFactura.consultarUsoDatosFactura(numeroTelefono, fechaFactura);
//        codigoResultado = resultado.getCodigoResultado();
//        if (codigoResultado == 0) {
//            if (resultado.getDataset().size() == 0) {
//                System.out.println("No se encontraron facturas para el cliente.");
//            } else {
//                System.out.println("\n|   Fecha   | Gigas consumidos | Monto por consumo |");;
//                for (Object usoDatos : resultado.getDataset()){
//                    System.out.println(((UsoDatos)(usoDatos)).toString());
//                }
//            }
//        }
//
//        System.out.println("\n\n*** ESTADOS DE CUENTA ***");
//        resultado = repositorioEstadoCuenta.consultarEstadoCuenta(empresa);
//        codigoResultado = resultado.getCodigoResultado();
//        if (codigoResultado == 0) {
//            if (resultado.getDataset().size() == 0) {
//                System.out.println("No se encontraron estados de cuenta para la empresa.");
//            } else {
//                System.out.println("| Minutos entrantes | Minutos salientes | Fecha apertura | Fecha cierre |   Estado   |");;
//                for (Object estadoCuenta : resultado.getDataset()){
//                    System.out.println(((EstadoCuenta)(estadoCuenta)).toString());
//                }
//            }
//        }
//
//        resultado = repositorioEstadoCuenta.consultarLlamadasEstadoCuenta(empresa, fechaEmpresa);
//        codigoResultado = resultado.getCodigoResultado();
//        if (codigoResultado == 0) {
//            if (resultado.getDataset().size() == 0) {
//                System.out.println("No se encontraron estados de cuenta para la empresa.");
//            } else {
//                System.out.println("\n|   Fecha   | Hora de inicio | Hora de fin | Duracion | Numero origen | Numero destino | Tipo de llamada |");;
//                for (Object llamada : resultado.getDataset()){
//                    System.out.println(((Llamada)(llamada)).toStringLong());
//                }
//            }
//        }
//    }
//}