MongoDB
=======

https://github.com/spring-boot-tutorials/spring-data-mongodb

In this article we will configure Spring Boot to connect to a `MongoDB <https://www.mongodb.com//>`_ database.

MongoDB Server
--------------

Install and run MongoDB server

.. code-block:: sh

    brew update
    brew install mongodb-community
    brew services start mongodb-community

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Click ``Add Dependencies``, search for ``mongodb``, then add
- Click ``Add Dependencies``, search for ``Lombok``, then add
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-mongodb</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.38</version>
    </dependency>
    <dependency>
        <groupId>org.instancio</groupId>
        <artifactId>instancio-junit</artifactId>
        <version>5.4.0</version>
    </dependency>

Properties
----------

In ``src/main/resources/application.properties`` let's add the following properties so the Spring Boot application
can connect to the database

.. code-block:: properties

    spring.data.mongodb.host=localhost
    spring.data.mongodb.port=27017

Model
------

Let's create a new POJO ``src/main/java/com/example/mongodb/Author.java``

.. code-block:: java

    Data
    @SuperBuilder
    @Document(collection = "authors")
    @NoArgsConstructor
    class Author {
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

Next we will create a Spring repository to CRUD against the database.

This file will be called ``src/main/java/com/example/AuthorRepository.java``

.. code-block:: java

    interface AuthorRepository extends MongoRepository<Author, String> {
        Optional<Author> findByEmail(String email);

        List<Author> findByActiveTrueAndArticleCountGreaterThanEqual(int articleCount);

        @Query("{ 'num_articles': { $gte: ?0, $lte: ?1 }, 'active': true }")
        List<Author> findActiveAuthorsInArticleRange(int minArticles, int maxArticles);

        // Returns active authors JUST email
        @Query(value = "{ 'active': true }", fields = "{ 'email': 1 }")
        List<Author> findActiveAuthorEmails();
    }

Main
----

Now let's use this repository.

Go back to ``MainApplication.java`` and add the following:

.. code-block:: java

    @SpringBootApplication
    @EnableMongoRepositories(basePackages = "com.example")
    public class MainApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(MainApplication.class, args);
    	}

    	@Autowired
    	AuthorRepository authorRepository;

    	@Autowired
    	MongoTemplate mongoTemplate;

    	@Override
    	public void run(String... args) throws Exception {
    		authorRepository.deleteAll();

    		// 1. Save
    		Author author = authorRepository.save(
    				Author.builder()
    						.name("Marcus Chiu")
    						.email("marcuschiu9@gmail.com")
    						.articleCount(15)
    						.active(true)
    						.build()
    		);
    		System.out.println(author);

    		// 2. FindAll
    		List<Author> authors = authorRepository.findAll();
    		authors.forEach(System.out::println);

    		// 3. Paging & Sorting
    		int authorCount = 10;
    		authors = Instancio.ofList(Author.class)
    				.size(authorCount)
    				.create();
    		authorRepository.saveAll(authors);

    		Sort sort = Sort.by("name").ascending();
    		PageRequest pageRequest = PageRequest.of(0, 5, sort);
    		List<Author> retrievedAuthors = authorRepository.findAll(pageRequest)
    				.getContent();
    		System.out.println("3. Paging & Sorting");
    		retrievedAuthors.forEach(System.out::println);

    		// 4. Derived Query Methods
    		Optional<Author> oAuthor = authorRepository.findByEmail("marcuschiu9@gmail.com");
    		System.out.println("4a. " + oAuthor.get());
    		authors = authorRepository.findByActiveTrueAndArticleCountGreaterThanEqual(1000);
    		System.out.println("4b. ");
    		authors.forEach(System.out::println);

    		// 5. Custom Query Methods
    		authors = authorRepository.findActiveAuthorsInArticleRange(0, 5000);
    		System.out.println("5. ");
    		authors.forEach(System.out::println);

    		// 6. MongoTemplate
    		author = Instancio.create(Author.class);
    		Author savedAuthor = mongoTemplate.insert(author);
    		Author retrievedAuthor = mongoTemplate.findById(savedAuthor.getId(), Author.class);
    		System.out.println("6. " + retrievedAuthor);

    		// 7. Complex Queries
    		author = Instancio.of(Author.class)
    				.set(field(Author::isActive), false)
    				.generate(field(Author::getEmail), gen -> gen.text().pattern("#a#a#a@baeldung.com"))
    				.create();
    		mongoTemplate.save(author);
    		Criteria nonActive = Criteria.where("active").is(false);
    		Criteria baeldungEmail = Criteria.where("email").regex("@baeldung\\.com$");
    		Query query = new Query();
    		query.addCriteria(nonActive);
    		query.addCriteria(baeldungEmail);
    		retrievedAuthors = mongoTemplate.find(query, Author.class);
    		System.out.println("7. Complex Queries");
    		retrievedAuthors.forEach(System.out::println);

    		// 8. Update Queries
    		authorRepository.save(Author.builder().name("Jigglypuff").build());
    		query = new Query(Criteria.where("name").is("Jigglypuff"));
    		Update update = new Update();
    		update.set("active", false);
    		UpdateResult updateResult = mongoTemplate.updateFirst(query, update, Author.class);
    		assertThat(updateResult.getModifiedCount()).isEqualTo(1);

    		// 9. Upsert
    		UUID authorId = UUID.randomUUID();
    		String email = RandomString.make() + "@baeldung.com";
    		String name = RandomString.make();
    		query = new Query(Criteria.where("email").is(email));
    		update = new Update()
    				.set("name", name)
    				.setOnInsert("id", authorId)
    				.setOnInsert("active", true);
    		mongoTemplate.upsert(query, update, Author.class);
    		retrievedAuthor = mongoTemplate.findOne(query, Author.class);
    		assertThat(retrievedAuthor).isNotNull();
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.