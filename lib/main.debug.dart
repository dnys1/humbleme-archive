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
import 'package:logging/logging.dart';
import 'package:redux/redux.dart';

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

void main(
    [AnalyticsRepository analyticsRepository,
    AuthRepository authRepository,
    DBRepository dbRepository,
    MessagesRepository messageRepository]) {
  var app = HumbleMeApp(
    analyticsRepository: analyticsRepository,
    authRepository: authRepository,
    dbRepository: dbRepository,
    messageRepository: messageRepository,
  );
  runZoned(
    () => runApp(app),
    onError: (error, stack) =>
        app.store.dispatch(GlobalErrorAction(error, stack)),
  );
}

class HumbleMeApp extends StatefulWidget {
  final Store<AppState> store;
  static Logger logger = Logger("Redux Logger");

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
    MessagesRepository messageRepository,
  })  : store = Store<AppState>(
          coreReducer,
          initialState: AppState.loading(),
          middleware: createMiddleware(
            analyticsRepository: analyticsRepository ??
                FirebaseAnalyticsRepository(analytics, observer),
            authRepository: authRepository ??
                FirebaseAuthRepository(auth: firebaseAuth),
            dbRepository: dbRepository ??
                FirestoreRepository(
                  firestore: Firestore.instance,
                  firebaseAuth: firebaseAuth,
                  storage: FirebaseStorage.instance,
                  performanceMonitoring: FirebasePerformance.instance,
                ),
            performance: FirebasePerformanceRepository(
                performance: FirebasePerformance.instance),
            messageRepository: messageRepository ??
                FirebaseMessagingRepository(firebaseMessaging),
            logger: logger,
          ),
        ),
        super(key: key) {
    logger.onRecord
        .where((record) => record.loggerName == logger.name)
        .listen((middlewareRecord) => print(middlewareRecord));

    // First dispatch an action to get this build's info
    // After this is asynchronously complete, the InitApp action
    // will fire and trigger the db configuration.
    store.dispatch(GetBuildInfo());
  }

  @override
  _HumbleMeAppState createState() => _HumbleMeAppState();
}

class _HumbleMeAppState extends State<HumbleMeApp> {
  ThemeData _theme = HumbleMe.welcomeTheme;

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
        debugShowCheckedModeBanner: false,
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
