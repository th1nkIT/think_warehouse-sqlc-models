ALTER TABLE product
    ADD CONSTRAINT product_product_code_key UNIQUE (product_code),
ADD CONSTRAINT product_name_key UNIQUE (name);

ALTER TABLE product
ADD COLUMN product_sku character varying(100) NOT NULL;
