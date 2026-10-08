/// Konfigurasi runtime aplikasi.
///
/// Nilai aktual nantinya diisi lewat `--dart-define` atau file environment,
/// bukan hardcode. Placeholder ini sengaja dikosongkan agar fondasi tetap bersih.
class AppConfig {
  const AppConfig._();

  /// Base URL server Elysia (contoh: http://192.168.1.10:3000).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Interval polling nilai live dari server (detik).
  static const int livePollIntervalSeconds = 10;
}
