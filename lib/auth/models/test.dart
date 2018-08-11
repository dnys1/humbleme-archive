import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'question.dart';
import 'survey_info.dart';

part 'test.g.dart';

@immutable
@JsonSerializable()
class Test extends Object with _$TestSerializerMixin {
  /// The identifier of the test -- for use in Firestore
  final String id;

  /// The name of the test, i.e. Open Hemispheric Brain Dominance Scale
  /// If randomly generated, the name will be a reference to the user its
  /// created for and the time it was created.
  final String name;

  /// This batch of questions
  final List<Question> questions;

  /// True if there are no more questions that can be answered for this
  /// test type
  final List<Question> questionsRemaining;

  /// Information related to the test
  final SurveyInfo surveyInfo;

  Test({
    this.id,
    this.name,
    this.questions = const [],
    this.questionsRemaining = const [],
    this.surveyInfo,
  });

  bool get lastSetOfQuestions =>
      questionsRemaining != null && questionsRemaining.length == 0;

  Test moveToNextBatch(int length) {
    questionsRemaining.shuffle();
    List<Question> nextBatch = []
      ..addAll(questions)
      ..addAll(questionsRemaining.take(length).toList());
    List<Question> newRemaining =
        questionsRemaining.where((q) => !nextBatch.contains(q)).toList();
    return Test(
      id: this.id,
      name: this.name,
      questions: nextBatch,
      questionsRemaining: newRemaining,
    );
  }

  Test setSurveyInfo(SurveyInfo surveyInfo) {
    return Test(
      id: this.id,
      name: this.name,
      questions: this.questions,
      questionsRemaining: this.questionsRemaining,
      surveyInfo: surveyInfo ?? this.surveyInfo,
    );
  }

  factory Test.fromJson(Map<String, dynamic> json) => _$TestFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Test &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          questions == other.questions &&
          questionsRemaining == other.questionsRemaining &&
          surveyInfo == other.surveyInfo;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      questions.hashCode ^
      questionsRemaining.hashCode ^
      surveyInfo.hashCode;

  @override
  String toString() {
    return 'Test{name: $name, surveyInfo: $surveyInfo, questionsRemaining: $questionsRemaining, questions: $questions}';
  }
}
