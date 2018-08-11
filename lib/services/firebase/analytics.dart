import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import '../api/models.dart';

class FirebaseAnalyticsRepository implements AnalyticsRepository {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  FirebaseAnalyticsRepository(this.analytics, this.observer);

  @override
  Future<Null> logAppOpen() async {
    await analytics.logAppOpen();
  }

  @override
  Future<Null> logLogin() async {
    await analytics.logLogin();
  }

  @override
  Future<Null> logSignUp({String signUpMethod}) async {
    await analytics.logSignUp(signUpMethod: signUpMethod);
  }

  @override
  Future<Null> logTutorialBegin() async {
    await analytics.logTutorialBegin();
  }

  @override
  Future<Null> logTutorialComplete() async {
    await analytics.logTutorialComplete();
  }

  @override
  Future<Null> logAnalyticsEvent(
      {String name, Map<String, dynamic> parameters}) async {
    await analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  @override
  Future<Null> setAnalyticsCollectionEnabled(bool enabled) async {
    await analytics.android?.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<Null> setCurrentScreen(
      {String screenName, String screenClassOverride}) async {
    await analytics.setCurrentScreen(
        screenName: screenName, screenClassOverride: screenClassOverride);
  }

  @override
  Future<Null> setMinimumSessionDuration(int milliseconds) async {
    await analytics.android?.setMinimumSessionDuration(milliseconds);
  }

  @override
  Future<Null> setUserId(String userId) async {
    await analytics.setUserId(userId);
  }

  @override
  Future<Null> setUserProperty({String name, String value}) async {
    await analytics.setUserProperty(name: name, value: value);
  }
}
