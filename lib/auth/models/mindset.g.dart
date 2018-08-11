// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mindset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mindset _$MindsetFromJson(Map<String, dynamic> json) => new Mindset(
    id: json['id'] as String,
    name: json['name'] == null
        ? null
        : Mindsets.values
            .singleWhere((x) => x.toString() == 'Mindsets.${json['name']}'),
    categoryWeights: json['categoryWeights'] == null
        ? null
        : categoryValuesFromJson(
            json['categoryWeights'] as Map<dynamic, dynamic>),
    ranking: json['ranking'] as int);

abstract class _$MindsetSerializerMixin {
  String get id;
  Mindsets get name;
  Map<Category, double> get categoryWeights;
  int get ranking;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name == null ? null : name.toString().split('.')[1],
        'categoryWeights': categoryWeights == null
            ? null
            : categoryValuesToJson(categoryWeights),
        'ranking': ranking
      };
}
