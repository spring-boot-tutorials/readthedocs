Cloud Config
============

We will be creating 2 applications:

- config server

  - which will be running on localhost:8888
  - https://github.com/spring-boot-tutorials/cloud-config-server

- config client

  - which will be running on localhost:8080
  - https://github.com/spring-boot-tutorials/cloud-config-client

**Config Server**
-----------------

Config Setup
------------

On your local filesystem create a directory and under this directory execute the following:

.. code-block:: sh

    mkdir cloud-config
    cd cloud-config
    git init
    echo 'user.role=Developer' > config-client-development.properties
    echo 'user.role=User'      > config-client-production.properties
    git add .
    git commit -m 'Initial config-client properties'

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:
  - spring-cloud-config-server
  - spring-boot-starter-security
  - spring-boot-starter-web
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``:

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-config-server</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.properties``:

.. code-block:: properties

    server.port=8888
    spring.cloud.config.server.git.uri=file:///Users/marcuschiu/Desktop/spring-boot-examples/02-spring-cloud/cloud-config
    #spring.cloud.config.server.git.uri=ssh://localhost/config-repo
    spring.cloud.config.server.git.clone-on-start=true
    spring.security.user.name=root
    spring.security.user.password=s3cr3t

Replace ``spring.cloud.config.server.git.uri`` with your path to the config directory that you've setup in the prior step

Main
----

Add the following annotation into the ``MainApplication.java``:

.. code-block:: java

    @SpringBootApplication
    @EnableConfigServer
    public class CloudConfigServerApplication {
    	public static void main(String[] args) {
    		SpringApplication.run(CloudConfigServerApplication.class, args);
    	}
    }

Run Cloud Config Server
-----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Verify Cloud Config Server
--------------------------

.. code-block:: sh

    $> curl http://root:s3cr3t@localhost:8888/config-client/development/master
    {"name":"config-client","profiles":["development"],"label":"master","version":"491910a02ddeda681d3eea27fd8bbdb868a44399","state":"","propertySources":[{"name":"file:///Users/marcuschiu/Desktop/spring-boot-examples/02-spring-cloud/cloud-config/config-client-development.properties","source":{"user.role":"Developer"}}]}
    $> curl http://root:s3cr3t@localhost:8888/config-client/production/master
    {"name":"config-client","profiles":["production"],"label":"master","version":"491910a02ddeda681d3eea27fd8bbdb868a44399","state":"","propertySources":[{"name":"file:///Users/marcuschiu/Desktop/spring-boot-examples/02-spring-cloud/cloud-config/config-client-production.properties","source":{"user.role":"User"}}]}

Different ways to query the config-server

.. code-block:: txt

    /{application}/{profile}[/{label}]
    /{application}-{profile}.yml
    /{label}/{application}-{profile}.yml
    /{application}-{profile}.properties
    /{label}/{application}-{profile}.properties

**Config Client**
-----------------

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:
  - spring-boot-starter-web
  - spring-cloud-starter-config
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
        <artifactId>spring-cloud-starter-config</artifactId>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.properties``:

.. code-block:: properties

    spring.application.name=config-client
    spring.profiles.active=development
    spring.config.import=optional:configserver:http://root:s3cr3t@localhost:8888

Controller
----------

Add the following to ``src/main/java/com/example/cloud_config_client/DefaultController.java``:

.. code-block:: java

    @RestController
    public class DefaultController {

        @Value("${user.role}")
        private String role;

        @GetMapping(value = "/whoami", produces = MediaType.TEXT_PLAIN_VALUE)
        public String whoami() {
            return String.format("Hello! User Role is: %s", role);
        }
    }

Run Cloud Config Client
-----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Verify Cloud Config Client
--------------------------

.. code-block:: sh

    curl http://localhost:8080/whoami

This should return ``Developer``.

If we change the client-config property ``spring.profiles.active=development``
 to ``spring.profiles.active=production`` and re-run the application would
 return ``User`` instead of ``Developer``.
