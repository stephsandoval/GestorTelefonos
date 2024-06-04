// Armando Castro, Stephanie Sandoval | Jun 10. 24
// Tarea Programada 03 | Base de Datos I

/* CLASE RESULTADO
 * Se utiliza para retornar los resultados de los sp de la BD
 * Tiene dos atributos: codigos de resultado y filas de un dataset
 */
 
/* Notas adicionales:
 * Todos los sp para consultar informacion de la base de datos devuelven,
 * como maximo, un dataset de informacion y un codigo de resultado.
 * Por eso, result almacena solo uno de cada uno.
 */

 package BaseDatos;

 import java.util.ArrayList;
 
 public class Resultado {
     
     private int codigoResultado;
     private ArrayList<Object> dataset;
         
     /* ------------------------------------------------------------ */
     // CONSTRUCTOR DE LA CLASE
 
     public Resultado (){
         dataset = new ArrayList<>();
     }
         
     /* ------------------------------------------------------------ */
     // MODIFICAR ESTRUCTURAS
     // metodos para agregar codigo de resultado y item de un dataset
 
     public void addCodigoResultado (int codigoResultado){
        this.codigoResultado = codigoResultado;
     }
 
     public void addDatasetItem (Object item){
         dataset.add(item);
     }
         
     /* ------------------------------------------------------------ */
     // GETTERS
     // metodos para consultar el codigo de resultado y el dataset
 
     public int getCodigoResultado (){
         return this.codigoResultado;
     }
 
     public ArrayList<Object> getDataset (){
         return this.dataset;
     }
 }
 