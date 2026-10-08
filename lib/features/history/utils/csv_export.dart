import '../../../shared/models/reading.dart';
import 'csv_download.dart';

String buildReadingsCsv(List<ReadingPoint> points) {
  final buffer = StringBuffer('timestamp,temp_c,nh3_ppm,heater_on,valve_open\n');
  for (final point in points) {
    buffer.writeln(
      [
        point.ts?.toUtc().toIso8601String() ?? '',
        point.tempC ?? '',
        point.nh3Ppm ?? '',
        point.heaterOn,
        point.valveOpen,
      ].join(','),
    );
  }
  return buffer.toString();
}

void exportReadingsCsv(
  List<ReadingPoint> points, {
  String filename = 'simohe-history.csv',
}) {
  downloadCsv(filename, buildReadingsCsv(points));
}
