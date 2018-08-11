import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'question_set.dart';
import 'relationship_type.dart';
import 'test_type.dart';
import 'util.dart';

part 'survey_info.g.dart';

@immutable
@JsonSerializable()
class SurveyInfo extends Object with _$SurveyInfoSerializerMixin {
  /// The type of survey
  final TestType testType;

  /// The set of questions this survey is based on
  final QuestionSet questionSet;

  /// Number of years the user has known the person they're testing for
  final int yearsKnown;

  /// How the user knows the person they're testing for
  final RelationshipType relationshipType;

  SurveyInfo({
    this.yearsKnown,
    this.relationshipType,
    TestType testType,
    this.questionSet = QuestionSet.IPIP,
  }) : testType = testType ?? getTestTypeForRelationship(relationshipType);

  static TestType getTestTypeForRelationship(RelationshipType relationship) {
    switch (relationship) {
      case RelationshipType.COWORKER:
        return TestType.professional;
      default:
        return TestType.personal;
    }
  }

  static SurveyInfo self(QuestionSet questionSet) {
    return SurveyInfo(
      testType: TestType.self,
      questionSet: questionSet,
    );
  }

  factory SurveyInfo.fromJson(Map json) =>
      _$SurveyInfoFromJson(jsonMapFromMap(json));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyInfo &&
          runtimeType == other.runtimeType &&
          testType == other.testType &&
          yearsKnown == other.yearsKnown &&
          relationshipType == other.relationshipType;

  @override
  int get hashCode => hashValues(testType, yearsKnown, relationshipType);

  @override
  String toString() {
    return 'SurveyInfo{testType: $testType, yearsKnown: $yearsKnown, relationshipType: $relationshipType}';
  }
}
