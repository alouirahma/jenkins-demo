package esprit.commandegestion;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@EnableDiscoveryClient
@RestController
public class CommandeGestionApplication {

	public static void main(String[] args) {
		SpringApplication.run(CommandeGestionApplication.class, args);
	}

	@GetMapping("/commande/test")
	public String testEndpoint() {
		System.out.println("CommandeGestion Service: Test endpoint accessed");
		return "CommandeGestion Service is running!";
	}
}
