import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'batch.freezed.dart';
part 'batch.g.dart';

@freezed
abstract class Batch with _$Batch {
  const factory Batch({
    required int id,
    String? label,
    required BatchStatus status,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'matured_at') DateTime? maturedAt,
    @JsonKey(name: 'harvested_at') DateTime? harvestedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _Batch;

  factory Batch.fromJson(Map<String, dynamic> json) => _$BatchFromJson(json);
}
