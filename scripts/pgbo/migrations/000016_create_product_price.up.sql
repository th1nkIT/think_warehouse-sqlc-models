CREATE SEQUENCE IF NOT EXISTS product_price_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE TYPE discount_type_enum AS ENUM ('nominal', 'percentage');

CREATE TABLE IF NOT EXISTS product_price
(
    id bigint NOT NULL DEFAULT nextval('product_price_id_seq'::regclass),
    guid character varying(36) NOT NULL,
    product_id character varying(36),
    product_variant_id character varying(36),
    price bigint NOT NULL,
    discount_type discount_type_enum,
    discount bigint,
    is_active boolean NOT NULL DEFAULT false,
    is_active_by character varying(36),
    created_at timestamp without time zone NOT NULL,
    created_by character varying(36) NOT NULL,
    updated_at timestamp without time zone,
    updated_by character varying(36),
    deleted_at timestamp without time zone,
    deleted_by character varying(36),
    CONSTRAINT product_price_pkey PRIMARY KEY (guid),
    CONSTRAINT product_id_fk FOREIGN KEY (product_id) REFERENCES product(guid));