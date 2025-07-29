Cloud Consul Discovery
======================

https://github.com/spring-boot-tutorials/cloud-consul-discovery

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
  - spring-boot-starter-web
  - spring-cloud-starter-consul-discovery
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
        <artifactId>spring-cloud-starter-consul-discovery</artifactId>
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
        name: myApp
      cloud:
        consul:
          host: localhost
          port: 8500
          discovery:
            instanceId: ${spring.application.name}:${random.value}
    #        uncomment to disable service discovery
    #        enabled: false
            healthCheckPath: /my-health-check
            healthCheckInterval: 20s

Model
-----

Create new file ``src/main/java/com/example/consul/discovery/MyDiscoveryConfiguration.java``:

.. code-block:: java

    @EnableDiscoveryClient
    public class MyDiscoveryConfiguration {
    }

Controller
----------

Create a new file ``src/main/java/com/example/consul/discovery/MyDiscoveryController.java``:

.. code-block:: java

    @RestController
    @RequiredArgsConstructor
    public class MyDiscoveryController {

        private final DiscoveryClient discoveryClient;

        @GetMapping("/ping")
        public String ping() {
            return "pong";
        }

        @GetMapping("/discoveryClient")
        public String discoveryPing() throws RestClientException, ServiceUnavailableException {
            URI service = serviceUrl()
                    .map(s -> s.resolve("/ping"))
                    .orElseThrow(ServiceUnavailableException::new);
            return new RestTemplate().getForEntity(service, String.class)
                    .getBody();
        }

        private Optional<URI> serviceUrl() {
            return discoveryClient.getInstances("myApp")
                    .stream()
                    .findFirst()
                    .map(ServiceInstance::getUri);
        }
    }

Create another file ``src/main/java/com/example/consul/discovery/MyHealthCheckController.java``:

.. code-block:: java

    @RestController
    public class MyHealthCheckController {

        @GetMapping("/my-health-check")
        public String healthCheck() {
            return "good";
        }
    }

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Go to `http://localhost:8500` and verify `myApp` was registered.