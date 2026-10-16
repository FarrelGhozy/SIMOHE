import 'package:flutter_test/flutter_test.dart';
import 'package:simohe/features/analysis/data/stability_calc.dart';

void main() {
  group('computeStability', () {
    test('gelombang pipih di nilai tinggi -> ok', () {
      final values = List<double?>.generate(
        20,
        (i) => 24.0 + (i.isEven ? 0.2 : -0.2),
      );
      final result = computeStability(
        values,
        rangeMaxPpm: 15,
        minSamples: 8,
        minMeanPpm: 1,
      );
      expect(result.status, StabilityStatus.ok);
      expect(result.percent, greaterThan(85));
    });

    test('gelombang liar -> % rendah, tetap ok', () {
      final values = List<double?>.generate(
        20,
        (i) => i.isEven ? 10.0 : 30.0,
      );
      final result = computeStability(
        values,
        rangeMaxPpm: 15,
        minSamples: 8,
        minMeanPpm: 1,
      );
      expect(result.status, StabilityStatus.ok);
      expect(result.percent, lessThan(50));
    });

    test('semua nol -> invalidNol (sensor mati), bukan 100%', () {
      final values = List<double?>.filled(20, 0);
      final result = computeStability(
        values,
        rangeMaxPpm: 15,
        minSamples: 8,
        minMeanPpm: 1,
      );
      expect(result.status, StabilityStatus.invalidNol);
      expect(result.percent, isNull);
    });

    test('banyak null -> dataKurang', () {
      final values = <double?>[
        for (var i = 0; i < 16; i++) null,
        for (var i = 0; i < 4; i++) 25.0,
      ];
      final result = computeStability(
        values,
        rangeMaxPpm: 15,
        minSamples: 8,
        minMeanPpm: 1,
      );
      expect(result.status, StabilityStatus.dataKurang);
    });

    test('titik kurang dari minimum -> dataKurang', () {
      final result = computeStability(
        [24.0, 24.1, 23.9],
        rangeMaxPpm: 15,
        minSamples: 8,
        minMeanPpm: 1,
      );
      expect(result.status, StabilityStatus.dataKurang);
    });

    test('nilai identik persis -> sensorMacet', () {
      final values = List<double?>.filled(20, 25.0);
      final result = computeStability(
        values,
        rangeMaxPpm: 15,
        minSamples: 8,
        minMeanPpm: 1,
      );
      expect(result.status, StabilityStatus.sensorMacet);
      expect(result.percent, isNull);
    });
  });
}
