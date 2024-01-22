-- name: InsertProduct :one
INSERT INTO product 
        (guid, name, product_picture_url, description, created_at, created_by)
    VALUES
        (@guid, @name, @product_picture_url, @description, (now() at time zone 'UTC')::TIMESTAMP, @created_by)
RETURNING product.*;

-- name: UpdateProduct :one
UPDATE product 
SET name = @name,
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

-- name: ListProduct :many
SELECT
    p.guid, p.name, p.product_picture_url, p.description, p.created_at, p.created_by, p.updated_at, p.updated_by, p.deleted_at, p.deleted_by,
    ub.name AS user_name, ub.guid AS user_id
FROM
    product p
        LEFT JOIN user_backoffice ub ON ub.guid = p.created_by
WHERE
    (CASE WHEN @set_name::bool THEN LOWER(p.name) LIKE LOWER(@name) ELSE TRUE END)
  AND p.deleted_at IS NULL
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
    p.guid, p.name, p.product_picture_url, p.description, p.created_at, p.created_by, p.updated_at, p.updated_by, p.deleted_at, p.deleted_by,
    ub.name AS user_name, ub.guid AS user_id
FROM
    product p
        LEFT JOIN user_backoffice ub ON ub.guid = p.created_by
WHERE
    p.guid = @guid
  AND p.deleted_at IS NULL;


-- name: GetCountProductList :one
SELECT COUNT(p.id) FROM product p
WHERE
    (CASE WHEN @set_name::bool THEN LOWER(p.name) LIKE LOWER(@name) ELSE TRUE END)
    AND p.deleted_at IS NULL;