// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyType _$SurveyTypeFromJson(Map<String, dynamic> json) => new SurveyType(
    self: json['self'] as bool,
    personal: json['personal'] as bool,
    professional: json['professional'] as bool);

abstract class _$SurveyTypeSerializerMixin {
  bool get self;
  bool get personal;
  bool get professional;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'self': self,
        'personal': personal,
        'professional': professional
      };
}
