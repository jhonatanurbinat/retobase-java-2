package arcmop.blog.springbootest.controladores;


import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import java.util.Collections;
import java.util.Map;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping
public class ControladorHolaMundo {

    @RequestMapping(value = "/sumar/{sum01}/{sum02}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    public @ResponseBody
    Map saludar(@PathVariable("sum01") Integer sum01, @PathVariable("sum02") Integer sum02) {
        return Collections.singletonMap("resultado", String.valueOf(sum01 + sum02));
    }


    @RequestMapping(value = "/restar/{sum01}/{sum02}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    public @ResponseBody
    Map restar(@PathVariable("sum01") Integer sum01, @PathVariable("sum02") Integer sum02) {
        return Collections.singletonMap("resultado", String.valueOf(sum01 - sum02));
    }


    @RequestMapping(value = "/healthz", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = Collections.singletonMap("status", "UP");
        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    // Simple health check endpoint that always returns 200 OK
    @RequestMapping(value = "/saludar", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    public @ResponseBody Map greetings() {
        return Collections.singletonMap("status", "Saludar");
    }

    // Simple health check endpoint that always returns 200 OK
    @RequestMapping(value = "/despedir", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    public @ResponseBody Map despedir() {
        return Collections.singletonMap("status", "Despedir");
    }

    // Simple health check endpoint that always returns 200 OK
    @RequestMapping(value = "/agregar", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    public @ResponseBody Map agregar() {
        return Collections.singletonMap("status", "agregar");
    }

    @RequestMapping(value = "/mul/{sum01}/{sum02}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    public @ResponseBody
    Map multi(@PathVariable("sum01") Integer sum01, @PathVariable("sum02") Integer sum02) {
        return Collections.singletonMap("resultado", String.valueOf(sum01 * sum02));
    }

}
