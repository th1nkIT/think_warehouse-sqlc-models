-- name: InsertWarehouse :one
INSERT INTO warehouse 
        (guid, warehouse_code, name, address, phone_number, created_at, created_by)
    VALUES
        (@guid, @warehouse_code,@name, @address, @phone_number, (now() at time zone 'UTC')::TIMESTAMP, @created_by)
RETURNING warehouse.*;

-- name: UpdateWarehouse :one
UPDATE warehouse 
SET name = @name,
    address = @address,
    phone_number = @phone_number,
    updated_by = @updated_by,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP 
WHERE guid = @guid
RETURNING warehouse.*;

-- name: DeleteWarehouse :exec
UPDATE warehouse
SET
    deleted_at = (now() at time zone 'UTC')::TIMESTAMP,
    deleted_by = @deleted_by
WHERE
    guid = @guid
  AND deleted_at IS NULL;

-- name: ReactiveWarehouse :exec
UPDATE warehouse
SET
    deleted_at = NULL,
    deleted_by = NULL,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP,
    updated_by = @updated_by
WHERE
    guid = @guid
  AND deleted_at IS NOT NULL;

-- name: ListWarehouse :many
SELECT w.guid, w.name, w.address, w.phone_number, w.warehouse_code, w.created_at,
       w.created_by, w.updated_at, w.updated_by, w.deleted_at, w.deleted_by,
       ub_created.name AS user_name, ub_created.guid AS user_id,
       ub_updated.name AS user_name_update, ub_updated.guid AS user_id_update
FROM
    warehouse w
        LEFT JOIN user_backoffice ub_created ON ub_created.guid = w.created_by
        LEFT JOIN user_backoffice ub_updated ON ub_updated.guid = w.updated_by
WHERE
    (CASE WHEN @set_name::bool THEN LOWER(w.name) LIKE LOWER(@name) ELSE TRUE END)
  AND (CASE WHEN @set_warehouse_code::bool THEN LOWER(w.warehouse_code) LIKE LOWER(@warehouse_code) ELSE TRUE END)
  AND (CASE WHEN @set_active::bool THEN
                (w.deleted_at IS NULL AND @active = 'active') OR
                (w.deleted_at IS NOT NULL AND @active = 'inactive')
            ELSE TRUE END)
ORDER BY (CASE WHEN @order_param = 'id ASC' THEN w.guid END) ASC,
         (CASE WHEN @order_param = 'id DESC' THEN w.guid END) DESC,
         (CASE WHEN @order_param = 'name ASC' THEN w.name END) ASC,
         (CASE WHEN @order_param = 'name DESC' THEN w.name END) DESC,
         (CASE WHEN @order_param = 'created_at ASC' THEN w.created_at END) ASC,
         (CASE WHEN @order_param = 'created_at DESC' THEN w.created_at END) DESC,
         w.created_at DESC
    LIMIT @limit_data
OFFSET @offset_page;


-- name: GetWarehouse :one
SELECT
    w.guid, w.name, w.address, w.phone_number, w.warehouse_code, w.created_at,
       w.created_by, w.updated_at, w.updated_by, w.deleted_at, w.deleted_by,
    ub_created.name AS user_name, ub_created.guid AS user_id,
    ub_updated.name AS user_name_update, ub_updated.guid AS user_id_update
FROM
    warehouse w
        LEFT JOIN user_backoffice ub_created ON ub_created.guid = w.created_by
        LEFT JOIN user_backoffice ub_updated ON ub_updated.guid = w.updated_by
WHERE
    w.guid = @guid;

-- name: GetWarehouseByWarehouseCode :one
SELECT
    w.guid, w.name, w.address, w.phone_number, w.warehouse_code, w.created_at,
    w.created_by, w.updated_at, w.updated_by, w.deleted_at, w.deleted_by,
    ub_created.name AS user_name, ub_created.guid AS user_id,
    ub_updated.name AS user_name_update, ub_updated.guid AS user_id_update
FROM
    warehouse w
        LEFT JOIN user_backoffice ub_created ON ub_created.guid = w.created_by
        LEFT JOIN user_backoffice ub_updated ON ub_updated.guid = w.updated_by

WHERE
    w.warehouse_code = @warehouse_code;

-- name: GetCountWarehouse :one
SELECT COUNT(w.id) FROM warehouse w
WHERE
    (CASE WHEN @set_name::bool THEN LOWER(w.name) LIKE LOWER(@name) ELSE TRUE END);