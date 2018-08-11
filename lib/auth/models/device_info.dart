import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../../services/platform/permissions.dart';
import 'util.dart';

part 'device_info.g.dart';

@immutable
@JsonSerializable()
class DeviceInfo extends Object with _$DeviceInfoSerializerMixin {
  final bool isAndroid;
  final String deviceIdentifier;
  final String systemVersion;
  final String appVersion;
  final int androidSdk;

  final bool configuredNotifications;
  final bool isPhysicalDevice;
  final String notificationToken;

  @JsonKey(toJson: permissionsToJson, fromJson: permissionsFromJson)
  final Map<PermissionType, PermissionState> permissions;

  DeviceInfo({
    this.isAndroid,
    this.deviceIdentifier,
    this.systemVersion,
    this.appVersion,
    this.androidSdk,
    this.configuredNotifications = false,
    this.isPhysicalDevice = true,
    this.notificationToken,
    Map<PermissionType, PermissionState> permissions,
  }) : permissions = permissions ??
            Map.fromEntries(PermissionType.values
                .map((type) => MapEntry(type, PermissionState.unknown)));

  DeviceInfo copyWith({
    bool isAndroid,
    String deviceIdentifier,
    String systemVersion,
    String appVersion,
    int androidSdk,
    bool configuredNotifications,
    bool isPhysicalDevice,
    int notificationCount,
    String notificationToken,
    Map<PermissionType, PermissionState> permissions,
    List<MapEntry<PermissionType, PermissionState>> updatePermissions,
  }) {
    if (updatePermissions != null) {
      permissions = this.permissions;
      updatePermissions.forEach(
        (updatePermission) => permissions.update(
            updatePermission.key, (_) => updatePermission.value),
      );
    }
    return DeviceInfo(
      isAndroid: isAndroid ?? this.isAndroid,
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
      systemVersion: systemVersion ?? this.systemVersion,
      appVersion: appVersion ?? this.appVersion,
      androidSdk: androidSdk ?? this.androidSdk,
      configuredNotifications:
          configuredNotifications ?? this.configuredNotifications,
      notificationToken: notificationToken ?? this.notificationToken,
      permissions: permissions ?? this.permissions,
      isPhysicalDevice: isPhysicalDevice ?? this.isPhysicalDevice,
    );
  }

  DeviceInfo reset({
    bool configuredNotifications = false,
    bool notificationCount = false,
    bool notificationToken = false,
    bool permissions = false,
  }) {
    return DeviceInfo(
      isAndroid: this.isAndroid,
      deviceIdentifier: this.deviceIdentifier,
      systemVersion: this.systemVersion,
      appVersion: this.appVersion,
      androidSdk: this.androidSdk,
      configuredNotifications:
          configuredNotifications ? false : this.configuredNotifications,
      notificationToken: notificationToken ? null : this.notificationToken,
      permissions: permissions
          ? Map.fromEntries(PermissionType.values
              .map((type) => MapEntry(type, PermissionState.unknown)))
          : this.permissions,
      isPhysicalDevice: this.isPhysicalDevice,
    );
  }

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceInfo &&
          runtimeType == other.runtimeType &&
          isAndroid == other.isAndroid &&
          deviceIdentifier == other.deviceIdentifier &&
          systemVersion == other.systemVersion &&
          appVersion == other.appVersion &&
          androidSdk == other.androidSdk &&
          notificationToken == other.notificationToken &&
          permissions == other.permissions &&
          isPhysicalDevice == other.isPhysicalDevice;

  @override
  int get hashCode =>
      isAndroid.hashCode ^
      deviceIdentifier.hashCode ^
      systemVersion.hashCode ^
      appVersion.hashCode ^
      androidSdk.hashCode ^
      notificationToken.hashCode ^
      permissions.hashCode ^
      isPhysicalDevice.hashCode;

  @override
  String toString() {
    return 'DeviceInfo{isAndroid: $isAndroid, isPhysicalDevice: $isPhysicalDevice, deviceIdentifier: $deviceIdentifier, systemVersion: $systemVersion, appVersion: $appVersion, androidSdk: $androidSdk, notificationToken: $notificationToken, permissions: $permissions}';
  }
}
