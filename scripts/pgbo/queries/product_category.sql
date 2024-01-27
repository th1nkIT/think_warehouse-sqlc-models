-- name: InsertProductCategory :one
INSERT INTO product_category
(guid, name, created_at, created_by)
VALUES
    (@guid, @name, (now() at time zone 'UTC')::TIMESTAMP, @created_by)
RETURNING product_category.*;

-- name: UpdateProductCategory :one
UPDATE product_category
SET
    name = @name,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP,
    updated_by = @updated_by
WHERE
    guid = @guid
  AND deleted_at IS NULL
RETURNING product_category.*;

-- name: ReactiveProductCategory :exec
UPDATE product_category
SET
    deleted_at = NULL,
    deleted_by = NULL,
    updated_at = (now() at time zone 'UTC')::TIMESTAMP,
    updated_by = @updated_by
WHERE
    guid = @guid
  AND deleted_at IS NOT NULL;

-- name: DeleteProductCategory :exec
UPDATE product_category
SET
    updated_at = (now() at time zone 'UTC')::TIMESTAMP,
    updated_by = @updated_by,
    deleted_at = (now() at time zone 'UTC')::TIMESTAMP,
    deleted_by = @deleted_by
WHERE
    guid = @guid
  AND deleted_at IS NULL;

-- name: ListProductCategory :many
SELECT
    pc.guid, pc.name, pc.created_at, pc.created_by,
    pc.updated_at, pc.updated_by, pc.deleted_at, pc.deleted_by,
    ub_created.name AS user_name, ub_created.guid AS user_id,
    ub_updated.name AS user_name_update, ub_updated.guid AS user_id_update,
    ub_deleted.name AS user_name_delete, ub_deleted.guid AS user_id_delete
FROM
    product_category pc
        LEFT JOIN user_backoffice ub_created ON ub_created.guid = pc.created_by
        LEFT JOIN user_backoffice ub_updated ON ub_updated.guid = pc.updated_by
        LEFT JOIN user_backoffice ub_deleted ON ub_deleted.guid = pc.deleted_by
WHERE
    (CASE WHEN @set_name::bool THEN LOWER(pc.name) LIKE LOWER (@name) ELSE TRUE END)
  AND (CASE WHEN @set_active::bool THEN
                (pc.deleted_at IS NULL AND @active = 'active') OR
                (pc.deleted_at IS NOT NULL AND @active = 'inactive')
            ELSE TRUE END)
ORDER BY (CASE WHEN @order_param = 'id ASC' THEN pc.guid END) ASC,
         (CASE WHEN @order_param = 'id DESC' THEN pc.guid END) DESC,
         (CASE WHEN @order_param = 'name ASC' THEN pc.name END) ASC,
         (CASE WHEN @order_param = 'name DESC' THEN pc.name END) DESC,
         (CASE WHEN @order_param = 'created_at ASC' THEN pc.created_at END) ASC,
         (CASE WHEN @order_param = 'created_at DESC' THEN pc.created_at END) DESC,
         pc.created_at DESC
LIMIT @limit_data
    OFFSET @offset_page;

-- name: GetProductCategory :one
SELECT
    pc.guid, pc.name, pc.created_at, pc.created_by,
    pc.updated_at, pc.updated_by, pc.deleted_at, pc.deleted_by,
    ub_created.name AS user_name, ub_created.guid AS user_id,
    ub_updated.name AS user_name_update, ub_updated.guid AS user_id_update,
    ub_deleted.name AS user_name_delete, ub_deleted.guid AS user_id_delete
FROM
    product_category pc
        LEFT JOIN user_backoffice ub_created ON ub_created.guid = pc.created_by
        LEFT JOIN user_backoffice ub_updated ON ub_updated.guid = pc.updated_by
        LEFT JOIN user_backoffice ub_deleted ON ub_deleted.guid = pc.deleted_by
WHERE
    pc.guid = @guid;

-- name: GetCountListProductCategory :one
SELECT
    count(pc.id) AS total_data
FROM
    product_category pc
WHERE
    (CASE WHEN @set_name::bool THEN LOWER(pc.name) LIKE LOWER (@name) ELSE TRUE END)
  AND (CASE WHEN @set_active::bool THEN
                (pc.deleted_at IS NULL AND @active = 'active') OR
                (pc.deleted_at IS NOT NULL AND @active = 'inactive')
            ELSE TRUE END)
  AND pc.deleted_at IS NULL;