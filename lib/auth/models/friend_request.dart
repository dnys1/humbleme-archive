import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'util.dart';

part 'friend_request.g.dart';

@immutable
@JsonSerializable()
class FriendRequest extends Object with _$FriendRequestSerializerMixin {
  final String id;
  final String fromUser;
  final String toUser;

  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime dateTime;
  final bool accepted;
  final bool denied;

  FriendRequest({
    this.id,
    this.fromUser,
    this.toUser,
    this.dateTime,
    this.accepted = false,
    this.denied = false,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendRequest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          toUser == other.toUser &&
          fromUser == other.fromUser &&
          dateTime == other.dateTime &&
          accepted == other.accepted &&
          denied == other.denied;

  @override
  int get hashCode =>
      id.hashCode ^
      toUser.hashCode ^
      fromUser.hashCode ^
      dateTime.hashCode ^
      accepted.hashCode ^
      denied.hashCode;

  @override
  String toString() {
    return 'FriendRequest{id: $id, to: $toUser, from: $fromUser, ts: $dateTime, accepted: $accepted, denied: $denied}';
  }
}
