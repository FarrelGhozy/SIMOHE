import 'package:json_annotation/json_annotation.dart';

enum HeaterMode {
  @JsonValue('AUTO')
  auto,
  @JsonValue('FORCE_ON')
  forceOn,
  @JsonValue('FORCE_OFF')
  forceOff,
}

enum DeviceStatus {
  @JsonValue('idle')
  idle,
  @JsonValue('heating')
  heating,
  @JsonValue('mature')
  mature,
  @JsonValue('draining')
  draining,
  @JsonValue('error')
  error,
}

enum CommandAction {
  @JsonValue('valve_open')
  valveOpen,
  @JsonValue('valve_close')
  valveClose,
  @JsonValue('heater_on')
  heaterOn,
  @JsonValue('heater_off')
  heaterOff,
  @JsonValue('heater_auto')
  heaterAuto,
}

enum CommandStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('sent')
  sent,
  @JsonValue('acked')
  acked,
  @JsonValue('failed')
  failed,
  @JsonValue('expired')
  expired,
}

enum EventType {
  @JsonValue('mature')
  mature,
  @JsonValue('temp_low')
  tempLow,
  @JsonValue('temp_high')
  tempHigh,
  @JsonValue('heater_on')
  heaterOn,
  @JsonValue('heater_off')
  heaterOff,
  @JsonValue('valve_open')
  valveOpen,
  @JsonValue('valve_close')
  valveClose,
  @JsonValue('device_offline')
  deviceOffline,
  @JsonValue('device_online')
  deviceOnline,
  @JsonValue('safety_cutoff')
  safetyCutoff,
}

enum EventSeverity {
  @JsonValue('info')
  info,
  @JsonValue('warning')
  warning,
  @JsonValue('critical')
  critical,
}

enum BatchStatus {
  @JsonValue('fermenting')
  fermenting,
  @JsonValue('mature')
  mature,
  @JsonValue('harvested')
  harvested,
}

enum ReadingBucket {
  @JsonValue('raw')
  raw,
  @JsonValue('15m')
  m15,
  @JsonValue('1h')
  h1,
}

extension HeaterModeLabel on HeaterMode {
  String get label => switch (this) {
        HeaterMode.auto => 'AUTO',
        HeaterMode.forceOn => 'FORCE ON',
        HeaterMode.forceOff => 'FORCE OFF',
      };
}

extension DeviceStatusLabel on DeviceStatus {
  String get label => switch (this) {
        DeviceStatus.idle => 'Idle',
        DeviceStatus.heating => 'Memanaskan',
        DeviceStatus.mature => 'Matang',
        DeviceStatus.draining => 'Pengurasan',
        DeviceStatus.error => 'Error',
      };
}

extension CommandActionLabel on CommandAction {
  String get label => switch (this) {
        CommandAction.valveOpen => 'Buka katup',
        CommandAction.valveClose => 'Tutup katup',
        CommandAction.heaterOn => 'Heater ON',
        CommandAction.heaterOff => 'Heater OFF',
        CommandAction.heaterAuto => 'Heater AUTO',
      };
}

extension CommandStatusLabel on CommandStatus {
  String get label => switch (this) {
        CommandStatus.pending => 'Menunggu',
        CommandStatus.sent => 'Terkirim',
        CommandStatus.acked => 'Dieksekusi',
        CommandStatus.failed => 'Gagal',
        CommandStatus.expired => 'Kedaluwarsa',
      };
}

extension EventTypeLabel on EventType {
  String get label => switch (this) {
        EventType.mature => 'Pupuk matang',
        EventType.tempLow => 'Suhu rendah',
        EventType.tempHigh => 'Suhu tinggi',
        EventType.heaterOn => 'Heater menyala',
        EventType.heaterOff => 'Heater mati',
        EventType.valveOpen => 'Katup dibuka',
        EventType.valveClose => 'Katup ditutup',
        EventType.deviceOffline => 'Perangkat offline',
        EventType.deviceOnline => 'Perangkat online',
        EventType.safetyCutoff => 'Safety cutoff',
      };
}

extension EventSeverityLabel on EventSeverity {
  String get label => switch (this) {
        EventSeverity.info => 'Info',
        EventSeverity.warning => 'Peringatan',
        EventSeverity.critical => 'Bahaya',
      };
}

extension BatchStatusLabel on BatchStatus {
  String get label => switch (this) {
        BatchStatus.fermenting => 'Fermentasi',
        BatchStatus.mature => 'Matang',
        BatchStatus.harvested => 'Dipanen',
      };
}
