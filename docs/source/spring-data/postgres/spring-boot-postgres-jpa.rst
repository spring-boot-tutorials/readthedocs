Postgres (JPA) #WIP#
====================

https://github.com/spring-boot-tutorials/spring-data-postgres-jpa

In this article we will configure Spring Boot to connect to a `Postgres <https://www.postgresql.org//>`_ database.

Postgres Server
---------------

Install and run Postgres server

.. code-block:: sh

    docker run --name postgres-server \
      -e POSTGRES_DB=testdb \
      -e POSTGRES_USER=my_user \
      -e POSTGRES_PASSWORD=my_password \
      -p 5432:5432 \
      -d postgres

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Click ``Add Dependencies``, search for ``Postgres``, then add
- Click ``Add Dependencies``, search for ``Lombok``, then add
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <scope>runtime</scope>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

TODO
----