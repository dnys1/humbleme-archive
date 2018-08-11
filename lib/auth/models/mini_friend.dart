import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'mini_friend.g.dart';

@immutable
@JsonSerializable()
class MiniFriend extends Object with _$MiniFriendSerializerMixin {
  /// The user's Firebase id
  final String id;

  /// The user's display name
  final String displayName;

  /// The user's photo URL
  final String photoUrl;

  MiniFriend({
    this.id,
    this.displayName,
    this.photoUrl,
  });

  factory MiniFriend.fromJson(Map json) => _$MiniFriendFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiniFriend &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode => hashValues(id, displayName, photoUrl);
}
