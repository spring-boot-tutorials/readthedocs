Spring Quartz Scheduler
=======================

https://github.com/spring-boot-tutorials/spring-quartz-scheduler

In this article we will configure Spring Quartz Scheduler.

Create Initial Code Base
------------------------

- Go to https://start.spring.io/
- Add the following dependencies:

  - spring-boot-starter-quartz
  - spring-boot-starter-web
  - lombok
- Click `Generate`

Dependencies
------------

Dependencies used in ``pom.xml``

.. code-block:: xml

    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-quartz</artifactId>
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

Properties
----------

Add the following properties in ``src/main/resources/application.properties``:

.. code-block:: properties

    spring.quartz.job-store-type=memory

Configuration
-------------

Let's create a new file ``src/main/java/com/example/spring_quartz_scheduler/SampleConfiguration.java``

.. code-block:: java

    @Configuration
    public class SampleConfiguration {

        ////////////////
        // JOB DETAIL //
        ////////////////

    //    /**
    //     * Quartz Way
    //     */
    //    @Bean
    //    public JobDetail jobDetail() {
    //        return JobBuilder.newJob()
    //                .ofType(SampleJob.class)
    //                .storeDurably()
    //                .withIdentity("Qrtz_Job_Detail")
    //                .withDescription("Invoke Sample Job service...")
    //                .build();
    //    }

        /**
         * Spring Way
         */
        @Bean
        public JobDetailFactoryBean jobDetail() {
            JobDetailFactoryBean jobDetailFactory = new JobDetailFactoryBean();
            jobDetailFactory.setJobClass(SampleJob.class);
            jobDetailFactory.setDescription("Invoke Sample Job service...");
            jobDetailFactory.setDurability(true);
            return jobDetailFactory;
        }


        /////////////
        // TRIGGER //
        /////////////

    //    /**
    //     * Quartz Way
    //     */
    //    @Bean
    //    public Trigger trigger(JobDetail jobDetail) {
    //        return TriggerBuilder.newTrigger().forJob(jobDetail)
    //                .withIdentity("Qrtz_Trigger")
    //                .withDescription("Sample trigger")
    //                .withSchedule(simpleSchedule().repeatForever().withIntervalInSeconds(10))
    //                .build();
    //    }

        /**
         * Spring Way
         */
        @Bean
        public SimpleTriggerFactoryBean trigger(JobDetail job) {
            SimpleTriggerFactoryBean trigger = new SimpleTriggerFactoryBean();
            trigger.setJobDetail(job);
            trigger.setRepeatInterval(1000);
            trigger.setRepeatCount(SimpleTrigger.REPEAT_INDEFINITELY);
            return trigger;
        }


        ///////////////
        // SCHEDULER //
        ///////////////

    //    /**
    //     * Quartz Way
    //     */
    //    @Bean
    //    public Scheduler scheduler(Trigger trigger, JobDetail jobDetail, SchedulerFactoryBean factory) throws SchedulerException {
    //        Scheduler scheduler = factory.getScheduler();
    //        scheduler.scheduleJob(jobDetail, trigger);
    //        scheduler.start();
    //        return scheduler;
    //    }


    //    /**
    //     * Spring Way - autoconfigured by
    //     * org.springframework.boot.autoconfigure.quartz.QuartzAutoConfiguration
    //     */
    //    @Bean
    //    public SchedulerFactoryBean scheduler(Trigger trigger, JobDetail jobDetail, DataSource quartzDataSource) {
    //        SchedulerFactoryBean schedulerFactory = new SchedulerFactoryBean();
    //        schedulerFactory.setConfigLocation(new ClassPathResource("quartz.properties"));
    //
    //        schedulerFactory.setJobFactory(springBeanJobFactory());
    //        schedulerFactory.setJobDetails(jobDetail);
    //        schedulerFactory.setTriggers(trigger);
    //        schedulerFactory.setDataSource(quartzDataSource);
    //        return schedulerFactory;
    //    }
    }


Sample Job
----------

Create a new file ``src/main/java/com/example/spring_quartz_scheduler/SampleJob.java``:

.. code-block:: java

    public class SampleJob implements Job {
        @Autowired
        private SampleJobService jobService;

        public SampleJob() {
            System.out.println("SampleJob created");
        }

        public void execute(JobExecutionContext context) throws JobExecutionException {
            this.jobService.doSomething();
        }
    }

Sample Job Service
------------------

Create a new file ``src/main/java/com/example/spring_quartz_scheduler/SampleJobService.java``:

.. code-block:: java

    @Service
    public class SampleJobService {
        public void doSomething() {
            System.out.println("Hello, World!");
        }
    }

Run & Verify Application
------------------------

Open terminal at project root and execute the following:

.. code-block:: sh

    mvn spring-boot:run
