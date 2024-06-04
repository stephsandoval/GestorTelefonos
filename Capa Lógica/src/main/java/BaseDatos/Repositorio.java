// Armando Castro, Stephanie Sandoval | Jun 10. 24
// Tarea Programada 03 | Base de Datos I

/* CLASE REPOSITORIO
 * Tiene los atributos y funcionalidades basicas de un repo
 * Se usa para las conexiones a la BD con los diferentes objetos
 */

 package BaseDatos;

 import java.sql.Connection;
 import java.sql.CallableStatement;
 
 public class Repositorio {
     
     protected Connection conexion;
     protected String conexionURL;
     protected CallableStatement callableStatement;
         
     /* ------------------------------------------------------------ */
     // CONSTRUCTOR DE LA CLASE
 
     protected Repositorio() {
         conexionURL = "jdbc:sqlserver://25.53.45.8:1433;"
                         + "database=Telefonos;"
                         + "user=progra-admin;"
                         + "password=admin;"
                         + "encrypt=false;"
                         + "trustServerCertificate=true;"
                         + "loginTimeout=30;";
     }
         
     /* ------------------------------------------------------------ */
     // CERRAR RECURSOS
     // cierra la llamada a la BD y la conexion
         
     protected void closeResources() {
         try {
             if (callableStatement != null) {
                 callableStatement.close();
             }
             if (conexion != null) {
                 conexion.close();
             }
         } catch (Exception e) {}
     }
 }