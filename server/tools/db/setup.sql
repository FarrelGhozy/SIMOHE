-- ============================================================================
-- SIMOHE — Setup database & user di MySQL lokal (di host, bukan container).
-- Jalankan sebagai admin (root) DI KOMPUTER tempat MySQL terpasang:
--     sudo mysql < setup.sql
-- Password di bawah ('S1mohe!Local') dipakai untuk development/testing; samakan
-- dengan DATABASE_URL di server/.env. Ganti di produksi.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS simohe
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- User khusus aplikasi SIMOHE (JANGAN pakai root untuk aplikasi).
-- '%' berarti boleh dari host mana pun; batasi bila perlu, mis. 'simohe_app'@'192.168.1.%'.
CREATE USER IF NOT EXISTS 'simohe_app'@'%' IDENTIFIED BY 'S1mohe!Local';
ALTER USER 'simohe_app'@'%' IDENTIFIED BY 'S1mohe!Local';

-- Hak akses hanya pada DB simohe. Dibutuhkan untuk migrasi (DDL) + baca/tulis.
GRANT ALL PRIVILEGES ON simohe.* TO 'simohe_app'@'%';
FLUSH PRIVILEGES;

-- Verifikasi:
--   SHOW GRANTS FOR 'simohe_app'@'%';
-- Uji koneksi:
--   mysql -h 127.0.0.1 -P 3306 -u simohe_app -p'S1mohe!Local' simohe
