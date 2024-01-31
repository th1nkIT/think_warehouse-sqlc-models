-- name: InsertProductPrice :one
INSERT INTO product_price
(guid, product_id, product_variant_id, price,
 discount_type, discount,
 is_active, created_at, created_by)
VALUES
    (@guid, @product_id, @product_variant_id, @price,
     @discount_type::discount_type_enum, @discount,
     @is_active, (now() at time zone 'UTC')::TIMESTAMP, @created_by)
    RETURNING product_price.*;

-- name: UpdateProductPrice :one
UPDATE product_price
SET
    price = @price,
    discount_type = @discount_type::discount_type_enum,
    discount = @discount,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP,
    updated_by = @updated_by
WHERE
    (CASE WHEN @set_product_id::bool THEN product_id = @product_id ELSE TRUE END)
  AND (CASE WHEN @set_product_variant_id::bool THEN product_variant_id = @product_variant_id ELSE TRUE END)
  AND deleted_at IS NULL
    RETURNING product_price.*;

-- name: UpdateProductPriceIsActive :exec
UPDATE product_price
SET
    is_active = @is_active
WHERE
    (CASE WHEN @set_product_id::bool THEN product_id = @product_id ELSE TRUE END)
  AND (CASE WHEN @set_product_variant_id::bool THEN product_variant_id = @product_variant_id ELSE TRUE END)
  AND deleted_at IS NULL;

-- name: DeleteProductPrice :exec
UPDATE product_price pp
SET
    deleted_at = (now() at time zone 'UTC')::TIMESTAMP,
    deleted_by = @deleted_by
WHERE
    (CASE WHEN @set_product_id::bool THEN pp.product_id = @product_id ELSE TRUE END)
  AND (CASE WHEN @set_product_variant_id::bool THEN pp.product_variant_id = @product_variant_id ELSE TRUE END);

-- name: GetProductPrice :one
SELECT
    pp.*
FROM
    product_price pp
WHERE
    (CASE WHEN @set_product_id::bool THEN pp.product_id = @product_id ELSE TRUE END)
  AND (CASE WHEN @set_product_variant_id::bool THEN pp.product_variant_id = @product_variant_id ELSE TRUE END)
  AND pp.is_active IS TRUE
ORDER BY pp.created_at DESC;