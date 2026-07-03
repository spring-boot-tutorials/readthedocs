Spring Integration
==================

https://github.com/spring-boot-tutorials/spring-hateoas

In this article we will configure Spring Integration.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-integration
  - spring-boot-starter-web
  - spring-integration-file
  - spring-integration-http
  - lombok
- Click `Generate`

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-integration</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.integration</groupId>
        <artifactId>spring-integration-file</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.integration</groupId>
        <artifactId>spring-integration-http</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

Configuration
-------------

Let's create a new file ``src/main/java/com/example/spring_integration/config/DefaultConfiguration.java``

.. code-block:: java

    @Configuration
    @EnableIntegration
    public class DefaultConfiguration {

        public String INPUT_DIR = "the_source_dir";
        public String OUTPUT_DIR = "the_dest_dir";
        public String FILE_PATTERN = "*.mpeg";

        @Bean
        public MessageChannel fileChannel() {
            return new DirectChannel();
        }

        @Bean
        @InboundChannelAdapter(value = "fileChannel", poller = @Poller(fixedDelay = "1000"))
        public MessageSource<File> fileReadingMessageSource() {
            FileReadingMessageSource sourceReader= new FileReadingMessageSource();
            sourceReader.setDirectory(new File(INPUT_DIR));
    //        sourceReader.setFilter(new SimplePatternFileListFilter(FILE_PATTERN));
            return sourceReader;
        }

        @Bean
        @ServiceActivator(inputChannel= "fileChannel")
        public MessageHandler fileWritingMessageHandler() {
            FileWritingMessageHandler handler = new FileWritingMessageHandler(new File(OUTPUT_DIR));
            handler.setFileExistsMode(FileExistsMode.REPLACE);
            handler.setExpectReply(false);
            return handler;
        }
    }

Main
----

Modify ``MainApplication.java``:

.. code-block:: java

    @SpringBootApplication
    public class SpringIntegrationApplication {

    	public static void main(String[] args) {
    		AbstractApplicationContext context = new AnnotationConfigApplicationContext(SpringIntegrationApplication.class);
    		context.registerShutdownHook();

    		Scanner scanner = new Scanner(System.in);
    		System.out.print("Please enter q and press <enter> to exit the program: ");

    		while (true) {
    			String input = scanner.nextLine();
    			if("q".equals(input.trim())) {
    				break;
    			}
    		}
    		System.exit(0);
    	}
    }

Run & Verify Application
------------------------

- write some files in PROJECT_ROOT/the_source_dir/
- run application then quit
- see the files copied over PROJECT_ROOT/to the_dest_dir/

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run
