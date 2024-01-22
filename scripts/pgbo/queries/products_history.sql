-- name: InsertProductsHistory :one
INSERT INTO products_history
(guid, product_guid, quantity, warehouse_guid, tgl_masuk, pegawai_masuk, created_at, created_by)
VALUES
    (@guid, @product_guid, @quantity, @warehouse_guid, (now() at time zone 'UTC')::TIMESTAMP, @pegawai_masuk, (now() at time zone 'UTC')::TIMESTAMP, @created_by)
RETURNING products_history.*;

-- name: InsertKeluarProductsHistory :one
INSERT INTO products_history
        (tgl_keluar, pegawai_keluar, updated_at, updated_by)
    VALUES
        ((now() at time zone 'UTC')::TIMESTAMP, @pegawai_keluar, (now() at time zone 'UTC')::TIMESTAMP, @updated_by)
RETURNING products_history.*;

-- Belum ada update
-- -- name: UpdateWarehouse :one
-- UPDATE products_history
-- SET name = @new_name,
--     product_picture_url = @new_product_picture_url,
--     description = @new_description,
--     updated_by = @new_created_by,
--     updated_at = (now() at time zone 'UTC')::TIMESTAMP
-- WHERE guid = @guid
-- RETURNING product.*;

-- name: DeleteProductsHistory :exec
UPDATE products_history
SET
    deleted_at = (now() at time zone 'UTC')::TIMESTAMP,
    deleted_by = @deleted_by
WHERE
    guid = @guid
  AND deleted_at IS NULL;

-- name: ListWithFilterProductHistory :many
SELECT *
FROM products_history
WHERE
    (CASE WHEN @set_pegawai_masuk::bool THEN LOWER(pegawai_masuk) LIKE LOWER(@pegawai_masuk) ELSE TRUE END)
    AND(CASE WHEN @set_pegawai_keluar::bool THEN LOWER(pegawai_keluar) LIKE LOWER(@pegawai_keluar) ELSE TRUE END)
    AND deleted_at IS NULL
ORDER BY (CASE WHEN @order_param = 'id ASC' THEN guid END) ASC,
         (CASE WHEN @order_param = 'id DESC' THEN guid END) DESC,
         (CASE WHEN @order_param = 'product id ASC' THEN product_guid END) ASC,
         (CASE WHEN @order_param = 'product id DESC' THEN product_guid END) DESC,
         (CASE WHEN @order_param = 'quantity ASC' THEN quantity END) ASC,
         (CASE WHEN @order_param = 'quantity DESC' THEN quantity END) DESC,
         (CASE WHEN @order_param = 'warehouse id ASC' THEN warehouse_guid END) ASC,
         (CASE WHEN @order_param = 'warehouse id DESC' THEN warehouse_guid END) DESC,
         (CASE WHEN @order_param = 'tanggal masuk ASC' THEN tgl_masuk END) ASC,
         (CASE WHEN @order_param = 'tanggal masuk DESC' THEN tgl_masuk END) DESC,
         (CASE WHEN @order_param = 'pegawai masuk DESC' THEN pegawai_masuk END) DESC,
         (CASE WHEN @order_param = 'pegawai masuk ASC' THEN pegawai_masuk END) ASC,
         (CASE WHEN @order_param = 'tanggal keluar ASC' THEN tgl_keluar END) ASC,
         (CASE WHEN @order_param = 'tanggal keluar DESC' THEN tgl_keluar END) DESC,
         (CASE WHEN @order_param = 'pegawai keluar DESC' THEN pegawai_keluar END) DESC,
         (CASE WHEN @order_param = 'pegawai keluar ASC' THEN pegawai_keluar END) ASC,
         (CASE WHEN @order_param = 'created_at ASC' THEN created_at END) ASC,
         (CASE WHEN @order_param = 'created_at DESC' THEN created_at END) DESC,
         products_history.created_at DESC
LIMIT @limit_data
OFFSET @offset_page;

-- name: FindWithGUIDProductsHistory :many
SELECT *
FROM products_history
WHERE guid = @guid;