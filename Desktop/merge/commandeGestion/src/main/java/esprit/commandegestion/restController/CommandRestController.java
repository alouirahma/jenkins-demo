package esprit.commandegestion.restController;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/Command")
public class CommandRestController {
    private String title="Hello, i'm the  Command Micro-Service";
    @RequestMapping("/hello")
    public String sayHello() {
        System.out.println(title);
        return title;
    }
}
