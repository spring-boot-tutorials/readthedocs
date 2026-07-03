Flyway (Postgres)
=================

https://github.com/spring-boot-tutorials/spring-data-flyway-postgres

In this article we will configure Flyway on Spring Boot.

Based on: https://blog.jetbrains.com/idea/2024/11/how-to-use-flyway-for-database-migrations-in-spring-boot-applications/

Postgres Server
---------------

Install and run server

.. code-block:: sh

    docker run --name postgres-server \
      -e POSTGRES_DB=testdb \
      -e POSTGRES_USER=my_user \
      -e POSTGRES_PASSWORD=my_password \
      -p 5432:5432 \
      postgres

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies
  - jpa
  - validation
  - lombok
  - flyway
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    		<dependency>
    			<groupId>org.springframework.boot</groupId>
    			<artifactId>spring-boot-starter-validation</artifactId>
    		</dependency>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-data-jpa</artifactId>
            </dependency>
    		<dependency>
    			<groupId>org.postgresql</groupId>
    			<artifactId>postgresql</artifactId>
    			<scope>runtime</scope>
    		</dependency>
    		<dependency>
    			<groupId>org.flywaydb</groupId>
    			<artifactId>flyway-core</artifactId>
    		</dependency>
    		<dependency>
    			<groupId>org.flywaydb</groupId>
    			<artifactId>flyway-database-postgresql</artifactId>
    		</dependency>
    		<dependency>
    			<groupId>org.projectlombok</groupId>
    			<artifactId>lombok</artifactId>
    			<optional>true</optional>
    		</dependency>

Properties
----------

In ``src/main/resources/application.yaml`` let's add the following properties so the Spring Boot application
can connect to the database

.. code-block:: properties

    spring:
      datasource:
        url: jdbc:postgresql://localhost:5432/testdb
        username: my_user
        password: my_password
        driver-class-name: org.postgresql.Driver
      jpa:
        properties:
          hibernate:
            dialect: org.hibernate.dialect.PostgreSQLDialect

Flyway Script #1
----------------

Let's create a script ``src/main/resources/db/migration/V1__create_bookmarks_table.sql``:

.. code-block:: sql

    CREATE SEQUENCE IF NOT EXISTS bookmark_id_seq START WITH 1 INCREMENT BY 50;

    CREATE TABLE bookmarks (
       id         BIGINT                                    NOT NULL,
       title      VARCHAR(200)                              NOT NULL,
       url        VARCHAR(500)                              NOT NULL,
       created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
       updated_at TIMESTAMP WITHOUT TIME ZONE,
       CONSTRAINT pk_bookmarks PRIMARY KEY (id)
    );

Model
-----

Let's create a new POJO ``src/main/java/com/example/Bookmark.java``

.. code-block:: java

    @Entity
    @Table(name = "bookmarks")
    @Data
    @SuperBuilder
    @NoArgsConstructor
    public class Bookmark {

        @Id
        @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "bookmarks_id_gen")
        @SequenceGenerator(name = "bookmarks_id_gen", sequenceName = "bookmark_id_seq")
        @Column(name = "id", nullable = false)
        private Long id;

        @Size(max = 200)
        @NotNull
        @Column(name = "title", nullable = false, length = 200)
        private String title;

        @Size(max = 500)
        @NotNull
        @Column(name = "url", nullable = false, length = 500)
        private String url;

        @NotNull
        @ColumnDefault("now()")
        @Column(name = "created_at", nullable = false)
        private Instant createdAt;

        @Column(name = "updated_at")
        private Instant updatedAt;
    }

Repository
----------

Next we will create a Spring repository to CRUD against the database.

This file will be called ``src/main/java/com/example/BookmarkRepository.java``

.. code-block:: java

    @Repository
    public interface BookmarkRepository extends CrudRepository<Bookmark, Long> {
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
    	BookmarkRepository bookmarkRepository;

    	@Override
    	public void run(String... args) throws Exception {
    		System.out.println("Count: " + bookmarkRepository.count());
    		Bookmark b = bookmarkRepository.save(Bookmark.builder()
    				.title("title")
    				.url("url")
    				.createdAt(Instant.now())
    				.updatedAt(Instant.now())
    				.build());
    		System.out.println(b);
    		System.out.println("Count: " + bookmarkRepository.count());
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.

Let's Simulate DB Schema Changes
--------------------------------

Flyway Script #2
----------------

Let's create another script ``src/main/resources/db/migration/V2__add_status_category_to_bookmarks.sql``:

.. code-block:: sql

    CREATE SEQUENCE IF NOT EXISTS category_id_seq START WITH 1 INCREMENT BY 50;

    CREATE TABLE categories
    (
       id   BIGINT NOT NULL,
       name VARCHAR(255),
       CONSTRAINT pk_categories PRIMARY KEY (id)
    );

    ALTER TABLE bookmarks
       ADD COLUMN status VARCHAR(255) DEFAULT 'DRAFT';
    ALTER TABLE bookmarks
       ALTER COLUMN status SET NOT NULL;

    ALTER TABLE bookmarks
       ADD COLUMN category_id BIGINT;
    ALTER TABLE bookmarks
       ADD CONSTRAINT FK_ARTICLES_ON_CATEGORY FOREIGN KEY (category_id) REFERENCES categories (id);

Model
-----

Let's modify ``Bookmark.java``:

.. code-block:: java

    public class Bookmark {

        // ...

        @Column(name = "updated_at")
        private Instant updatedAt;

        //  START V2 Changes

        @NotNull
        @ColumnDefault("'DRAFT'")
        @Column(name = "status", nullable = false)
        private String status;

        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "category_id")
        private Category category;
    }

Let's create another POJO ``Category.java``:

.. code-block:: java

    @Entity
    @Data
    @SuperBuilder
    @NoArgsConstructor
    @Table(name = "categories")
    public class Category {

        @Id
        @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "category_id_generator")
        @SequenceGenerator(name = "category_id_generator", sequenceName = "category_id_seq")
        private Long id;

        private String name;
    }

Main
----

Let's modify ``MainApplication.java`` and add ``status("DEFAULT")``:

.. code-block:: java

    System.out.println("Count: " + bookmarkRepository.count());
    Bookmark b = bookmarkRepository.save(Bookmark.builder()
            .title("title")
            .url("url")
            .createdAt(Instant.now())
            .updatedAt(Instant.now())
            .status("DEFAULT")
            .build());
    System.out.println(b);
    System.out.println("Count: " + bookmarkRepository.count());

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.
