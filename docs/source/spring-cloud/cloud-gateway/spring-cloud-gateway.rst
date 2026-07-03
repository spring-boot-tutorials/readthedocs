Cloud Gateway #WIP#
===================

https://github.com/spring-boot-tutorials/cloud-gateway

TODO pure-code configuration https://www.baeldung.com/spring-cloud-gateway

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-cloud-starter-gateway
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``:

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-gateway</artifactId>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.yaml``:

.. code-block:: yaml

    spring:
      cloud:
        gateway:
    #      open http://localhost:8080/example/
          routes:
            - id: example_route
              uri: https://example.com/
              predicates:
                - Path=/example/
    management:
      endpoints:
        web:
          exposure:
            include: "*"

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Verify
------

Go to: http://localhost:8080/example/
