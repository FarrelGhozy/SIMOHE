import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'command.freezed.dart';
part 'command.g.dart';

@freezed
abstract class Command with _$Command {
  const factory Command({
    required String id,
    required CommandAction action,
    required CommandStatus status,
    @Default(<String, dynamic>{}) Map<String, dynamic> args,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'sent_at') DateTime? sentAt,
    @JsonKey(name: 'acked_at') DateTime? ackedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _Command;

  factory Command.fromJson(Map<String, dynamic> json) =>
      _$CommandFromJson(json);
}

@freezed
abstract class CreateCommandResult with _$CreateCommandResult {
  const factory CreateCommandResult({
    required String id,
    required CommandAction action,
    required CommandStatus status,
    @JsonKey(name: 'expires_at') required DateTime expiresAt,
  }) = _CreateCommandResult;

  factory CreateCommandResult.fromJson(Map<String, dynamic> json) =>
      _$CreateCommandResultFromJson(json);
}
