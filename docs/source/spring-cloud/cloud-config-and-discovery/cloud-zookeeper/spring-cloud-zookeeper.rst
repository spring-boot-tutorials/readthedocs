Cloud Zookeeper
===============

We will create 2 applications:

- service producer:

  - https://github.com/spring-boot-tutorials/cloud-zookeeper-service-producer
  - running on localhost:8080

- service consumer:

  - https://github.com/spring-boot-tutorials/cloud-zookeeper-service-consumer
  - running on localhost:8081

Install & Run Zookeeper Server
------------------------------

.. code-block:: sh

    docker run --name zookeeper-server -p 2181:2181 zookeeper:latest

**Service Producer Application**
--------------------------------

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
  - spring-cloud-starter-zookeeper-discovery
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
        <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.yaml``:

.. code-block:: yaml

    spring:
      application:
        name: my-service-provider
      cloud:
        zookeeper:
           # uncomment if zookeeper server is running elsewhere
    #      connect-string: localhost:2181
          discovery:
            enabled: true
    logging:
      level:
        org.apache.zookeeper.ClientCnxn: WARN

Controller
----------

Create a new file ``src/main/java/com/example/spring_cloud_zookeeper/DefaultController.java``:

.. code-block:: java

    @RestController
    public class DefaultController {

        @GetMapping("/helloworld")
        public String helloWorld() {
            return "Hello World!";
        }
    }

Main
----

Modify ``MainApplication.java``:

.. code-block:: java

    @EnableDiscoveryClient
    @SpringBootApplication
    public class SpringCloudZookeeperApplication {

    	public static void main(String[] args) {
    		SpringApplication.run(SpringCloudZookeeperApplication.class, args);
    	}

    }

Run Application
---------------

.. code-block:: sh

    mvn spring-boot:run






**Service Consumer Application**
--------------------------------

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
  - spring-cloud-starter-zookeeper-discovery
  - spring-boot-starter-actuator
  - spring-cloud-starter-openfeign
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
        <artifactId>spring-cloud-starter-zookeeper-discovery</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-openfeign</artifactId>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.yaml``:

.. code-block:: yaml

    server:
      port: 8081

    # uncomment if zookeeper server is running elsewhere
    #spring:
    #  cloud:
    #    zookeeper:
    #      connect-string: localhost:2181

    logging:
      level:
        org.apache.zookeeper.ClientCnxn: WARN

Configuration
-------------

Create a new file ``src/main/java/com/example/spring_cloud_zookeeper/DefaultFeignClient.java``:

.. code-block:: java

    @Configuration
    @EnableFeignClients
    @EnableDiscoveryClient
    public class DefaultFeignClient {

        @Autowired
        private TheClient theClient;

        @FeignClient(name = "my-service-provider")
        public interface TheClient {
            @RequestMapping(path = "/helloworld", method = RequestMethod.GET)
            @ResponseBody
            String helloWorld();
        }

        public String helloWorld() {
            return theClient.helloWorld();
        }
    }

Controller
----------

Create a new file ``src/main/java/com/example/spring_cloud_zookeeper/DefaultController.java``:

.. code-block:: java

    @RestController
    public class DefaultController {

        @Autowired
        private DefaultFeignClient defaultFeignClient;

        @GetMapping("/get-greeting")
        public String greeting() {
            return defaultFeignClient.helloWorld();
        }
    }

Run Application
---------------

.. code-block:: sh

    mvn spring-boot:run

Verify
------

Go to http:/localhost:8081/get-greeting
