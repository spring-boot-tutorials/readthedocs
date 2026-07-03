Cloud Streams
=============

https://github.com/spring-boot-tutorials/cloud-streams

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
  - spring-cloud-starter-stream-rabbit
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
        <artifactId>spring-cloud-starter-stream-rabbit</artifactId>
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
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-stream-test-binder</artifactId>
        <scope>test</scope>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.yaml``:

.. code-block:: yaml

    spring:
      cloud:
        function:
          definition: enrichLogMessage;processLogs
        stream:
          function.routing.enabled: true
          bindings:
            enrichLogMessage-in-0:
              destination: my.input.queue.log.messages
            enrichLogMessage-out-0:
              destination: my.output.queue.log.messages

Configuration
-------------

Create new file ``src/main/java/com/example/spring_cloud_streams/DefaultConfiguration.java``:

.. code-block:: java

    @Configuration
    public class DefaultConfiguration {

        @Bean
        public Function<String, String> enrichLogMessage() {
            return value -> "[%s] - %s".formatted("Marcus", value);
        }

        @Bean
        public Function<String, Message<String>> processLogs() {
            return log -> {
                boolean shouldBeEnriched = log.length() > 10;
                String destination = shouldBeEnriched ? "enrichLogMessage-in-0" : "my.output.queue.log.messages";
                return MessageBuilder.withPayload(log)
                        .setHeader("spring.cloud.stream.sendto.destination", destination)
                        .build();
            };
        }
    }

Create Tests
------------

Create a new file ````:

.. code-block:: java

    @EnableTestBinder
    @SpringBootTest
    class SpringCloudStreamsApplicationTests {

    	@Autowired
    	private InputDestination input;

    	@Autowired
    	private OutputDestination output;

    	@Test
    	void whenSendingLogMessage_thenMessageIsEnrichedWithPrefix() {
    		Message<String> messageIn = MessageBuilder.withPayload("hello world").build();
    		input.send(messageIn, "my.input.queue.log.messages");

    		Message<byte[]> messageOut = output.receive(1000L, "my.output.queue.log.messages");
    		assertThat(messageOut.getPayload())
    				.asString()
    				.isEqualTo("[Marcus] - hello world");
    	}

    	@Test
    	void whenProcessingLongLogMessage_thenItsEnrichedWithPrefix() {
    		Message<String> messageIn = MessageBuilder.withPayload("hello world").build();
    		input.send(messageIn, "processLogs-in-0");

    		Message<byte[]> messageOut = output.receive(1000L, "my.output.queue.log.messages");
    		assertThat(messageOut.getPayload())
    				.asString()
    				.isEqualTo("[Marcus] - hello world");
    	}

    	@Test
    	void whenProcessingShortLogMessage_thenItsNotEnrichedWithPrefix() {
    		Message<String> messageIn = MessageBuilder.withPayload("hello").build();
    		input.send(messageIn, "processLogs-in-0");

    		Message<byte[]> messageOut = output.receive(1000L, "my.output.queue.log.messages");
    		assertThat(messageOut .getPayload())
    				.asString()
    				.isEqualTo("hello");
    	}
    }

Run Tests
---------

.. code-block:: sh

    mvn clean package
