import 'dart:ui';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'util.dart';

part 'notification.g.dart';

enum NotificationType {
  NEW_FRIEND_REQUEST,
  NEW_FRIEND,
  NEW_SURVEY,
}

@immutable
@JsonSerializable()
class Notification extends Object with _$NotificationSerializerMixin {
  /// The Firestore reference
  final String id;

  /// If sent as a push notification, include the message id
  @JsonKey(nullable: true)
  final String messageId;

  final String toUser;
  final NotificationType type;
  @JsonKey(fromJson: notificationBodyFromJson)
  final NotificationBody notification;

  /// The notification data
  @JsonKey(fromJson: notificationDataFromJson)
  final NotificationData data;

  @JsonKey(toJson: dateTimeToJson, fromJson: dateTimeFromJson)
  final DateTime dateTime;

  final bool read;

  Notification({
    @required this.id,
    this.messageId,
    this.toUser,
    this.type,
    this.notification,
    this.data,
    this.dateTime,
    this.read,
  });

  factory Notification.fromJson(Map json) => _$NotificationFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Notification &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          messageId == other.messageId &&
          type == other.type &&
          toUser == other.toUser &&
          data == other.data &&
          notification == other.notification &&
          dateTime == other.dateTime &&
          read == other.read;

  @override
  int get hashCode => hashValues(
      id, messageId, type, toUser, notification, data, dateTime, read);

  @override
  String toString() {
    return 'Notification{id: $id, messageId: $messageId, toUser: $toUser, notification: $notification, data: $data, dateTime: $dateTime, read: $read}';
  }
}

@immutable
@JsonSerializable()
class NotificationBody extends Object with _$NotificationBodySerializerMixin {
  final String title;
  final String body;

  NotificationBody({
    this.title,
    this.body,
  });

  factory NotificationBody.fromJson(Map json) =>
      _$NotificationBodyFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationBody &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          body == other.body;

  @override
  int get hashCode => hashValues(title, body);

  @override
  String toString() {
    return '{title: $title, body: $body}';
  }
}

@immutable
@JsonSerializable()
class NotificationData extends Object with _$NotificationDataSerializerMixin {
  /// The profile associated with this notification.
  /// Useful for building routes to other user's profiles
  /// Will be a Firestore user id
  @JsonKey(nullable: true)
  final String profile;

  /// If not associated with a profile, we can include a route
  /// string, such as '/app/resources' which will direct the user
  /// to the correct route.
  final String route;

  /// The icon to show in the notification's screen
  /// Can be a URL i.e. to a user's profile picture
  /// or it can be a path to an image asset
  @JsonKey(nullable: true)
  final String icon;

  NotificationData({
    this.profile,
    this.route,
    this.icon,
  });

  factory NotificationData.fromJson(Map json) =>
      _$NotificationDataFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationData &&
          runtimeType == other.runtimeType &&
          profile == other.profile &&
          icon == other.icon &&
          route == other.route;

  @override
  int get hashCode => hashValues(profile, route, icon);
}
