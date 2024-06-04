package BaseDatos;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Types;

import Elementos.Llamada;
import Elementos.UsoDatos;
import Facturas.DetalleFactura;
import Facturas.Factura;

import java.sql.Date;
import java.sql.Time;

public class RepositorioFactura extends Repositorio {
    
    private static RepositorioFactura instance;
        
    /* ------------------------------------------------------------ */
    // CONSTRUCTOR DE LA CLASE

    private RepositorioFactura() {
        super();
    }

    /* ------------------------------------------------------------ */
    // INSTANCIA DE LA CLASE

    public static synchronized RepositorioFactura getInstance() {
        if (instance == null){
            instance = new RepositorioFactura();
        }
        return instance;
    }

    public Resultado consultarFacturas (String numeroTelefono) {
        ResultSet resultSet;
        Resultado resultado = new Resultado();

        try {
            conexion = DriverManager.getConnection(conexionURL);
            String storedProcedureQuery = "{CALL dbo.ConsultarFacturas(?, ?)}";
            callableStatement = conexion.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, numeroTelefono);

            callableStatement.registerOutParameter(2, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            resultado.addCodigoResultado(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            while (resultSet.next()) {
                float montoAntesIVA = resultSet.getFloat(1);
                float montoDespuesIVA = resultSet.getFloat(2);
                float multa = resultSet.getFloat(3);
                float total = resultSet.getFloat(4);
                Date fechaFactura = resultSet.getDate(5);
                Date fechaPago = resultSet.getDate(6);
                String estado = resultSet.getString(7);
                resultado.addDatasetItem(new Factura(montoAntesIVA, montoDespuesIVA, multa, total, 
                    fechaFactura, fechaPago, estado));
            }
        } catch (Exception e){} finally {
            closeResources();                  
        }
        return resultado; 
    }

    public Resultado consultarDetalleFactura (String numeroTelefono, Date fechaCierreFactura) {
        ResultSet resultSet;
        Resultado resultado = new Resultado();

        try {
            conexion = DriverManager.getConnection(conexionURL);
            String storedProcedureQuery = "{CALL dbo.ConsultarDetalleFactura(?, ?, ?)}";
            callableStatement = conexion.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, numeroTelefono);
            callableStatement.setDate(2, fechaCierreFactura);

            callableStatement.registerOutParameter(3, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            resultado.addCodigoResultado(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            while (resultSet.next()) {
                float tarifaBase = resultSet.getFloat(1);
                int minutosBase = resultSet.getInt(2);
                int minutosExceso = resultSet.getInt(3);
                int minutosFamiliares = resultSet.getInt(4);
                float gigasBase = resultSet.getFloat(5);
                float gigasExceso = resultSet.getFloat(6);
                float cobro911 = resultSet.getFloat(7);
                float cobro110 = resultSet.getFloat(8);
                float cobro900 = resultSet.getFloat(9);
                resultado.addDatasetItem(new DetalleFactura(tarifaBase, gigasBase, gigasExceso, cobro911
                    , cobro110, cobro900, minutosBase, minutosExceso, minutosFamiliares));
            }
        } catch (Exception e){} finally {
            closeResources();                  
        }
        return resultado; 
    }

    public Resultado consultarLlamadasFactura (String numeroTelefono, Date fechaCierreFactura) {
        ResultSet resultSet;
        Resultado resultado = new Resultado();

        try {
            conexion = DriverManager.getConnection(conexionURL);
            String storedProcedureQuery = "{CALL dbo.ConsultarLlamadasFactura(?, ?, ?)}";
            callableStatement = conexion.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, numeroTelefono);
            callableStatement.setDate(2, fechaCierreFactura);

            callableStatement.registerOutParameter(3, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            resultado.addCodigoResultado(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            while (resultSet.next()) {
                Date fecha = resultSet.getDate(1);
                Time horaInicio = resultSet.getTime(2);
                Time horaFin = resultSet.getTime(3);
                int duracion = resultSet.getInt(4);
                String numeroDestino = resultSet.getString(5);
                String condicion = resultSet.getString(6);
                resultado.addDatasetItem(new Llamada(fecha, horaInicio, horaFin, numeroDestino
                    , condicion, duracion));
            }
        } catch (Exception e){} finally {
            closeResources();                  
        }
        return resultado; 
    }

    public Resultado consultarUsoDatosFactura (String numeroTelefono, Date fechaCierreFactura) {
        ResultSet resultSet;
        Resultado resultado = new Resultado();

        try {
            conexion = DriverManager.getConnection(conexionURL);
            String storedProcedureQuery = "{CALL dbo.ConsultarUsoDatosFactura(?, ?, ?)}";
            callableStatement = conexion.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, numeroTelefono);
            callableStatement.setDate(2, fechaCierreFactura);

            callableStatement.registerOutParameter(3, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            resultado.addCodigoResultado(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            while (resultSet.next()) {
                Date fecha = resultSet.getDate(1);
                float gigasConsumidos = resultSet.getFloat(2);
                float monto = resultSet.getFloat(3);
                resultado.addDatasetItem(new UsoDatos(fecha, gigasConsumidos, monto));
            }
        } catch (Exception e){} finally {
            closeResources();                  
        }
        return resultado; 
    }
}