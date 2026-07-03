Spring Validation
=================

https://github.com/spring-boot-tutorials/spring-validation

In this article we will configure Spring Validation.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-validation
  - spring-boot-starter-web
  - lombok
- Click `Generate`

Dependencies
------------

Dependencies in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
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

Model
-----

Create new POJO class ``src/main/java/com/example/spring_validation/User.java``:

.. code-block:: java

    @Data
    @SuperBuilder
    @NoArgsConstructor
    public class User {

        private long id;

        @NotBlank(message = "Name is mandatory")
        private String name;

        @NotBlank(message = "Email is mandatory")
        private String email;
    }

Service
-------

Create new file ``src/main/java/com/example/spring_validation/UserService.java``:

.. code-block:: java

    @Service
    @Validated
    public class UserService {

        public void validateUserViaAnnotation(@Valid User user) {
            System.out.println("Bean is valid");
        }

        @Autowired
        Validator validator;

        public void validateUserProgrammatically(User user) {
            Set<ConstraintViolation<User>> violations = validator.validate(user);

            if (!violations.isEmpty()) {
                for (ConstraintViolation<User> violation : violations) {
                    System.out.println("Validation error: " + violation.getMessage());
                }
            } else {
                System.out.println("Bean is valid.");
            }
        }
    }

Controller
----------

Let's create a new file ``src/main/java/com/example/spring_validation/UserController.java``

.. code-block:: java

    @RestController
    public class UserController {

        @PostMapping("/users")
        String addUser(@Valid @RequestBody User user) {
            return "User is valid";
        }

        @ResponseStatus(HttpStatus.BAD_REQUEST)
        @ExceptionHandler(MethodArgumentNotValidException.class)
        public Map<String, String> handleValidationExceptions(MethodArgumentNotValidException ex) {
            Map<String, String> errors = new HashMap<>();
            ex.getBindingResult().getAllErrors().forEach((error) -> {
                String fieldName = ((FieldError) error).getField();
                String errorMessage = error.getDefaultMessage();
                errors.put(fieldName, errorMessage);
            });
            return errors;
        }
    }

Main
----

Modify ``MainApplication.java``:

.. code-block:: java

    @SpringBootApplication
    public class SpringValidationApplication implements CommandLineRunner {
    	@Autowired
    	UserService userService;

    	public static void main(String[] args) {
    		SpringApplication.run(SpringValidationApplication.class, args);
    	}

    	public void run(String... args) throws Exception {
    		try {
    			this.userService.validateUserViaAnnotation(User.builder().name("Marcus Chiu").build());
    		} catch (ConstraintViolationException e) {
    			Set<ConstraintViolation<?>> violations = e.getConstraintViolations();
    			if (!violations.isEmpty()) {
    				for(ConstraintViolation violation : violations) {
    					System.out.println("Validation error: " + violation.getMessage());
    				}
    			} else {
    				System.out.println("Bean is valid.");
    			}
    		}

    		this.userService.validateUserProgrammatically(User.builder().name("Marcus Chiu").build());
    	}
    }

Run Application
---------------

.. code-block:: sh

    mvn spring-boot:run

Verify output console is correct
