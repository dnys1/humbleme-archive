import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'category.dart';
import 'mindset.dart';
import 'question_set.dart';
import 'util.dart';

part 'score.g.dart';

@immutable
@JsonSerializable()
class Score extends Object with _$ScoreSerializerMixin {
  static Map<Mindsets, bool> get defaultPrivacySettings =>
      Map<Mindsets, bool>.fromIterable(Mindsets.values,
          key: (mindset) => mindset, value: (_) => false);

  /// Unique id for score. For use in Firestore.
  final String id;

  /// The total number of questions answered for each category
  @JsonKey(fromJson: categoryValuesFromJson, toJson: categoryValuesToJson)
  final Map<Category, double> categoryTotals;

  /// The raw "score" for each category. Basically just a sum of all individual scores.
  @JsonKey(fromJson: categoryValuesFromJson, toJson: categoryValuesToJson)
  final Map<Category, double> categoryRaw;

  /// The computed score for each category, i.e. `categoryRaw / categoryTotal`
  @JsonKey(fromJson: categoryValuesFromJson, toJson: categoryValuesToJson)
  final Map<Category, double> categoryWeighted;

  /// The computed scores for each mindset. Basically, a recipe is created for
  /// each mindset from the categories. It's done this way because the categories
  /// of popular tests (whose questions we're using) calculate values for different
  /// categories, and thus our mindsets don't exactly align.
  ///
  /// This is for the best though. Our mindsets are a more hollistic description of
  /// people than "personality traits" are.
  @JsonKey(fromJson: mindsetWeightedFromJson, toJson: mindsetWeightedToJson)
  final Map<Mindsets, double> mindsetWeighted;

  @JsonKey(
      fromJson: questionSetWeightedFromJson, toJson: questionSetWeightedToJson)
  final Map<QuestionSet, double> questionSetWeighted;

  /// Keeps track of which mindsets the user would like to display publicly/privately.
  ///
  /// Will be `true` for public / `false` for private
  @JsonKey(fromJson: privacySettingsFromJson, toJson: privacySettingsToJson)
  final Map<Mindsets, bool> privacySettings;

  /// The overall score for the user. The `mindsetWeighted` weighted for each mindset.
  /// In this way, we can provide a "social credit score" if it's ever of interest.
  @JsonKey(nullable: true)
  final double score;

  /// The date and time that this score is valid.
  /// This is used to track past scores and allow users to revisit their history /
  /// track their progress.
  @JsonKey(toJson: dateTimeToJson, fromJson: dateTimeFromJson)
  final DateTime dateTime;

  /// Whether this score set is from self-assessments (i.e. `self = true`) or from
  /// a collection of peer assessments (i.e. `self = false`).
  final bool self;

  Score({
    this.id,
    this.categoryTotals,
    this.categoryRaw,
    this.categoryWeighted,
    this.mindsetWeighted,
    this.dateTime,
    this.score,
    this.self,
    this.questionSetWeighted = const {},
    Map<Mindsets, bool> privacySettings,
  }) : privacySettings = privacySettings ?? defaultPrivacySettings;

  Score addMindsetWeight(Mindsets mindset, double value) {
    Map<Mindsets, double> newMindsetWeighted = mindsetWeighted
      ..update(mindset, (_) => value, ifAbsent: () => value);
    return this.copyWith(
      mindsetWeighted: newMindsetWeighted,
    );
  }

  Score copyWith({
    String id,
    Map<Category, int> categoryTotals,
    Map<Category, double> categoryRaw,
    Map<Category, double> categoryWeighted,
    Map<Mindsets, double> mindsetWeighted,
    DateTime dateTime,
    double score,
    Map<Mindsets, bool> privacySettings,
  }) {
    return Score(
      id: id ?? this.id,
      categoryTotals: categoryTotals ?? this.categoryTotals,
      categoryRaw: categoryRaw ?? this.categoryRaw,
      categoryWeighted: categoryWeighted ?? this.categoryWeighted,
      mindsetWeighted: mindsetWeighted ?? this.mindsetWeighted,
      dateTime: dateTime ?? this.dateTime,
      score: score ?? this.score,
      self: this.self,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }

  factory Score.init(bool self) {
    return Score(
      categoryTotals: Map<Category, double>.fromIterable(Category.values,
          key: (cat) => cat, value: (_) => 0.0),
      categoryRaw: Map<Category, double>.fromIterable(Category.values,
          key: (cat) => cat, value: (_) => 0.0),
      categoryWeighted: Map<Category, double>.fromIterable(Category.values,
          key: (cat) => cat, value: (_) => 0.0),
      mindsetWeighted: Map<Mindsets, double>.fromIterable(Mindsets.values,
          key: (key) => key, value: (_) => 0.0),
      self: self,
      dateTime: DateTime.now(),
      privacySettings: defaultPrivacySettings,
    );
  }

  factory Score.fromJson(Map json) => _$ScoreFromJson(
      json.map((key, val) => MapEntry<String, dynamic>(key as String, val)));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Score &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          categoryRaw == other.categoryRaw &&
          categoryTotals == other.categoryTotals &&
          categoryWeighted == other.categoryWeighted &&
          mindsetWeighted == other.mindsetWeighted &&
          score == other.score &&
          dateTime == other.dateTime &&
          self == other.self &&
          privacySettings == other.privacySettings;

  @override
  int get hashCode =>
      id.hashCode ^
      categoryRaw.hashCode ^
      categoryTotals.hashCode ^
      categoryWeighted.hashCode ^
      mindsetWeighted.hashCode ^
      score.hashCode ^
      dateTime.hashCode ^
      self.hashCode ^
      privacySettings.hashCode;

  @override
  String toString() {
    return 'Score{dateTime: $dateTime, privacySettings: $privacySettings, self: $self, score: $score, categoryWeighted: $categoryWeighted, mindsetWeighted: $mindsetWeighted}';
  }
}
