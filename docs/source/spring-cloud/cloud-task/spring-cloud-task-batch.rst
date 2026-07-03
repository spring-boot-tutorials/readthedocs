Cloud Task Batch #WIP#
======================

https://github.com/spring-boot-tutorials/cloud-task-batch

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
  - spring-cloud-starter-task
  - spring-boot-starter-data-jpa
  - h2
  - lombok
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``:

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-task</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>com.h2database</groupId>
        <artifactId>h2</artifactId>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-batch</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-task-batch</artifactId>
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

Properties
----------

Add the following properties into ``src/main/resources/application.properties``:

.. code-block:: properties

    spring.datasource.url=jdbc:h2:mem:testdb
    spring.datasource.driverClassName=org.h2.Driver
    spring.datasource.username=sa
    spring.datasource.password=

    # enables H2 console http://localhost:8080/h2-console
    spring.h2.console.enabled=true

Configuration
-------------

Create new file ``src/main/java/com/example/spring_cloud_task/configuration/DefaultConfiguration.java``:

.. code-block:: java

    @EnableTask
    @Configuration
    public class DefaultConfiguration {

        @Bean
        public HelloWorldTaskConfigurer getTaskConfigurer(DataSource dataSource) {
            return new HelloWorldTaskConfigurer(dataSource);
        }

        public class HelloWorldTaskConfigurer extends DefaultTaskConfigurer {
            public HelloWorldTaskConfigurer(DataSource dataSource){
                super(dataSource);
            }
        }
    }

Create another file ``src/main/java/com/example/spring_cloud_task/configuration/JobConfiguration.java``:

.. code-block:: java

    @Configuration
    @EnableBatchProcessing
    public class JobConfiguration {

        @Bean
        public Job job2() {
            return jobBuilderFactory.get("job2")
                    .start(stepBuilderFactory.get("job2step1")
                            .tasklet((Tasklet) (contribution, chunkContext) -> {
                                System.out.println("This is a random job");
                                return RepeatStatus.FINISHED;
                            }).build()).build();
        }
    }

TODO
----
