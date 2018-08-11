import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'survey_info.dart';
import 'util.dart';

part 'survey.g.dart';

@immutable
@JsonSerializable()
class Survey extends Object with _$SurveySerializerMixin {
  /// The survey's id, for use in Firestore.
  final String id;

  /// The date and time that it was last visited.
  @JsonKey(toJson: dateTimeToJson, fromJson: dateTimeFromJson)
  final DateTime dateTime;

  /// The user id of the person for whom the quiz is taken.
  final String toUser;

  /// The user id of the person from whom the quiz is taken.
  final String fromUser;

  /// The map of questionIds and corresponding answers.
  /// All questions are answered on a Likert-type 5-point scale.
  final Map<String, int> answers;

  /// Whether the quiz is completed or not. Firestore is triggered
  /// to update scores when this is set to `true`.
  final bool completed;

  /// More information about the survey.
  final SurveyInfo surveyInfo;

  Survey({
    this.id,
    this.dateTime,
    this.toUser,
    this.fromUser,
    this.answers = const <String, int>{},
    this.completed = false,
    this.surveyInfo,
  });

  factory Survey.fromJson(Map<String, dynamic> json) => _$SurveyFromJson(json);

  Survey copyWith({
    DateTime dateTime,
    Map<String, int> answers,
    bool completed,
    SurveyInfo surveyInfo,
  }) {
    return Survey(
      id: this.id,
      dateTime: dateTime ?? this.dateTime,
      toUser: this.toUser,
      fromUser: this.fromUser,
      answers: answers ?? this.answers,
      completed: completed ?? this.completed,
      surveyInfo: surveyInfo ?? this.surveyInfo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Survey &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          dateTime == other.dateTime &&
          toUser == other.toUser &&
          fromUser == other.fromUser &&
          answers == other.answers &&
          completed == other.completed &&
          surveyInfo == other.surveyInfo;

  @override
  int get hashCode =>
      id.hashCode ^
      dateTime.hashCode ^
      toUser.hashCode ^
      fromUser.hashCode ^
      answers.hashCode ^
      completed.hashCode ^
      surveyInfo.hashCode;

  @override
  String toString() {
    return 'Survey{id: $id, dateTime: $dateTime, toUser: $toUser, fromUser: $fromUser, questions: $answers, completed: $completed, surveyInfo: $surveyInfo}';
  }
}
