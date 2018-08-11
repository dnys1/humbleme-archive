import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'category.dart';
import 'question_set.dart';
import 'survey_type.dart';
import 'util.dart';

part 'question.g.dart';

@immutable
@JsonSerializable()
class Question extends Object with _$QuestionSerializerMixin {
  /// The question's identifier -- used primarily in Firestore
  final String id;

  /// The question posed for the user for the self-assessment
  final String self;

  /// The question given to peers when taking a survey
  final String peer;

  /// The corresponding test from which this question comes
  final QuestionSet testCode;

  /// The types of surveys this question is valid for
  final SurveyType surveyTypes;

  /// The categories for which this question scores and the
  /// corresponding weights.
  @JsonKey(fromJson: categoryValuesFromJson, toJson: categoryValuesToJson)
  final Map<Category, double> categoryWeights;

  Question({
    @required this.id,
    this.self,
    this.peer,
    this.testCode,
    this.surveyTypes,
    this.categoryWeights,
  });

  factory Question.fromJson(Map json) => _$QuestionFromJson(
      json.map((key, val) => MapEntry<String, dynamic>(key as String, val)));

  Question copyWith({
    String self,
    String peer,
    String testCode,
    SurveyType surveyTypes,
    Map<Category, double> categoryWeights,
  }) {
    return Question(
      id: this.id,
      self: self ?? this.self,
      peer: peer ?? this.peer,
      testCode: testCode ?? this.testCode,
      surveyTypes: surveyTypes ?? this.surveyTypes,
      categoryWeights: categoryWeights ?? this.categoryWeights,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          self == other.self &&
          peer == other.peer &&
          testCode == other.testCode &&
          surveyTypes == other.surveyTypes &&
          categoryWeights == other.categoryWeights;

  @override
  int get hashCode =>
      id.hashCode ^
      self.hashCode ^
      peer.hashCode ^
      testCode.hashCode ^
      surveyTypes.hashCode ^
      categoryWeights.hashCode;

  @override
  String toString() {
    return 'Question{id: $id, self: $self, peer: $peer, testCode: $testCode, surveyTypes: $surveyTypes, categoryWeights: $categoryWeights}';
  }
}
