import '../models/enums.dart';
import 'status_badge.dart';

StatusTone toneForDeviceStatus(DeviceStatus status) => switch (status) {
      DeviceStatus.idle => StatusTone.normal,
      DeviceStatus.heating => StatusTone.info,
      DeviceStatus.mature => StatusTone.warning,
      DeviceStatus.draining => StatusTone.info,
      DeviceStatus.error => StatusTone.danger,
    };

StatusTone toneForSeverity(EventSeverity severity) => switch (severity) {
      EventSeverity.info => StatusTone.info,
      EventSeverity.warning => StatusTone.warning,
      EventSeverity.critical => StatusTone.danger,
    };

StatusTone toneForCommandStatus(CommandStatus status) => switch (status) {
      CommandStatus.pending => StatusTone.warning,
      CommandStatus.sent => StatusTone.info,
      CommandStatus.acked => StatusTone.normal,
      CommandStatus.failed => StatusTone.danger,
      CommandStatus.expired => StatusTone.offline,
    };

StatusTone toneForTemp(double? temp, double min, double max) {
  if (temp == null) return StatusTone.offline;
  if (temp >= max) return StatusTone.danger;
  if (temp < min) return StatusTone.warning;
  return StatusTone.normal;
}

String tempStatusLabel(double? temp, double min, double max) {
  if (temp == null) return 'Tidak ada data';
  if (temp >= max) return 'Panas';
  if (temp < min) return 'Dingin';
  return 'Normal';
}
