Elasticsearch
=============

https://github.com/spring-boot-tutorials/spring-data-elasticsearch

In this article we will configure Spring Boot to connect to a `Elasticsearch <https://www.elastic.co/elasticsearch/>`_ server.

Elasticsearch Server
--------------------

Install and run server

.. code-block:: sh

    docker run \
     --name es762 \
     -p 9200:9200 \
      -e "discovery.type=single-node" \
      -e "xpack.security.enabled=false" \
      -e "xpack.security.http.ssl.enabled=false" \
      -e "xpack.security.enrollment.enabled=false" \
      elasticsearch:8.17.5

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Click ``Add Dependencies``, search for ``Elasticsearch``, then add
- Click ``Add Dependencies``, search for ``Lombok``, then add
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-elasticsearch</artifactId>
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
can connect to the database

.. code-block:: properties

    spring.elasticsearch.uris=http://localhost:9200
    #spring.elasticsearch.username=elastic
    #spring.elasticsearch.password=+60_FPpXOH6qOeX__PP5
    #spring.elasticsearch.rest.connection-timeout=5s
    #spring.elasticsearch.rest.read-timeout=60s

Model
------

Let's create a new POJO ``src/main/java/com/example/Conference.java``

.. code-block:: java

    @Data
    @SuperBuilder
    @Document(indexName = "conference-index")
    @NoArgsConstructor
    public class Conference {

        @Id
        private String id;
        private String name;
    }

Repository
----------

Next we will create a Spring repository to CRUD against the database.

This file will be called ``src/main/java/com/example/ConferenceRepository.java``

.. code-block:: java

    @Repository
    public interface ConferenceRepository extends ElasticsearchRepository<Conference, String> {
        List<Conference> findByName(String name);
    }

Main
----

Now let's use this repository.

Go back to ``ElasticsearchApplication.java`` and add the following:

.. code-block:: java

    @SpringBootApplication
    public class ElasticsearchApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(ElasticsearchApplication.class, args);
    	}

    	@Autowired
    	ConferenceRepository conferenceRepository;

    	@Override
    	public void run(String... args) throws Exception {
    		conferenceRepository.deleteAll();

    		// 1. save
    		var conference = Instancio.create(Conference.class);
    		conference.setName("marcus chiu");
    		var returnedConference = conferenceRepository.save(conference);
    		System.out.println("1. save");
    		System.out.println(returnedConference);

    		// 2. saveAll
    		int count = 10;
    		var conferences = Instancio.ofList(Conference.class)
    				.size(count)
    				.create();
    		System.out.println("2. saveAll");
    		conferenceRepository.saveAll(conferences)
    				.forEach(System.out::println);

    		// 3. method query
    		System.out.println("3. method query");
    		conferenceRepository.findByName("marcus chiu").forEach(System.out::println);
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.