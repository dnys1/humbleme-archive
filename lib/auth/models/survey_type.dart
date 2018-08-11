import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'survey_type.g.dart';

@immutable
@JsonSerializable()
class SurveyType extends Object with _$SurveyTypeSerializerMixin {
  /// Whether this question is valid for a self-assessment.
  final bool self;

  /// Whether this question is valid for a personal peer assessment;
  final bool personal;

  /// Whether this question is valid for a professional peer assessment.
  final bool professional;

  SurveyType({
    this.self,
    this.personal,
    this.professional,
  });

  factory SurveyType.fromJson(Map<String, dynamic> json) =>
      _$SurveyTypeFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyType &&
          runtimeType == other.runtimeType &&
          self == other.self &&
          personal == other.personal &&
          professional == other.professional;

  @override
  int get hashCode => self.hashCode ^ personal.hashCode ^ professional.hashCode;

  @override
  String toString() {
    return 'SurveyType: {self: $self, personal: $personal, professional: $professional}';
  }
}
