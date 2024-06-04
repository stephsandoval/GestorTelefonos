package Elementos;

import java.sql.Date;

public class UsoDatos {
    
    private Date fecha;
    private float gigasConsumidos, monto;

    public UsoDatos(Date fecha, float gigasConsumidos, float monto) {
        this.fecha = fecha;
        this.gigasConsumidos = gigasConsumidos;
        this.monto = monto;
    }

    public void setFecha(Date fecha) {
        this.fecha = fecha;
    }

    public void setGigasConsumidos(float gigasConsumidos) {
        this.gigasConsumidos = gigasConsumidos;
    }

    public void setMonto(float monto) {
        this.monto = monto;
    }

    public Date getFecha() {
        return fecha;
    }

    public float getGigasConsumidos() {
        return gigasConsumidos;
    }

    public float getMonto() {
        return monto;
    }

    @Override
    public String toString() {
        return String.format("|%11s|%18s|%19s|", fecha, gigasConsumidos, monto);
    }
}