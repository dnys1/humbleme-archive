import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../app/models.dart';
import '../auth/models.dart';
import '../auth/models/device_info.dart';
import '../auth/models/resource.dart';

enum Flavor { development, production }

@immutable
class AppState {
  final bool isLoading;
  final bool isLoadingUser;
  final bool appThemeEnabled;
  final AppTab activeTab;
  final AppTab initialTab;
  final AuthState auth;
  final List<String> allActions;
  final Function(ThemeData) handleThemeChange;
  final BuildInfo buildInfo;
  final DeviceInfo deviceInfo;
  final GlobalKey<ScaffoldState> currentScaffold;
  final List<Resource> resources;
  final Map<QuestionSet, QuestionSetStatistics> questionSetStatistics;
  final bool errorOccurred;

  const AppState({
    this.isLoading = true,
    this.isLoadingUser = true,
    this.appThemeEnabled = false,
    this.activeTab = AppTab.home,
    this.initialTab,
    this.auth = const AuthState(),
    this.allActions = const [],
    this.handleThemeChange,
    this.buildInfo,
    this.deviceInfo,
    this.currentScaffold,
    this.errorOccurred = false,
    this.resources,
    this.questionSetStatistics,
  });

  factory AppState.loading() => const AppState();

  AppState reset() => AppState.loading().copyWith(
        isLoading: false,
        auth: auth.reset(),
        buildInfo: this.buildInfo,
        handleThemeChange: this.handleThemeChange,
        resources: this.resources,
        questionSetStatistics: this.questionSetStatistics,
      );

  AppState copyWith({
    bool isLoading,
    bool isLoadingUser,
    bool appThemeEnabled,
    AppTab activeTab,
    AppTab initialTab,
    AuthState auth,
    List<String> allActions,
    Function(ThemeData) handleThemeChange,
    BuildInfo buildInfo,
    DeviceInfo deviceInfo,
    GlobalKey<ScaffoldState> currentScaffold,
    bool errorOccurred,
    List<Resource> resources,
    Map<QuestionSet, QuestionSetStatistics> questionSetStatistics,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingUser: isLoadingUser ?? this.isLoadingUser,
      appThemeEnabled: appThemeEnabled ?? this.appThemeEnabled,
      activeTab: activeTab ?? this.activeTab,
      initialTab: initialTab ?? this.initialTab,
      auth: auth ?? this.auth,
      allActions: allActions ?? this.allActions,
      handleThemeChange: handleThemeChange ?? this.handleThemeChange,
      buildInfo: buildInfo ?? this.buildInfo,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      currentScaffold: currentScaffold ?? this.currentScaffold,
      errorOccurred: errorOccurred ?? this.errorOccurred,
      resources: resources ?? this.resources,
      questionSetStatistics:
          questionSetStatistics ?? this.questionSetStatistics,
    );
  }

  @override
  int get hashCode =>
      isLoading.hashCode ^
      isLoadingUser.hashCode ^
      appThemeEnabled.hashCode ^
      activeTab.hashCode ^
      initialTab.hashCode ^
      auth.hashCode ^
      allActions.hashCode ^
      deviceInfo.hashCode ^
      currentScaffold.hashCode ^
      errorOccurred.hashCode ^
      resources.hashCode ^
      questionSetStatistics.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isLoadingUser == other.isLoadingUser &&
          appThemeEnabled == other.appThemeEnabled &&
          activeTab == other.activeTab &&
          initialTab == other.initialTab &&
          auth == other.auth &&
          allActions == other.allActions &&
          deviceInfo == other.deviceInfo &&
          currentScaffold == other.currentScaffold &&
          errorOccurred == other.errorOccurred &&
          resources == other.resources &&
          questionSetStatistics == other.questionSetStatistics;

  @override
  String toString() {
    return 'AppState{isLoading: $isLoading, isLoadingUser: $isLoadingUser, appThemeEnabled: $appThemeEnabled, errorOccurred: $errorOccurred, initalTab: $initialTab, activeTab: $activeTab, auth: $auth, handleThemeChange: isNull = ${handleThemeChange == null}, deviceInfo: $deviceInfo, resources: $resources}';
  }
}

class BuildInfo {
  String appName;
  String packageName;
  String version;
  String buildNumber;
  Flavor flavor;

  BuildInfo({
    this.appName,
    this.packageName,
    this.version,
    this.buildNumber,
    this.flavor,
  });

  @override
  int get hashCode =>
      hashValues(appName, packageName, version, buildNumber, flavor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildInfo &&
          appName == other.appName &&
          packageName == other.packageName &&
          version == other.version &&
          buildNumber == other.buildNumber &&
          flavor == other.flavor;

  @override
  String toString() {
    return 'BuildInfo{flavor: $flavor, appName: $appName, packageName: $packageName, version: $version, buildNumber: $buildNumber}';
  }
}
