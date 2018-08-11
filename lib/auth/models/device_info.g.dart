// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => new DeviceInfo(
    isAndroid: json['isAndroid'] as bool,
    deviceIdentifier: json['deviceIdentifier'] as String,
    systemVersion: json['systemVersion'] as String,
    appVersion: json['appVersion'] as String,
    androidSdk: json['androidSdk'] as int,
    configuredNotifications: json['configuredNotifications'] as bool,
    isPhysicalDevice: json['isPhysicalDevice'] as bool,
    notificationToken: json['notificationToken'] as String,
    permissions: json['permissions'] == null
        ? null
        : permissionsFromJson(json['permissions'] as Map<dynamic, dynamic>));

abstract class _$DeviceInfoSerializerMixin {
  bool get isAndroid;
  String get deviceIdentifier;
  String get systemVersion;
  String get appVersion;
  int get androidSdk;
  bool get configuredNotifications;
  bool get isPhysicalDevice;
  String get notificationToken;
  Map<PermissionType, PermissionState> get permissions;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'isAndroid': isAndroid,
        'deviceIdentifier': deviceIdentifier,
        'systemVersion': systemVersion,
        'appVersion': appVersion,
        'androidSdk': androidSdk,
        'configuredNotifications': configuredNotifications,
        'isPhysicalDevice': isPhysicalDevice,
        'notificationToken': notificationToken,
        'permissions':
            permissions == null ? null : permissionsToJson(permissions)
      };
}
