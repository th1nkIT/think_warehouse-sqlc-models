CREATE SEQUENCE IF NOT EXISTS product_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE TABLE IF NOT EXISTS product
(
    id bigint NOT NULL DEFAULT nextval('product_id_seq'::regclass),
    guid character varying NOT NULL,
    name character varying(100),
    product_picture_url text,
    description character varying(150) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    updated_at timestamp without time zone,
    updated_by character varying,
    deleted_at timestamp without time zone,
    deleted_by character varying,
    CONSTRAINT product_pkey PRIMARY KEY (guid)
);