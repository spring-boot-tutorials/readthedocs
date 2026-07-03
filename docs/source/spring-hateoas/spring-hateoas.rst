Spring Hateoas #WIP#
====================

https://github.com/spring-boot-tutorials/spring-hateoas

In this article we will configure Spring Boot with Hateoas.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-hateoas
  - spring-boot-starter-web
  - lombok
- Click `Generate`

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-hateoas</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
    </dependency>

Model
-----

Let's create a new POJO ``src/main/java/com/example/spring_hateoas/model/Customer.java``

.. code-block:: java

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public class Customer extends RepresentationModel<Customer> {
        private String customerId;
        private String customerName;
        private String companyName;
    }

Controller
----------

Create a stub repository with fake data ``src/main/java/com/example/spring_hateoas/controller/DefaultController.java``:

.. code-block:: java

    @RestController
    @RequestMapping(value = "/customers")
    public class DefaultController {

        private final List<Customer> customers = List.of(
                new Customer("id-1", "name-1","company-name-1"),
                new Customer("id-2", "name-2","company-name-2"),
                new Customer("id-3", "name-3","company-name-3")
        );

        public DefaultController() {
            for (Customer c : customers) {
                c.add(linkTo(DefaultController.class).slash(c.getCustomerId()).withSelfRel());
            }
        }

        /**
         * http://localhost:8080/customers/id-1
         * @param customerId
         * @return
         */
        @GetMapping(value = "/{customerId}", produces = { "application/hal+json" })
        public Customer getCustomerById(@PathVariable String customerId) {
            return customers.stream().filter(c -> c.getCustomerId().equals(customerId)).findAny().orElse(null);
        }
    }

Run & Verify Application
------------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Goto:

- http://localhost:8080/customers/id-1

TODO
----

continue from: https://www.baeldung.com/spring-hateoas-tutorial#relations
