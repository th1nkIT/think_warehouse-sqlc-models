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
    p.*,
    pc.name product_category_name,
    json_agg(
            json_build_object(
                    'product_variant_id', pv.guid,
                    'name', pv.name,
                    'sku', pv.sku,
                    'price', pp.price,
                    'discount', pp.discount,
                    'discount_type', pp.discount_type,
                    'is_active', (CASE WHEN pv.is_active IS NOT NULL THEN pv.is_active WHEN p.deleted_at IS NOT NULL THEN 'inactive' ELSE 'inactive' END),
                    'stock_id', (SELECT guid FROM stock WHERE product_id = p.guid AND (CASE WHEN pv.guid IS NOT NULL THEN product_variant_id = pv.guid ELSE product_variant_id IS NULL END)),
                    'stock', (SELECT stock FROM stock WHERE product_id = p.guid AND (CASE WHEN pv.guid IS NOT NULL THEN product_variant_id = pv.guid ELSE product_variant_id IS NULL END)),
                    'created_at', p.created_at,
                    'created_by', ub_created.name,
                    'updated_at', p.updated_at,
                    'updated_by', ub_updated.name
            )
    ) AS product_variant
FROM
    product p
        LEFT JOIN
    product_category pc
    ON
        p.category_id = pc.guid
        LEFT JOIN
    product_variant pv
    ON
        pv.product_id = p.guid
    LEFT JOIN user_backoffice ub_created ON ub_created.guid = p.created_by
    LEFT JOIN user_backoffice ub_updated ON ub_updated.guid = p.updated_by
        LEFT JOIN
    product_price pp
    ON
        pp.product_id = p.guid
            AND (CASE WHEN pp.product_variant_id IS NULL THEN pp.product_variant_id IS NULL ELSE pp.product_variant_id = pv.guid END)
WHERE
    (CASE WHEN @set_is_variant::bool THEN p.is_variant = @is_variant::bool ELSE TRUE END)
  AND (CASE WHEN @set_product_category_id::bool THEN p.category_id = @product_category_id ELSE TRUE END)
  AND (CASE WHEN @set_name::bool THEN LOWER(p.name) LIKE LOWER(@name) ELSE TRUE END)
  AND (CASE WHEN @set_description::bool THEN LOWER(p.description) LIKE LOWER(@description) ELSE TRUE END)
  AND (CASE WHEN @set_sku::bool THEN LOWER(p.product_sku) LIKE LOWER(@sku) ELSE TRUE END)
  AND (CASE WHEN @set_is_active::bool THEN p.deleted_at = @deleted_at ELSE TRUE END)
GROUP BY
    p.guid,
    p.product_picture_url,
    p.is_variant,
    p.category_id,
    p.name,
    p.description,
    p.product_sku,
    p.created_at,
    p.created_by,
    p.updated_at,
    p.updated_by,
    pc.name
ORDER BY (CASE WHEN @order_param = 'id ASC' THEN p.guid END) ASC,
         (CASE WHEN @order_param = 'id DESC' THEN p.guid END) DESC,
         (CASE WHEN @order_param = 'category_name ASC' THEN pc.name END) ASC,
         (CASE WHEN @order_param = 'category_name DESC' THEN pc.name END) DESC,
         (CASE WHEN @order_param = 'product_category_id ASC' THEN p.category_id END) ASC,
         (CASE WHEN @order_param = 'product_category_id DESC' THEN p.category_id END) DESC,
         (CASE WHEN @order_param = 'name ASC' THEN p.name END) ASC,
         (CASE WHEN @order_param = 'name DESC' THEN p.name END) DESC,
         (CASE WHEN @order_param = 'description ASC' THEN p.description END) ASC,
         (CASE WHEN @order_param = 'description DESC' THEN p.description END) DESC,
         (CASE WHEN @order_param = 'sku ASC' THEN p.product_sku END) ASC,
         (CASE WHEN @order_param = 'sku DESC' THEN p.product_sku END) DESC,
         (CASE WHEN @order_param = 'is_active ASC' THEN CASE WHEN p.deleted_at IS NOT NULL THEN 1 ELSE 0 END END) ASC,
         (CASE WHEN @order_param = 'is_active DESC' THEN CASE WHEN p.deleted_at IS NOT NULL THEN 1 ELSE 0 END END) DESC,
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