HyperSQL Embedded (Autoconfigure Datasource)
========================================================

https://github.com/spring-boot-tutorials/spring-data-hypersql-embedded-autoconfigure-jdbctemplate

In this article we will configure Spring Boot to connect to an `HyperSQL <https://hsqldb.org//>`_ database.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:
  - hypersql
  - Lombok
  - jpa
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.hsqldb</groupId>
        <artifactId>hsqldb</artifactId>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

Model
-----

Let's create a POJO class ``src/main/java/com/example/spring_hypersql_database/model/Person.java``:

.. code-block:: java

    @Data
    @NoArgsConstructor
    @Entity
    @AllArgsConstructor
    public class Person {
        @Id
        private Long id;
        private String firstName;
        private String lastName;
    }

Repository
----------

Let's create a repository ``src/main/java/com/example/spring_hypersql_database/repository/PersonRepository.java``:

.. code-block:: java

    @Repository
    public interface PersonRepository extends CrudRepository<Person, Long> {
    }

Main
----

Now let's use this repository.

Go back to ``SpringHypersqlDatabaseApplication.java`` and add the following:

.. code-block:: java

    @SpringBootApplication
    public class SpringHypersqlDatabaseApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(SpringHypersqlDatabaseApplication.class, args);
    	}

    	@Autowired
    	PersonRepository personRepository;

    	@Override
    	public void run(String... args) throws Exception {
    		personRepository.deleteAll();
    		Person p = personRepository.save(new Person(1L, "Marcus", "Chiu"));
    		System.out.println(p);
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.
