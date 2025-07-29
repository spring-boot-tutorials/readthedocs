Cloud Function #WIP#
====================

https://github.com/spring-boot-tutorials/cloud-function

TODO integrate with AWS: https://www.baeldung.com/spring-cloud-function#spring_cloud_function_on_aws

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
  - spring-cloud-function-web
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
        <artifactId>spring-cloud-function-web</artifactId>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.yaml``:

.. code-block:: yaml

    spring.cloud.function.scan.packages=com.example.cloud_function.functions

Configuration
-------------

Modify ``src/main/java/com/example/cloud_function/DefaultConfiguration.java``:

.. code-block:: java

    @Configuration
    public class DefaultConfiguration {

        // curl localhost:8080/reverseString -H "Content-Type: text/plain" -d "Hello, World"
        @Bean
        public Function<String, String> reverseString() {
            return value -> new StringBuilder(value).reverse().toString();
        }
    }

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Verify
------

Execute in terminal

.. code-block:: sh

    curl localhost:8080/reverseString -H "Content-Type: text/plain" -d "Hello, World"
