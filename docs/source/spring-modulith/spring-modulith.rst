Spring Modulith
===============

https://github.com/spring-boot-tutorials/spring-modulith

In this article we will configure Spring Modulith.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-modulith-starter-core
  - spring-boot-starter-web
  - lombok
- Click `Generate`

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.modulith</groupId>
        <artifactId>spring-modulith-starter-core</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

Modulith #1 - POJO
------------------

Let's create a new POJO ``src/main/java/com/example/spring_modulith/module_notification/NotificationDTO.java``

.. code-block:: java

    @Data
    @SuperBuilder
    @AllArgsConstructor
    @NoArgsConstructor
    public class NotificationDTO {
        private String productName;
        private String format;
        private Date date;
    }

Modulith #1 - Service
---------------------

Create a new file ``src/main/java/com/example/spring_modulith/module_notification/NotificationService.java``:

.. code-block:: java

    @Service
    public class NotificationService {

        private static final Logger LOG = LoggerFactory.getLogger(NotificationService.class);

        public void createNotification(NotificationDTO notification) {
            LOG.info("Received notification by module DEPENDENCY for product {} in date {} by {}.",
                    notification.getProductName(),
                    notification.getDate(),
                    notification.getFormat());
        }

        // TODO doesn't work
        @ApplicationModuleListener
        public void notificationEvent(NotificationDTO event) {
            LOG.info("Received notification by EVENT for product {} in date {} by {}.",
                    event.getProductName(),
                    event.getDate(),
                    event.getFormat());
        }
    }

Modulith #1 - Internal - POJO
-----------------------------

Create a new POJO class ``src/main/java/com/example/spring_modulith/module_notification/internal/Notification.java``:

.. code-block:: java

    @Data
    @SuperBuilder
    @AllArgsConstructor
    @NoArgsConstructor
    public class Notification {
        private String productName;
        private NotificationType format;
        private Date date;
    }

And another POJO class ``src/main/java/com/example/spring_modulith/module_notification/internal/NotificationType.java``:

.. code-block:: java

    public enum NotificationType {
        SMS
    }

Modulith #2 - Service
---------------------

Create new file ``src/main/java/com/example/spring_modulith/module_product/ProductService.java``:

.. code-block:: java

    @Service
    @RequiredArgsConstructor
    public class ProductService {

        private final ApplicationEventPublisher events;
        private final NotificationService notificationService;

        public void create(Product product) {
            notificationService.createNotification(new NotificationDTO(product.getName(), "SMS", new Date()));
            events.publishEvent(new NotificationDTO(product.getName(), "SMS", new Date()));
        }
    }

Modulith #2 - Internal - POJO
-----------------------------

Create new POJO class ``src/main/java/com/example/spring_modulith/module_product/internal/Product.java``:

.. code-block:: java

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    @SuperBuilder
    public class Product {
        private String name;
        private String description;
        private int price;
    }

Main
----

Modify ``MainApplication.java``:

.. code-block:: java

    @EnableAsync
    @SpringBootApplication
    public class SpringModulithApplication {

    	public static void main(String[] args) {
    		SpringApplication.run(SpringModulithApplication.class, args)
    				.getBean(ProductService.class)
    				.create(new Product("marcus", "description", 100));
    	}
    }

Create Tests
------------

Create new file ``src/test/java/com/example/spring_modulith/SpringModulithApplicationTests.java``:

.. code-block:: java

    @SpringBootTest
    class SpringModulithApplicationTests {

    	@Test
    	void createApplicationModuleModel() {
    		ApplicationModules modules = ApplicationModules.of(SpringModulithApplication.class);
    		modules.forEach(System.out::println);
    	}

    	@Test
    	void verifiesModularStructure() {
    		ApplicationModules modules = ApplicationModules.of(SpringModulithApplication.class);
    		modules.verify();
    	}

    	@Test
    	void createModuleDocumentation() {
    		ApplicationModules modules = ApplicationModules.of(SpringModulithApplication.class);
    		new Documenter(modules)
    				.writeDocumentation()
    				.writeIndividualModulesAsPlantUml();
    	}
    }

Run & Verify Tests
------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn clean package
