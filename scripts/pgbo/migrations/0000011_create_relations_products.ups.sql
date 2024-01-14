BEGIN;

ALTER TABLE IF EXISTS public.products_history
    VALIDATE CONSTRAINT product_id_fk;

ALTER TABLE IF EXISTS public.products_history
    VALIDATE CONSTRAINT pegawai_masuk_fk;

ALTER TABLE IF EXISTS public.products_history
    VALIDATE CONSTRAINT pegawai_keluar_fk;

ALTER TABLE IF EXISTS public.products_history
    VALIDATE CONSTRAINT warehouse_guid_fk;

END;