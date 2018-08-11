// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_set_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionSetStatistics _$QuestionSetStatisticsFromJson(
        Map<String, dynamic> json) =>
    new QuestionSetStatistics(
        min: (json['min'] as num)?.toDouble(),
        max: (json['max'] as num)?.toDouble(),
        average: (json['average'] as num)?.toDouble(),
        standardDeviation: (json['standardDeviation'] as num)?.toDouble(),
        firstQuartile: (json['firstQuartile'] as num)?.toDouble(),
        median: (json['median'] as num)?.toDouble(),
        thirdQuartile: (json['thirdQuartile'] as num)?.toDouble(),
        count: json['count'] as int,
        questionSet: json['questionSet'] == null
            ? null
            : QuestionSet.values.singleWhere(
                (x) => x.toString() == 'QuestionSet.${json['questionSet']}'));

abstract class _$QuestionSetStatisticsSerializerMixin {
  QuestionSet get questionSet;
  double get min;
  double get max;
  double get average;
  double get standardDeviation;
  double get firstQuartile;
  double get median;
  double get thirdQuartile;
  int get count;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'questionSet':
            questionSet == null ? null : questionSet.toString().split('.')[1],
        'min': min,
        'max': max,
        'average': average,
        'standardDeviation': standardDeviation,
        'firstQuartile': firstQuartile,
        'median': median,
        'thirdQuartile': thirdQuartile,
        'count': count
      };
}
