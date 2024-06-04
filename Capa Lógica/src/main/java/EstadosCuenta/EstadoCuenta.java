package EstadosCuenta;

import java.sql.Date;

public class EstadoCuenta {
    
    private int minutosEntrantes, minutosSalientes;
    private Date fechaApertura, fechaCierre;
    private String estado;

    public EstadoCuenta(int minutosEntrantes, int minutosSalientes, Date fechaApertura, Date fechaCierre, String estado) {
        this.minutosEntrantes = minutosEntrantes;
        this.minutosSalientes = minutosSalientes;
        this.fechaApertura = fechaApertura;
        this.fechaCierre = fechaCierre;
        this.estado = estado;
    }

    public void setMinutosEntrantes(int minutosEntrantes) {
        this.minutosEntrantes = minutosEntrantes;
    }

    public void setMinutosSalientes(int minutosSalientes) {
        this.minutosSalientes = minutosSalientes;
    }

    public void setFechaApertura(Date fechaApertura) {
        this.fechaApertura = fechaApertura;
    }

    public void setFechaCierre(Date fechaCierre) {
        this.fechaCierre = fechaCierre;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public int getMinutosEntrantes() {
        return minutosEntrantes;
    }

    public int getMinutosSalientes() {
        return minutosSalientes;
    }

    public Date getFechaApertura() {
        return fechaApertura;
    }

    public Date getFechaCierre() {
        return fechaCierre;
    }

    public String getEstado() {
        return estado;
    }

    @Override
    public String toString() {
        return String.format("|%19s|%19s|%16s|%14s|%12s|",
            minutosEntrantes, minutosSalientes, fechaApertura, fechaCierre, estado);
    }
}