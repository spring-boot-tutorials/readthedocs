h2 JPA
======

https://github.com/spring-boot-tutorials/spring-data-h2-jpa

In this article we will configure Spring Boot to connect to an `h2 <https://www.h2database.com/html/main.html/>`_ database
via JPA.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:
  - jpa
  - h2
  - JDBC
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
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.38</version>
    </dependency>

Properties
----------

In ``src/main/resources/application.properties`` let's add the following properties so the Spring Boot application
can connect to the database

.. code-block:: properties

    spring.datasource.url=jdbc:h2:mem:testdb
    spring.datasource.username=sa
    spring.datasource.password=

    spring.jpa.generate-ddl=false
    spring.jpa.hibernate.ddl-auto=none

    spring.h2.console.enabled=true

data.sql
--------

Create a new file ``src/main/resources/data.sql``:

.. code-block:: sql

    -- Spring Boot will automatically pick up the data.sql and run
    -- it against our configured H2 database during application startup.
    -- This is a good way to seed the database for testing or other purposes

    DROP TABLE IF EXISTS person;
    CREATE TABLE person (
      id INT AUTO_INCREMENT PRIMARY KEY,
      first_name VARCHAR(250) NOT NULL,
      last_name VARCHAR(250) NOT NULL
    );

Model
------

Let's create a new POJO ``src/main/java/com/example/Person.java``

.. code-block:: java

    @Data
    @SuperBuilder
    @Entity
    @NoArgsConstructor
    public class Person {
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;
        private String firstName;
        private String lastName;
    }

Repository
----------

Next we will create a Spring repository to CRUD against the database

.. code-block:: java

    public interface PersonRepository extends JpaRepository<Person, Long> {

        // Automatic Custom Query
        Person findByFirstName(String name);

        // Manual Custom Query
    //    @Query("SELECT p FROM PERSON p WHERE LOWER(p.first_name) = LOWER(:first_name)")
    //    Person retrieveByName(@Param("first_name") String firstName);
    }

Main
----

Now let's use this repository.

Go back to ``MainApplication.java`` and add the following:

.. code-block:: java

    @SpringBootApplication
    public class MainApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(MainApplication.class, args);
    	}

    	@Autowired
    	PersonRepository personRepository;

    	@Override
    	public void run(String... args) throws Exception {
    		// 1. INSERT
    		Person saved = personRepository.save(Person.builder()
    				.firstName("marcus")
    				.lastName("chiu")
    				.build());
    		System.out.println("1. " + saved);

    		// 2. AUTO CUSTOM QUERY
    		Person p = personRepository.findByFirstName("marcus");
    		System.out.println("2. " + p);

    		// 3. MANUAL CUSTOM QUERY
    //		p = personRepository.retrieveByName("marcus");
    //		System.out.println("3. " + p);

    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.
