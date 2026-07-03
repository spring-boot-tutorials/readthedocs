OAuth Example #1
================

https://github.com/spring-boot-tutorials/spring-oauth

Based on: https://www.baeldung.com/spring-security-oauth-auth-server

Here we will create 3 applications:

- authorization server - running on localhost:9000
- resource server - running on localhost:8090
- resource client - running on localhost:8080


**Authorization Server**
------------------------

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
      port: 9000
    spring:
      security:
        oauth2:
          authorizationserver:
            issuer: http://auth-server:9000
            client:
              articles-client:
                registration:
                  # Client ID – Spring will use it to identify which client is trying to access the resource
                  client-id: articles-client
                  # Client secret code – a secret known to the client and server that provides trust between the two
                  client-secret: "{noop}secret"
                  client-name: Articles Client
                  # Authentication method – in our case, we’ll use basic authentication, which is just a username and password
                  client-authentication-methods:
                    - client_secret_basic
                  # Authorization grant type – we want to allow the client to generate both an authorization code and a refresh token
                  authorization-grant-types:
                    - authorization_code
                    - refresh_token
                  # Redirect URI – the client will use it in a redirect-based flow
                  redirect-uris:
                    - http://127.0.0.1:8080/login/oauth2/code/articles-client-oidc
                    - http://127.0.0.1:8080/authorized
                  # Scope – this parameter defines authorizations that the client may have. In our case, we’ll have the required OidcScopes.OPENID and our custom one, articles. read
                  scopes:
                    - openid
                    - articles.read

Configuration
-------------

Create new file ``src/main/java/com/example/DefaultConfiguration.java``:

.. code-block:: java

    @Configuration
    @EnableWebSecurity
    public class DefaultConfiguration {

        @Bean
        @Order(1)
        SecurityFilterChain authorizationServerSecurityFilterChain(HttpSecurity http) throws Exception {
            OAuth2AuthorizationServerConfiguration.applyDefaultSecurity(http);
            http.getConfigurer(OAuth2AuthorizationServerConfigurer.class)
                    .oidc(withDefaults()); // Enable OpenID Connect 1.0
            return http.formLogin(withDefaults()).build();
        }

        @Bean
        @Order(2)
        SecurityFilterChain defaultSecurityFilterChain(HttpSecurity http) throws Exception {
            http.authorizeHttpRequests(authorizeRequests -> authorizeRequests.anyRequest()
                            .authenticated())
                    .formLogin(withDefaults());
            return http.build();
        }

        @Bean
        UserDetailsService users() {
            PasswordEncoder encoder = PasswordEncoderFactories.createDelegatingPasswordEncoder();
            UserDetails user = User.builder()
                    .username("admin")
                    .password("password")
                    .passwordEncoder(encoder::encode)
                    .roles("USER")
                    .build();
            return new InMemoryUserDetailsManager(user);
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