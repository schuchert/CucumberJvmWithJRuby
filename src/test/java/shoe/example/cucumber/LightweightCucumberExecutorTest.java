package shoe.example.cucumber;

import cucumber.junit.Cucumber;
import org.junit.runner.RunWith;

@RunWith(Cucumber.class)
@Cucumber.Options(format = {"pretty", "html:target/cucumber-html-report"}, features = "src/test/resources", glue = "src/test/resources")
public class LightweightCucumberExecutorTest {

}
