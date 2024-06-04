package Elementos;

import java.sql.Date;
import java.sql.Time;

public class Llamada {
    
    private Date fecha;
    private Time horaInicio, horaFin;
    private String numeroOrigen, numeroDestino, condicion;
    private int duracion;

    public Llamada(Date fecha, Time horaInicio, Time horaFin, String numeroDestino, String condicion, int duracion) {
        this.fecha = fecha;
        this.horaInicio = horaInicio;
        this.horaFin = horaFin;
        this.numeroDestino = numeroDestino;
        this.condicion = condicion;
        this.duracion = duracion;
    }

    public Llamada(Date fecha, Time horaInicio, Time horaFin, String numeroOrigen, String numeroDestino, String condicion, int duracion) {
        this.fecha = fecha;
        this.horaInicio = horaInicio;
        this.horaFin = horaFin;
        this.numeroOrigen = numeroOrigen;
        this.numeroDestino = numeroDestino;
        this.condicion = condicion;
        this.duracion = duracion;
    }

    public void setFecha (Date fecha) {
        this.fecha = fecha;
    }

    public void setHoraInicio (Time horaInicio) {
        this.horaInicio = horaInicio;
    }

    public void setHoraFin (Time horaFin) {
        this.horaFin = horaFin;
    }

    public void setNumeroOrigen (String numeroOrigen) {
        this.numeroOrigen = numeroOrigen;
    }

    public void setNumeroDestino (String numeroDestino) {
        this.numeroDestino = numeroDestino;
    }

    public void setCondicion (String condicion) {
        this.condicion = condicion;
    }

    public void setDuracion (int duracion) {
        this.duracion = duracion;
    }

    public Date getFecha() {
        return fecha;
    }

    public Time getHoraInicio() {
        return horaInicio;
    }

    public Time getHoraFin() {
        return horaFin;
    }

    public String getNumeroOrigen() {
        return numeroOrigen;
    }

    public String getNumeroDestino() {
        return numeroDestino;
    }

    public String getCondicion() {
        return condicion;
    }

    public int getDuracion() {
        return duracion;
    }

    public String toStringShort() {
        return String.format("|%11s|%16s|%13s|%10s|%16s|%17s|",
            fecha, horaInicio, horaFin, duracion, numeroDestino, condicion);
    }

    public String toStringLong() {
        return String.format("|%11s|%16s|%13s|%10s|%15s|%16s|%17s|",
            fecha, horaInicio, horaFin, duracion, numeroOrigen, numeroDestino, condicion);
    }
}