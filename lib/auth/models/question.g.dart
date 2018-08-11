// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => new Question(
    id: json['id'] as String,
    self: json['self'] as String,
    peer: json['peer'] as String,
    testCode: json['testCode'] == null
        ? null
        : QuestionSet.values.singleWhere(
            (x) => x.toString() == 'QuestionSet.${json['testCode']}'),
    surveyTypes: json['surveyTypes'] == null
        ? null
        : new SurveyType.fromJson(json['surveyTypes'] as Map<String, dynamic>),
    categoryWeights: json['categoryWeights'] == null
        ? null
        : categoryValuesFromJson(
            json['categoryWeights'] as Map<dynamic, dynamic>));

abstract class _$QuestionSerializerMixin {
  String get id;
  String get self;
  String get peer;
  QuestionSet get testCode;
  SurveyType get surveyTypes;
  Map<Category, double> get categoryWeights;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'self': self,
        'peer': peer,
        'testCode': testCode == null ? null : testCode.toString().split('.')[1],
        'surveyTypes': surveyTypes,
        'categoryWeights': categoryWeights == null
            ? null
            : categoryValuesToJson(categoryWeights)
      };
}
