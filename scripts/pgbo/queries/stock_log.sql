-- name: InsertStockLog :one
INSERT INTO stock_log
(guid, product_id, product_variant_id, stock_log, stock_type, note, created_at, created_by)
VALUES
    (@guid, @product_id, @product_variant_id, @stock_log, @stock_type, @note, (now() at time zone 'UTC')::TIMESTAMP, @created_by)
    RETURNING stock_log.*;

-- name: UpdateStockLog :one
UPDATE stock_log
SET
    stock_log = @stock_log,
    stock_type = @stock_type,
    note = @note,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP,
    updated_by = @updated_by
WHERE
    guid = @guid
  AND deleted_at IS NULL
    RETURNING stock_log.*;

-- name: ListStockLog :many
SELECT
    s.*,
    p.name AS product_name,
    v.name AS variant_name
FROM
    stock_log s
        LEFT JOIN
    product p
    ON
        s.product_id = p.guid
        LEFT JOIN
    product_variant v
    ON
        s.product_variant_id = v.guid
WHERE
    (CASE WHEN @set_stock_log_greater::bool THEN s.stock_log >= @stock_log ELSE TRUE END)
  AND (CASE WHEN @set_stock_log_lower::bool THEN s.stock_log <= @stock_log ELSE TRUE END)
  AND (CASE WHEN @set_is_stock_type::bool THEN LOWER(s.stock_type) LIKE LOWER (@stock_type) ELSE TRUE END)
  AND (CASE WHEN @set_product_name::bool THEN LOWER(p.name) LIKE LOWER (@product_name) ELSE TRUE END)
  AND (CASE WHEN @set_variant_name::bool THEN LOWER(v.name) LIKE LOWER (@variant_name) ELSE TRUE END)
  AND s.deleted_at IS NULL
ORDER BY (CASE WHEN @order_param = 'id ASC' THEN s.guid END) ASC,
         (CASE WHEN @order_param = 'id DESC' THEN s.guid END) DESC,
         (CASE WHEN @order_param = 'stock_log ASC' THEN s.stock_log END) ASC,
         (CASE WHEN @order_param = 'stock_log DESC' THEN s.stock_log END) DESC,
         (CASE WHEN @order_param = 'stock_type ASC' THEN s.stock_type END) ASC,
         (CASE WHEN @order_param = 'stock_type DESC' THEN s.stock_type END) DESC,
         (CASE WHEN @order_param = 'product_name ASC' THEN p.name END) ASC,
         (CASE WHEN @order_param = 'product_name DESC' THEN p.name END) DESC,
         (CASE WHEN @order_param = 'variant_name ASC' THEN v.name END) ASC,
         (CASE WHEN @order_param = 'variant_name DESC' THEN v.name END) DESC,
         (CASE WHEN @order_param = 'created_at ASC' THEN s.created_at END) ASC,
         (CASE WHEN @order_param = 'created_at DESC' THEN s.created_at END) DESC,
         s.created_at DESC
    LIMIT @limit_data
OFFSET @offset_page;

-- name: GetCountListStockLog :one
SELECT
    count(s.id)
FROM
    stock_log s
        LEFT JOIN
    product p
    ON
        s.product_id = p.guid
        LEFT JOIN
    product_variant v
    ON
        s.product_variant_id = v.guid
WHERE
    (CASE WHEN @set_stock_log_greater::bool THEN s.stock_log >= @stock_log ELSE TRUE END)
  AND (CASE WHEN @set_stock_log_lower::bool THEN s.stock_log <= @stock_log ELSE TRUE END)
  AND (CASE WHEN @set_is_stock_type::bool THEN LOWER(s.stock_type) LIKE LOWER (@stock_type) ELSE TRUE END)
  AND (CASE WHEN @set_product_name::bool THEN LOWER(p.name) LIKE LOWER (@product_name) ELSE TRUE END)
  AND (CASE WHEN @set_variant_name::bool THEN LOWER(v.name) LIKE LOWER (@variant_name) ELSE TRUE END)
  AND s.deleted_at IS NULL;

-- name: GetStockLogByProductAndVariantId :many
SELECT
    s.*
FROM
    stock_log s
WHERE
    s.product_id = @product_id
  AND (CASE WHEN @set_product_variant_id::bool THEN s.product_variant_id = @product_variant_id ELSE s.product_variant_id IS NULL END);

-- name: DeleteStockLog :exec
UPDATE stock_log s
SET
    deleted_at = (now() at time zone 'UTC')::TIMESTAMP,
    deleted_by = @deleted_by
WHERE
    (CASE WHEN @set_product_id::bool THEN s.product_id = @product_id ELSE TRUE END)
  AND (CASE WHEN @set_product_variant_id::bool THEN s.product_variant_id = @product_variant_id ELSE TRUE END);
