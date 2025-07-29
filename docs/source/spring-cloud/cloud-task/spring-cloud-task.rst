Cloud Task #WIP#
================

https://github.com/spring-boot-tutorials/cloud-task

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
  - spring-cloud-starter-task
  - spring-boot-starter-data-jpa
  - h2
  - lombok
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
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-task</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.properties``:

.. code-block:: properties

    spring.datasource.url=jdbc:h2:mem:testdb
    spring.datasource.driverClassName=org.h2.Driver
    spring.datasource.username=sa
    spring.datasource.password=

    # enables H2 console http://localhost:8080/h2-console
    spring.h2.console.enabled=true

Configuration
-------------

Create new file ``src/main/java/com/example/spring_cloud_task/configuration/DefaultConfiguration.java``:

.. code-block:: java

    @EnableTask
    @Configuration
    public class DefaultConfiguration {

        @Bean
        public HelloWorldTaskConfigurer getTaskConfigurer(DataSource dataSource) {
            return new HelloWorldTaskConfigurer(dataSource);
        }

        public class HelloWorldTaskConfigurer extends DefaultTaskConfigurer {
            public HelloWorldTaskConfigurer(DataSource dataSource){
                super(dataSource);
            }
        }
    }

Main
----

Modify the ``MainApplication.java`` as so:

.. code-block:: java

    @SpringBootApplication
    public class SpringCloudTaskApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(SpringCloudTaskApplication.class, args);
    	}

    	@Override
    	public void run(String... args) throws Exception {
    		System.out.println("Hello World from Spring Cloud Task!");
    	}
    }

Run Application
---------------

.. code-block:: sh

    mvn spring-boot:run

Create Tests
------------

Create a new file ````:

.. code-block:: java

    @EnableTestBinder
    @SpringBootTest
    class SpringCloudStreamsApplicationTests {

        @Autowired
        private InputDestination input;

        @Autowired
        private OutputDestination output;

        @Test
        void whenHighlightingLogMessage_thenItsTransformedToUppercase() {
            Message<String> messageIn = MessageBuilder.withPayload("hello")
                    .setHeader("contentType", "text/plain")
                    .build();
            input.send(messageIn, "highlightLogs-in-0");

            Message<byte[]> messageOut = output.receive(1000L, "highlightLogs-out-0");
            assertThat(messageOut.getPayload())
                    .asString()
                    .isEqualTo("HELLO");
        }
    }

Run Tests
---------

.. code-block:: sh

    mvn clean package
