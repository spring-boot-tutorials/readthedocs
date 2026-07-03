Spring Rest Docs #WIP#
======================

https://github.com/spring-boot-tutorials/spring-rest-docs

In this article we will configure Spring Rest Docs.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - restdocs
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
            <groupId>org.springframework.restdocs</groupId>
            <artifactId>spring-restdocs-mockmvc</artifactId>
            <scope>test</scope>
        </dependency>

Controller
----------

Let's create a new file ``src/main/java/com/example/spring_rest_docs/CrudController.java``

.. code-block:: java

    @RestController
    @RequestMapping("/crud")
    public class CrudController {

        @GetMapping
        public List<CrudInput> read(@RequestBody CrudInput crudInput) {
            List<CrudInput> returnList = new ArrayList<CrudInput>();
            returnList.add(crudInput);
            return returnList;
        }

        @ResponseStatus(HttpStatus.CREATED)
        @PostMapping
        public HttpHeaders save(@RequestBody CrudInput crudInput) {
            HttpHeaders httpHeaders = new HttpHeaders();
            httpHeaders.setLocation(linkTo(CrudController.class).slash(crudInput.getTitle()).toUri());
            return httpHeaders;
        }

        @DeleteMapping("/{id}")
        public void delete(@PathVariable("id") long id) {
            // delete
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

Create Tests
------------

Create a new file ``src/test/java/com/example/spring_rest_docs/ApiDocumentationJUnit5IntegrationTest.java``:

.. code-block:: java

    @ExtendWith({RestDocumentationExtension.class, SpringExtension.class})
    @SpringBootTest
    public class ApiDocumentationJUnit5IntegrationTest {

        private MockMvc mockMvc;

        @BeforeEach
        public void setUp(WebApplicationContext webApplicationContext,
                          RestDocumentationContextProvider restDocumentation) {
            this.mockMvc = MockMvcBuilders.webAppContextSetup(webApplicationContext)
                    .apply(documentationConfiguration(restDocumentation)).build();
        }
    }

Run & Verify Tests
------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn clean package
