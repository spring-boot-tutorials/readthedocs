OIDC Google
===========

https://github.com/spring-boot-tutorials/spring-oidc-google


Setup OIDC on Google
--------------------

Register this application onto Google:

- https://developers.google.com/identity/protocols/OpenIDConnect#appsetup

Set Redirect URI to:

- `http://localhost:8081/login/oauth2/code/google`




Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-oauth2-client
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
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

Properties
----------

Add the following properties in ``src/main/resources/application.yaml``:

.. code-block:: yaml

    server:
      port: 8081
    spring:
      security:
        oauth2:
          client:
            registration:
              google:
                client-id: 0987654321-somethinghere.apps.googleusercontent.com
                client-secret: GOCSPX-something-here

Configuration
-------------

Create new file ``src/main/java/com/example/OIDC/Google/DefaultConfiguration.java``:

.. code-block:: java

    @Configuration
    public class DefaultConfiguration {

        @Autowired
        private ClientRegistrationRepository clientRegistrationRepository;

        @Bean
        public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
            Set<String> googleScopes = new HashSet<>();
            googleScopes.add("https://www.googleapis.com/auth/userinfo.email");
            googleScopes.add("https://www.googleapis.com/auth/userinfo.profile");
            googleScopes.add("https://www.googleapis.com/auth/contacts.readonly");
            // additional scopes here: https://developers.google.com/identity/protocols/oauth2/scopes

            OidcUserService googleUserService = new OidcUserService();
            googleUserService.setAccessibleScopes(googleScopes);

            http
                    .authorizeHttpRequests(authorizeRequests -> authorizeRequests
                            .requestMatchers("/home", "/").permitAll()
                            .anyRequest().authenticated())
                    .oauth2Login(ol -> ol.userInfoEndpoint(config -> config.oidcUserService(googleUserService)))
                    .logout(logout -> logout.logoutSuccessHandler(oidcLogoutSuccessHandler()));
            return http.build();
        }

        private LogoutSuccessHandler oidcLogoutSuccessHandler() {
            var oidcLogoutSuccessHandler = new OidcClientInitiatedLogoutSuccessHandler(this.clientRegistrationRepository);
            oidcLogoutSuccessHandler.setPostLogoutRedirectUri("http://localhost:8081/home");
            return oidcLogoutSuccessHandler;
        }
    }

Controller
----------

Create new file ``src/main/java/com/example/OIDC/Google/DefaultController.java``:

.. code-block:: java

    @RestController
    public class DefaultController {

        @GetMapping("/")
        public String home1() {
            return home();
        }

        @GetMapping("/home")
        public String home() {
            return "- http://localhost:8081/login\n" +
                    "- http://localhost:8081/oidc-principal-1\n" +
                    "- http://localhost:8081/logout";
        }

        /**
         * http://localhost:8081/oidc-principal-1
         * @param principal
         * @return
         */
        @GetMapping("/oidc-principal-1")
        public OidcUser getOidcUserPrincipal(@AuthenticationPrincipal OidcUser principal) {
            return principal;
        }

        /**
         * http://localhost:8081/oidc-principal-2
         * @return
         */
        @GetMapping("/oidc-principal-2")
        public OidcUser getOidcUserPrincipal2() {
            OidcUser principal = null;
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            if (authentication.getPrincipal() instanceof OidcUser) {
                 principal = ((OidcUser) authentication.getPrincipal());
            }
            return principal;
        }
    }

Run Spring Application
----------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

Verify
------

Open the following links in a browser:

- http://localhost:8081/login
- http://localhost:8081/oidc-principal-1
- http://localhost:8081/logout