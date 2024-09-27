// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionWithSets _$SessionWithSetsFromJson(Map<String, dynamic> json) =>
    SessionWithSets(
      session_id: (json['session_id'] as num).toInt(),
      workout_date: json['workout_date'] as String? ?? '',
      member_uid: json['member_uid'] as String,
      trainer_uid: json['trainer_uid'] as String?,
      is_pt: json['is_pt'] as bool,
      session_type_id: (json['session_type_id'] as num).toInt(),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SetResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SessionWithSetsToJson(SessionWithSets instance) =>
    <String, dynamic>{
      'session_id': instance.session_id,
      'workout_date': instance.workout_date,
      'member_uid': instance.member_uid,
      'trainer_uid': instance.trainer_uid,
      'is_pt': instance.is_pt,
      'session_type_id': instance.session_type_id,
      'sets': instance.sets,
    };

SetResponse _$SetResponseFromJson(Map<String, dynamic> json) => SetResponse(
      set_num: (json['set_num'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      rest_time: (json['rest_time'] as num).toInt(),
    );

Map<String, dynamic> _$SetResponseToJson(SetResponse instance) =>
    <String, dynamic>{
      'set_num': instance.set_num,
      'weight': instance.weight,
      'reps': instance.reps,
      'rest_time': instance.rest_time,
    };

WorkoutInfo _$WorkoutInfoFromJson(Map<String, dynamic> json) => WorkoutInfo(
      workout_key: (json['workout_key'] as num).toInt(),
      workout_name: json['workout_name'] as String,
      workout_part: json['workout_part'] as String,
      workoutSets: (json['workoutSets'] as List<dynamic>?)
              ?.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$WorkoutInfoToJson(WorkoutInfo instance) =>
    <String, dynamic>{
      'workout_key': instance.workout_key,
      'workout_name': instance.workout_name,
      'workout_part': instance.workout_part,
      'workoutSets': instance.workoutSets,
    };

WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) => WorkoutSet(
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      rest_time: (json['rest_time'] as num).toInt(),
    );

Map<String, dynamic> _$WorkoutSetToJson(WorkoutSet instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'reps': instance.reps,
      'rest_time': instance.rest_time,
    };

SessionIDMap _$SessionIDMapFromJson(Map<String, dynamic> json) => SessionIDMap(
      session_id: (json['session_id'] as num).toInt(),
      workout_date: DateTime.parse(json['workout_date'] as String),
      member_uid: json['member_uid'] as String,
      trainer_uid: json['trainer_uid'] as String?,
      is_pt: json['is_pt'] as bool,
      session_type_id: (json['session_type_id'] as num).toInt(),
      quest_id: (json['quest_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SessionIDMapToJson(SessionIDMap instance) =>
    <String, dynamic>{
      'session_id': instance.session_id,
      'workout_date': instance.workout_date.toIso8601String(),
      'member_uid': instance.member_uid,
      'trainer_uid': instance.trainer_uid,
      'is_pt': instance.is_pt,
      'session_type_id': instance.session_type_id,
      'quest_id': instance.quest_id,
    };

SetSave _$SetSaveFromJson(Map<String, dynamic> json) => SetSave(
      set_num: (json['set_num'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      rest_time: (json['rest_time'] as num).toInt(),
    );

Map<String, dynamic> _$SetSaveToJson(SetSave instance) => <String, dynamic>{
      'set_num': instance.set_num,
      'weight': instance.weight,
      'reps': instance.reps,
      'rest_time': instance.rest_time,
    };

ExerciseSave _$ExerciseSaveFromJson(Map<String, dynamic> json) => ExerciseSave(
      workout_key: (json['workout_key'] as num).toInt(),
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SetSave.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExerciseSaveToJson(ExerciseSave instance) =>
    <String, dynamic>{
      'workout_key': instance.workout_key,
      'sets': instance.sets,
    };

SessionSave _$SessionSaveFromJson(Map<String, dynamic> json) => SessionSave(
      session_id: (json['session_id'] as num).toInt(),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseSave.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SessionSaveToJson(SessionSave instance) =>
    <String, dynamic>{
      'session_id': instance.session_id,
      'exercises': instance.exercises,
    };

SessionSaveResponse _$SessionSaveResponseFromJson(Map<String, dynamic> json) =>
    SessionSaveResponse(
      session_id: (json['session_id'] as num).toInt(),
      workout_date: DateTime.parse(json['workout_date'] as String),
      member_uid: json['member_uid'] as String,
      trainer_uid: json['trainer_uid'] as String?,
      is_pt: json['is_pt'] as bool,
      session_type_id: (json['session_type_id'] as num).toInt(),
      quest_id: (json['quest_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SessionSaveResponseToJson(
        SessionSaveResponse instance) =>
    <String, dynamic>{
      'session_id': instance.session_id,
      'workout_date': instance.workout_date.toIso8601String(),
      'member_uid': instance.member_uid,
      'trainer_uid': instance.trainer_uid,
      'is_pt': instance.is_pt,
      'session_type_id': instance.session_type_id,
      'quest_id': instance.quest_id,
    };

SessionDetail _$SessionDetailFromJson(Map<String, dynamic> json) =>
    SessionDetail(
      session_id: (json['session_id'] as num).toInt(),
      workout_date: DateTime.parse(json['workout_date'] as String),
      member_uid: json['member_uid'] as String,
      trainer_uid: json['trainer_uid'] as String?,
      trainer_name: json['trainer_name'] as String?,
      is_pt: json['is_pt'] as bool,
      session_type_id: (json['session_type_id'] as num).toInt(),
      session_type: json['session_type'] as String,
      workouts: (json['workouts'] as List<dynamic>)
          .map((e) => WorkoutDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SessionDetailToJson(SessionDetail instance) =>
    <String, dynamic>{
      'session_id': instance.session_id,
      'workout_date': instance.workout_date.toIso8601String(),
      'member_uid': instance.member_uid,
      'trainer_uid': instance.trainer_uid,
      'trainer_name': instance.trainer_name,
      'is_pt': instance.is_pt,
      'session_type_id': instance.session_type_id,
      'session_type': instance.session_type,
      'workouts': instance.workouts,
    };

WorkoutDetail _$WorkoutDetailFromJson(Map<String, dynamic> json) =>
    WorkoutDetail(
      workout_key: (json['workout_key'] as num).toInt(),
      workout_name: json['workout_name'] as String,
      workout_part: json['workout_part'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => SetDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WorkoutDetailToJson(WorkoutDetail instance) =>
    <String, dynamic>{
      'workout_key': instance.workout_key,
      'workout_name': instance.workout_name,
      'workout_part': instance.workout_part,
      'sets': instance.sets,
    };

SetDetail _$SetDetailFromJson(Map<String, dynamic> json) => SetDetail(
      set_num: (json['set_num'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      rest_time: (json['rest_time'] as num).toInt(),
    );

Map<String, dynamic> _$SetDetailToJson(SetDetail instance) => <String, dynamic>{
      'set_num': instance.set_num,
      'weight': instance.weight,
      'reps': instance.reps,
      'rest_time': instance.rest_time,
    };
