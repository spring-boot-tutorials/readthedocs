Spring GraphQL
==============

https://github.com/spring-boot-tutorials/spring-graphql

In this article we will configure Spring Boot to serve GraphQL endpoints.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-graphql
  - spring-boot-starter-web
  - lombok
- Click `Generate`

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-graphql</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.yaml``:

.. code-block:: yml

    spring:
      graphql:
        graphiql:
          # enables GraphQL UI at http://localhost:8080/graphiql
          enabled: true

GraphQL Schema Files
--------------------

Create new file ``src/main/resources/graphql/start.gqls``:

.. code-block:: graphql

    type Post {
        id: ID!
        title: String!
        text: String!
        category: String
        author: Author!
    }

    type Author {
        id: ID!
        name: String!
        thumbnail: String
        posts: [Post]!
    }

    # The Root Query for the application
    type Query {
        recentPosts(count: Int, offset: Int): [Post]!
    }

    # The Root Mutation for the application
    type Mutation {
        createPost(title: String!, text: String!, category: String, authorId: String!) : Post!
    }

Model
-----

Let's create a new POJO ``src/main/java/com/example/graphql/model/Author.java``

.. code-block:: java

    @Data
    @SuperBuilder
    @NoArgsConstructor
    public class Author {
        private String id;
        private String name;
        private String thumbnail;
        private List<Post>  posts;
    }

Create a new POJO ``src/main/java/com/example/graphql/model/Post.java``:

.. code-block:: java

    @Data
    @SuperBuilder
    @NoArgsConstructor
    public class Post {
        private String id;
        private String title;
        private String category;
        private String authorId;
        private String text;
    }

Repository
----------

Create a stub repository with fake data ``src/main/java/com/example/graphql/repository/PostRepository.java``:

.. code-block:: java

    @Service
    public class PostRepository {

        private List<Post> posts = new ArrayList<>();
        private List<Author> authors = new ArrayList<>();

        public PostRepository() {
            posts.add(Post.builder()
                    .id("id-1")
                    .title("title-1")
                    .authorId("author-1")
                    .text("text-1")
                    .category("category-1")
                    .build());
            posts.add(Post.builder()
                    .id("id-2")
                    .title("title-2")
                    .authorId("author-2")
                    .text("text-2")
                    .category("category-2")
                    .build());
            posts.add(Post.builder()
                    .id("id-3")
                    .title("title-3")
                    .authorId("author-3")
                    .text("text-3")
                    .category("category-3")
                    .build());

            authors.add(Author.builder()
                    .id("author-1")
                    .name("name-1")
                    .thumbnail("thumbnail-1")
                    .posts(List.of(posts.get(0)))
                    .build());
            authors.add(Author.builder()
                    .id("author-2")
                    .name("name-2")
                    .thumbnail("thumbnail-2")
                    .posts(List.of(posts.get(1)))
                    .build());
            authors.add(Author.builder()
                    .id("author-3")
                    .name("name-3")
                    .thumbnail("thumbnail-3")
                    .posts(List.of(posts.get(2)))
                    .build());
        }

        public List<Post> getRecentPosts() {
            return this.posts;
        }

        public void savePost(Post post) {
            this.posts.add(post);
        }

        public Author getAuthor(String authorID) {
            return authors.stream()
                    .filter(a -> a.getId().equals(authorID)).findFirst()
                    .orElse(null);
        }
    }

Controller
----------

Create a new class ``src/main/java/com/example/graphql/controller/PostController.java``:

.. code-block:: java

    @Controller
    public class PostController {

        @Autowired
        private PostRepository postDao;

        @QueryMapping
        public List<Post> recentPosts(@Argument int count, @Argument int offset) {
            return postDao.getRecentPosts();
        }

        @SchemaMapping
        public Author author(Post post) {
            return postDao.getAuthor(post.getAuthorId());
        }

        @MutationMapping
        public Post createPost(@Argument String title,
                               @Argument String text,
                               @Argument String category,
                               @Argument String authorId) {
            Post post = new Post();
            post.setId(UUID.randomUUID().toString());
            post.setTitle(title);
            post.setText(text);
            post.setCategory(category);
            post.setAuthorId(authorId);

            postDao.savePost(post);

            return post;
        }
    }

Run & Verify Application
------------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Goto: http://localhost:8080/graphiql

Input GraphQL Query:

.. code-block:: graphql

    query {
        recentPosts(count: 10, offset: 0) {
            id
            title
            category
            author {
                id
                name
                thumbnail
            }
        }
    }
