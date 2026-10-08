import 'package:flutter_test/flutter_test.dart';

import 'package:simohe/features/history/utils/csv_export.dart';
import 'package:simohe/shared/models/reading.dart';

void main() {
  test('membangun CSV dengan header dan baris data', () {
    final points = [
      ReadingPoint(
        ts: DateTime.utc(2026, 10, 8, 9, 45),
        tempC: 31,
        nh3Ppm: 17.8,
        heaterOn: true,
        valveOpen: false,
      ),
      ReadingPoint(
        ts: DateTime.utc(2026, 10, 8, 10, 0),
        heaterOn: false,
        valveOpen: true,
      ),
    ];

    final csv = buildReadingsCsv(points);
    final lines = csv.trim().split('\n');

    expect(lines.first, 'timestamp,temp_c,nh3_ppm,heater_on,valve_open');
    expect(lines[1], '2026-10-08T09:45:00.000Z,31.0,17.8,true,false');
    expect(lines[2], '2026-10-08T10:00:00.000Z,,,false,true');
  });
}
