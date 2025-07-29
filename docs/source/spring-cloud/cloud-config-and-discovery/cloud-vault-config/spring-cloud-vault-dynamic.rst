Cloud Vault (Dynamic Secrets)
=============================

https://github.com/spring-boot-tutorials/cloud-vault-dynamic

Resources:

- https://developer.hashicorp.com/vault/tutorials/app-integration/spring-reload-secrets
- https://www.youtube.com/watch?v=E9XDfOVNN2U&t=3s
- https://spring.io/projects/spring-cloud-vault

Create Docker Network
---------------------

.. code-block:: sh

    docker network create my-app-network

Install & Run MySQL Server
--------------------------

.. code-block:: sh

    docker run \
      --name my-mysql-server \
      --network my-app-network \
      -e MYSQL_ROOT_PASSWORD=my_root_password \
      -e MYSQL_DATABASE=my_app_database \
      -p 3306:3306 \
      mysql:latest

Get IP address of container

.. code-block:: sh

    docker ps
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <CONTAINER_NAME_OR_ID>

Install & Run Vault Server
--------------------------

.. code-block:: sh

    docker run \
      --cap-add=IPC_LOCK \
      --name=my-vault-server \
      --network my-app-network \
      -e 'VAULT_DEV_ROOT_TOKEN_ID=my-root-token' \
      -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
      -p 8200:8200 \
      hashicorp/vault

- ``--cap-add=IPC_LOCK``: This capability is crucial to prevent sensitive information from being swapped to disk, enhancing security.
- ``--name=dev-vault``: Assigns a name to the container for easier management.
- ``hashicorp/vault``: Specifies the official Docker image for HashiCorp Vault.
- ``VAULT_DEV_ROOT_TOKEN_ID``: Sets the ID of the initial root token.
- ``VAULT_DEV_LISTEN_ADDRESS``: Sets the IP and port for the listener (defaults to 0.0.0.0:8200).
- ``-p 8200:8200``: Maps port 8200 from the container to port 8200 on the host, allowing access to the Vault UI or API.

Setup Secrets on Vault Server (UI Way)
--------------------------------------

Login to Vault Server:

- token way:
- token: `my-root-token`

Enable database:

- goto: http://localhost:8200/ui/vault/settings/mount-secret-backend
- click `Enable Engine`

Create database connection:

- goto: http://localhost:8200/ui/vault/secrets/database/create
- fill in form:

  - database_plugin: `mysql-aurora-database-plugin`
  - connection_name: `my-mysql`
  - connection_url: `root:my_root_password@tcp(172.19.0.2:3306)/`

    - replace `172.19.0.2` with IP address of `mysql-server`
  - username: `root`
  - password: `my_root_password`
- click `create` and `disable rotate`

Create role:

- goto: http://localhost:8200/ui/vault/secrets/database/create?itemType=role
- fill in form:

  - role_name: `my-app-role`
  - db_name: `my-mysql`
  - role_type: `dynamic`
  - Generated credentials’s Time-to-Live (TTL): `10s`
  - Generated credentials’s maximum Time-to-Live (Max TTL): `10s`
  - creation_statements:

    - `CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';`
    - `GRANT ALL PRIVILEGES ON my_app_database.* TO '{{name}}'@'%' WITH GRANT OPTION;`
    - `FLUSH PRIVILEGES;`

  - revoke_statements:

    - TODO REMOVE OLD USER

Manually Generate credentials:

- goto: http://localhost:8200/ui/vault/secrets/database/show/role/my-app-role?type=dynamic
- click on `Generate Credentials`

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
  - spring-cloud-starter-vault-config
  - spring-cloud-vault-config-databases
  - spring-boot-starter-data-jpa
  - spring-boot-starter-actuator
  - mysql-connector-j
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
        <artifactId>spring-cloud-starter-vault-config</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-vault-config-databases</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
        <groupId>com.mysql</groupId>
        <artifactId>mysql-connector-j</artifactId>
        <scope>runtime</scope>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.yaml``:

.. code-block:: yaml

    spring:
      application:
        name: my-app
      config:
        import: vault://
      cloud:
        vault:
          uri: http://localhost:8200
          token: my-root-token
          kv:
            enabled: false
          database:
            enabled: true
            role: my-app-role
            backend: database
          # On Vault Server tune lease renewal and expiry threshold for 2min max ttl
          config:
            lifecycle:
              min-renewal: 30s
              expiry-threshold: 10s
      datasource:
        url: 'jdbc:mysql://localhost:3306/my_app_database'
        driverClass: com.mysql.cj.jdbc.Driver

Component
---------

Create a new file ````:

.. code-block:: java

    @Component
    public class VaultRefresherComponent {

        VaultRefresherComponent(@Value("${spring.cloud.vault.database.role}") String databaseRole,
                                @Value("${spring.cloud.vault.database.backend}") String databaseBackend,
                                SecretLeaseContainer secretLeaseContainer,
                                ContextRefresher contextRefresher) {
            var vaultCredsPath = String.format("%s/creds/%s", databaseBackend, databaseRole);
            secretLeaseContainer.addLeaseListener(e -> {
                if (vaultCredsPath.equals(e.getSource().getPath())) {
                    if (e instanceof SecretLeaseExpiredEvent) {
                        contextRefresher.refresh();
                        System.out.println("refreshing database credentials");
                    }
                }
            });
        }
    }

Main
----

Modify ``VaultConfigurationApplication.java``:

.. code-block:: java

    @SpringBootApplication
    public class VaultConfigurationApplication {

    	public static void main(String[] args) {
    		SpringApplication.run(VaultConfigurationApplication.class, args);
    	}

    	/**
    	 * TODO not being refreshed after 2 min expiry
    	 * @param properties
    	 * @return
    	 */
    	@Bean
    	@RefreshScope
    	public DataSource dataSource(DataSourceProperties properties) {
    		System.out.println("Rebuilding dataSource: " + properties.getUsername() + " " + properties.getPassword());
    		return DataSourceBuilder.create()
    				.url(properties.getUrl())
    				.username(properties.getUsername())
    				.password(properties.getPassword())
    				.build();
    	}
    }

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Verify output console that credentials are being refreshed every 2-ish minutes.
