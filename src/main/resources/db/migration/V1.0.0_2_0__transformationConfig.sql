DROP TABLE IF EXISTS hdfc_adapter_transformation_config;
DROP TABLE IF EXISTS hdfc_adapter_transformation_templates;


CREATE TABLE hdfc_adapter_transformation_templates (
	transformation_template_id VARCHAR(255) NOT NULL,
	transformation_template_version int4 NOT NULL,
	request_template varchar NOT NULL,
	response_template varchar NOT NULL,
	message_type VARCHAR(30) NULL,
	created_on TIMESTAMP NOT NULL,
    updated_on TIMESTAMP NOT NULL,
    created_by VARCHAR(255) NOT NULL,
    updated_by VARCHAR(255) NOT NULL,
    extension_fields JSONB,
    version BIGINT NOT NULL,
    status VARCHAR(6) NOT NULL,
	CONSTRAINT hdfc_adapter_transformation_templates_pk PRIMARY KEY (transformation_template_id, transformation_template_version)
) SPLIT INTO 1 TABLETS;

CREATE TABLE hdfc_adapter_transformation_config (
	api_id varchar NOT NULL,
	transformation_template_id varchar NOT NULL,
	transformation_template_version int4 NOT NULL,
	created_on TIMESTAMP NOT NULL,
    updated_on TIMESTAMP NOT NULL,
    created_by VARCHAR(255) NOT NULL,
    updated_by VARCHAR(255) NOT NULL,
    extension_fields JSONB,
    version BIGINT NOT NULL,
    status VARCHAR(6) NOT NULL,
	CONSTRAINT hdfc_adapter_transformation_config_pk PRIMARY KEY (api_id),
	CONSTRAINT hdfc_adapter_transformation_config_fk FOREIGN KEY (transformation_template_id,transformation_template_version) REFERENCES hdfc_adapter_transformation_templates(transformation_template_id,transformation_template_version)
) SPLIT INTO 1 TABLETS;
-- Insert Data
