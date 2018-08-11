import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'category.dart';
import 'util.dart';

part 'mindset.g.dart';

enum Mindsets {
  Altruistic,
  Athletic,
  Attractive,
  Collaborator,
  Compassionate,
  Courageous,
  Friendly,
  Generous,
  Healthy,
  Honest,
  Humble,
  Intelligent,
  Kind,
  Loyal,
  Professional,
  Talented,
  Thrifty,
  Transparent,
  Trustworthy,
}

@immutable
@JsonSerializable()
class Mindset extends Object with _$MindsetSerializerMixin {
  /// The mindset's id, for use in Firestore.
  final String id;

  /// The mindset's name, or title.
  final Mindsets name;

  /// A list of categories from which this mindset is calculated.
  @JsonKey(toJson: categoryValuesToJson, fromJson: categoryValuesFromJson)
  final Map<Category, double> categoryWeights;

  /// The mindset ranking, i.e. how many people have chosen this among their
  /// top 5 mindsets.
  final int ranking;

  String getName() {
    return name.toString().split('.')[1];
  }

  Mindset({
    @required this.id,
    this.name,
    this.categoryWeights,
    this.ranking = 0,
  });

  factory Mindset.fromJson(Map<String, dynamic> json) =>
      _$MindsetFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mindset &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          categoryWeights == other.categoryWeights &&
          ranking == other.ranking;

  @override
  int get hashCode =>
      name.hashCode ^ id.hashCode ^ categoryWeights.hashCode ^ ranking.hashCode;

  @override
  String toString() {
    return 'Mindset{id: $id, ranking: $ranking, mindset: $name, categoryWeights: $categoryWeights}';
  }
}
