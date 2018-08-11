import 'package:redux/redux.dart';
import 'package:sentry/sentry.dart';

import '../../core/actions.dart';
import '../../core/models.dart';
import 'actions.dart';
import 'contacts.dart';
import 'permissions.dart';

SentryClient sentry;

void captureError(Store<AppState> store, Object error,
    [StackTrace stackTrace]) {
  store.dispatch(GlobalErrorAction(error, stackTrace));
  sentry?.captureException(exception: error, stackTrace: stackTrace ?? null);
}

createPlatformMiddleware([SentryClient sentryClient]) {
  sentry = sentryClient ?? null;
  return <Middleware<AppState>>[
    TypedMiddleware<AppState, RequestPermission>(_requestPermission()),
    TypedMiddleware<AppState, GetPermissionState>(_getPermissionState()),
    TypedMiddleware<AppState, GetContacts>(_getContacts()),
  ];
}

_getPermissionState() {
  return (Store<AppState> store, GetPermissionState action, next) {
    next(action);

    Permissions
        .getPermissionState(action.permissionType)
        .then((state) =>
            store.dispatch(UpdatePermission(action.permissionType, state)))
        .catchError((error, stack) => captureError(store, error, stack));
  };
}

_requestPermission() {
  return (Store<AppState> store, RequestPermission action, next) {
    next(action);

    Permissions
        .requestPermission(action.permissionType)
        .then((state) =>
            store.dispatch(UpdatePermission(action.permissionType, state)))
        .catchError((error, stack) => captureError(store, error, stack));
  };
}

_getContacts() {
  return (Store<AppState> store, GetContacts action, next) {
    next(action);

    Contacts.getContactsWithMobileNumber().then((contacts) {
      store.dispatch(GetFriendsForContacts(contacts));
    }).catchError((error, stack) => captureError(store, error, stack));
  };
}
