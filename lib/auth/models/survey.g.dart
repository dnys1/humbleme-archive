// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Survey _$SurveyFromJson(Map<String, dynamic> json) => new Survey(
    id: json['id'] as String,
    dateTime:
        json['dateTime'] == null ? null : dateTimeFromJson(json['dateTime']),
    toUser: json['toUser'] as String,
    fromUser: json['fromUser'] as String,
    answers: json['answers'] == null
        ? null
        : new Map<String, int>.from(json['answers'] as Map),
    completed: json['completed'] as bool,
    surveyInfo: json['surveyInfo'] == null
        ? null
        : new SurveyInfo.fromJson(json['surveyInfo'] as Map<dynamic, dynamic>));

abstract class _$SurveySerializerMixin {
  String get id;
  DateTime get dateTime;
  String get toUser;
  String get fromUser;
  Map<String, int> get answers;
  bool get completed;
  SurveyInfo get surveyInfo;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'dateTime': dateTime == null ? null : dateTimeToJson(dateTime),
        'toUser': toUser,
        'fromUser': fromUser,
        'answers': answers,
        'completed': completed,
        'surveyInfo': surveyInfo
      };
}
