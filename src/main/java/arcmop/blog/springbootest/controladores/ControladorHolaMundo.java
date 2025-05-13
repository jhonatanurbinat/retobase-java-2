package arcmop.blog.springbootest.controladores;

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
        return Collections.singletonMap("resultado", String.valueOf(sum01 * sum02));
    }


    @RequestMapping(value = "/restar/{sum01}/{sum02}", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    public @ResponseBody
    Map restar(@PathVariable("sum01") Integer sum01, @PathVariable("sum02") Integer sum02) {
        return Collections.singletonMap("resultado", String.valueOf(sum01 - sum02));
    }

    // Simple health check endpoint that always returns 200 OK
    @RequestMapping(value = "/health", method = RequestMethod.GET, produces = MediaType.APPLICATION_JSON_VALUE)
    public @ResponseBody Map health() {
        return Collections.singletonMap("status", "UP");
    }

}
