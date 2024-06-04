package BaseDatos;

import java.sql.Date;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Types;

import EstadosCuenta.EstadoCuenta;
import Facturas.Factura;

public class RepositorioEstadoCuenta extends Repositorio {
    
    private static RepositorioEstadoCuenta instance;
        
    /* ------------------------------------------------------------ */
    // CONSTRUCTOR DE LA CLASE

    private RepositorioEstadoCuenta() {
        super();
    }

    /* ------------------------------------------------------------ */
    // INSTANCIA DE LA CLASE

    public static synchronized RepositorioEstadoCuenta getInstance() {
        if (instance == null){
            instance = new RepositorioEstadoCuenta();
        }
        return instance;
    }

    public Resultado consultarEstadoCuenta (char empresa) {
        ResultSet resultSet;
        Resultado resultado = new Resultado();

        try {
            conexion = DriverManager.getConnection(conexionURL);
            String storedProcedureQuery = "{CALL dbo.ConsultarEstadoCuenta(?, ?)}";
            callableStatement = conexion.prepareCall(storedProcedureQuery);

            callableStatement.setString(1, String.valueOf(empresa));

            callableStatement.registerOutParameter(2, Types.INTEGER);
            callableStatement.execute();

            resultSet = callableStatement.getResultSet();
            resultSet.next();
            resultado.addCodigoResultado(resultSet.getInt(1));

            callableStatement.getMoreResults();
            resultSet = callableStatement.getResultSet();
            while (resultSet.next()) {
                int minutosEntrantes = resultSet.getInt(1);
                int minutosSalientes = resultSet.getInt(2);
                Date fechaApertura = resultSet.getDate(3);
                Date fechaCierre = resultSet.getDate(4);
                String estado = resultSet.getString(5);
                resultado.addDatasetItem(new EstadoCuenta(minutosEntrantes, minutosSalientes, fechaApertura, fechaCierre, estado));
            }
        } catch (Exception e){} finally {
            closeResources();                  
        }
        return resultado; 
    }
}