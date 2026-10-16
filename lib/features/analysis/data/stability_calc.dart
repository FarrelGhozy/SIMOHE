import 'dart:math';

/// Status hasil analisis stabilitas NH3.
///
/// `ok` berarti angka % valid. Status lain berarti TIDAK BOLEH memicu
/// notifikasi matang (fail-safe): data kurang, sensor error/nol/macat.
enum StabilityStatus {
  /// Persentase valid, boleh dibandingkan ke ambang matang.
  ok,

  /// Titik valid kurang dari `minSamples` / rasio null tinggi / gap besar.
  dataKurang,

  /// Rata-rata di lantai sensor (`<= minMeanPpm`) atau semua nol —
  /// indikasi sensor mati / belum preheat / kabel putus.
  invalidNol,

  /// Seluruh titik identik persis (std == 0 && range == 0) —
  /// sensor nyata selalu ber-noise kecil, jadi ini ADC macet.
  sensorMacet,
}

/// Hasil perhitungan stabilitas gelombang NH3 ("tabung makin pipih =
/// makin stabil") tanpa ML, full di HP.
class StabilityResult {
  const StabilityResult({
    required this.status,
    required this.total,
    required this.valid,
    this.percent,
    this.mean,
    this.min,
    this.max,
    this.range,
    this.std,
  });

  final StabilityStatus status;

  /// Jumlah titik di window (termasuk null).
  final int total;

  /// Jumlah titik valid (non-null).
  final int valid;

  /// 0..100, hanya terisi bila [status] == [StabilityStatus.ok].
  final double? percent;
  final double? mean;
  final double? min;
  final double? max;

  /// Lebar "tabung" (max - min).
  final double? range;
  final double? std;
}

/// Menghitung % stabilitas dari deret NH3 dalam satu window.
///
/// - [values]: NH3 per titik (null = tidak terbaca), urutan waktu naik.
/// - [rangeMaxPpm]: lebar tabung yang dianggap 0% stabil (toleransi).
/// - [minSamples]: minimal titik valid agar boleh dinilai.
/// - [minMeanPpm]: lantai sensor; rata-rata di bawah ini = sensor mati.
/// - [maxNullRatio]: rasio null maksimum yang ditoleransi.
///
/// Rumus: `0.65 * skorRange + 0.35 * skorStd`, dengan
/// `skorRange = 100 * (1 - range/rangeMax)` dan
/// `skorStd = 100 / (1 + (std/tolStd)^2)`, `tolStd = rangeMax/3`.
/// Tidak memakai tinggi-rendah absolut — hanya bentuk gelombang.
StabilityResult computeStability(
  List<double?> values, {
  required double rangeMaxPpm,
  required int minSamples,
  required double minMeanPpm,
  double maxNullRatio = 0.3,
}) {
  final total = values.length;
  final valids = values.whereType<double>().toList();

  if (total == 0 || valids.length < minSamples) {
    return StabilityResult(
      status: StabilityStatus.dataKurang,
      total: total,
      valid: valids.length,
    );
  }
  if ((total - valids.length) / total > maxNullRatio) {
    return StabilityResult(
      status: StabilityStatus.dataKurang,
      total: total,
      valid: valids.length,
    );
  }

  var sum = 0.0;
  var minV = valids.first;
  var maxV = valids.first;
  for (final v in valids) {
    sum += v;
    if (v < minV) minV = v;
    if (v > maxV) maxV = v;
  }
  final mean = sum / valids.length;
  final range = maxV - minV;

  var sq = 0.0;
  for (final v in valids) {
    sq += (v - mean) * (v - mean);
  }
  final std = sqrt(sq / valids.length);

  if (mean <= minMeanPpm || maxV <= 0) {
    return StabilityResult(
      status: StabilityStatus.invalidNol,
      total: total,
      valid: valids.length,
      mean: mean,
      min: minV,
      max: maxV,
      range: range,
      std: std,
    );
  }
  if (range == 0 && std == 0) {
    return StabilityResult(
      status: StabilityStatus.sensorMacet,
      total: total,
      valid: valids.length,
      mean: mean,
      min: minV,
      max: maxV,
      range: range,
      std: std,
    );
  }

  final rangeMax = rangeMaxPpm <= 0 ? 1.0 : rangeMaxPpm;
  final scoreRange = 100 * (1 - (range / rangeMax).clamp(0.0, 1.0));
  final tolStd = rangeMax / 3;
  final scoreStd = 100 / (1 + pow(std / tolStd, 2));

  return StabilityResult(
    status: StabilityStatus.ok,
    total: total,
    valid: valids.length,
    percent: (0.65 * scoreRange + 0.35 * scoreStd).clamp(0.0, 100.0),
    mean: mean,
    min: minV,
    max: maxV,
    range: range,
    std: std,
  );
}
