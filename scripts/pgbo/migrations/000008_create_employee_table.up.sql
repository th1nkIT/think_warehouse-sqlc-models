CREATE SEQUENCE IF NOT EXISTS employee_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE TABLE IF NOT EXISTS employee
(
    id bigint NOT NULL DEFAULT nextval('employee_id_seq'::regclass),
    guid character varying NOT NULL,
    name character varying(100),
    profile_picture_image_url text,
    phone character varying(20) NOT NULL,
    email character varying(50) NOT NULL,
    role_id integer NOT NULL,
    is_active boolean,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    updated_at timestamp without time zone,
    updated_by character varying,
    deleted_at timestamp without time zone,
    deleted_by character varying,
    last_login timestamp without time zone,
    CONSTRAINT employee_pkey PRIMARY KEY (guid)
);