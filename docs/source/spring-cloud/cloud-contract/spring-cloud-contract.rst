Cloud Contract
==============

We will create 2 applications:

- service producer:

  - https://github.com/spring-boot-tutorials/cloud-contract-producer
  - running on localhost:9090

- service consumer:

  - https://github.com/spring-boot-tutorials/cloud-contract-consumer
  - running on localhost:8080








**Service Producer Application**
--------------------------------

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - lombok
  - spring-boot-starter-test
  - spring-cloud-starter-contract-verifier
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``:

.. code-block:: xml

    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-contract-verifier</artifactId>
        <scope>test</scope>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.properties``:

.. code-block:: properties

    server.port=9090

Service
-------

Create a new file ``src/main/java/com/example/DefaultService.java``:

.. code-block:: java

    @Service
    public class DefaultService {

        public String isEven(Integer number) {
            return number % 2 == 0 ? "Even" : "Odd";
        }
    }

Controller
----------

Create a new file ``src/main/java/com/example/DefaultController.java``:

.. code-block:: java

    @RestController
    public class DefaultController {

        @Autowired
        private DefaultService defaultService;

        /**
         * http://localhost:9090/validate/even-number?number=NUMBER_HERE
         * @param number
         * @return
         */
        @GetMapping("/validate/even-number")
        public String isNumberEven(@RequestParam("number") Integer number) {
            return defaultService.isEven(number);
        }
    }

Create Test
-----------

Create a new file ``src/test/java/com/example/spring_cloud_contract/producer/BaseClass.java``:

.. code-block:: java

    @SpringBootTest(classes = SpringCloudContractApplication.class)
    public abstract class BaseClass {

        @Autowired
        DefaultController defaultController;

    //    @MockitoBean
    //    DefaultService defaultService;

        @BeforeEach
        public void setup() {
            RestAssuredMockMvc.standaloneSetup(defaultController);
    //        Mockito.when(defaultService.isEven(2))
    //                .thenReturn("Even");
        }

    }

Contract
--------

Create a new file ``src/test/resources/contracts/shouldReturnEvenWhenRequestParamIsEven.groovy``:

.. code-block:: groovy

    package contracts

    import org.springframework.cloud.contract.spec.Contract

    Contract.make {
        description "should return even when number input is even"
        request{
            method GET()
            url("/validate/even-number") {
                queryParameters {
                    parameter("number", "2")
                }
            }
        }
        response {
            body("Even")
            status 200
        }
    }

Run Test
--------

.. code-block:: sh

    mvn clean install

This will auto-generate a test based on the contract and run it at the same time.sh














**Service Consumer Application**
--------------------------------

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
  - spring-boot-starter-test
  - spring-cloud-contract-wiremock
  - spring-cloud-contract-stub-runner
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``:

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-contract-wiremock</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-contract-stub-runner</artifactId>
        <scope>test</scope>
    </dependency>

Controller
----------

Create a new file ``src/main/java/com/example/DefaultController.java``:

.. code-block:: java

    @RestController
    class DefaultController {

        private final RestTemplate restTemplate;

        DefaultController(RestTemplateBuilder restTemplateBuilder) {
            this.restTemplate = restTemplateBuilder.build();
        }

        @GetMapping("/calculate")
        public String checkOddAndEven(@RequestParam("number") Integer number) {
            return restTemplate.getForObject("http://localhost:9090/validate/prime-number?number=" + number, String.class);
        }
    }

Create Test
-----------

Create a new file ``src/test/java/com/example/spring_cloud_contract/consumer/SpringCloudContractApplicationTests.java``:

.. code-block:: java

    @SpringBootTest
    @AutoConfigureStubRunner(
    		ids = "com.example:spring-cloud-contract-producer:0.0.1-SNAPSHOT:stubs:9090",
    		stubsMode = StubRunnerProperties.StubsMode.LOCAL
    )
    class SpringCloudContractApplicationTests {

    	@Test
    	void get_person_from_service_contract() {
    		RestTemplate restTemplate = new RestTemplate();
    		ResponseEntity<String> responseEntity = restTemplate.getForEntity("http://localhost:9090/validate/even-number?number=2", String.class);

    		BDDAssertions.then(responseEntity.getStatusCode().is2xxSuccessful()).isEqualTo(true);
    		BDDAssertions.then(responseEntity.getBody()).isEqualTo("Even");
    	}
    }

Run Test
--------

.. code-block:: sh

    mvn clean package
