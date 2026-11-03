
CREATE DATABASE praktikum_function_trigger;

# Memilih database yang akan digunakan
USE praktikum_function_trigger;

# Memastikan database aktif
SELECT DATABASE();

# 1. Membuat Tabel Produk
# Menyimpan data produk/barang
CREATE TABLE produk (

    # ID unik produk
    id_produk INT AUTO_INCREMENT PRIMARY KEY,
    # Nama produk
    nama_produk VARCHAR(100) NOT NULL,
    # Harga produk
    harga DECIMAL(12,2) NOT NULL,
    # Jumlah stok tersedia
    stok INT NOT NULL DEFAULT 0,
    # Harga harus positif
    CHECK (harga > 0),
    # Stok tidak boleh negatif
    CHECK (stok >= 0)
);

# Cek
DESC produk;


# 2. Membuat Tabel Penjualan
# Menyimpan data transaksi penjualan
CREATE TABLE penjualan (

    # ID transaksi
    id_penjualan INT AUTO_INCREMENT PRIMARY KEY,
    # Produk yang dijual
    id_produk INT NOT NULL,
    # Jumlah pembelian
    jumlah INT NOT NULL,
    # Harga per unit
    harga_satuan DECIMAL(12,2) NOT NULL,
    # Total transaksi
    total DECIMAL(14,2) NOT NULL DEFAULT 0,
    # Waktu transaksi otomatis
    tanggal_transaksi TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    # Relasi ke tabel produk
    CONSTRAINT fk_penjualan_produk
    FOREIGN KEY (id_produk)
    REFERENCES produk(id_produk),
    # Validasi jumlah harus lebih dari 0
    CHECK (jumlah > 0),
    # Validasi harga harus lebih dari 0
    CHECK (harga_satuan > 0),
    # Validasi total tidak boleh negatif
    CHECK (total >= 0)
);



# 3. Membuat Tabel Log Stok
# Menyimpan riwayat perubahan stok
CREATE TABLE log_stok (
    # ID log
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    # ID produk yang berubah
    id_produk INT NOT NULL,
    # Stok sebelum perubahan
    stok_awal INT NOT NULL,
    # Stok setelah perubahan
    stok_akhir INT NOT NULL,
    # Keterangan perubahan
    keterangan VARCHAR(100) NOT NULL,
    # Waktu perubahan
    waktu_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



# 4. Memasukkan Data Awal
# Menambahkan data awal
INSERT INTO produk
(nama_produk, harga, stok)
VALUES
('Laptop', 7500000, 10),
('Mouse', 150000, 25),
('Keyboard', 350000, 15),
('Monitor', 1800000, 8);


# Verifikasi
# Menampilkan seluruh produk
SELECT * FROM produk;

DELIMITER //
CREATE FUNCTION hitung_total(
    p_harga DECIMAL(12,2),
    p_jumlah INT
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_harga * p_jumlah;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION hitung_diskon(
    p_total DECIMAL(14,2)
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    IF p_total >= 1000000 THEN
        RETURN p_total * 0.10;
    ELSE
        RETURN 0;
    END IF;
END //

DELIMITER ;

SELECT
    1500000 AS total_transaksi,
    hitung_diskon(1500000) AS diskon,
    1500000 - hitung_diskon(1500000) AS total_bayar;


SELECT
    hitung_total(350000, 4) AS total_transaksi,
    hitung_diskon(hitung_total(350000, 4)) AS diskon,
    hitung_total(350000, 4)
      - hitung_diskon(hitung_total(350000, 4))
      AS total_bayar;

DELIMITER //
CREATE TRIGGER validasi_penjualan
BEFORE INSERT ON penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok INT DEFAULT NULL;
    DECLARE v_ada INT DEFAULT 0;

    IF NEW.jumlah <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Jumlah pembelian harus lebih dari nol';
    END IF;

    IF NEW.harga_satuan <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Harga satuan harus lebih dari nol';
    END IF;

    SELECT COUNT(*)
    INTO v_ada
    FROM produk
    WHERE id_produk = NEW.id_produk;

    IF v_ada = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Produk tidak ditemukan';
    END IF;

    SELECT stok
    INTO v_stok
    FROM produk
    WHERE id_produk = NEW.id_produk
    FOR UPDATE;

    IF NEW.jumlah > v_stok THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'Stok produk tidak mencukupi';
    END IF;
    SET NEW.total =
        hitung_total(NEW.harga_satuan, NEW.jumlah);
END //
DELIMITER ;

DELIMITER //

CREATE TRIGGER update_stok_penjualan
AFTER INSERT ON penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok_awal INT;
    DECLARE v_stok_akhir INT;

    SELECT stok
    INTO v_stok_awal
    FROM produk
    WHERE id_produk = NEW.id_produk;

    SET v_stok_akhir = v_stok_awal - NEW.jumlah;

    UPDATE produk
    SET stok = v_stok_akhir
    WHERE id_produk = NEW.id_produk;

    INSERT INTO log_stok (
        id_produk,
        stok_awal,
        stok_akhir,
        keterangan
    )
    VALUES (
        NEW.id_produk,
        v_stok_awal,
        v_stok_akhir,
        'Pengurangan stok karena penjualan'
    );
END //

DELIMITER ;

INSERT INTO penjualan (
    id_produk,
    jumlah,
    harga_satuan,
    total
)
VALUES (2, 2, 150000, 0);

SELECT * FROM penjualan;

SELECT nama_produk, stok
FROM produk
WHERE id_produk = 2;

SELECT * FROM log_stok;

INSERT INTO penjualan (
    id_produk,
    jumlah,
    harga_satuan,
    total
)
VALUES (2, 100, 150000, 0);

SHOW FUNCTION STATUS
WHERE Db = 'praktikum_function_trigger';

SHOW TRIGGERS
FROM praktikum_function_trigger;

SELECT hitung_total(250000, 4) AS total_transaksi;

SELECT
    800000 AS total_transaksi,
    hitung_diskon(800000) AS diskon,
    800000 - hitung_diskon(800000) AS total_bayar

UNION ALL

SELECT
    1500000,
    hitung_diskon(1500000),
    1500000 - hitung_diskon(1500000);

INSERT INTO penjualan (id_produk, jumlah, harga_satuan, total)
VALUES (2, 1, 150000, 0);

INSERT INTO penjualan (id_produk, jumlah, harga_satuan, total)
VALUES (2, 100, 150000, 0);

SELECT * FROM penjualan;

SELECT nama_produk, stok
FROM produk
WHERE id_produk = 2;

INSERT INTO penjualan (id_produk, jumlah, harga_satuan, total)
VALUES (3, 3, 350000, 0);

SELECT nama_produk, stok
FROM produk
WHERE id_produk = 3;

SELECT *
FROM log_stok
WHERE id_produk = 3;

SELECT nama_produk, stok AS stok_sebelum
FROM produk
WHERE id_produk = 1;

INSERT INTO penjualan (id_produk, jumlah, harga_satuan, total)
VALUES (1, 2, 7500000, 0);

SELECT
    hitung_total(7500000, 2) AS total_transaksi,
    hitung_diskon(hitung_total(7500000, 2)) AS diskon,
    hitung_total(7500000, 2)
      - hitung_diskon(hitung_total(7500000, 2))
      AS total_bayar;

SELECT nama_produk, stok AS stok_sesudah
FROM produk
WHERE id_produk = 1;

SELECT *
FROM log_stok
WHERE id_produk = 1;

SELECT * FROM produk;
SELECT * FROM penjualan;
SELECT * FROM log_stok;


Tugas mandiri
USE praktikum_function_trigger;

DROP FUNCTION IF EXISTS hitung_pajak;

DELIMITER //

CREATE FUNCTION hitung_pajak(
    p_total DECIMAL(14,2)
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_total * 0.11;
END //

DELIMITER ;

SELECT
    hitung_pajak(2000000) AS pajak_transaksi_1,
    hitung_pajak(5000000) AS pajak_transaksi_2;


DROP FUNCTION IF EXISTS hitung_total_akhir;

DELIMITER //

CREATE FUNCTION hitung_total_akhir(
    p_total DECIMAL(14,2),
    p_diskon DECIMAL(5,2)
)
RETURNS DECIMAL(14,2)
DETERMINISTIC
NO SQL
BEGIN
    RETURN p_total - (p_total * p_diskon / 100);
END //

DELIMITER ;

SELECT hitung_total_akhir(3000000, 15) AS total_akhir;

DROP TRIGGER IF EXISTS catat_perubahan_stok;

DELIMITER //

CREATE TRIGGER catat_perubahan_stok
AFTER UPDATE ON produk
FOR EACH ROW
BEGIN
    IF OLD.stok <> NEW.stok THEN
        INSERT INTO log_stok (
            id_produk,
            stok_awal,
            stok_akhir,
            keterangan
        )
        VALUES (
            NEW.id_produk,
            OLD.stok,
            NEW.stok,
            'Perubahan stok produk'
        );
    END IF;
END //

DELIMITER ;

SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk = 2;

UPDATE produk
SET stok = 25
WHERE id_produk = 2;

UPDATE produk
SET stok = 30
WHERE id_produk = 2;

SELECT id_produk, nama_produk, stok
FROM produk
WHERE id_produk = 2;

SELECT nama_produk, stok
FROM produk
WHERE id_produk = 2;

SELECT *
FROM log_stok
WHERE id_produk = 2
ORDER BY id_log DESC;

4. DROP TRIGGER IF EXISTS validasi_harga_produk;

DELIMITER //

CREATE TRIGGER validasi_harga_produk
BEFORE UPDATE ON produk
FOR EACH ROW
BEGIN
    IF NEW.harga <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Harga produk harus lebih dari nol';
    END IF;
END //

DELIMITER ;

UPDATE produk
SET harga = 200000
WHERE id_produk = 2;

UPDATE produk
SET harga = 0
WHERE id_produk = 2;

SELECT nama_produk, harga
FROM produk
WHERE id_produk = 2;