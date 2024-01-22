-- name: InsertProduct :one
INSERT INTO product 
        (guid, name, product_picture_url, description, created_at, created_by)
    VALUES
        (@guid, @name, @product_picture_url, @description, (now() at time zone 'UTC')::TIMESTAMP, @created_by)
RETURNING product.*;

-- name: UpdateProduct :one
UPDATE product 
SET name = @new_name, 
    product_picture_url = @new_product_picture_url, 
    description = @new_description, 
    updated_by = @new_created_by, 
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

-- name: ListWithFilter :many
SELECT *
FROM product
WHERE
    (CASE WHEN @set_name::bool THEN LOWER(name) LIKE LOWER(@name) ELSE TRUE END)
    AND(CASE WHEN @set_description::bool THEN LOWER(description) LIKE LOWER(@description) ELSE TRUE END)
    AND deleted_at IS NULL
ORDER BY (CASE WHEN @order_param = 'id ASC' THEN guid END) ASC,
         (CASE WHEN @order_param = 'id DESC' THEN guid END) DESC,
         (CASE WHEN @order_param = 'name ASC' THEN name END) ASC,
         (CASE WHEN @order_param = 'name DESC' THEN name END) DESC,
         (CASE WHEN @order_param = 'role_id ASC' THEN description END) ASC,
         (CASE WHEN @order_param = 'role_id DESC' THEN description END) DESC,
         (CASE WHEN @order_param = 'created_at ASC' THEN created_at END) ASC,
         (CASE WHEN @order_param = 'created_at DESC' THEN created_at END) DESC,
         product.created_at DESC
LIMIT @limit_data
OFFSET @offset_page;

-- name: FindWithGUID :many
SELECT *
FROM product
WHERE guid = @guid;