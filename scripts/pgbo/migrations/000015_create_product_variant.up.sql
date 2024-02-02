CREATE SEQUENCE IF NOT EXISTS product_variant_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE TABLE IF NOT EXISTS product_variant
(
    id bigint NOT NULL DEFAULT nextval('product_variant_id_seq'::regclass),
    guid character varying(36) NOT NULL,
    product_id character varying(36) NOT NULL,
    name character varying(100) NOT NULL,
    sku character varying(100) NOT NULL,
    is_active boolean NOT NULL DEFAULT false,
    is_active_by character varying(36),
    created_at timestamp without time zone NOT NULL,
    created_by character varying(36) NOT NULL,
    updated_at timestamp without time zone,
    updated_by character varying(36),
    deleted_at timestamp without time zone,
    deleted_by character varying(36),
    CONSTRAINT product_variant_pkey PRIMARY KEY (guid),
    CONSTRAINT product_id_fk FOREIGN KEY (product_id) REFERENCES product(guid));
