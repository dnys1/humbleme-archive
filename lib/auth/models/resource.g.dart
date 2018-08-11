// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Resource _$ResourceFromJson(Map<String, dynamic> json) => new Resource(
    id: json['id'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
    author: json['author'] as String,
    url: json['url'] as String,
    imageUrl: json['image_url'] as String,
    description: json['description'] as String,
    itemPos: json['item_pos'] as num,
    updatedAt: json['updated_at'] == null
        ? null
        : _dateTimeFromJson(json['updated_at']));

abstract class _$ResourceSerializerMixin {
  String get id;
  String get title;
  String get subtitle;
  String get author;
  String get url;
  String get imageUrl;
  String get description;
  int get itemPos;
  DateTime get updatedAt;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'author': author,
        'url': url,
        'image_url': imageUrl,
        'description': description,
        'item_pos': itemPos,
        'updated_at': updatedAt == null ? null : _dateTimeToJson(updatedAt)
      };
}
