HyperSQL Embedded (Autoconfigure JdbcTemplate)
==========================================================

https://github.com/spring-boot-tutorials/spring-data-hypersql-embedded-autoconfigure-none

In this article we will configure Spring Boot to connect to an `HyperSQL <https://hsqldb.org//>`_ database
via JDBC.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:
  - hypersql
  - Lombok
  - spring-boot-starter
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-jdbc</artifactId>
    </dependency>
    <dependency>
        <groupId>org.hsqldb</groupId>
        <artifactId>hsqldb</artifactId>
        <scope>runtime</scope>
    </dependency>

schema.sql
----------

Let's create a file ``src/main/resources/-my-schema.sql``

.. code-block:: sql

    DROP TABLE PERSON IF EXISTS;

    CREATE TABLE PERSON  (
        person_id BIGINT IDENTITY NOT NULL PRIMARY KEY,
        first_name VARCHAR(20),
        last_name VARCHAR(20)
    );

Configuration
-------------

Let's create a configuration ``src/main/java/com/example/DefaultConfig.java``

.. code-block:: java

    @Configuration
    public class DefaultConfig {

        @Bean
        public DataSource dataSource() {
            return new EmbeddedDatabaseBuilder()
                    .setType(EmbeddedDatabaseType.HSQL)
                    .addScript("classpath:my-schema.sql")
                    .build();
        }

        @Bean
        public JdbcTemplate jdbcTemplate(DataSource dataSource) {
            return new JdbcTemplate(dataSource);
        }
    }

Main
----

Go back to ``MainApplication.java`` and add the following:

.. code-block:: java

    @SpringBootApplication
    public class SpringHypersqlDatabaseApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(SpringHypersqlDatabaseApplication.class, args);
    	}

    	@Autowired
    	JdbcTemplate jdbcTemplate;

    	@Override
    	public void run(String... args) throws Exception {
    		jdbcTemplate.execute("INSERT INTO PERSON(person_id, first_name, last_name) VALUES (1, 'marcus', 'chiu')");
    		int result = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM PERSON", Integer.class);
    		System.out.println("1. " + result);
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.
