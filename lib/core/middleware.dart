import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:package_info/package_info.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:sentry/sentry.dart';

import '../auth/middleware.dart';
import '../selectors.dart';
import '../services/api/models.dart';
import '../services/platform/middleware.dart';
import 'actions.dart';
import 'models.dart';

SentryClient sentryClient;

var initializeApp = (store) => store.dispatch(InitAppAction());

var sendAllMiddleware = (DBRepository dbRepository) =>
    TypedMiddleware<AppState, SendAllActions>(
        (store, SendAllActions action, next) {
      next(action);

      if (store.state.auth.user != null) {
        dbRepository
            .sendUserActions(getLastActions(store.state))
            .then((wasSuccessful) {
          if (wasSuccessful) {
            store.dispatch(ClearAllActions());
          }
        }).catchError((error) {
          print('Send All Actions Platform Error: ${error.details}');
          sentryClient?.captureException(exception: error);
        }, test: (e) => e is PlatformException);
      }
    });

var getDeviceInfo = (DBRepository db) =>
    TypedMiddleware<AppState, GetBuildInfo>(
        (store, GetBuildInfo action, next) {
      next(action);

      PackageInfo.fromPlatform().then((PackageInfo info) async {
        String appName = info.appName;
        String packageName = info.packageName;
        String version = info.version;
        String buildNumber = info.buildNumber;

        Flavor flavor;
        if (packageName == "com.humbleme.humblemeiOS.test" ||
            packageName == "com.humbleme.humblemeandroid.test") {
          flavor = Flavor.development;
        } else {
          flavor = Flavor.production;
        }

        BuildInfo buildInfo = BuildInfo(
          appName: appName,
          packageName: packageName,
          version: version,
          buildNumber: buildNumber,
          flavor: flavor,
        );

        store.dispatch(SetBuildInfo(buildInfo));

        initializeApp(store);
      });
    });

List<Middleware<AppState>> createMiddleware({
  AnalyticsRepository analyticsRepository,
  AuthRepository authRepository,
  DBRepository dbRepository,
  MessagesRepository messageRepository,
  PerformanceMonitoringRepository performance,
  Logger logger,
  SentryClient sentry,
}) {
  sentryClient = sentry;
  List<Middleware<AppState>> middleware = [];
  middleware.addAll(createAuthAnalyticsMiddleware(
      authRepository,
      analyticsRepository,
      dbRepository,
      messageRepository,
      performance,
      sentry));
  middleware.add(sendAllMiddleware(dbRepository));
  middleware.add(getDeviceInfo(dbRepository));
  middleware.addAll(createPlatformMiddleware(sentry));
  if (logger != null) middleware.add(LoggingMiddleware(logger: logger));
  return middleware;
}
