ALTER TABLE product
ADD COLUMN product_code character varying NOT NULL,
ADD COLUMN category_id character varying NOT NULL
REFERENCES product_category (guid)
ON DELETE RESTRICT;