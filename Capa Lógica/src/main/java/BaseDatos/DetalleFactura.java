package BaseDatos;

public class DetalleFactura {
    
    private float tarifaBase, gigasBase, gigasExceso, cobro911, cobro110, cobro900;
    private int minutosBase, minutosExceso, minutosFamiliares;

    public DetalleFactura (float tarifaBase, float gigasBase, float gigasExceso, float cobro911, float cobro110, float cobro900, int minutosBase, int minutosExceso, int minutosFamiliares) {
        this.tarifaBase = tarifaBase;
        this.gigasBase = gigasBase;
        this.gigasExceso = gigasExceso;
        this.cobro911 = cobro911;
        this.cobro110 = cobro110;
        this.cobro900 = cobro900;
        this.minutosBase = minutosBase;
        this.minutosExceso = minutosExceso;
        this.minutosFamiliares = minutosFamiliares;
    }

    public void setTarifaBase (float tarifaBase) {
        this.tarifaBase = tarifaBase;
    }

    public void setGigasBase (float gigasBase) {
        this.gigasBase = gigasBase;
    }

    public void setGigasExceso (float gigasExceso) {
        this.gigasExceso = gigasExceso;
    }

    public void setCobro911 (float cobro911) {
        this.cobro911 = cobro911;
    }

    public void setCobro110 (float cobro110) {
        this.cobro110 = cobro110;
    }

    public void setCobro900 (float cobro900) {
        this.cobro900 = cobro900;
    }

    public void setMinutosBase (int minutosBase) {
        this.minutosBase = minutosBase;
    }

    public void setMinutosExceso (int minutosExceso) {
        this.minutosExceso = minutosExceso;
    }

    public void setMinutosFamiliares (int minutosFamiliares) {
        this.minutosFamiliares = minutosFamiliares;
    }

    public float getTarifaBase() {
        return tarifaBase;
    }

    public float getGigasBase() {
        return gigasBase;
    }

    public float getGigasExceso() {
        return gigasExceso;
    }

    public float getCobro911() {
        return cobro911;
    }

    public float getCobro110() {
        return cobro110;
    }

    public float getCobro900() {
        return cobro900;
    }

    public int getMinutosBase() {
        return minutosBase;
    }

    public int getMinutosExceso() {
        return minutosExceso;
    }

    public int getMinutosFamiliares() {
        return minutosFamiliares;
    }

    @Override
    public String toString() {
        return String.format("|%13s|%14s|%16s|%20s|%12s|%14s|%11s|%11s|%11s|",
            tarifaBase, minutosBase, minutosExceso, minutosFamiliares, gigasBase,
                gigasExceso, cobro911, cobro110, cobro900);
    }

}