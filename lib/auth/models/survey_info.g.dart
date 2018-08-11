// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurveyInfo _$SurveyInfoFromJson(Map<String, dynamic> json) => new SurveyInfo(
    yearsKnown: json['yearsKnown'] as int,
    relationshipType: json['relationshipType'] == null
        ? null
        : RelationshipType.values.singleWhere((x) =>
            x.toString() == 'RelationshipType.${json['relationshipType']}'),
    testType: json['testType'] == null
        ? null
        : TestType.values
            .singleWhere((x) => x.toString() == 'TestType.${json['testType']}'),
    questionSet: json['questionSet'] == null
        ? null
        : QuestionSet.values.singleWhere(
            (x) => x.toString() == 'QuestionSet.${json['questionSet']}'));

abstract class _$SurveyInfoSerializerMixin {
  TestType get testType;
  QuestionSet get questionSet;
  int get yearsKnown;
  RelationshipType get relationshipType;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'testType': testType == null ? null : testType.toString().split('.')[1],
        'questionSet':
            questionSet == null ? null : questionSet.toString().split('.')[1],
        'yearsKnown': yearsKnown,
        'relationshipType': relationshipType == null
            ? null
            : relationshipType.toString().split('.')[1]
      };
}
