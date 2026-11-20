USE electromart;

START TRANSACTION;

INSERT INTO penjualan
(id_penjualan, id_pelanggan, id_pegawai, total_harga, diskon, total_bayar)
VALUES
('TRX005', 'PLG005', 'PGW002', 15000000, 1500000, 13500000);

INSERT INTO detail_penjualan
(id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES
('TRX005', 'PRD001', 1, 14500000, 14500000);


INSERT INTO detail_penjualan
(id_penjualan, id_produk, jumlah, harga_satuan, subtotal)
VALUES
('TRX005', 'PRD002', 2, 250000, 500000);


UPDATE produk
SET stok = stok - 1
WHERE id_produk = 'PRD001';

UPDATE produk
SET stok = stok - 2
WHERE id_produk = 'PRD002';

COMMIT;

SELECT * FROM penjualan
WHERE id_penjualan = 'TRX005';

SELECT * FROM detail_penjualan
WHERE id_penjualan = 'TRX005';

SELECT * FROM produk
WHERE id_produk IN ('PRD001', 'PRD002');

USE electromart;

USE electromart;

SELECT * FROM produk WHERE id_produk = 'PRD006';

SELECT id_pelanggan FROM pelanggan LIMIT 1;

SELECT id_pegawai FROM pegawai LIMIT 1;