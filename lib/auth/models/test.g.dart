// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Test _$TestFromJson(Map<String, dynamic> json) => new Test(
    id: json['id'] as String,
    name: json['name'] as String,
    questions: (json['questions'] as List)
        ?.map((e) => e == null
            ? null
            : new Question.fromJson(e as Map<dynamic, dynamic>))
        ?.toList(),
    questionsRemaining: (json['questionsRemaining'] as List)
        ?.map((e) => e == null
            ? null
            : new Question.fromJson(e as Map<dynamic, dynamic>))
        ?.toList(),
    surveyInfo: json['surveyInfo'] == null
        ? null
        : new SurveyInfo.fromJson(json['surveyInfo'] as Map<dynamic, dynamic>));

abstract class _$TestSerializerMixin {
  String get id;
  String get name;
  List<Question> get questions;
  List<Question> get questionsRemaining;
  SurveyInfo get surveyInfo;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'questions': questions,
        'questionsRemaining': questionsRemaining,
        'surveyInfo': surveyInfo
      };
}
