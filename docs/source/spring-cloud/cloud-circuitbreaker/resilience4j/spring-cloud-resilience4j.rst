Resilience4j
============

https://github.com/spring-boot-tutorials/spring-cloud-circuitbreaker-resilience4j

In this article we will configure Resilience4j in Spring Boot.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:
  - spring-cloud-starter-circuitbreaker-resilience4j
  - spring-boot-starter-web
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-circuitbreaker-resilience4j</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

Service
-------

Create a new file ``src/main/java/com/example/circuitbreaker_resilience4j/DefaultService.java``:

.. code-block:: java

    @Service
    public class DefaultService {

        @Autowired
        private CircuitBreakerFactory circuitBreakerFactory;

        private final RestTemplate restTemplate = new RestTemplate();

        public String getAlbumList() {
            System.out.println("INSIDE getAlbumList()");

            CircuitBreaker circuitBreaker = circuitBreakerFactory.create("circuitbreaker");
            String url = "http://localhost:1234/not-real";

            return circuitBreaker.run(
                    () -> restTemplate.getForObject(url, String.class),
                    throwable -> getFallbackAlbumList());
        }

        private String getFallbackAlbumList() {
            System.out.println("INSIDE getFallbackAlbumList()");

            CircuitBreaker circuitBreaker = circuitBreakerFactory.create("circuitbreaker");
            String url = "https://jsonplaceholder.typicode.com/albums";

            return circuitBreaker.run(() -> restTemplate.getForObject(url, String.class));
        }
    }

Main
----

Now let's use this service.

Go back to ``MainApplication.java`` and add the following:

.. code-block:: java

    @SpringBootApplication
    public class CircuitbreakerResilience4jApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(CircuitbreakerResilience4jApplication.class, args);
    	}

    	@Autowired
    	private DefaultService defaultService;

    	@Override
    	public void run(String... args) throws Exception {
    		System.out.println(defaultService.getAlbumList().replace("\n", "").replace("\r", "").replaceAll("\\s+", ""));
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.

Configuration (optional)
------------------------

See: https://www.baeldung.com/spring-cloud-circuit-breaker#global-custom-configuration

.. code-block:: java

    @Configuration
    public class DefaultConfiguration {
    }
