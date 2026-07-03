Rest Repositories
===============

https://github.com/spring-boot-tutorials/spring-data-rest-repositories

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
        <artifactId>spring-boot-starter-data-rest</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
    </dependency>
    <dependency>
        <groupId>org.instancio</groupId>
        <artifactId>instancio-junit</artifactId>
        <version>5.4.1</version>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

Model
------

Let's create a new POJO ``src/main/java/com/example/Person.java``

.. code-block:: java

    @Data
    @Entity
    @SuperBuilder
    @NoArgsConstructor
    public class Person {

        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private long id;

        private String name;
        private String email;
    }


Repository
----------

Next we will create a Spring repository to CRUD against the database.

This file will be called ``src/main/java/com/example/PersonRepositoryRestResource.java``

.. code-block:: java

    @RepositoryRestResource(collectionResourceRel = "persons", path = "persons")
    public interface PersonRepositoryRestResource extends PagingAndSortingRepository<Person, Long> {
        List<Person> findByName(@Param("name") String name);
    }

Let's create another one for internal use

.. code-block:: java

    @Repository
    public interface PersonCrudRepository extends CrudRepository<Person, Long> {
    }

Main
----

Now let's use this repository.

Go back to ``MainApplication.java`` and add the following:

.. code-block:: java

    @SpringBootApplication
    public class DataRestApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(DataRestApplication.class, args);
    	}

    	@Autowired
    	PersonCrudRepository personCrudRepository;

    	@Override
    	public void run(String... args) throws Exception {
    		int personCount = 100;
    		List<Person> persons = Instancio.ofList(Person.class)
    				.size(personCount)
    				.set(field(Person::getId), null)
    				.create();
    		personCrudRepository.saveAll(persons);
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Verify
------

In a browser of your choice go to http://localhost:8080/
