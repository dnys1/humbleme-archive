import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'resource.g.dart';

/// Build runner wants to convert DateTime objects to Strings for
/// storage, but Firebase accepts pure DateTime objects, so we'll
/// leave them as such.
DateTime _dateTimeFromJson(dateTime) => dateTime as DateTime;

/// Build runner wants to convert DateTime objects to Strings for
/// storage, but Firebase accepts pure DateTime objects, so we'll
/// leave them as such.
DateTime _dateTimeToJson(dateTime) => dateTime;

@immutable
@JsonSerializable()
class Resource extends Object with _$ResourceSerializerMixin {
  /// The resource id for use in Firestore
  final String id;

  /// The resource title
  final String title;

  /// The resource subtitle (can be `null`)
  @JsonKey(nullable: true)
  final String subtitle;

  /// The resource author
  final String author;

  /// The resource url (usually an affiliate link)
  final String url;

  /// The resource image url (cached in Storage)
  @JsonKey(name: 'image_url')
  final String imageUrl;

  /// The Amazon listing description for the book
  final String description;

  /// The resource item position in the list screen
  /// (for consistent listings)
  @JsonKey(name: 'item_pos')
  final int itemPos;

  /// The date and time the resource was last updated
  @JsonKey(
    name: 'updated_at',
    toJson: _dateTimeToJson,
    fromJson: _dateTimeFromJson,
  )
  final DateTime updatedAt;

  Resource({
    this.id,
    this.title,
    this.subtitle,
    this.author,
    this.url,
    this.imageUrl,
    this.description,
    num itemPos,
    this.updatedAt,
  }) : itemPos = itemPos.toInt();

  factory Resource.fromJson(Map<String, dynamic> json) =>
      _$ResourceFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Resource &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          subtitle == other.subtitle &&
          author == other.author &&
          url == other.url &&
          imageUrl == other.imageUrl &&
          description == other.description &&
          itemPos == other.itemPos &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => hashValues(
        id,
        title,
        subtitle,
        author,
        url,
        imageUrl,
        description,
        itemPos,
        updatedAt,
      );

  @override
  String toString() {
    return 'Resource{title: $title, subtitle: $subtitle author: $author, url: $url, description: $description, imageUrl: $imageUrl, itemPos: $itemPos, updatedAt: $updatedAt}';
  }
}
