import 'package:json_annotation/json_annotation.dart';

part 'schemas.g.dart';

@JsonSerializable()
class SessionWithSets {
  final int session_id;
  @JsonKey(name: 'workout_date', defaultValue: '')
  final String workout_date;
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

  factory SessionWithSets.fromJson(Map<String, dynamic> json) =>
      _$SessionWithSetsFromJson(json);
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

  factory SetResponse.fromJson(Map<String, dynamic> json) =>
      _$SetResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SetResponseToJson(this);
}

@JsonSerializable()
class WorkoutInfo {
  final int workout_key;
  final String workout_name;
  final String workout_part;
  @JsonKey(defaultValue: [])
  final List<WorkoutSet> workoutSets;

  WorkoutInfo({
    required this.workout_key,
    required this.workout_name,
    required this.workout_part,
    this.workoutSets = const [],
  });

  factory WorkoutInfo.fromJson(Map<String, dynamic> json) =>
      _$WorkoutInfoFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutInfoToJson(this);
}

@JsonSerializable()
class WorkoutSet {
  final double weight;
  final int reps;
  final int rest_time;

  WorkoutSet({
    required this.weight,
    required this.reps,
    required this.rest_time,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutSetToJson(this);

  WorkoutSet copyWith({
    double? weight,
    int? reps,
    int? rest_time,
  }) {
    return WorkoutSet(
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rest_time: rest_time ?? this.rest_time,
    );
  }
}

@JsonSerializable()
class SessionIDMap {
  final int session_id;
  final DateTime workout_date;
  final String member_uid;
  final String? trainer_uid;
  final bool is_pt;
  final int session_type_id;
  final int? quest_id;

  SessionIDMap({
    required this.session_id,
    required this.workout_date,
    required this.member_uid,
    this.trainer_uid,
    required this.is_pt,
    required this.session_type_id,
    this.quest_id,
  });

  factory SessionIDMap.fromJson(Map<String, dynamic> json) =>
      _$SessionIDMapFromJson(json);
  Map<String, dynamic> toJson() => _$SessionIDMapToJson(this);
}

@JsonSerializable()
class SetSave {
  final int set_num;
  final double weight;
  final int reps;
  final int rest_time;

  SetSave({
    required this.set_num,
    required this.weight,
    required this.reps,
    required this.rest_time,
  });

  factory SetSave.fromJson(Map<String, dynamic> json) =>
      _$SetSaveFromJson(json);
  Map<String, dynamic> toJson() => _$SetSaveToJson(this);
}

@JsonSerializable()
class ExerciseSave {
  final int workout_key;
  final List<SetSave> sets;

  ExerciseSave({
    required this.workout_key,
    required this.sets,
  });

  factory ExerciseSave.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSaveFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseSaveToJson(this);
}

@JsonSerializable()
class SessionSave {
  final int session_id;
  final List<ExerciseSave> exercises;

  SessionSave({
    required this.session_id,
    required this.exercises,
  });

  factory SessionSave.fromJson(Map<String, dynamic> json) =>
      _$SessionSaveFromJson(json);
  Map<String, dynamic> toJson() => _$SessionSaveToJson(this);
}

@JsonSerializable()
class SessionSaveResponse {
  final int session_id;
  final DateTime workout_date;
  final String member_uid;
  final String? trainer_uid;
  final bool is_pt;
  final int session_type_id;
  final int? quest_id;

  SessionSaveResponse({
    required this.session_id,
    required this.workout_date,
    required this.member_uid,
    this.trainer_uid,
    required this.is_pt,
    required this.session_type_id,
    this.quest_id,
  });

  factory SessionSaveResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionSaveResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SessionSaveResponseToJson(this);
}

@JsonSerializable()
class SessionDetail {
  final int session_id;
  final DateTime workout_date;
  final String member_uid;
  final String? trainer_uid;
  final String? trainer_name;  // New field
  final bool is_pt;
  final int session_type_id;
  final String session_type;
  final List<WorkoutDetail> workouts;

  SessionDetail({
    required this.session_id,
    required this.workout_date,
    required this.member_uid,
    this.trainer_uid,
    this.trainer_name,  // New field
    required this.is_pt,
    required this.session_type_id,
    required this.session_type,
    required this.workouts,
  });

  factory SessionDetail.fromJson(Map<String, dynamic> json) =>
      _$SessionDetailFromJson(json);
  Map<String, dynamic> toJson() => _$SessionDetailToJson(this);
}

@JsonSerializable()
class WorkoutDetail {
  final int workout_key;
  final String workout_name;
  final String workout_part;
  final List<SetDetail> sets;

  WorkoutDetail({
    required this.workout_key,
    required this.workout_name,
    required this.workout_part,
    required this.sets,
  });

  factory WorkoutDetail.fromJson(Map<String, dynamic> json) =>
      _$WorkoutDetailFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutDetailToJson(this);
}

@JsonSerializable()
class SetDetail {
  final int set_num;
  final double weight;
  final int reps;
  final int rest_time;

  SetDetail({
    required this.set_num,
    required this.weight,
    required this.reps,
    required this.rest_time,
  });

  factory SetDetail.fromJson(Map<String, dynamic> json) =>
      _$SetDetailFromJson(json);
  Map<String, dynamic> toJson() => _$SetDetailToJson(this);
}
