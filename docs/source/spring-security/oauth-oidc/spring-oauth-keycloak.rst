OAuth Keycloak
==============

https://github.com/spring-boot-tutorials/spring-oauth-keycloak

Install & Run Keycloak Server
-----------------------------

Create a keycloak directory

.. code-block:: sh

    mkdir keycloak
    cd keycloak

 Within that directory, create a docker-compose.yml file with the following contents:

.. code-block:: yaml

    services:
      keycloak:
        container_name: baeldung-keycloak.openid-provider
        image: quay.io/keycloak/keycloak:25.0.1
        command:
        - start-dev
        - --import-realm
        ports:
        - 8080:8080
        volumes:
        - ./keycloak/:/opt/keycloak/data/import/
        environment:
          KEYCLOAK_ADMIN: admin
          KEYCLOAK_ADMIN_PASSWORD: ${KEYCLOAK_ADMIN_PASSWORD}
          KC_HTTP_PORT: 8080
          KC_HOSTNAME_URL: http://localhost:8080
          KC_HOSTNAME_ADMIN_URL: http://localhost:8080
          KC_HOSTNAME_STRICT_BACKCHANNEL: true
          KC_HTTP_RELATIVE_PATH: /
          KC_HTTP_ENABLED: true
          KC_HEALTH_ENABLED: true
          KC_METRICS_ENABLED: true
        extra_hosts:
        - "host.docker.internal:host-gateway"
        healthcheck:
          test: ['CMD-SHELL', '[ -f /tmp/HealthCheck.java ] || echo "public class HealthCheck { public static void main(String[] args) throws java.lang.Throwable { System.exit(java.net.HttpURLConnection.HTTP_OK == ((java.net.HttpURLConnection)new java.net.URL(args[0]).openConnection()).getResponseCode() ? 0 : 1); } }" > /tmp/HealthCheck.java && java /tmp/HealthCheck.java http://localhost:8080/auth/health/live']
          interval: 5s
          timeout: 5s
          retries: 20

Run Keycloak server

.. code-block:: sh

    export KEYCLOAK_ADMIN_PASSWORD=admin
    docker compose up -d

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-oauth2-client
  - spring-boot-starter-security
  - spring-boot-starter-thymeleaf
  - spring-boot-starter-web
  - thymeleaf-extras-springsecurity6
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``:

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-oauth2-client</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-thymeleaf</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.thymeleaf.extras</groupId>
        <artifactId>thymeleaf-extras-springsecurity6</artifactId>
    </dependency>

Properties
----------

Add the following properties in ``src/main/resources/application.properties``:

.. code-block:: properties

    spring.security.oauth2.client.provider.baeldung-keycloak.issuer-uri=http://localhost:8080/realms/baeldung-keycloak

    spring.security.oauth2.client.registration.keycloak.provider=baeldung-keycloak
    spring.security.oauth2.client.registration.keycloak.authorization-grant-type=authorization_code
    spring.security.oauth2.client.registration.keycloak.client-id=baeldung-keycloak-confidential
    spring.security.oauth2.client.registration.keycloak.client-secret=secret
    spring.security.oauth2.client.registration.keycloak.scope=openid

Configuration
-------------

Create new file ``src/main/java/com/example/OAuth2/Login/config/AuthoritiesConverter.java``:

.. code-block:: java

    public interface AuthoritiesConverter extends Converter<Map<String, Object>, Collection<GrantedAuthority>> {
    }

Create new file ``src/main/java/com/example/OAuth2/Login/config/DefaultConfiguration.java``:

.. code-block:: java

    @Configuration
    public class DefaultConfiguration {

        @Bean
        AuthoritiesConverter realmRolesAuthoritiesConverter() {
            return claims -> {
                var realmAccess = Optional.ofNullable((Map<String, Object>) claims.get("realm_access"));
                var roles = realmAccess.flatMap(map -> Optional.ofNullable((List<String>) map.get("roles")));
                return roles.map(List::stream)
                        .orElse(Stream.empty())
                        .map(SimpleGrantedAuthority::new)
                        .map(GrantedAuthority.class::cast)
                        .toList();
            };
        }

        @Bean
        GrantedAuthoritiesMapper authenticationConverter(AuthoritiesConverter authoritiesConverter) {
            return (authorities) -> authorities.stream()
                    .filter(OidcUserAuthority.class::isInstance)
                    .map(OidcUserAuthority.class::cast)
                    .map(OidcUserAuthority::getIdToken)
                    .map(OidcIdToken::getClaims)
                    .map(authoritiesConverter::convert)
                    .flatMap(roles -> roles.stream())
                    .collect(Collectors.toSet());
        }

        @Bean
        SecurityFilterChain clientSecurityFilterChain(HttpSecurity http,
                                                      ClientRegistrationRepository clientRegistrationRepository) throws Exception {
            http.oauth2Login(Customizer.withDefaults());
            http.logout((logout) -> {
                var logoutSuccessHandler = new OidcClientInitiatedLogoutSuccessHandler(clientRegistrationRepository);
                logoutSuccessHandler.setPostLogoutRedirectUri("{baseUrl}/");
                logout.logoutSuccessHandler(logoutSuccessHandler);
            });

            http.authorizeHttpRequests(requests -> {
                requests.requestMatchers("/", "/favicon.ico").permitAll();
                requests.requestMatchers("/nice").hasAuthority("NICE");
                requests.anyRequest().denyAll();
            });

            return http.build();
        }
    }

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run







**Resource Server**
-------------------

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-oauth2-authorization-server
  - spring-boot-starter-security
  - spring-boot-starter-web
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``:

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-oauth2-authorization-server</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

Properties
----------

Add the following properties in ``src/main/resources/application.yaml``:

.. code-block:: yaml

    server:
      port: 8090
    spring:
      security:
        oauth2:
          resourceserver:
            jwt:
              issuer-uri: http://auth-server:9000

Configuration
-------------

Create new file ``src/main/java/com/example/DefaultConfiguration.java``:

.. code-block:: java

    @Configuration
    @EnableWebSecurity
    public class DefaultConfiguration {

        @Bean
        SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
            http.securityMatcher("/articles/**")
                    .authorizeHttpRequests(authorize -> authorize.anyRequest()
                            .hasAuthority("SCOPE_articles.read"))
                    .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()));
            return http.build();
        }
    }

Controller
----------

Create new file ``src/main/java/com/example/DefaultController.java``:

.. code-block:: java

    @RestController
    public class DefaultController {

        @GetMapping("/articles")
        public String[] getArticles() {
            return new String[] { "Article 1", "Article 2", "Article 3" };
        }
    }

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run









**Resource Client**
-------------------

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-oauth2-client
  - spring-webflux
  - reactor-netty
  - spring-boot-starter-security
  - spring-boot-starter-web
- Click ``Generate``

Dependencies
------------

Dependencies used in ``pom.xml``:

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-oauth2-client</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-webflux</artifactId>
    </dependency>
    <dependency>
        <groupId>io.projectreactor.netty</groupId>
        <artifactId>reactor-netty</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

Properties
----------

Add the following properties in ``src/main/resources/application.yaml``:

.. code-block:: yaml

    server:
      port: 8080

    spring:
      security:
        oauth2:
          client:
            registration:
              articles-client-oidc:
                provider: spring
                client-id: articles-client
                client-secret: secret
                authorization-grant-type: authorization_code
                redirect-uri: "http://127.0.0.1:8080/login/oauth2/code/{registrationId}"
                scope: openid
                client-name: articles-client-oidc
              articles-client-authorization-code:
                provider: spring
                client-id: articles-client
                client-secret: secret
                authorization-grant-type: authorization_code
                redirect-uri: "http://127.0.0.1:8080/authorized"
                scope: articles.read
                client-name: articles-client-authorization-code
            provider:
              spring:
                issuer-uri: http://auth-server:9000

Configuration
-------------

Create new file ``src/main/java/com/example/DefaultConfiguration.java``:

.. code-block:: java

    @Configuration
    @EnableWebSecurity
    public class DefaultConfiguration {

        @Bean
        WebClient webClient(OAuth2AuthorizedClientManager authorizedClientManager) {
            ServletOAuth2AuthorizedClientExchangeFilterFunction oauth2Client =
                    new ServletOAuth2AuthorizedClientExchangeFilterFunction(authorizedClientManager);
            return WebClient.builder()
                    .apply(oauth2Client.oauth2Configuration())
                    .build();
        }

        @Bean
        OAuth2AuthorizedClientManager authorizedClientManager(
                ClientRegistrationRepository clientRegistrationRepository,
                OAuth2AuthorizedClientRepository authorizedClientRepository) {

            OAuth2AuthorizedClientProvider authorizedClientProvider =
                    OAuth2AuthorizedClientProviderBuilder.builder()
                            .authorizationCode()
                            .refreshToken()
                            .build();
            DefaultOAuth2AuthorizedClientManager authorizedClientManager = new DefaultOAuth2AuthorizedClientManager(
                    clientRegistrationRepository, authorizedClientRepository);
            authorizedClientManager.setAuthorizedClientProvider(authorizedClientProvider);

            return authorizedClientManager;
        }

        @Bean
        SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
            http
                    .authorizeHttpRequests(authorizeRequests ->
                            authorizeRequests.anyRequest().authenticated()
                    )
                    .oauth2Login(oauth2Login ->
                            oauth2Login.loginPage("/oauth2/authorization/articles-client-oidc"))
                    .oauth2Client(withDefaults());
            return http.build();
        }
    }

Controller
----------

Create new file ``src/main/java/com/example/DefaultController.java``:

.. code-block:: java

    @RestController
    public class DefaultController {

        @Autowired
        private WebClient webClient;

        @GetMapping(value = "/articles")
        public String[] getArticles(@RegisteredOAuth2AuthorizedClient("articles-client-authorization-code") OAuth2AuthorizedClient authorizedClient) {
            return this.webClient
                    .get()
                    .uri("http://127.0.0.1:8090/articles")
                    .attributes(oauth2AuthorizedClient(authorizedClient))
                    .retrieve()
                    .bodyToMono(String[].class)
                    .block();
        }
    }

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run










Verify
------

Access the http://127.0.0.1:8080/articles page, we’ll be automatically redirected
to the OAuth server login page under http://auth-server:9000/login URL.

After providing the proper username and password, the authorization server will
redirect us back to the requested URL, the list of articles.