h2 JPA #2
=========

https://github.com/spring-boot-tutorials/spring-data-h2-jpa-2

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
    spring.datasource.driverClassName=org.h2.Driver
    spring.datasource.username=sa
    spring.datasource.password=

    #spring.jpa.database=POSTGRESQL
    spring.jpa.show-sql=true
    spring.jpa.hibernate.ddl-auto=none
    #spring.jpa.database-platform=org.hibernate.dialect.H2Dialect

    # enables H2 console http://localhost:8080/h2-console
    spring.h2.console.enabled=true
    #spring.h2.console.path=/h2-console

data.sql
--------

Create a new file ``src/main/resources/data.sql``:

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

Next we will create a Spring repository to CRUD against the database

.. code-block:: java

    @Repository
    public interface BillionaireRepository extends CrudRepository<Billionaire, Long> {

        // Automatic Custom Query
        List<Billionaire> findByFirstName(String name);

        // Manual Custom Query #1
        @Query(value = "SELECT * FROM BILLIONAIRE u WHERE u.first_name = ?1", nativeQuery = true)
        List<Billionaire> retrieveByName1(String firstName);

        // Manual Custom Query #2
        @Query(value = "SELECT * FROM BILLIONAIRE u WHERE u.first_name = :name", nativeQuery = true)
        List<Billionaire> retrieveByName2(@Param("name") String firstName);
    }

Main
----

Now let's use this repository.

Go back to ``MainApplication.java`` and add the following:

.. code-block:: java

    @SpringBootApplication
    public class JpaH2ExampleApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(JpaH2ExampleApplication.class, args);
    	}

    	@Autowired
    	BillionaireRepository billionaireRepository;


    	@Override
    	public void run(String... args) throws Exception {
    		// 1. INSERT
    		Billionaire saved = billionaireRepository.save(Billionaire.builder()
    				.firstName("marcus")
    				.lastName("chiu")
    				.career("software engineer")
    				.build());
    		System.out.println("1. " + saved);

    		// 2. AUTO CUSTOM QUERY
    		List<Billionaire> p = billionaireRepository.findByFirstName("marcus");
    		System.out.println("2. " + p);

    		// 3. MANUAL CUSTOM QUERY #1
    		p = billionaireRepository.retrieveByName1("marcus");
    		System.out.println("3. " + p);

    		// 3. MANUAL CUSTOM QUERY #2
    		p = billionaireRepository.retrieveByName2("marcus");
    		System.out.println("4. " + p);
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.
