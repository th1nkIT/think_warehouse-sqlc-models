-- name: InsertWarehouse :one
INSERT INTO warehouse 
        (guid, name, address, phone_number, is_active, created_at, created_by)
    VALUES
        (@guid, @name, @phone_number, @is_active, (now() at time zone 'UTC')::TIMESTAMP, @created_by)
RETURNING product.*;

-- name: UpdateWarehouse :one
UPDATE warehouse 
SET name = @new_name, 
    address = @address, 
    phone_number = @phone_number,
    is_active = @is_active, 
    updated_by = @new_created_by,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP 
WHERE guid = @guid;

-- name: DeleteWarehouse :one
UPDATE warehouse
SET deleted_at = (now() at time zone 'UTC')::TIMESTAMP,
    deleted_by = @new_deleted_by
WHERE guid = @guid;

-- name: ListWithFilterWarehouse :many
SELECT *
FROM warehouse
WHERE
    (CASE WHEN @set_name::bool THEN LOWER(name) LIKE LOWER(@name) ELSE TRUE END)
    AND(CASE WHEN @set_address::bool THEN LOWER(address) LIKE LOWER(@address) ELSE TRUE END)
    AND(CASE WHEN @set_phone_number::bool THEN LOWER(phone_number) LIKE LOWER(@phone_number) ELSE TRUE END)
    AND deleted_at IS NULL
ORDER BY (CASE WHEN @order_param = 'id ASC' THEN guid END) ASC,
         (CASE WHEN @order_param = 'id DESC' THEN guid END) DESC,
         (CASE WHEN @order_param = 'name ASC' THEN name END) ASC,
         (CASE WHEN @order_param = 'name DESC' THEN name END) DESC,
         (CASE WHEN @order_param = 'address ASC' THEN address END) ASC,
         (CASE WHEN @order_param = 'address DESC' THEN address END) DESC,
         (CASE WHEN @order_param = 'phone_number ASC' THEN phone_number END) ASC,
         (CASE WHEN @order_param = 'phone_number DESC' THEN phone_number END) DESC,
         (CASE WHEN @order_param = 'is_active ASC' THEN is_active END) ASC,
         (CASE WHEN @order_param = 'is_active DESC' THEN is_active END) DESC,
         (CASE WHEN @order_param = 'created_at ASC' THEN created_at END) ASC,
         (CASE WHEN @order_param = 'created_at DESC' THEN created_at END) DESC,
         warehouse.created_at DESC
LIMIT @limit_data
OFFSET @offset_page;

-- name: FindWithGUIDWarehouse :many
SELECT *
FROM warehouse
WHERE guid = @guid;