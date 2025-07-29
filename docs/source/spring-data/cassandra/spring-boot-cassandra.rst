Cassandra
=========

https://github.com/spring-boot-tutorials/spring-data-cassandra

In this article we will configure Spring Boot to connect to a `Cassandra <https://cassandra.apache.org/>`_ database.

Cassandra Server
----------------

Install and run Cassandra server

.. code-block:: sh

    brew install cassandra
    brew services start cassandra

Enter Cassandra Cli

.. code-block:: sh

    cqlsh

Create a new KEYSPACE in Cassandra

.. code-block:: sql

    CREATE KEYSPACE my_keyspace WITH replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };

Create a table under new KEYSPACE

.. code-block:: sh

    USE my_keyspace;
    CREATE TABLE person (
        id uuid PRIMARY KEY,
        title text,
        publisher text,
        tags set<text>
    );

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Click `Add Dependencies`, search for `Cassandra`, then add
- Click `Add Dependencies`, search for `Lombok`, then add
- Click `Generate`

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-cassandra</artifactId>
    </dependency>
    <dependency>
        <groupId>org.instancio</groupId>
        <artifactId>instancio-junit</artifactId>
        <version>5.4.0</version>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

Properties
----------

In ``src/main/resources/application.properties`` let's add the following properties so the Spring Boot application
can connect to the Cassandra database

.. code-block:: properties

    spring.cassandra.keyspace-name=my_keyspace
    spring.data.cassandra.port=9142
    spring.data.cassandra.contact-points=127.0.0.1
    spring.cassandra.local-datacenter=datacenter1

Configuration
-------------

Let's annotate ``CassandraApplication.java`` like so:

.. code-block:: java

    @SpringBootApplication
    @EnableCassandraRepositories(basePackages = "com.example.cassandra")
    public class CassandraApplication

Model
-----

Let's create a new POJO ``src/main/java/com/example/cassandra/model/Person.java``

.. code-block:: java

    @Table
    @Data
    @SuperBuilder
    @NoArgsConstructor
    public class Person {

        @PrimaryKeyColumn(
                name = "id",
                ordinal = 2,
                type = PrimaryKeyType.CLUSTERED,
                ordering = Ordering.DESCENDING)
        private UUID id;

        @PrimaryKeyColumn(name = "title", ordinal = 0, type = PrimaryKeyType.PARTITIONED)
        private String title;

        @PrimaryKeyColumn(name = "publisher", ordinal = 1, type = PrimaryKeyType.PARTITIONED)
        private String publisher;

        @Column
        private Set<String> tags = new HashSet<>();
    }

Repository
----------

Next we will create a Spring repository to CRUD against the database

.. code-block:: java

    @Repository
    public interface PersonRepository extends CassandraRepository<Person, Long> {
    }

Main
----

Now let's use this repository.

Go back to ``CassandraApplication.java`` and add the following:

.. code-block:: java

    ...
    public class CassandraApplication implements CommandLineRunner {

        public static void main(String[] args) {
            SpringApplication.run(CassandraApplication.class, args);
        }

        @Autowired
        private PersonRepository personRepository;

        public void run(String... args) throws Exception {
            personRepository.deleteAll();

            // 1. save
            Person person = Person.builder()
                    .id(UUID.randomUUID())
                    .title("Head First Java")
                    .publisher("O'Reilly Media")
                    .tags(ImmutableSet.of("Computer", "Software"))
                    .build();
            personRepository.save(person);

            // 2. saveAll
            int count = 10;
            List<Person> persons = Instancio.ofList(Person.class)
                    .size(count)
                    .create();
            persons = personRepository.saveAll(persons);
            System.out.println("2. saveAll");
            persons.forEach(System.out::println);

            // 3. update
            person.setTitle("Head First Java Second Edition");
            person = personRepository.save(person);
            System.out.println("3. " + person);

            // 4. findAll
            persons = personRepository.findAll();
            System.out.println("4. findAll");
            persons.forEach(System.out::println);
        }
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.