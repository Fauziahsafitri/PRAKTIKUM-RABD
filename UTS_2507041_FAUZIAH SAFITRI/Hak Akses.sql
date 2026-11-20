USE electromart;

CREATE ROLE IF NOT EXISTS 'role_admin'@'%';
CREATE ROLE IF NOT EXISTS 'role_penjualan'@'%';
CREATE ROLE IF NOT EXISTS 'role_gudang'@'%';
CREATE ROLE IF NOT EXISTS 'role_manajer'@'%';


GRANT ALL PRIVILEGES ON electromart.* TO 'role_admin'@'%';

GRANT SELECT ON electromart.produk TO 'role_penjualan'@'%';
GRANT SELECT ON electromart.pelanggan TO 'role_penjualan'@'%';
GRANT SELECT ON electromart.pegawai TO 'role_penjualan'@'%';
GRANT INSERT ON electromart.penjualan TO 'role_penjualan'@'%';
GRANT INSERT ON electromart.detail_penjualan TO 'role_penjualan'@'%';

GRANT SELECT ON electromart.produk TO 'role_gudang'@'%';
GRANT UPDATE (stok) ON electromart.produk TO 'role_gudang'@'%';

GRANT SELECT ON electromart.produk TO 'role_manajer'@'%';
GRANT SELECT ON electromart.penjualan TO 'role_manajer'@'%';
GRANT SELECT ON electromart.detail_penjualan TO 'role_manajer'@'%';
GRANT SELECT ON electromart.pelanggan TO 'role_manajer'@'%';


GRANT SELECT ON electromart.log_stok TO 'role_penjualan'@'%';

REVOKE SELECT ON electromart.log_stok FROM 'role_penjualan'@'%';


CREATE USER IF NOT EXISTS 'user_admin'@'localhost'
IDENTIFIED BY 'Admin123!';

CREATE USER IF NOT EXISTS 'user_penjualan'@'localhost'
IDENTIFIED BY 'Sales123!';

CREATE USER IF NOT EXISTS 'user_gudang'@'localhost'
IDENTIFIED BY 'Gudang123!';

CREATE USER IF NOT EXISTS 'user_manajer'@'localhost'
IDENTIFIED BY 'Manager123!';


GRANT 'role_admin'@'%' TO 'user_admin'@'localhost';
GRANT 'role_penjualan'@'%' TO 'user_penjualan'@'localhost';
GRANT 'role_gudang'@'%' TO 'user_gudang'@'localhost';
GRANT 'role_manajer'@'%' TO 'user_manajer'@'localhost';

SET DEFAULT ROLE 'role_admin'@'%' TO 'user_admin'@'localhost';
SET DEFAULT ROLE 'role_penjualan'@'%' TO 'user_penjualan'@'localhost';
SET DEFAULT ROLE 'role_gudang'@'%' TO 'user_gudang'@'localhost';
SET DEFAULT ROLE 'role_manajer'@'%' TO 'user_manajer'@'localhost';


SHOW GRANTS FOR 'role_admin'@'%';
SHOW GRANTS FOR 'role_penjualan'@'%';
SHOW GRANTS FOR 'role_gudang'@'%';
SHOW GRANTS FOR 'role_manajer'@'%';


SHOW GRANTS FOR 'user_admin'@'localhost';
SHOW GRANTS FOR 'user_penjualan'@'localhost';
SHOW GRANTS FOR 'user_gudang'@'localhost';
SHOW GRANTS FOR 'user_manajer'@'localhost';

GRANT SELECT
ON electromart.log_stok
TO 'role_penjualan'@'%';
