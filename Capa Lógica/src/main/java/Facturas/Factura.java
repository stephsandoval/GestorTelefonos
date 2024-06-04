package Facturas;

import java.util.Date;

public class Factura {
    
    private float montoAntesIVA, montoDespuesIVA, multa, total;
    private Date fechaFactura, fechaPago;
    private String estado;

    public Factura (float montoAntesIVA, float montoDespuesIVA, float multa, float total, Date fechaFactura, Date fechaPago, String estado) {
        this.montoAntesIVA = montoAntesIVA;
        this.montoDespuesIVA = montoDespuesIVA;
        this.multa = multa;
        this.total = total;
        this.fechaFactura = fechaFactura;
        this.fechaPago = fechaPago;
        this.estado = estado;
    }

    public void setMontoAntesIVA(float montoAntesIVA) {
        this.montoAntesIVA = montoAntesIVA;
    }

    public void setMontoDespuesIVA(float montoDespuesIVA) {
        this.montoDespuesIVA = montoDespuesIVA;
    }

    public void setMulta(float multa) {
        this.multa = multa;
    }

    public void setTotal(float total) {
        this.total = total;
    }

    public void setFechaFactura(Date fechaFactura) {
        this.fechaFactura = fechaFactura;
    }

    public void setFechaPago(Date fechaPago) {
        this.fechaPago = fechaPago;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public float getMontoAntesIVA() {
        return montoAntesIVA;
    }

    public float getMontoDespuesIVA() {
        return montoDespuesIVA;
    }

    public float getMulta() {
        return multa;
    }

    public float getTotal() {
        return total;
    }

    public Date getFechaFactura() {
        return fechaFactura;
    }

    public Date getFechaPago() {
        return fechaPago;
    }

    public String getEstado() {
        return estado;
    }

    @Override
    public String toString() {
        return String.format("|%17s|%19s|%7s|%9s|%15s|%12s|%10s|",
            montoAntesIVA, montoDespuesIVA, multa, total, fechaFactura, fechaPago, estado);
    }
}