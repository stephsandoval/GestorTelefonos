package controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
@RequestMapping(method = {RequestMethod.GET})
public class MainController {
	
	@GetMapping("/listaFacturasTelefono")
    public String fwd() {
    	return "forward:/";
    }
	
	@GetMapping("/listaDetallesTelefono")
    public String fwd2() {
    	return "forward:/";
    }
	
	@GetMapping("/listaLlamadasTelefono")
    public String fwd3() {
    	return "forward:/";
    }
	
	@GetMapping("/listaUsoDatosTelefono")
    public String fwd4() {
    	return "forward:/";
    }
	
	@GetMapping("/estadoCuenta")
    public String fwd5() {
    	return "forward:/";
    }
	
	@GetMapping("/listaLlamadasEmpresa")
    public String fwd6() {
    	return "forward:/";
    }
}
