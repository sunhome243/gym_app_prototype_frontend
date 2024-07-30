// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionWithSets _$SessionWithSetsFromJson(Map<String, dynamic> json) =>
    SessionWithSets(
      session_id: (json['session_id'] as num).toInt(),
      workout_date: DateTime.parse(json['workout_date'] as String),
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
      'workout_date': instance.workout_date.toIso8601String(),
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
