// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mini_friend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiniFriend _$MiniFriendFromJson(Map<String, dynamic> json) => new MiniFriend(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    photoUrl: json['photoUrl'] as String);

abstract class _$MiniFriendSerializerMixin {
  String get id;
  String get displayName;
  String get photoUrl;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'displayName': displayName,
        'photoUrl': photoUrl
      };
}
