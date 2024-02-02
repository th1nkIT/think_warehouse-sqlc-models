CREATE SEQUENCE IF NOT EXISTS stock_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE TABLE IF NOT EXISTS stock
(
    id bigint NOT NULL DEFAULT nextval('stock_id_seq'::regclass),
    guid CHARACTER VARYING NOT NULL PRIMARY KEY,
    product_id character varying(36),
    product_variant_id character varying(36),
    stock bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    updated_at timestamp without time zone,
    updated_by character varying,
    deleted_at timestamp without time zone,
    deleted_by character varying
    );