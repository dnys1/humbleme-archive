import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'question_set.dart';
import 'util.dart';

part 'question_set_statistics.g.dart';

@immutable
@JsonSerializable()
class QuestionSetStatistics extends Object
    with _$QuestionSetStatisticsSerializerMixin {
  final QuestionSet questionSet;
  final double min;
  final double max;
  final double average;
  final double standardDeviation;
  final double firstQuartile;
  final double median;
  final double thirdQuartile;
  final int count;

  QuestionSetStatistics({
    this.min,
    this.max,
    this.average,
    this.standardDeviation,
    this.firstQuartile,
    this.median,
    this.thirdQuartile,
    this.count,
    this.questionSet,
  });

  factory QuestionSetStatistics.fromJson(Map json) =>
      _$QuestionSetStatisticsFromJson(jsonMapFromMap(json));

  @override
  String toString() {
    return 'QuestionSetStatistics{questionSet: $questionSet, min: $min, max: $max, average: $average, stdDev: $standardDeviation, firstQuartile: $firstQuartile, median: $median, thirdQuartile: $thirdQuartile, count: $count';
  }
}
