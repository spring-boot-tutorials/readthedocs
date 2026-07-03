Cloud LoadBalancer Static Services #WIP#
=======================================

https://github.com/spring-boot-tutorials/cloud-loadbalancer-clietside-static-services

Here we will create 3 applications:

- producer service #1 - running on localhost:8081
- producer service #2 - running on localhost:8082
- client service - running on localhost:8080


**Producer Service #1**
------------------------

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``:

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

Properties
----------

Add the following properties in ``src/main/resources/application.properties``:

.. code-block:: properties

    server.port=8081

Controller
----------

Create new file ``src/main/java/com/example/cloud_loadbalancer/DefaultController.java``:

.. code-block:: java

    @RestController
    public class DefaultController {

        @GetMapping("/hello")
        public String hello(HttpServletRequest request) {
            return "Hello from " + request.getLocalPort();
        }
    }

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run







**Producer Service #2**
------------------------

Exact same as #1 but ``server.port=8082`` instead of ``server.port=8081``.






**Client Service**
--------------------

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
  - spring-cloud-starter-loadbalancer
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
        <artifactId>spring-cloud-starter-loadbalancer</artifactId>
    </dependency>

TODO
----
