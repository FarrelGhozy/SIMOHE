import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static const String _locale = 'id_ID';

  static Future<void> initialize() async {
    Intl.defaultLocale = _locale;
    await initializeDateFormatting(_locale);
  }

  static final DateFormat _dateTime =
      DateFormat('d MMM yyyy, HH:mm', _locale);
  static final DateFormat _date = DateFormat('d MMM yyyy', _locale);
  static final DateFormat _time = DateFormat('HH:mm:ss', _locale);

  static String dateTime(DateTime? value) =>
      value == null ? '-' : _dateTime.format(value.toLocal());

  static String date(DateTime? value) =>
      value == null ? '-' : _date.format(value.toLocal());

  static String time(DateTime? value) =>
      value == null ? '-' : _time.format(value.toLocal());

  static String number(num? value, {int digits = 1}) =>
      value == null ? '-' : value.toStringAsFixed(digits);

  static String percent(double? value) =>
      value == null ? '-' : '${(value * 100).toStringAsFixed(0)}%';

  static String relative(DateTime? value, {DateTime? now}) {
    if (value == null) return '-';
    final reference = now ?? DateTime.now();
    final diff = reference.difference(value.toLocal());
    if (diff.inSeconds < 60) return '${diff.inSeconds} detik lalu';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}
