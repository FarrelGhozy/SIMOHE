-- ============================================================================
-- SIMOHE — Setup database di MySQL terpusat (dipakai bersama aplikasi lain).
-- Jalankan sebagai admin (root) DI KOMPUTER SERVER MySQL:
--     mysql -u root -p < central-setup.sql
-- Ganti 'GANTI-PASSWORD-KUAT' di bawah sebelum menjalankan.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS simohe
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- User khusus aplikasi SIMOHE (JANGAN pakai root untuk aplikasi).
-- '%' berarti boleh dari host mana pun; batasi bila perlu, mis. 'simohe_app'@'192.168.1.%'.
CREATE USER IF NOT EXISTS 'simohe_app'@'%' IDENTIFIED BY 'GANTI-PASSWORD-KUAT';
ALTER USER 'simohe_app'@'%' IDENTIFIED BY 'GANTI-PASSWORD-KUAT';

-- Hak akses hanya pada DB simohe. Dibutuhkan untuk migrasi (DDL) + baca/tulis.
GRANT ALL PRIVILEGES ON simohe.* TO 'simohe_app'@'%';
FLUSH PRIVILEGES;

-- Verifikasi:
--   SHOW GRANTS FOR 'simohe_app'@'%';
-- Uji koneksi dari komputer aplikasi:
--   mysql -h <IP-SERVER-MYSQL> -P 3306 -u simohe_app -p simohe
