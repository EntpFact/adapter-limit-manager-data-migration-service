do $$
	declare version_var decimal;
 	declare timezone_var varchar(50);
begin
	-- selecting version into version variable and timezone into timezone_var
    select substring(regexp_replace(version()
    ,'^PostgreSQL ([0-9]+)[.]([0-9]+)-YB-([0-9]+)[.]([0-9]+)[.]([0-9]+)[.]([0-9]+)-b([0-9]+).*'
    ,'\3.\4\5') from 1 for 6)::decimal into version_var;
   select current_setting('TIMEZONE') into timezone_var;
  	-- if-else based on yugabyte version
if version_var >= 2.192 -- equals or greater to major version
	then
		ALTER TABLE hdfc_adapter_transformation_templates ALTER COLUMN created_on TYPE timestamp with time zone USING created_on::timestamp with time zone;
        ALTER TABLE hdfc_adapter_transformation_templates ALTER COLUMN updated_on TYPE timestamp with time zone USING updated_on::timestamp with time zone;

        ALTER TABLE hdfc_adapter_transformation_config ALTER COLUMN created_on TYPE timestamp with time zone USING created_on::timestamp with time zone;
        ALTER TABLE hdfc_adapter_transformation_config ALTER COLUMN updated_on TYPE timestamp with time zone USING updated_on::timestamp with time zone;
	else
	    -- set timezone to utc to avoid error(cannot alter partition column) while altering table
	   	set timezone = 'UTC';
	   	ALTER TABLE hdfc_adapter_transformation_templates ALTER COLUMN created_on TYPE timestamp with time zone USING created_on::timestamp with time zone;
        ALTER TABLE hdfc_adapter_transformation_templates ALTER COLUMN updated_on TYPE timestamp with time zone USING updated_on::timestamp with time zone;

        ALTER TABLE hdfc_adapter_transformation_config ALTER COLUMN created_on TYPE timestamp with time zone USING created_on::timestamp with time zone;
        ALTER TABLE hdfc_adapter_transformation_config ALTER COLUMN updated_on TYPE timestamp with time zone USING updated_on::timestamp with time zone;
		-- update time zone as per value present in timezone_var
		perform set_config('timezone', timezone_var::text, false);
	end if;
end $$ language plpgsql;