
USE electromart;

DROP PROCEDURE IF EXISTS sp_tampil_produk;
DROP PROCEDURE IF EXISTS sp_tambah_produk;
DROP PROCEDURE IF EXISTS sp_ubah_produk;

DELIMITER $$

CREATE PROCEDURE sp_tampil_produk()
BEGIN
    SELECT
        id_produk,
        nama_produk,
        kategori,
        harga,
        stok
    FROM produk
    ORDER BY id_produk;
END$$

CREATE PROCEDURE sp_tambah_produk(
    IN p_id_produk VARCHAR(10),
    IN p_nama_produk VARCHAR(100),
    IN p_kategori VARCHAR(50),
    IN p_harga DECIMAL(12,2),
    IN p_stok INT
)
BEGIN
    INSERT INTO produk (
        id_produk,
        nama_produk,
        kategori,
        harga,
        stok
    )
    VALUES (
        p_id_produk,
        p_nama_produk,
        p_kategori,
        p_harga,
        p_stok
    );
END$$

CREATE PROCEDURE sp_ubah_produk(
    IN p_id_produk VARCHAR(10),
    IN p_nama_produk VARCHAR(100),
    IN p_kategori VARCHAR(50),
    IN p_harga DECIMAL(12,2),
    IN p_stok INT
)
BEGIN
    UPDATE produk
    SET
        nama_produk = p_nama_produk,
        kategori = p_kategori,
        harga = p_harga,
        stok = p_stok
    WHERE id_produk = p_id_produk;
END$$

DELIMITER ;

CALL sp_tampil_produk();

SHOW PROCEDURE STATUS
WHERE Db = 'electromart';

SHOW CREATE PROCEDURE sp_tampil_produk;

SHOW CREATE PROCEDURE sp_tambah_produk;

SHOW CREATE PROCEDURE sp_ubah_produk;

CALL sp_tambah_produk(
    'PRD011',
    'Laptop Acer Aspire 5',
    'Laptop',
    8500000,
    10
);

SELECT * FROM produk
WHERE id_produk = 'PRD011';

CALL sp_ubah_produk(
    'PRD011',
    'Laptop Acer Aspire 5 Updated',
    'Laptop',
    9000000,
    15
);

SELECT * FROM produk
WHERE id_produk = 'PRD011';

CALL sp_tampil_produk();
