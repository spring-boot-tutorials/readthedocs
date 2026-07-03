Rest Repositories & HAL Explorer
================================

https://github.com/spring-boot-tutorials/spring-data-rest-repositories-hal-explorer

In this article we will configure Rest Repositories in Spring Boot.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:
  - rest repositories
  - lombok
  - jpa
  - h2
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
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-rest</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.8</version>
        <scope>provided</scope>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>runtime</scope>
    </dependency>

Properties
----------

Add the following properties to ``src/main/resources/application.properties``:

.. code-block:: properties

    spring.datasource.url=jdbc:h2:mem:testdb
    spring.datasource.driverClassName=org.h2.Driver
    spring.datasource.username=sa
    spring.datasource.password=

    spring.jpa.show-sql=true
    spring.jpa.hibernate.ddl-auto=none

    # enables H2 console http://localhost:8080/h2-console
    spring.h2.console.enabled=true

data.sql
--------

Add the following into ``src/main/resources/data.sql``:

.. code-block:: sql

    -- Spring Boot will automatically pick up the data.sql and run
    -- it against our configured H2 database during application startup.
    -- This is a good way to seed the database for testing or other purposes

    DROP TABLE IF EXISTS billionaire;
    CREATE TABLE billionaire (
      id INT AUTO_INCREMENT PRIMARY KEY,
      first_name VARCHAR(250) NOT NULL,
      last_name VARCHAR(250) NOT NULL,
      career VARCHAR(250) DEFAULT NULL
    );

    INSERT INTO billionaire (first_name, last_name, career) VALUES
      ('Aliko', 'Dangote', 'Billionaire Industrialist'),
      ('Bill', 'Gates', 'Billionaire Tech Entrepreneur'),
      ('Folrunsho', 'Alakija', 'Billionaire Oil Magnate');

Model
------

Let's create a new POJO ``src/main/java/com/example/Billionaire.java``

.. code-block:: java

    @Entity
    @Data
    @SuperBuilder
    @NoArgsConstructor
    public class Billionaire {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        @NonNull
        private String firstName;

        @NonNull
        private String lastName;

        @NonNull
        private String career;
    }


Repository
----------

Next we will create a Spring repository to CRUD against the database.

This file will be called ``src/main/java/com/example/BillionaireRepository.java``

.. code-block:: java

    @Repository
    public interface BillionaireRepository extends PagingAndSortingRepository<Billionaire, Long> {

        @RestResource(rel = "first-name-contains", path="first-name-contains")
        Page<Billionaire> findByFirstNameContaining(@Param("query") String query, Pageable page);

        @RestResource(rel = "last-name-contains", path="last-name-contains", exported = false)
        Page<Billionaire> findByLastNameContaining(@Param("query") String query, Pageable page);
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Test Endpoints
--------------

- goto: http://localhost:8080/
- goto: http://localhost:8080/billionaires/search/first-name-contains?query=ill
