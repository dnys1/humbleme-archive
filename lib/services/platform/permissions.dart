import 'dart:async';

import 'package:flutter/services.dart';

enum PermissionType {
  contacts,
  locationAlways,
  locationWhenInUse,
  notifications,
  microphone,
  camera,
  photos,
  reminders,
  events,
  bluetooth,
  motion,
  storage
}
enum PermissionState { granted, denied, showRationale, unknown }

class Permissions {
  static MethodChannel methodChannel =
      const MethodChannel('humbleme/permissions');

  static List<PermissionType> allPermissions = <PermissionType>[
    PermissionType.contacts,
    PermissionType.locationWhenInUse,
    PermissionType.locationAlways,
  ];

  static Future<PermissionState> getPermissionState(PermissionType type) async {
    final int permissionInt =
        await methodChannel.invokeMethod('getPermissionState', type.index);
    return PermissionState.values.elementAt(permissionInt);
  }

  static Future<PermissionState> requestPermission(PermissionType type) async {
    try {
      final int result =
          await methodChannel.invokeMethod('requestPermission', type.index);
      return PermissionState.values.elementAt(result);
    } catch (e) {
      print('Exception ' + e.toString());
      return PermissionState.denied;
    }
  }
}
