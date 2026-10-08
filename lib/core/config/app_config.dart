/// Konfigurasi runtime aplikasi.
///
/// Nilai diisi lewat `--dart-define`, bukan hardcode. Contoh:
/// `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
/// --dart-define=APP_TOKEN=change-me-app-token`
class AppConfig {
  const AppConfig._();

  /// Base URL server Elysia (contoh: http://192.168.1.10:3000).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Token aplikasi (single user) untuk header `Authorization: Bearer`.
  static const String appToken = String.fromEnvironment(
    'APP_TOKEN',
    defaultValue: 'change-me-app-token',
  );

  /// Interval polling nilai live dari server (detik).
  static const int livePollIntervalSeconds = 10;

  /// Interval polling daftar event/notifikasi (detik).
  static const int eventsPollIntervalSeconds = 30;

  /// Interval polling status perintah pending→sent→acked (detik).
  static const int commandPollIntervalSeconds = 5;

  /// Batas waktu request HTTP.
  static const Duration requestTimeout = Duration(seconds: 10);
}
