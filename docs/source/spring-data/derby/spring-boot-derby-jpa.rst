Derby (JPA) #WIP#
=================

https://github.com/spring-boot-tutorials/spring-data-derby-jpa

In this article we will configure Spring Boot to connect to a `Derby <https://db.apache.org/derby//>`_ database.

Derby Server
------------

Run Derby database without saving to local filesystem:

.. code-block:: sh

    docker run \
      -p 1527:1527 \
      -e DBNAME=testdb \
      -e DERBY_USER=my_user \
      -e DERBY_PASSWORD=my_password \
      --name derby_instance \
      adito/derby

Run Derby database while saving to local filesystem:

.. code-block:: sh

    docker run \
      -p 1527:1527 \
      -e DBNAME=testdb \
      -e DERBY_USER=my_user \
      -e DERBY_PASSWORD=my_password \
      -v $(pwd)/dbs:/dbs \
      --name derby_instance \
      adito/derby

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Click ``Add Dependencies``, search for ``Derby``, then add
- Click ``Add Dependencies``, search for ``Lombok``, then add
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
        <groupId>org.apache.derby</groupId>
        <artifactId>derbyclient</artifactId>
    </dependency>
    <dependency>
        <groupId>org.apache.derby</groupId>
        <artifactId>derby</artifactId>
<!--			<scope>runtime</scope>-->
    </dependency>
    <dependency>
        <groupId>org.apache.derby</groupId>
        <artifactId>derbytools</artifactId>
<!--			<scope>runtime</scope>-->
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

    # Increased timeout to fit slower environments like TravisCI
    spring.couchbase.env.timeouts.view=15000
    spring.couchbase.env.timeouts.query=15000
    spring.couchbase.connection-string=couchbase://127.0.0.1
    spring.couchbase.username=admin
    spring.couchbase.password=password
    spring.data.couchbase.bucket-name=travel-sample
    spring.data.couchbase.auto-index=true

Configuration
-------------

Let's create a file ``src/main/java/com/example/Couchbase/config/CouchbaseConfiguration.java``:

.. code-block:: java

    @Configuration
    public class CouchbaseConfiguration {

        @Autowired
        CouchbaseTemplate couchbaseTemplate;

        @Autowired
        Cluster cluster;

        /**
         * Add the _class field to all Airline documents
         */
        @PostConstruct
        private void postConstruct() {
            cluster.queryIndexes().createPrimaryIndex(
                    couchbaseTemplate.getBucketName(),
                    CreatePrimaryQueryIndexOptions.createPrimaryQueryIndexOptions().ignoreIfExists(true)
            );

            // Need to post-process travel data to add _class attribute
            cluster.query("update `travel-sample` set _class='" + Airline.class.getName() + "' where type = 'airline'");
        }
    }

Model
------

Let's create a new POJO ``src/main/java/com/example/cassandra/model/Airline.java``

.. code-block:: java

    @Data
    @Document
    @SuperBuilder
    @NoArgsConstructor
    @JsonIgnoreProperties(ignoreUnknown = true)
    public class Airline {

        @Id
        private String id;
        private String name;
        private String iata;
        private String icao;
        private String callsign;
        private String country;
    }

Repository
----------

Next we will create a Spring repository to CRUD against the Couchbase database.

This file will be called ``src/main/java/com/example/Couchbase/repository/AirlineRepository.java``

.. code-block:: java

    @Repository
    public interface AirlineRepository extends CrudRepository<Airline, String> {

        List<Airline> findByIata(String code);
    }

Main
----

Now let's use this repository.

Go back to ``CassandraApplication.java`` and add the following:

.. code-block:: java

    ...
    @SpringBootApplication
    public class CouchbaseApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(CouchbaseApplication.class, args);
    	}

    	@Autowired
    	AirlineRepository airlineRepository;

    	@Override
    	public void run(String... args) throws Exception {
    		airlineRepository.deleteAll();

    		// 1. save
    		Airline airline = Instancio.create(Airline.class);
    		airline.setIata("iata");
    		airline = airlineRepository.save(airline);
    		System.out.println("1. " + airline);

    		// 2. saveAll
    		int count = 10;
    		var airlines = Instancio.ofList(Airline.class)
    				.size(count)
    				.create();
    		System.out.println("2. saveAll");
    		airlineRepository.saveAll(airlines)
    				.forEach(System.out::println);

    		// 3. Query Methods
    		System.out.println("3. query methods");
    		airlineRepository.findByIata("iata").forEach(System.out::println);
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.