-- name: InsertProductVariant :one
INSERT INTO product_variant
(guid, product_id, name, sku,
 is_active, created_at, created_by
)
VALUES
    (@guid, @product_id, @name, @sku,
     @is_active, (now() at time zone 'UTC')::TIMESTAMP, @created_by)
RETURNING product_variant.*;

-- name: UpdateProductVariant :one
UPDATE product_variant
SET
    product_id = @product_id,
    name = @name,
    sku = @sku,
    is_active = @is_active,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP,
    updated_by = @updated_by
WHERE
    guid = @guid
  AND deleted_at IS NULL
RETURNING product_variant.*;

-- name: UpdateProductVariantIsActive :exec
UPDATE product_variant
SET
    is_active = @is_active,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP,
    updated_by = @updated_by
WHERE
    guid = @guid
  AND deleted_at IS NULL;

-- name: DeleteProductVariant :exec
UPDATE product_variant
SET
    deleted_at = (now() at time zone 'UTC')::TIMESTAMP,
    deleted_by = @deleted_by
WHERE
    guid = @guid
  AND deleted_at IS NULL;

-- name: ListProductVariant :many
SELECT
    pv.*
FROM
    product_variant pv
WHERE
    (CASE WHEN @set_product_id::bool THEN pv.product_id = @product_id ELSE TRUE END)
  AND (CASE WHEN @set_name::bool THEN LOWER(pv.name) LIKE LOWER (@name) ELSE TRUE END)
  AND (CASE WHEN @set_sku::bool THEN LOWER(pv.sku) LIKE LOWER (@sku) ELSE TRUE END)
  AND (CASE WHEN @set_is_active::bool THEN pv.is_active = @is_active ELSE TRUE END)
  AND pv.deleted_at IS NULL
ORDER BY (CASE WHEN @order_param = 'id ASC' THEN pv.guid END) ASC,
         (CASE WHEN @order_param = 'id DESC' THEN pv.guid END) DESC,
         (CASE WHEN @order_param = 'product_id ASC' THEN pv.product_id END) ASC,
         (CASE WHEN @order_param = 'product_id DESC' THEN pv.product_id END) DESC,
         (CASE WHEN @order_param = 'name ASC' THEN pv.name END) ASC,
         (CASE WHEN @order_param = 'name DESC' THEN pv.name END) DESC,
         (CASE WHEN @order_param = 'sku ASC' THEN pv.sku END) ASC,
         (CASE WHEN @order_param = 'sku DESC' THEN pv.sku END) DESC,
         (CASE WHEN @order_param = 'is_active ASC' THEN pv.is_active END) ASC,
         (CASE WHEN @order_param = 'is_active DESC' THEN pv.is_active END) DESC,
         (CASE WHEN @order_param = 'created_at ASC' THEN pv.created_at END) ASC,
         (CASE WHEN @order_param = 'created_at DESC' THEN pv.created_at END) DESC,
         pv.created_at DESC;

-- name: GetProductVariant :one
SELECT
    pv.*, pp.price, pp.discount, pp.discount_type
FROM
    product_variant pv
        LEFT JOIN
    product_price pp ON pv.guid = pp.product_variant_id
WHERE
    pv.guid = @guid
  AND pv.product_id = @product_id
ORDER BY pv.created_at DESC;

-- name: GetProductVariantByNameAndProductID :one
SELECT
    *
FROM
    product_variant
WHERE
    name = @name
  AND product_id = @product_id
  AND deleted_at IS NULL;

-- name: GetCountListProductVariant :one
SELECT
    count(pv.id)
FROM
    product_variant pv
WHERE
    (CASE WHEN @set_product_id::bool THEN pv.product_id = @product_id ELSE TRUE END)
  AND (CASE WHEN @set_name::bool THEN LOWER(pv.name) LIKE LOWER (@name) ELSE TRUE END)
  AND (CASE WHEN @set_sku::bool THEN LOWER(pv.sku) LIKE LOWER (@sku) ELSE TRUE END)
  AND (CASE WHEN @set_is_active::bool THEN pv.is_active = @is_active ELSE TRUE END)
  AND pv.deleted_at IS NULL;
