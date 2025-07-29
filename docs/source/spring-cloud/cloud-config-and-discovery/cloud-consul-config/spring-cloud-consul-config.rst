Cloud Consul Config
===================

https://github.com/spring-boot-tutorials/cloud-consul-config

Install & Run Consul Server
---------------------------

.. code-block:: sh

    docker run \
      --name consul-server \
      -p 8500:8500 \
      -p 8600:8600/udp \
      hashicorp/consul \
      agent -server \
      -bootstrap-expect=1 \
      -ui -client=0.0.0.0

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:
  - starter-web
  - starter-consul-config
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
        <artifactId>spring-cloud-starter-consul-config</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.yaml``:

.. code-block:: yaml

    spring:
      application:
        name: my-app-2
      config:
        import: 'optional:consul:'
      cloud:
        consul:
          host: localhost
          port: 8500
          config:
            enabled: true
          discovery:
            instanceId: ${spring.application.name}:${random.value}
    #        uncomment to disable service discovery
    #        enabled: false
            healthCheckPath: /my-health-check
            healthCheckInterval: 20s

Model
-----

Create a new file ``src/main/java/com/example/consul/config/MyConfigProperties.java``:

.. code-block:: java

    /**
     * @RefreshScope
     * - all beans annotated with the @RefreshScope annotation will be
     *   refreshed after configuration changes
     */
    @Data
    @RefreshScope
    @Configuration
    @NoArgsConstructor
    @ConfigurationProperties("my")
    public class MyConfigProperties {
        private String prop;
    }

Controller
----------

Create a new file ````:

.. code-block:: java

    @RestController
    @RequiredArgsConstructor
    public class MyConfigPropertiesController {

        @Value("${my.prop}")
        private String value;

        private final MyConfigProperties properties;

        /**
         * http://localhost:8080/value
         * @return
         */
        @GetMapping("/value")
        public String getConfigFromValue() {
            return value;
        }

        /**
         * http://localhost:8080/property
         * @return
         */
        @GetMapping("/property")
        public String getConfigFromProperty() {
            return properties.getProp();
        }
    }

Create another file ``src/main/java/com/example/consul/config/MyHealthCheckController.java``:

.. code-block:: java

    @RestController
    public class MyHealthCheckController {

        @GetMapping("/my-health-check")
        public String healthCheck() {
            return "good";
        }
    }

Create Config Properties in Consul Server
-----------------------------------------

goto ``http://localhost:8500/ui/dc1/kv/create``

- key should be: `/config/myApp/my/prop`
- value should be: `Hello World`

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Next do the following:
- goto `http://localhost:8500` and verify `myApp` was registered
- open:
  - http://localhost:8080/value
  - http://localhost:8080/property
- goto `http://localhost:8500` and modify the property
- open:
  - http://localhost:8080/value this should show no change
  - http://localhost:8080/property this should show change