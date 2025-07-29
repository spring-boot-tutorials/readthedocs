Spring Cache (Redis)
====================

https://github.com/spring-boot-tutorials/spring-cache-redis

In this article we will use Redis as a cache for a Spring Boot application.

`Spring Boot supported cache providers <https://docs.spring.io/spring-boot/docs/3.0.8/reference/html/io.html#io.caching.provider.jcache/>`_:

- Generic
- JCache (JSR-107) (EhCache 3, Hazelcast, Infinispan, and others)
- Hazelcast
- Infinispan
- Couchbase
- Redis
- Caffeine
- Cache2k
- Simple

Install & Run Redis Server
--------------------------

.. code-block:: sh

    docker run -p 6379:6379 redis

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-cache
  - spring-boot-starter-data-redis
  - lombok

- Click `Generate`

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-cache</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-redis</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>

Properties
----------

Add the following properties into ``src/main/resources/application.properties``:

.. code-block:: properties

    spring.data.redis.host=localhost
    spring.data.redis.port=6379

Configuration
-------------

Let's create a new file ``src/main/java/com/example/spring_cache_abstraction/DefaultConfig.java``

.. code-block:: java

    @Configuration
    @EnableCaching
    public class DefaultConfig {

        public static final String CACHE_ADDRESS = "addresses";
        public static final String CACHE_DIRECTORY = "directory";

        @Bean
        public RedisCacheManager cacheManager(RedisConnectionFactory connectionFactory) {
            RedisCacheConfiguration cacheConfiguration = RedisCacheConfiguration.defaultCacheConfig()
                    .entryTtl(Duration.ofMinutes(10)) // Set default TTL to 10 minutes
                    .disableCachingNullValues(); // Don't cache null values

            return RedisCacheManager.builder(connectionFactory)
                    .cacheDefaults(cacheConfiguration)
                    .initialCacheNames(Set.of(CACHE_ADDRESS, CACHE_DIRECTORY))
                    .build();
        }
    }


Model
-----

Let's create a new POJO ``src/main/java/com/example/spring_cache_abstraction/Customer.java``

.. code-block:: java

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    @SuperBuilder
    public class Customer {
        private String name;
    }

Service
-------

Let's create a service class ``src/main/java/com/example/spring_cache_abstraction/DefaultService.java``:

.. code-block:: java

    @Service
    public class DefaultService {

        ///////////////
        // CACHEABLE //
        ///////////////

        @Cacheable(value = CACHE_ADDRESS, key = "#customer.name")
        public String getCachedAddress(Customer customer) {
            System.out.println("inside cacheable function `getCachedAddress`");
            return "address + " + customer.getName();
        }

        @Cacheable(value = CACHE_DIRECTORY, key = "#customer.name")
        public String getCachedDirectory(Customer customer) {
            System.out.println("inside cacheable function `getCachedDirectory`");
            return "address + " + customer.getName();
        }


        /////////////////
        // CACHE EVICT //
        /////////////////

        @CacheEvict(value = CACHE_ADDRESS, allEntries = true)
        public void evictAllAddress() {}

        @CacheEvict(value = CACHE_ADDRESS, key = "#customer.name")
        public void evictSingleAddress(Customer customer) {}


        ///////////////
        // CACHE PUT //
        ///////////////

        // @CachePut is used to ensure that a method is always executed
        // and its result is then placed into the cache. Unlike @Cacheable,
        // @CachePut does not skip method execution if a value is already
        // present in the cache. Instead, it forces the method to run, and the
        // result of that execution is used to update the corresponding entry
        // in the cache. This is useful for scenarios where you need to guarantee
        // that the cache always reflects the latest state of data, such as
        // after an update operation.

        @CachePut(value = CACHE_ADDRESS, key = "#customer.name")
        public String getAddressAndCache(Customer customer) {
            System.out.println("inside cacheable function `getAddressAndCache`");
            return "address + " + customer.getName();
        }


        /////////////
        // CACHING //
        /////////////

        @Caching(evict = {
                @CacheEvict(value = CACHE_ADDRESS, allEntries = true),
                @CacheEvict(value = CACHE_DIRECTORY, allEntries = true),
        })
        public void evictAllAddressAndDirectory() {}

        @Caching(
                cacheable = {
                        @Cacheable(CACHE_ADDRESS),
                        @Cacheable(value = CACHE_DIRECTORY)},
                put = {
                        @CachePut(CACHE_ADDRESS),
                        @CachePut(CACHE_DIRECTORY),}
        )
        public void unintelligible() {}


        /////////////////////////
        // Conditional Caching //
        /////////////////////////

        @CachePut(value="addresses", condition="#customer.name=='Tom'")
        public String getAddressConditional1(Customer customer) {
            return null;
        }

        @CachePut(value="addresses", unless="#result.length()<64")
        public String getAddressConditional2(Customer customer) {
            return null;
        }

    }

Main
----

Now let's use this service.

Go back to ``MainApplication.java`` and add the following:

.. code-block:: java

    @SpringBootApplication
    public class SpringCacheAbstractionApplication implements CommandLineRunner {

    	public static void main(String[] args) {
    		SpringApplication.run(SpringCacheAbstractionApplication.class, args);
    	}

    	@Autowired
    	DefaultService defaultService;

    	@Override
    	public void run(String... args) {
    		List<Customer> customers = List.of(
    				new Customer("marcus"),
    				new Customer("jesus"),
    				new Customer("marcus"),
    				new Customer("jesus"),
    				new Customer("asher"));

    		System.out.println("\nSTART ADDRESSES");
    		customers.forEach(c -> {
    			System.out.println("Invoking cacheable function `getCachedAddress` for input param=" + c);
    			defaultService.getCachedAddress(c);
    		});

    		System.out.println("\nSTART DIRECTORY");
    		customers.forEach(c -> {
    			System.out.println("Invoking cacheable function `getCachedDirectory` for input param=" + c);
    			defaultService.getCachedDirectory(c);
    		});
    	}
    }

Run Application
---------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run

There should be no errors and verify the output.
