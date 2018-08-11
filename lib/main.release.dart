import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:sentry/sentry.dart';

import 'core/actions.dart';
import 'core/container.dart';
import 'core/middleware.dart';
import 'core/models.dart';
import 'core/reducers.dart';
import 'routes.dart';
import 'services/api/models.dart';
import 'services/firebase/analytics.dart';
import 'services/firebase/auth.dart';
import 'services/firebase/firestore.dart';
import 'services/firebase/messaging.dart';
import 'services/firebase/performance.dart';
import 'theme.dart';

final SentryClient sentryClient = SentryClient(
    dsn:
        'https://8c5902dd400f49e6888eb48fa864bf43:e64f51a4e5fb41feb6f7a99017a5a7ad@sentry.io/1194465');

void main(
    [AnalyticsRepository analyticsRepository,
    AuthRepository authRepository,
    DBRepository dbRepository]) {
  FlutterError.onError = (FlutterErrorDetails details) async {
    await sentryClient.captureException(
        exception: details.exception, stackTrace: details.stack);
  };
  runZoned<Null>(() {
    runApp(HumbleMeApp(
      analyticsRepository: analyticsRepository,
      authRepository: authRepository,
      dbRepository: dbRepository,
    ));
  }, onError: (error, stackTrace) async {
    await sentryClient.captureException(
        exception: error, stackTrace: stackTrace);
  });
}

class HumbleMeApp extends StatefulWidget {
  final Store<AppState> store;

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  HumbleMeApp({
    Key key,
    AnalyticsRepository analyticsRepository,
    AuthRepository authRepository,
    DBRepository dbRepository,
  })  : store = Store<AppState>(
          coreReducer,
          initialState: AppState.loading(),
          middleware: createMiddleware(
            analyticsRepository: analyticsRepository ??
                FirebaseAnalyticsRepository(analytics, observer),
            authRepository: authRepository ??
                FirebaseAuthRepository(
                    auth: firebaseAuth, messaging: firebaseMessaging),
            dbRepository: dbRepository ??
                FirestoreRepository(
                  firestore: Firestore.instance,
                  firebaseAuth: firebaseAuth,
                  storage: FirebaseStorage.instance,
                  performanceMonitoring: FirebasePerformance.instance,
                ),
            messageRepository: FirebaseMessagingRepository(firebaseMessaging),
            performance: FirebasePerformanceRepository(
                performance: FirebasePerformance.instance),
            sentry: sentryClient,
          ),
        ),
        super(key: key) {
    store.dispatch(GetBuildInfo());
  }

  @override
  _HumbleMeAppState createState() => _HumbleMeAppState();
}

class _HumbleMeAppState extends State<HumbleMeApp> {
  ThemeData _theme = HumbleMe.welcomeTheme;

  @override
  void dispose() {
    sentryClient?.close();
    super.dispose();
  }

  void _handleThemeChange(ThemeData newTheme) {
    setState(() {
      _theme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: MaterialApp(
        title: 'HumbleMe',
        theme: _theme,
        home: HMContainer(
          handleThemeChange: _handleThemeChange,
        ),
        navigatorObservers: [HumbleMeApp.observer, Routes.rootObserver],
        routes: Routes.routes,
      ),
    );
  }
}
