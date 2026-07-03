Cloud Vault (Static Secrets)
============================

https://github.com/spring-boot-tutorials/cloud-vault-static

Install & Run Vault Server
--------------------------

.. code-block:: sh

    docker run --cap-add=IPC_LOCK --name=dev-vault \
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

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-web
  - spring-cloud-starter-vault-config
  - spring-cloud-vault-config-databases
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

Properties
----------

Add the following properties into ``src/main/resources/application.yaml``:

.. code-block:: yaml

    spring:
      application:
    #    this is used to specify the `path` of the secret in the `secret-engine`
        name: my-bank
      config:
        import: vault://
      cloud:
        vault:
          uri: http://localhost:8200
          token: my-root-token
          kv:
    #        this specifies the `secret-engine` name
            backend: secret
    #      Uncomment to turn off KV
    #        enabled: false

Main
----

Modify ``VaultConfigurationApplication.java``:

.. code-block:: java

    @SpringBootApplication
    public class VaultConfigurationApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(VaultConfigurationApplication.class, args);
    	}

    	@Autowired
    	Environment env;

    	@Override
    	public void run(String... args) throws Exception {
    		System.out.println(env.getProperty("my-foo-1"));
    		System.out.println(env.getProperty("my-foo-2"));
    	}
    }

Setup Secrets on Vault Server
-----------------------------

Connect to Vault Server

.. code-block:: sh

    docker ps
    docker exec -it CONTAINER_ID /bin/sh

Configure `vault` command

.. code-block:: sh

    export VAULT_ADDR="http://127.0.0.1:8200"
    export VAULT_TOKEN="my-root-token"

Use `vault` command to create secrets

.. code-block:: sh

    vault kv put secret/my-bank my-foo-1=secret-1 my-foo-2=secret-2

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Verify output console.
