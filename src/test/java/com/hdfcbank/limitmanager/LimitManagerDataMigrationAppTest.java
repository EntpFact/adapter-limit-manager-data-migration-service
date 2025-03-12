package com.hdfcbank.limitmanager;

import com.hdfcbank.limitmanager.service.DataValidatorService;
import org.junit.Assert;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.testcontainers.junit.jupiter.Container;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.YugabyteDBYSQLContainer;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers
@SpringBootTest
public class LimitManagerDataMigrationAppTest {


    @Container
    static YugabyteDBYSQLContainer con = new YugabyteDBYSQLContainer("yugabytedb/yugabyte:2.16.0.0-b90")
            .withDatabaseName("yugabyte").withUsername("yugabyte").withPassword("yugabyte").withReuse(true);


    @DynamicPropertySource
    static void datasourceProps(final DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", con::getJdbcUrl);
        registry.add("spring.datasource.hikari.jdbc-url",con::getJdbcUrl);
        registry.add("flyway.url", con::getJdbcUrl);
        registry.add("spring.datasource.driver-class-name", () -> "com.yugabyte.Driver");
    }

    @Autowired
    private DataValidatorService dataService;

    @Test
    public void context(){

    }


    /**
     *
     */
    @Test
    public void checkVersionAndScriptMatchTest() {
        var resultsMap=dataService.getVersionAndScript();
        //Assert.assertEquals("V1.0.0_2_0",resultsMap.get("version"));
        Assert.assertEquals("R__hdfc_limit_manager_adapter_transformation_template_and_config_seed.sql",resultsMap.get("script"));
    }


}
