import 'package:flutter/material.dart';

import '../auth/models/device_info.dart';
import 'models.dart';

class InitAppAction {
  InitAppAction();

  @override
  String toString() {
    return 'InitAppAction{}';
  }
}

class GlobalErrorAction {
  Object error;
  StackTrace stackTrace;

  GlobalErrorAction(this.error, this.stackTrace);

  @override
  String toString() {
    return 'GlobalErrorAction{error: ${error.toString()}}';
  }
}

class DidChangeLifecycleState {
  AppLifecycleState appLifecycleState;

  DidChangeLifecycleState(this.appLifecycleState);

  @override
  String toString() {
    return 'DidChangeLifecycleState{lifecycleState: $appLifecycleState}';
  }
}

class DidPushRoute {
  String route;

  DidPushRoute(this.route);

  @override
  String toString() {
    return 'DidPushRoute{route: $route}';
  }
}

class SendAllActions {
  SendAllActions();

  @override
  String toString() {
    return 'SendAllActions{}';
  }
}

class ClearAllActions {
  ClearAllActions();

  @override
  String toString() {
    return 'ClearAllActions{}';
  }
}

class SetThemeChangeHandler {
  Function(ThemeData) handler;

  SetThemeChangeHandler(this.handler);

  @override
  String toString() {
    return 'SetThemeChangeHandler{handler: null = ${handler == null}}';
  }
}

class SetTheme {
  ThemeData newTheme;
  bool appTheme;

  SetTheme(this.newTheme, this.appTheme);

  @override
  String toString() {
    return 'SetTheme{newTheme: null = ${newTheme == null}}';
  }
}

class GetBuildInfo {
  GetBuildInfo();

  @override
  String toString() {
    return 'GetBuildInfo{}';
  }
}

class SetBuildInfo {
  BuildInfo buildInfo;

  SetBuildInfo(this.buildInfo);

  @override
  String toString() {
    return 'SetBuildInfo{buildInfo: $buildInfo}';
  }
}

class GetDeviceInfo {
  GetDeviceInfo();

  @override
  String toString() {
    return 'GetDeviceInfo{}';
  }
}

class SetDeviceInfo {
  DeviceInfo deviceInfo;

  SetDeviceInfo(this.deviceInfo);

  @override
  String toString() {
    return 'SetDeviceInfo{deviceInfo: $deviceInfo}';
  }
}

class SetCurrentScaffold {
  GlobalKey<ScaffoldState> currentScaffold;

  SetCurrentScaffold(this.currentScaffold);

  @override
  String toString() {
    return 'SetCurrentScaffold{currentScaffold is ${currentScaffold == null ? "" : "not "}null';
  }
}
