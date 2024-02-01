CREATE SEQUENCE IF NOT EXISTS stock_log_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE TYPE stock_type_enum AS ENUM ('IN', 'OUT');

CREATE TABLE IF NOT EXISTS stock_log
(
    id bigint NOT NULL DEFAULT nextval('stock_log_id_seq'::regclass),
    guid CHARACTER VARYING NOT NULL PRIMARY KEY,
    stock_id character varying,
    product_id character varying,
    product_variant_id character varying,
    stock_log int NOT NULL,
    stock_type stock_type_enum,
    note TEXT,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    updated_at timestamp without time zone,
    updated_by character varying,
    deleted_at timestamp without time zone,
    deleted_by character varying
    );