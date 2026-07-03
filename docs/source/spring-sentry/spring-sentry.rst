Spring Sentry #WIP#
===================

TODO
----

- not working for some reason

  - using `sentry-spring-boot-starter-jakarta` because of SpringBoot 3.0+
  - tried running with and without the `sentry-opentelemetry-agent-8.16.0.jar`

- https://docs.sentry.io/platforms/java/guides/spring-boot/

https://github.com/spring-boot-tutorials/spring-sentry

In this article we will configure Spring Sentry.

Based on: https://docs.sentry.io/platforms/java/guides/spring-boot/

Install & Run Sentry
--------------------

Execute in terminal

.. code-block:: sh

    cd sentry
    docker compose up -d
    docker compose exec sentry sentry upgrade # to setup database and create admin user
    docker compose restart sentry

Sentry is now running on public port http://localhost:9000.

Get DSN for this App
--------------------

Example DSN property value:

- ``sentry.dsn=http://ea8e63b0d20e459da55a48cb2f7b4c6b@localhost:9000/2``
- value template https://{public_key}@{host}:{port}/{project_id}
- To obtain DSN for this project goto the Sentry UI
  - create new project
  - navigate to ``settings``
  - click ``Client Keys (DSN)``
- save value into ``application.properties``

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - sentry
  - spring-boot-starter-web
  - lombok
- Click `Generate`

Dependency Management
---------------------

In ``pom.xml``

.. code-block:: xml

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>io.sentry</groupId>
                <artifactId>sentry-bom</artifactId>
                <version>${sentry.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

Properties
----------

Add the following into ````:

.. code-block:: properties

    sentry.dsn=http://ea8e63b0d20e459da55a48cb2f7b4c6b@localhost:9000/2
    # value template https://{public_key}@{host}:{port}/{project_id}
    # To obtain DSN for this project goto the Sentry UI
    # - create new project
    # - navigate to `settings`
    # - click `Client Keys (DSN)`

    # Add data like request headers and IP for users,
    # see https://docs.sentry.io/platforms/java/guides/spring-boot/data-management/data-collected/ for more info
    sentry.send-default-pii=true

    # By default, only unhandled exceptions are sent to Sentry.
    # This behavior can be tuned through configuring the
    # sentry.exception-resolver-order property. For example,
    # setting it to -2147483647 (the value of
    # org.springframework.core.Ordered#HIGHEST_PRECEDENCE)
    # ensures exceptions that have been handled by exception
    # resolvers with higher order are sent to Sentry -
    # including ones handled by @ExceptionHandler annotated methods
    sentry.exception-resolver-order=-2147483647

Controller
----------

Let's create a new file ``src/main/java/com/example/spring_sentry/DefaultController.java``

.. code-block:: java

    @RestController
    public class DefaultController {

        @GetMapping({"/"})
        public String home() throws Exception {
            try {
                throw new UnsupportedOperationException("You shouldn't call this!");
            } catch (Exception e) {
                Sentry.captureException(e);
                throw e;
            }
        }
    }

Create another controller ``src/main/java/com/example/spring_rest_docs/IndexController.java``:

.. code-block:: java

    @RestController
    @RequestMapping("/")
    public class IndexController {

        static class CustomRepresentationModel extends RepresentationModel<CustomRepresentationModel> {
            public CustomRepresentationModel(Link initialLink) {
                super(initialLink);
            }
        }

        @GetMapping
        public CustomRepresentationModel index() {
            return new CustomRepresentationModel(linkTo(CrudController.class).withRel("crud"));
        }
    }

Run & Verify Application
------------------------

Build JAR

.. code-block:: sh

    mvn clean package

CURL sentry.jar thingymajig

.. code-block:: sh

    curl https://repo1.maven.org/maven2/io/sentry/sentry-opentelemetry-agent/8.16.0/sentry-opentelemetry-agent-8.16.0.jar -o sentry-opentelemetry-agent-8.16.0.jar

RUN application

.. code-block:: sh

    SENTRY_AUTO_INIT=false
    JAVA_TOOL_OPTIONS="-javaagent:sentry-opentelemetry-agent-8.16.0.jar"
    java -jar target/spring-sentry-0.0.1-SNAPSHOT.jar
