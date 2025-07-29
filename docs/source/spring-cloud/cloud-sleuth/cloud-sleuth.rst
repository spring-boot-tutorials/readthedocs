Cloud Sleuth
------------

Spring Cloud Sleuth has been deprecated.

Spring Cloud Sleuth was removed from the Spring Cloud release train starting with Spring Cloud 2022.0 (codename Kilburn), which aligns with Spring Boot 3.0. The core functionality of Spring Cloud Sleuth has been transitioned to Micrometer Tracing, and instrumentations are now handled by Micrometer and other respective projects.

Therefore, for applications using Spring Boot 3.x and later, the recommended approach for distributed tracing is to migrate from Spring Cloud Sleuth to Micrometer Tracing. Spring Cloud Sleuth remains compatible with Spring Boot 2.x applications, and the 2021.0 release train (2021.0.3 or later) includes Spring Cloud Sleuth for these older versions.