package controllers;

import java.sql.Date;
import java.util.ArrayList;

import org.json.JSONObject;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import BaseDatos.RepositorioEstadoCuenta;
import BaseDatos.RepositorioFactura;
import BaseDatos.Resultado;

@RestController
@RequestMapping("/api")
public class ApiController {
	
	RepositorioFactura repositorioFactura = RepositorioFactura.getInstance();
	RepositorioEstadoCuenta repositorioEstadoCuenta = RepositorioEstadoCuenta.getInstance();
	Resultado resultado;
	int codigoResultado;
	
	@PostMapping("/getFacturasTelefono")
	public ArrayList<Object> getFacturasTelefono(@RequestBody String data) {
		String telefono = new JSONObject(data).getString("telefono");
		resultado = repositorioFactura.consultarFacturas(telefono);
		codigoResultado = resultado.getCodigoResultado();
		return resultado.getDataset();
	}
	
	@PostMapping("/getDetalleFacturaTelefono")
	public ArrayList<Object> getDetalleFacturaTelefono(@RequestBody String data) {
		String telefono = new JSONObject(data).getString("telefono");
		String fecha = new JSONObject(data).getString("fecha");
		resultado = repositorioFactura.consultarDetalleFactura(telefono, Date.valueOf(fecha));
		codigoResultado = resultado.getCodigoResultado();
		return resultado.getDataset();
	}
	
	@PostMapping("/getLlamadasTelefono")
	public ArrayList<Object> getLlamadasTelefono(@RequestBody String data) {
		String telefono = new JSONObject(data).getString("telefono");
		String fecha = new JSONObject(data).getString("fecha");
		resultado = repositorioFactura.consultarLlamadasFactura(telefono, Date.valueOf(fecha));
		codigoResultado = resultado.getCodigoResultado();
		return resultado.getDataset();
	}
	
	@PostMapping("/getUsoDatosTelefono")
	public ArrayList<Object> getUsoDatosTelefono(@RequestBody String data) {
		String telefono = new JSONObject(data).getString("telefono");
		String fecha = new JSONObject(data).getString("fecha");
		resultado = repositorioFactura.consultarUsoDatosFactura(telefono, Date.valueOf(fecha));
		codigoResultado = resultado.getCodigoResultado();
		return resultado.getDataset();
	}

	@PostMapping("/getEstadoCuentaEmpresa")
	public ArrayList<Object> getEstadoCuentaEmpresa(@RequestBody String data) {
		String empresa = new JSONObject(data).getString("empresa");
		resultado = repositorioEstadoCuenta.consultarEstadoCuenta(empresa.charAt(0));
		codigoResultado = resultado.getCodigoResultado();
		return resultado.getDataset();
	}
	
	@PostMapping("/getListaLlamadasEmpresa")
	public ArrayList<Object> getListaLlamadasEmpresa(@RequestBody String data) {
		String empresa = new JSONObject(data).getString("empresa");
		resultado = repositorioEstadoCuenta.consultarLlamadasEstadoCuenta(empresa.charAt(0));
		codigoResultado = resultado.getCodigoResultado();
		return resultado.getDataset();
	}
	
}
