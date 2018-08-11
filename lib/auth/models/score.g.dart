// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Score _$ScoreFromJson(Map<String, dynamic> json) => new Score(
    id: json['id'] as String,
    categoryTotals: json['categoryTotals'] == null
        ? null
        : categoryValuesFromJson(
            json['categoryTotals'] as Map<dynamic, dynamic>),
    categoryRaw: json['categoryRaw'] == null
        ? null
        : categoryValuesFromJson(json['categoryRaw'] as Map<dynamic, dynamic>),
    categoryWeighted: json['categoryWeighted'] == null
        ? null
        : categoryValuesFromJson(
            json['categoryWeighted'] as Map<dynamic, dynamic>),
    mindsetWeighted: json['mindsetWeighted'] == null
        ? null
        : mindsetWeightedFromJson(
            json['mindsetWeighted'] as Map<dynamic, dynamic>),
    dateTime:
        json['dateTime'] == null ? null : dateTimeFromJson(json['dateTime']),
    score: (json['score'] as num)?.toDouble(),
    self: json['self'] as bool,
    questionSetWeighted: json['questionSetWeighted'] == null
        ? null
        : questionSetWeightedFromJson(
            json['questionSetWeighted'] as Map<dynamic, dynamic>),
    privacySettings: json['privacySettings'] == null
        ? null
        : privacySettingsFromJson(
            json['privacySettings'] as Map<dynamic, dynamic>));

abstract class _$ScoreSerializerMixin {
  String get id;
  Map<Category, double> get categoryTotals;
  Map<Category, double> get categoryRaw;
  Map<Category, double> get categoryWeighted;
  Map<Mindsets, double> get mindsetWeighted;
  Map<QuestionSet, double> get questionSetWeighted;
  Map<Mindsets, bool> get privacySettings;
  double get score;
  DateTime get dateTime;
  bool get self;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'categoryTotals': categoryTotals == null
            ? null
            : categoryValuesToJson(categoryTotals),
        'categoryRaw':
            categoryRaw == null ? null : categoryValuesToJson(categoryRaw),
        'categoryWeighted': categoryWeighted == null
            ? null
            : categoryValuesToJson(categoryWeighted),
        'mindsetWeighted': mindsetWeighted == null
            ? null
            : mindsetWeightedToJson(mindsetWeighted),
        'questionSetWeighted': questionSetWeighted == null
            ? null
            : questionSetWeightedToJson(questionSetWeighted),
        'privacySettings': privacySettings == null
            ? null
            : privacySettingsToJson(privacySettings),
        'score': score,
        'dateTime': dateTime == null ? null : dateTimeToJson(dateTime),
        'self': self
      };
}
