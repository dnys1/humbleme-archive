// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequest _$FriendRequestFromJson(Map<String, dynamic> json) =>
    new FriendRequest(
        id: json['id'] as String,
        fromUser: json['fromUser'] as String,
        toUser: json['toUser'] as String,
        dateTime: json['dateTime'] == null
            ? null
            : dateTimeFromJson(json['dateTime']),
        accepted: json['accepted'] as bool,
        denied: json['denied'] as bool);

abstract class _$FriendRequestSerializerMixin {
  String get id;
  String get fromUser;
  String get toUser;
  DateTime get dateTime;
  bool get accepted;
  bool get denied;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'fromUser': fromUser,
        'toUser': toUser,
        'dateTime': dateTime == null ? null : dateTimeToJson(dateTime),
        'accepted': accepted,
        'denied': denied
      };
}
