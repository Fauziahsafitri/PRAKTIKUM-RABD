USE electromart;

DELIMITER //

CREATE FUNCTION hitung_total(
    p_harga_satuan DECIMAL(12,2),
    p_jumlah INT
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    RETURN p_harga_satuan * p_jumlah;
END //

DELIMITER //

CREATE FUNCTION hitung_diskon(
    p_total DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_diskon DECIMAL(12,2);
    IF p_total >= 1000000 THEN
        SET v_diskon = p_total * 0.10;
    ELSE
        SET v_diskon = 0;
    END IF;
    RETURN v_diskon;
END //

DELIMITER //
CREATE TRIGGER validasi_penjualan
BEFORE INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    DECLARE v_stok_tersedia INT;
    DECLARE v_harga_asli DECIMAL(12,2);

    IF NEW.jumlah <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Jumlah pembelian harus lebih dari 0!';
    END IF;

    SELECT stok, harga INTO v_stok_tersedia, v_harga_asli
    FROM produk
    WHERE id_produk = NEW.id_produk;

    IF v_stok_tersedia IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Produk tidak terdaftar di sistem!';
    END IF;

    IF NEW.jumlah > v_stok_tersedia THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Stok produk tidak mencukupi untuk transaksi ini!';
    END IF;

    SET NEW.harga_satuan = v_harga_asli;

    SET NEW.subtotal = hitung_total(NEW.harga_satuan, NEW.jumlah);
END //

DELIMITER //

CREATE TRIGGER update_stok_penjualan
AFTER INSERT ON detail_penjualan
FOR EACH ROW
BEGIN
    DECLARE v_total_akumulasi DECIMAL(12,2);
    DECLARE v_diskon_baru DECIMAL(12,2);

    UPDATE produk
    SET stok = stok - NEW.jumlah
    WHERE id_produk = NEW.id_produk;

    INSERT INTO log_stok (id_produk, jumlah_perubahan, tipe_transaksi, keterangan)
    VALUES (
        NEW.id_produk,
        -NEW.jumlah,
        'KELUAR',
        CONCAT('Pengurangan stok otomatis dari ', NEW.id_penjualan)
    );

    SELECT SUM(subtotal) INTO v_total_akumulasi
    FROM detail_penjualan
    WHERE id_penjualan = NEW.id_penjualan;

    SET v_diskon_baru = hitung_diskon(v_total_akumulasi);

    UPDATE penjualan
    SET total_harga = v_total_akumulasi,
        diskon = v_diskon_baru,
        total_bayar = v_total_akumulasi - v_diskon_baru
    WHERE id_penjualan = NEW.id_penjualan;
END //

DELIMITER ;

INSERT INTO penjualan (id_penjualan, id_pelanggan, id_pegawai) VALUES ('TRX006', 'PLG001', 'PGW002');
INSERT INTO penjualan (id_penjualan, id_pelanggan, id_pegawai) VALUES ('TRX007', 'PLG002', 'PGW002');

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX006', 'PRD004', 1, 0, 0);

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX007', 'PRD008', 2, 0, 0);

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX006', 'PRD006', 5, 0, 0);

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX006', 'PRD002', 0, 0, 0);

INSERT INTO detail_penjualan (id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES ('TRX006', 'PRD999', 1, 0, 0);

SELECT * FROM penjualan WHERE id_penjualan IN ('TRX006', 'TRX007');
SELECT * FROM produk WHERE id_produk IN ('PRD004', 'PRD008');
SELECT * FROM log_stok ORDER BY id_log DESC LIMIT 5;

