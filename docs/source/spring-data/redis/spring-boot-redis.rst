Redis
=====

https://github.com/spring-boot-tutorials/spring-data-redis

In this article we will configure Spring Boot to connect to a `Redis <https://redis.io//>`_ database.

Redis Server
------------

Install and run Redis server

.. code-block:: sh

    brew install redis
    brew services start redis

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Click ``Add Dependencies``, search for ``redis``, then add
- Click ``Add Dependencies``, search for ``Lombok``, then add
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-redis</artifactId>
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

    spring.data.redis.host=localhost
    spring.data.redis.port=6379

    # Optional: Redis database index
    #spring.data.redis.database=0
    # Optional: if Redis requires authentication
    #spring.data.redis.password=your_password
    # Optional: connection timeout in milliseconds
    #spring.data.redis.timeout=60000

Model
------

Let's create a new POJO ``src/main/java/com/example/Student.java``

.. code-block:: java

    @Data
    @SuperBuilder
    @NoArgsConstructor
    @RedisHash("Student")
    public class Student implements Serializable {

        public enum Gender {
            MALE, FEMALE
        }

        private String id;
        private String name;
        private Gender gender;
        private int grade;
    }

Repository
----------

Next we will create a Spring repository to CRUD against the database.

This file will be called ``src/main/java/com/example/StudentRepository.java``

.. code-block:: java

    @Repository
    public interface StudentRepository extends CrudRepository<Student, String> {

    }

Main
----

Now let's use this repository.

Go back to ``MainApplication.java`` and add the following:

.. code-block:: java

    @SpringBootApplication
    public class RedisExampleApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(RedisExampleApplication.class, args);
    	}

    	@Autowired
    	StudentRepository studentRepository;

    	@Override
    	public void run(String... args) throws Exception {
    		studentRepository.deleteAll();

    		// 1. save
    		Student student = Student.builder()
    				.name("John Doe")
    				.gender(Student.Gender.MALE)
    				.grade(50)
    				.build();
    		student = studentRepository.save(student);
    		System.out.println(student);

    		// 2. findAll
    		Iterable<Student> students = studentRepository.findAll();
    		students.forEach(System.out::println);

    		student = studentRepository.findById(student.getId()).get();
    		System.out.println(student);

    		// 3. Updating
    		student.setName("Richard Watson");
    		student = studentRepository.save(student);
    		System.out.println(student);

    		// 4. Deleting
    		studentRepository.deleteById(student.getId());
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and the output will display all the CRUD operations.