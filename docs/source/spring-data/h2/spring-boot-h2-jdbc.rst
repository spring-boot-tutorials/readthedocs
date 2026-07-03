h2 JDBC
=======

https://github.com/spring-boot-tutorials/spring-data-h2-jdbc

In this article we will configure Spring Boot to connect to an `h2 <https://www.h2database.com/html/main.html/>`_ database
via JDBC.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:
  - h2
  - Lombok
  - JDBC
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-jdbc</artifactId>
    </dependency>
    <dependency>
        <groupId>com.mysql</groupId>
        <artifactId>mysql-connector-j</artifactId>
        <version>9.1.0</version>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.38</version>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>runtime</scope>
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

Model
------

Let's create a new POJO ``src/main/java/com/example/Person.java``

.. code-block:: java

    @Data
    @SuperBuilder
    public class Person {
        private Long id;
        private String firstName;
        private String lastName;
    }

RowMapper
---------

Next we will create a RowMapper to convert ResultSet into our POJO Person.

This file will be called ``src/main/java/com/example/PersonRowMapper.java``

.. code-block:: java

    public class PersonRowMapper implements RowMapper<Person> {
        @Override
        public Person mapRow(ResultSet rs, int rowNum) throws SQLException {
            return Person.builder()
                    .id(rs.getLong("ID"))
                    .firstName(rs.getString("FIRST_NAME"))
                    .lastName(rs.getString("LAST_NAME"))
                    .build();
        }
    }

Sql Exception Handler
---------------------

Create a custom SQLErrorCodeSQLExceptionTranslator to handle any SQL execution errors:

.. code-block:: java

    public class CustomSQLErrorCodeTranslator extends SQLErrorCodeSQLExceptionTranslator {
        @Override
        protected DataAccessException customTranslate(String task, String sql, SQLException sqlException) {
            if (sqlException.getErrorCode() == 23505) {
                return new DuplicateKeyException("Custom Exception translator - Integrity constraint violation.", sqlException);
            }
            return null;
        }
    }

Main
----

Now let's use this repository.

Go back to ``MainApplication.java`` and add the following:

.. code-block:: java

    @Configuration
    @SpringBootApplication
    public class MainApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(MainApplication.class, args);
    	}

    	@Autowired
    	private JdbcTemplate jdbcTemplate;

    	@Autowired
    	private NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    	@Autowired
    	private DataSource dataSource;

    	@Override
    	public void run(String... args) {
    		// Custom Exception Handling
    		jdbcTemplate.setExceptionTranslator(new CustomSQLErrorCodeTranslator());

    		// 1. Simple Inserts
    		jdbcTemplate.execute("INSERT INTO PERSON(first_name, last_name) VALUES('Victor', 'Hugo')");
    		jdbcTemplate.update("INSERT INTO PERSON(first_name, last_name) VALUES (?, ?)", "Bill", "Gates");

    		// 2. Simple Query
    		int result = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM PERSON", Integer.class);
    		System.out.println("2. Number of Persons, " + result);

    		// 3. Named Parameter Query
    		SqlParameterSource namedParameters = new MapSqlParameterSource().addValue("id", 1);
    		String firstName = namedParameterJdbcTemplate.queryForObject("SELECT FIRST_NAME FROM PERSON WHERE ID = :id", namedParameters, String.class);
    		System.out.println("3. Person with ID=1 has name=" + firstName);

    		// 4. RowMapper
    		String query = "SELECT * FROM PERSON WHERE ID = ?";
    		Person person = jdbcTemplate.queryForObject(query, new PersonRowMapper(), 1);
    		System.out.println("4. " + person.toString());

    		// 5. SimpleJDBC
    		SimpleJdbcInsert simpleJdbcInsert = new SimpleJdbcInsert(dataSource).withTableName("PERSON");
    		Map<String, Object> parameters = new HashMap<>();
    		parameters.put("ID", 1000);
    		parameters.put("FIRST_NAME", "Jesus");
    		parameters.put("LAST_NAME", "Christ");
    		int i = simpleJdbcInsert.execute(parameters);
    		System.out.println("5. SimpleJDBC returned i=" + i);

    		// 6. SimpleJDBC with Generated Key Columns
    		simpleJdbcInsert = new SimpleJdbcInsert(dataSource).withTableName("PERSON")
    				.usingGeneratedKeyColumns("ID");
    		parameters = new HashMap<>();
    		parameters.put("FIRST_NAME", "Jesus");
    		parameters.put("LAST_NAME", "Christ");
    		Number id = simpleJdbcInsert.executeAndReturnKey(parameters);
    		System.out.println("6. SimpleJDBC with Generated Key Columns return id=" + id.longValue());

    		// 7. Stored Procedure Calls
    //		SimpleJdbcCall simpleJdbcCall = new SimpleJdbcCall(dataSource).withProcedureName("READ_EMPLOYEE");
    //		SqlParameterSource in = new MapSqlParameterSource().addValue("in_id", id);
    //		Map<String, Object> out = simpleJdbcCall.execute(in);
    //		System.out.println("7. " + out);

    		// 8. Batch JdbcTemplate
    		List<Person> people = List.of(
    				Person.builder().id(100L).firstName("Person100").lastName("Person100").build(),
    				Person.builder().id(101L).firstName("Person101").lastName("Person101").build(),
    				Person.builder().id(102L).firstName("Person102").lastName("Person102").build(),
    				Person.builder().id(103L).firstName("Person103").lastName("Person103").build()
    		);
    		int[] batched = jdbcTemplate.batchUpdate("INSERT INTO PERSON VALUES (?, ?, ?)",
    				new BatchPreparedStatementSetter() {
    					@Override
    					public void setValues(PreparedStatement ps, int i) throws SQLException {
    						ps.setLong(1, people.get(i).getId());
    						ps.setString(2, people.get(i).getFirstName());
    						ps.setString(3, people.get(i).getLastName());
    					}
    					@Override
    					public int getBatchSize() {
    						return 4;
    					}
    				});
    		System.out.println("8. " + Arrays.toString(batched));

    		// 9. Batch NamedParameterJdbcTemplate
    		SqlParameterSource[] batch = SqlParameterSourceUtils.createBatch(List.of(
    				Person.builder().id(104L).firstName("Person104").lastName("Person104").build(),
    				Person.builder().id(105L).firstName("Person105").lastName("Person105").build(),
    				Person.builder().id(106L).firstName("Person106").lastName("Person106").build(),
    				Person.builder().id(107L).firstName("Person107").lastName("Person107").build()
    		).toArray());
    		int[] updateCounts = namedParameterJdbcTemplate.batchUpdate("INSERT INTO PERSON VALUES (:id, :firstName, :lastName)", batch);
    		System.out.println("9. " + Arrays.toString(updateCounts));
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.
