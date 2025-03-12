package com.hdfcbank.limitmanager.service;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 *
 */
@Service
public class DataValidatorService {

    private static final String GET_VERSION_QUERY="select version,script from hdfc_limit_manager_adapter.flyway_schema_history fsh order by installed_rank desc limit 1";

    private static final String VERSION_FIELD="version";

    private static final String SCRIPT_FIELD="script";

    @Autowired
    NamedParameterJdbcTemplate jdbcTemplate;


    /**
     *
     * @return
     */
    public Map<String,String> getVersionAndScript(){

        return jdbcTemplate.queryForObject(GET_VERSION_QUERY,new HashMap<>(),(rs, rowNum) -> {

            Map<String,String> results=new HashMap<>();
            var version=rs.getString(VERSION_FIELD);
            var script=rs.getString(SCRIPT_FIELD);
            results.put(VERSION_FIELD,version);
            results.put(SCRIPT_FIELD,script);
            return results;
        });


    }
}
