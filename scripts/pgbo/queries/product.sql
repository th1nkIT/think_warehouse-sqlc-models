-- name: InsertProduct :one
INSERT INTO product 
        (guid, category_id, name, is_variant, product_code, product_picture_url, description, created_at, created_by)
    VALUES
        (@guid, @category_id, @name, @is_variant, @product_code, @product_picture_url, @description, (now() at time zone 'UTC')::TIMESTAMP, @created_by)
RETURNING product.*;

-- name: UpdateProduct :one
UPDATE product 
SET name = @name,
    is_variant = @is_variant,
    category_id = @category_id,
    product_picture_url = @product_picture_url,
    description = @description,
    updated_by = @updated_by,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP 
WHERE guid = @guid
RETURNING product.*;

-- name: DeleteProduct :exec
UPDATE product
SET
    deleted_at = (now() at time zone 'UTC')::TIMESTAMP,
    deleted_by = @deleted_by
WHERE
    guid = @guid
  AND deleted_at IS NULL;

-- name: ReactiveProduct :exec
UPDATE product
SET
    deleted_at = NULL,
    deleted_by = NULL,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP,
    updated_by = @updated_by
WHERE
    guid = @guid
AND deleted_at IS NOT NULL;


-- name: ListProduct :many
SELECT
    p.guid, p.category_id, p.name, p.is_variant, p.product_code, p.product_picture_url, p.description, p.created_at, p.created_by, p.updated_at, p.updated_by, p.deleted_at, p.deleted_by,
    ub_created.name AS user_name, ub_created.guid AS user_id,
    ub_updated.name AS user_name_update, ub_updated.guid AS user_id_update,
    pc.name AS category_name,
    pp.price, pp.discount_type, pp.discount, pp.is_active,
    pv.guid AS product_variant_id, pv.name AS product_variant_name, pv.sku AS product_variant_sku
FROM
    product p
        LEFT JOIN product_category pc ON pc.guid = p.category_id
        LEFT JOIN user_backoffice ub_created ON ub_created.guid = p.created_by
        LEFT JOIN user_backoffice ub_updated ON ub_updated.guid = p.updated_by
        LEFT JOIN
    product_variant pv
    ON
        pv.product_id = p.guid
        LEFT JOIN
    product_price pp
    ON
        pp.product_id = p.guid
            AND (CASE WHEN pp.product_variant_id IS NULL THEN pp.product_variant_id IS NULL ELSE pp.product_variant_id = pv.guid END)
WHERE
    (CASE WHEN @set_name::bool THEN LOWER(p.name) LIKE LOWER(@name) ELSE TRUE END)
AND (CASE WHEN @set_product_code::bool THEN LOWER(p.product_code) LIKE LOWER(@product_code) ELSE TRUE END)
ORDER BY
    (CASE WHEN @order_param = 'id ASC' THEN p.guid END) ASC,
    (CASE WHEN @order_param = 'id DESC' THEN p.guid END) DESC,
    (CASE WHEN @order_param = 'name ASC' THEN p.name END) ASC,
    (CASE WHEN @order_param = 'name DESC' THEN p.name END) DESC,
    (CASE WHEN @order_param = 'created_at ASC' THEN p.created_at END) ASC,
    (CASE WHEN @order_param = 'created_at DESC' THEN p.created_at END) DESC,
    p.created_at DESC
    LIMIT @limit_data
OFFSET @offset_page;

-- name: GetProduct :one
SELECT
    p.guid, p.category_id, p.name, p.is_variant, p.product_code, p.product_picture_url, p.description, p.created_at, p.created_by,
    p.updated_at, p.updated_by, p.deleted_at, p.deleted_by,
    ub_created.name AS user_name, ub_created.guid AS user_id,
    ub_updated.name AS user_name_update, ub_updated.guid AS user_id_update,
    pc.name AS category_name,
    pp.price, pp.discount_type, pp.discount, pp.is_active,
    pv.guid AS product_variant_id, pv.name AS product_variant_name, pv.sku AS product_variant_sku
FROM
    product p
        LEFT JOIN user_backoffice ub_created ON ub_created.guid = p.created_by
        LEFT JOIN user_backoffice ub_updated ON ub_updated.guid = p.updated_by
        LEFT JOIN product_category pc ON pc.guid = p.category_id
        LEFT JOIN
    product_variant pv
ON
    pv.product_id = p.guid
    LEFT JOIN
    product_price pp
    ON
    pp.product_id = p.guid
    AND (CASE WHEN pp.product_variant_id IS NULL THEN pp.product_variant_id IS NULL ELSE pp.product_variant_id = pv.guid END)
WHERE
    p.guid = @guid;

-- name: GetCountProductList :one
SELECT COUNT(p.id) FROM product p
WHERE
    (CASE WHEN @set_name::bool THEN LOWER(p.name) LIKE LOWER(@name) ELSE TRUE END);