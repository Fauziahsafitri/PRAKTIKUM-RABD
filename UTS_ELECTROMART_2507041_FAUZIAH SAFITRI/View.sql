USE electromart;

CREATE OR REPLACE VIEW View_Produk AS
SELECT
    id_produk,
    nama_produk,
    kategori,
    harga
FROM produk;

CREATE OR REPLACE VIEW View_Transaksi AS
SELECT
    p.id_penjualan,
    p.tanggal,
    pl.nama_pelanggan,
    pg.nama_pegawai AS kasir,
    p.total_harga,
    p.diskon,
    p.total_bayar
FROM penjualan p
JOIN pelanggan pl ON p.id_pelanggan = pl.id_pelanggan
JOIN pegawai pg ON p.id_pegawai = pg.id_pegawai;

CREATE OR REPLACE VIEW View_Laporan_Penjualan AS
SELECT
    pr.kategori,
    COUNT(DISTINCT dp.id_penjualan) AS jumlah_transaksi,
    SUM(dp.jumlah) AS total_unit_terjual,
    SUM(dp.subtotal) AS total_pendapatan_kotor
FROM detail_penjualan dp
JOIN produk pr ON dp.id_produk = pr.id_produk
GROUP BY pr.kategori;

CREATE OR REPLACE VIEW View_Stok_Rendah AS
SELECT
    id_produk,
    nama_produk,
    kategori,
    harga,
    stok
FROM produk
WHERE stok <= 5
WITH CHECK OPTION;

SELECT * FROM View_Produk;
SELECT * FROM View_Transaksi;
SELECT * FROM View_Laporan_Penjualan;
SELECT * FROM View_Stok_Rendah;

UPDATE View_Stok_Rendah
SET stok = 4
WHERE id_produk = 'PRD006';

UPDATE View_Stok_Rendah
SET stok = 20
WHERE id_produk = 'PRD006';

DROP VIEW IF EXISTS View_Produk;

SHOW FULL TABLES WHERE Table_type = 'VIEW';