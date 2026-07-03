Spring GraphQL DGS Netflix
==========================

https://github.com/spring-boot-tutorials/spring-graphql-dgs-netflix

In this article we will configure Spring Boot to serve GraphQL endpoints.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - graphql-dgs-spring-graphql-starter
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
        <groupId>com.netflix.graphql.dgs</groupId>
        <artifactId>graphql-dgs-spring-graphql-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

GraphQL Schema Files
--------------------

Create new file ``src/main/resources/schema/schema.graphqls``:

.. code-block:: graphql

    type Query {
        albums(titleFilter: String): [Album]
    }

    type Album {
        title: String
        artist: String
        recordNo: Int
    }

Model
-----

Let's create a new POJO ``src/main/java/com/example/spring_graphql_dgs_netflix/Album.java``

.. code-block:: java

    @Data
    public class Album {

        private final String title;
        private final String artist;
        private final Integer recordNo;

        public Album(String title, String artist, Integer recordNo) {
            this.title = title;
            this.recordNo = recordNo;
            this.artist = artist;
        }
    }

Component
---------

Create a stub repository with fake data ``src/main/java/com/example/spring_graphql_dgs_netflix/AlbumDgsComponent.java``:

.. code-block:: java

    @DgsComponent
    public class AlbumDgsComponent {

        // do not name `albumList` as `album` as that would overload the method `album()` for DGS
        private final List<Album> albumList = Arrays.asList(
                new Album("Rumours", "Fleetwood Mac", 20),
                new Album("What's Going On", "Marvin Gaye", 10),
                new Album("Pet Sounds", "The Beach Boys", 12)
        );

        @DgsQuery
        public List<Album> albums(@InputArgument String titleFilter) {
            if (titleFilter == null) {
                return albumList;
            }
            return albumList.stream()
                    .filter(s -> s.getTitle().contains(titleFilter))
                    .collect(Collectors.toList());
        }
    }

Run & Verify Application
------------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Goto: http://localhost:8080/graphiql

Execute the following GraphQL query:

.. code-block:: graphql

    query {
        albums(titleFilter: "o") {
            title
            artist
            recordNo
        }
    }
