Cloud Feign #WIP#
=================

https://github.com/spring-boot-tutorials/cloud-open-feign

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
  - spring-cloud-starter-openfeign
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
        <artifactId>spring-cloud-starter-openfeign</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.36</version>
    </dependency>

Model
-----

Create new file ``src/main/java/com/example/cloud_openfeign/Post.java``:

.. code-block:: java

    @Data
    @NoArgsConstructor
    public class Post {
        private Integer userId;
        private Integer id;
        private String title;
        private String body;
    }

Configuration
-------------

Create a new file ``src/main/java/com/example/cloud_openfeign/MyFeignClientConfiguration.java``:

.. code-block:: java

    @Configuration
    @EnableFeignClients
    public class MyFeignClientConfiguration {
        // TODO see https://www.baeldung.com/spring-cloud-openfeign#configuration
    }

Feign Client
------------

Create a new file ``src/main/java/com/example/cloud_openfeign/MyFeignClient.java``:

.. code-block:: java

    @FeignClient(
            value = "jplaceholder",
            url = "https://jsonplaceholder.typicode.com/",
            configuration = MyFeignClientConfiguration.class
    )
    public interface MyFeignClient {

        @GetMapping("/posts")
        List<Post> getPosts();

        @GetMapping(value = "/posts/{postId}", produces = "application/json")
        Post getPostById(@PathVariable("postId") Long postId);
    }

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Verify
------

Go to: http://localhost:8080/example/
