Neo4j #WIP#
===========

https://github.com/spring-boot-tutorials/spring-data-neo4j

In this article we will configure Spring Boot to connect to a `Neo4j <https://neo4j.com//>`_ database.

Neo4j Server
------------

Install and run Neo4j server

.. code-block:: sh

    docker run \
      --publish=7474:7474 \
      --publish=7687:7687 \
       --volume=$HOME/neo4j/data:/data \
        arm64v8/neo4j:2025-community-bullseye

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Click ``Add Dependencies``, search for ``neo4j``, then add
- Click ``Add Dependencies``, search for ``Lombok``, then add
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-neo4j</artifactId>
    </dependency>
    <dependency>
        <groupId>org.instancio</groupId>
        <artifactId>instancio-junit</artifactId>
        <version>5.4.0</version>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

TODO
----