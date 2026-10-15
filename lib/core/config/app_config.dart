/// Konfigurasi runtime aplikasi.
///
/// Nilai diisi lewat `--dart-define`, bukan hardcode. Contoh:
/// `flutter run -d chrome --dart-define=SUPABASE_URL=https://xyz.supabase.co
/// --dart-define=SUPABASE_PUBLISHABLE_KEY=...`
/// Backend: Supabase (tanpa login, anon key + RLS read-only).
class AppConfig {
  const AppConfig._();

  /// URL project Supabase (contoh: https://xyzcompany.supabase.co).
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://<ref>.supabase.co',
  );

  /// Publishable/anon key Supabase (boleh disematkan di app; RLS read-only).
  /// Terima kunci baru (`sb_publishable_...`) maupun anon key lama.
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'change-me-publishable-key',
    ),
  );

  /// Kunci tulis opsional untuk Edge Functions (header X-App-Key).
  /// Kosongkan bila APP_WRITE_KEY tidak diset di Supabase.
  static const String appWriteKey = String.fromEnvironment(
    'APP_WRITE_KEY',
    defaultValue: '',
  );

  /// Header tulis ke Edge Functions (kosong bila tanpa kunci).
  static Map<String, String> get functionHeaders =>
      appWriteKey.isEmpty ? const {} : {'X-App-Key': appWriteKey};

  /// Interval polling nilai live (detik). Tetap dipakai sebagai fallback
  /// bila Realtime terputus.
  static const int livePollIntervalSeconds = 10;

  /// Interval polling daftar event/notifikasi (detik).
  static const int eventsPollIntervalSeconds = 30;

  /// Interval polling status perintah pending→sent→acked (detik).
  static const int commandPollIntervalSeconds = 5;

  /// Batas waktu request HTTP.
  static const Duration requestTimeout = Duration(seconds: 10);
}
