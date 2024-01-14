CREATE SEQUENCE IF NOT EXISTS warehouse_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE TABLE IF NOT EXISTS warehouse
(
    id bigint NOT NULL DEFAULT nextval('warehouse_id_seq'::regclass),
    guid character varying NOT NULL,
    name character varying(100),
    address character varying(100) NOT NULL,
    phone_number character varying(50) NOT NULL,
    is_active boolean,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    updated_at timestamp without time zone,
    updated_by character varying,
    deleted_at timestamp without time zone,
    deleted_by character varying,
    last_login timestamp without time zone,
    CONSTRAINT warehouse_pkey PRIMARY KEY (guid)
);