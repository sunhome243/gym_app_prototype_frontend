import 'package:json_annotation/json_annotation.dart';

part 'schemas.g.dart';

@JsonSerializable()
class SessionWithSets {
  final int session_id;
  final DateTime workout_date;
  final String member_uid;
  final String? trainer_uid;
  final bool is_pt;
  final int session_type_id;
  final List<SetResponse> sets;

  SessionWithSets({
    required this.session_id,
    required this.workout_date,
    required this.member_uid,
    this.trainer_uid,
    required this.is_pt,
    required this.session_type_id,
    required this.sets,
  });

  factory SessionWithSets.fromJson(Map<String, dynamic> json) => _$SessionWithSetsFromJson(json);
  Map<String, dynamic> toJson() => _$SessionWithSetsToJson(this);
}

@JsonSerializable()
class SetResponse {
  final int set_num;
  final double weight;
  final int reps;
  final int rest_time;

  SetResponse({
    required this.set_num,
    required this.weight,
    required this.reps,
    required this.rest_time,
  });

  factory SetResponse.fromJson(Map<String, dynamic> json) => _$SetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SetResponseToJson(this);
}