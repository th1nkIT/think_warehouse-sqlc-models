CREATE SEQUENCE IF NOT EXISTS products_history_id_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

CREATE TABLE IF NOT EXISTS products_history
(
    id bigint NOT NULL DEFAULT nextval('products_history_id_seq'::regclass),
    guid character varying NOT NULL,
    product_guid character varying(20) NOT NULL,
    quantity bigint NOT NULL,
    warehouse_guid character varying(20) NOT NULL,
    tgl_masuk timestamp without time zone NOT NULL,
    pegawai_masuk character varying NOT NULL,
    tgl_keluar timestamp without time zone NOT NULL,
    pegawai_keluar character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    created_by character varying NOT NULL,
    updated_at timestamp without time zone,
    updated_by character varying,
    deleted_at timestamp without time zone,
    deleted_by character varying,
    CONSTRAINT products_history_pkey PRIMARY KEY (guid),
    CONSTRAINT product_id_fk FOREIGN KEY (product_guid) REFERENCES product(guid),
    CONSTRAINT pegawai_masuk_fk FOREIGN KEY (pegawai_masuk) REFERENCES user_backoffice(guid),
    CONSTRAINT pegawai_keluar_fk FOREIGN KEY (pegawai_keluar) REFERENCES user_backoffice(guid),
    CONSTRAINT warehouse_guid_fk FOREIGN KEY (warehouse_guid) REFERENCES warehouse(guid)
);