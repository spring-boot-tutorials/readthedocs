Cloud Streams (RabbitMQ)
========================

https://github.com/spring-boot-tutorials/cloud-streams-rabbitmq

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

Install & Run RabbitMQ
----------------------

.. code-block:: sh

    docker run \
      --name some-rabbit \
      -e RABBITMQ_DEFAULT_USER=myuser \
      -e RABBITMQ_DEFAULT_PASS=mypassword \
      -p 5672:5672 \
      -p 15672:15672 \
      rabbitmq:3-management

Properties
----------

Add the following properties into ``src/main/resources/application.yaml``:

.. code-block:: yaml

    spring:
      cloud:
        stream:
          bindings:
            input:
              destination: my.input.queue.log.messages
              binder: local_rabbit
            output:
              destination: my.output.queue.log.messages
              binder: local_rabbit
          binders:
            local_rabbit:
              type: rabbit
              environment:
                spring:
                  rabbitmq:
                    host: localhost
                    port: 5672
                    username: myuser
                    password: mypassword
                    virtual-host: /

Configuration
-------------

Create new file ``src/main/java/com/example/spring_cloud_streams/DefaultConfiguration.java``:

.. code-block:: java

    @Configuration
    public class DefaultConfiguration {

        @Bean
        Function<LogMessage, String> highlightLogs() {
            return logMsg -> logMsg.message().toUpperCase();
        }
    }

Model
-----

Create new file ``src/main/java/com/example/spring_cloud_streams/component/LogMessage.java``:

.. code-block:: java

    public record LogMessage(String message) {
    }

Component
---------

Create a new file ``src/main/java/com/example/spring_cloud_streams/component/PlainTextMessageConverter.java``:

.. code-block:: java

    @Component
    class PlainTextMessageConverter extends AbstractMessageConverter {

        public PlainTextMessageConverter() {
            super(new MimeType("text", "plain"));
        }

        @Override
        protected boolean supports(Class<?> clazz) {
            return (LogMessage.class == clazz);
        }

        @Override
        protected Object convertFromInternal(Message<?> message, Class<?> targetClass, Object conversionHint) {
            Object payload = message.getPayload();
            String text = payload instanceof String ? (String) payload : new String((byte[]) payload);
            return new LogMessage(text);
        }
    }

Run Application
---------------

.. code-block:: sh

    mvn spring-boot:run

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
        void whenHighlightingLogMessage_thenItsTransformedToUppercase() {
            Message<String> messageIn = MessageBuilder.withPayload("hello")
                    .setHeader("contentType", "text/plain")
                    .build();
            input.send(messageIn, "highlightLogs-in-0");

            Message<byte[]> messageOut = output.receive(1000L, "highlightLogs-out-0");
            assertThat(messageOut.getPayload())
                    .asString()
                    .isEqualTo("HELLO");
        }
    }

Run Tests
---------

.. code-block:: sh

    mvn clean package
