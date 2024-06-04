package BaseDatos;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.Date;

public class FacturaRepositorio extends Repositorio {
    
    private static FacturaRepositorio instance;
        
    /* ------------------------------------------------------------ */
    // CONSTRUCTOR DE LA CLASE

    private FacturaRepositorio() {
        super();
    }

    /* ------------------------------------------------------------ */
    // INSTANCIA DE LA CLASE

    public static synchronized FacturaRepositorio getInstance() {
        if (instance == null){
            instance = new FacturaRepositorio();
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
            System.out.println(resultSet.getFetchSize());
            while (resultSet.next()) {
                float montoAntesIVA = resultSet.getFloat(1);
                float montoDespuesIVA = resultSet.getFloat(2);
                float multa = resultSet.getFloat(3);
                float total = resultSet.getFloat(4);
                Date fechaFactura = resultSet.getDate(5);
                Date fechaPago = resultSet.getDate(6);
                String estado = resultSet.getString(7);
                resultado.addDatasetItem(new Factura(montoAntesIVA, montoDespuesIVA, multa, total, fechaFactura, fechaPago, estado));
            }
        } catch (Exception e){} finally {
            closeResources();                  
        }
        return resultado; 
    }
}