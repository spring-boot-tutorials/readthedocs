Spring Sentry #WIP#
===================

https://github.com/spring-boot-tutorials/spring-testcontainers-mongodb

In this article we will configure Spring Testcontainers MongoDB.

Based on: https://docs.sentry.io/platforms/java/guides/spring-boot/

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-data-mongodb
  - spring-boot-starter-web
  - spring-boot-testcontainers
  - lombok
- Click `Generate`

Dependencies
------------

Dependencies in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-mongodb</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-testcontainers</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>mongodb</artifactId>
        <scope>test</scope>
    </dependency>

Model
-----

Create new POJO class ``src/main/java/com/example/spring_testcontainers/Author.java``:

.. code-block:: java

    @Data
    @SuperBuilder
    @Document(collection = "authors")
    @NoArgsConstructor
    @AllArgsConstructor
    public class Author {
        @Id
        @Indexed(unique = true)
        @Field(name = "_id")
        private String id = UUID.randomUUID().toString();

        @Field(name = "full_name")
        private String name;

        @Indexed(unique = true)
        private String email;

        @Field(name = "num_articles")
        private Integer articleCount;

        private Boolean active;

        public Boolean isActive() {
            return this.active;
        }
    }

Repository
----------

Create new file ``src/main/java/com/example/spring_testcontainers/AuthorRepository.java``:

.. code-block:: java

    public interface AuthorRepository extends MongoRepository<Author, String> {
        List<Author> findByEmail(String email);

        List<Author> findByActiveTrueAndArticleCountGreaterThanEqual(int articleCount);

        @Query("{ 'num_articles': { $gte: ?0, $lte: ?1 }, 'active': true }")
        List<Author> findActiveAuthorsInArticleRange(int minArticles, int maxArticles);

        // Returns active authors JUST email
        @Query(value = "{ 'active': true }", fields = "{ 'email': 1 }")
        List<Author> findActiveAuthorEmails();
    }

Controller
----------

Let's create a new file ``src/main/java/com/example/spring_testcontainers/AuthorController.java``

.. code-block:: java

    @RestController
    @RequestMapping("characters")
    @RequiredArgsConstructor
    public class AuthorController {

        private final AuthorRepository repository;

        // curl http://localhost:8080/characters
        @GetMapping
        public List<Author> findAll() {
            return repository.findAll();
        }

        // curl -X POST -H "Content-Type: application/json" -d '{"id": "id-1", "name": "marcus chiu", "email": "marcuschiu9@gmail.com"}' http://localhost:8080/characters
        // curl -X POST -H "Content-Type: application/json" -d '{"id": "id-2", "name": "marcus chiu", "email": "marcuschiu9@gmail.com"}' http://localhost:8080/characters
        @PostMapping
        public Author save(@RequestBody Author character) {
            return repository.save(character);
        }
    }

Create Tests #1
---------------

Create new file ``src/test/java/com/example/spring_testcontainers/individual/ServiceConnectionIntegrationTest.java``:

.. code-block:: java

    @Testcontainers
    @SpringBootTest(webEnvironment = DEFINED_PORT)
    class ServiceConnectionIntegrationTest {

        @Container
        @ServiceConnection
        static MongoDBContainer mongoDBContainer = new MongoDBContainer(DockerImageName.parse("mongo:7.0"));

        @Autowired
        AuthorRepository repository;
        @Autowired
        TestRestTemplate restTemplate;

        @Test
        void given_when_then() {
            // given
            repository.saveAll(List.of(
                    new Author(UUID.randomUUID().toString(), "name-1", "email-1", 1, true),
                    new Author(UUID.randomUUID().toString(), "name-2", "email-2", 1, true),
                    new Author(UUID.randomUUID().toString(), "name-3", "email-3", 1, true),
                    new Author(UUID.randomUUID().toString(), "name-4", "email-4", 1, true)
            ));

            ResponseEntity<String> response = restTemplate.getForEntity("/characters", String.class);
            assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
            assertThat(response.getBody()).contains("name-1", "name-2", "name-3", "name-4");
        }
    }

Run Test #1
-----------

.. code-block:: sh

    mvn clean package

Create Local Development Environment
------------------------------------

Create the following files:

- ``src/test/java/com/example/spring_testcontainers/localdevelopment/TestcontainersConfiguration.java``
- ``src/test/java/com/example/spring_testcontainers/localdevelopment/SpringTestcontainersApplicationTests.java``
- ``src/test/java/com/example/spring_testcontainers/localdevelopment/TestSpringTestcontainersApplication.java``

.. code-block:: java

    @TestConfiguration(proxyBeanMethods = false)
    class TestcontainersConfiguration {
        @Bean
        @ServiceConnection
        public MongoDBContainer mongoDBContainer() {
            return new MongoDBContainer(DockerImageName.parse("mongo:7.0"));
        }
    }

.. code-block:: java

    @Import(TestcontainersConfiguration.class)
    @SpringBootTest
    class SpringTestcontainersApplicationTests {

    	@Test
    	void contextLoads() {
    	}

    }

.. code-block:: java

    public class TestSpringTestcontainersApplication {

    	public static void main(String[] args) {
    		SpringApplication.from(SpringTestcontainersApplication::main)
    				.with(TestcontainersConfiguration.class)
    				.run(args);
    	}
    }

Run Local Development Environment
---------------------------------

If you have IntelliJ as an IDE you could right click ``TestSpringTestcontainersApplication`` and click ``run``.
