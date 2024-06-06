package gestorTelefonos;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@ComponentScan("controllers")
@SpringBootApplication
public class CapaLogicaApplication {

	public static void main(String[] args) {
		SpringApplication.run(CapaLogicaApplication.class, args);
	}

}
