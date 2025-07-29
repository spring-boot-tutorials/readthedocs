HyperSQL External (Autoconfigure Datasource)
============================================

https://github.com/spring-boot-tutorials/spring-data-hypersql

In this article we will configure Spring Boot to connect to an `HyperSQL <https://hsqldb.org//>`_ database.

Install & Run HyperSQL
----------------------

.. code-block:: sh

    docker run \
      --name hsqldb-with-password \
      -e "HSQLDB_DATABASE_ALIAS=testdb" \
      -e "HSQLDB_DATABASE_NAME=testdb" \
      -e "HSQLDB_USER=my_user" \
      -e "HSQLDB_PASSWORD=my_password" \
      -p 9001:9001 \
      mitchtalmadge/hsqldb

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

Properties
----------

Add the following properties into ``src/main/resources/application.yaml``

.. code-block:: yaml

    spring:
      datasource:
        url: jdbc:hsqldb:hsql://localhost/testdb
        username: my_user
        password: my_password
        driver-class-name: org.hsqldb.jdbc.JDBCDriver
    #    below was removed since Spring Boot 2.7
    #    initialization-mode: always
      sql:
        init:
          mode: always

schema.sql
----------

Let's create a file ``src/main/resources/-my-schema.sql``

.. code-block:: sql

    -- If datasource points to a non-embedded database, then Spring Boot doesn't run this.
    -- To re-enabled this, set property spring.sql.init.mode=always
    --
    -- The actual class that read schema.sql and execute it used to be DataSourceInitializer#createSchema().
    -- As of Spring Boot 3.3, it is in SettingsCreator.
    --
    -- Here are the high level flow which somehow triggers it:
    -- * If DataSource class is found from the class-path, spring-boot auto-configuration will enable DataSourceAutoConfiguration
    -- * DataSourceAutoConfiguration imports DataSourceInitializationConfiguration
    -- * DataSourceInitializationConfiguration registers DataSourceInitializerPostProcessor which will be executed and force initialising DataSourceInitializerInvoker.
    -- * DataSourceInitializerInvoker's afterPropertiesSet will then execute DataSourceInitializer#createSchema() to read and execute schema.sql

    DROP TABLE PERSON IF EXISTS;

    CREATE TABLE PERSON (
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

        /**
         *
         * @param dataSource was autoconfigured by
         *                   `org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration`
         * @return
         */
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
    //		jdbcTemplate.execute("INSERT INTO PERSON(person_id, first_name, last_name) VALUES (1, 'marcus', 'chiu')");
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
