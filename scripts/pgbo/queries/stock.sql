-- name: InsertStock :one
INSERT INTO stock
(guid, product_id, product_variant_id, stock, created_at, created_by)
VALUES
    (@guid, @product_id, @product_variant_id, @stock, (now() at time zone 'UTC')::TIMESTAMP, @created_by)
    RETURNING stock.*;

-- name: UpdateStock :one
UPDATE stock
SET
    stock = @stock,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP,
    updated_by = @updated_by
WHERE
    guid = @guid
  AND deleted_at IS NULL
    RETURNING stock.*;

-- name: GetStock :one
SELECT
    s.*,
    p.name AS product_name,
    p.product_sku AS product_sku,
    v.name AS variant_name,
    v.sku AS variant_sku
FROM
    stock s
        LEFT JOIN
    product p
    ON
        s.product_id = p.guid
        LEFT JOIN
    product_variant v
    ON
        s.product_variant_id = v.guid
WHERE
    s.guid = @guid;

-- name: GetStockByProductOrVariantId :one
SELECT
    s.*
FROM
    stock s
WHERE
    (CASE WHEN @set_product_id::bool THEN s.product_id = @product_id ELSE TRUE END)
  AND (CASE WHEN @set_product_variant_id::bool THEN s.product_variant_id = @product_variant_id ELSE TRUE END);

-- name: DeleteStock :exec
UPDATE stock s
SET
    deleted_at = (now() at time zone 'UTC')::TIMESTAMP,
    deleted_by = @deleted_by
WHERE
    (CASE WHEN @set_product_id::bool THEN s.product_id = @product_id ELSE TRUE END)
  AND (CASE WHEN @set_product_variant_id::bool THEN s.product_variant_id = @product_variant_id ELSE TRUE END);

-- name: GetStockByProduct :many
SELECT
    s.*
FROM
    stock s
WHERE
    s.product_id = @product_id;

-- name: GetStockByProductAndVariant :one
SELECT
    s.*
FROM
    stock s
WHERE
    s.product_id = @product_id
  AND (CASE WHEN @set_product_variant_id::bool THEN s.product_variant_id = @product_variant_id ELSE s.product_variant_id IS NULL END);

-- name: ListStock :many
SELECT
    s.*,
    p.name AS product_name,
    p.product_sku AS product_sku,
    v.name AS variant_name,
    v.sku AS variant_sku
FROM
    stock s
        JOIN
    product p
    ON
        s.product_id = p.guid
        LEFT JOIN
    product_variant v
    ON
        s.product_variant_id = v.guid
WHERE
    (CASE WHEN @set_stock_greater::bool THEN s.stock >= @stock ELSE TRUE END)
  AND (CASE WHEN @set_stock_lower::bool THEN s.stock <= @stock ELSE TRUE END)
  AND (CASE WHEN @set_product_name::bool THEN LOWER(p.name) LIKE LOWER (@product_name) ELSE TRUE END)
  AND (CASE WHEN @set_variant_name::bool THEN LOWER(v.name) LIKE LOWER (@variant_name) ELSE TRUE END)
  AND s.deleted_at IS NULL
ORDER BY (CASE WHEN @order_param = 'id ASC' THEN s.guid END) ASC,
         (CASE WHEN @order_param = 'id DESC' THEN s.guid END) DESC,
         (CASE WHEN @order_param = 'stock ASC' THEN s.stock END) ASC,
         (CASE WHEN @order_param = 'stock DESC' THEN s.stock END) DESC,
         (CASE WHEN @order_param = 'product_name ASC' THEN p.name END) ASC,
         (CASE WHEN @order_param = 'product_name DESC' THEN p.name END) DESC,
         (CASE WHEN @order_param = 'variant_name ASC' THEN v.name END) ASC,
         (CASE WHEN @order_param = 'variant_name DESC' THEN v.name END) DESC,
         (CASE WHEN @order_param = 'created_at ASC' THEN s.created_at END) ASC,
         (CASE WHEN @order_param = 'created_at DESC' THEN s.created_at END) DESC,
         s.created_at DESC
    LIMIT @limit_data
OFFSET @offset_page;

-- name: GetCountListStock :one
SELECT
    count(s.id)
FROM
    stock s
        JOIN
    product p
    ON
        s.product_id = p.guid
        LEFT JOIN
    product_variant v
    ON
        s.product_variant_id = v.guid
WHERE
    (CASE WHEN @set_stock_greater::bool THEN s.stock >= @stock ELSE TRUE END)
  AND (CASE WHEN @set_stock_lower::bool THEN s.stock <= @stock ELSE TRUE END)
  AND (CASE WHEN @set_product_name::bool THEN LOWER(p.name) LIKE LOWER (@product_name) ELSE TRUE END)
  AND (CASE WHEN @set_variant_name::bool THEN LOWER(v.name) LIKE LOWER (@variant_name) ELSE TRUE END)
  AND s.deleted_at IS NULL;