import 'dart:async';

import 'package:flutter/material.dart' hide Notification;
import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:sentry/sentry.dart' hide User;

import '../app/actions.dart';
import '../app/models.dart';
import '../auth/actions.dart';
import '../auth/models.dart';
import '../core/actions.dart';
import '../core/models.dart';
import '../selectors.dart';
import '../services/api/models.dart';
import '../services/platform/actions.dart';
import '../services/platform/permissions.dart';
import '../services/platform/phoneNumber.dart';
import '../theme.dart';
import 'actions.dart';

Stream<User> _userStream;
Stream<List<PublicUser>> _friendsStream;
Stream<List<FriendRequest>> _friendRequestsReceivedStream;
Stream<List<FriendRequest>> _friendRequestsSentStream;
Stream<List<Survey>> _surveysReceivedStream;
Stream<List<Survey>> _surveysGivenStream;
Stream<DeviceInfo> _deviceInfoStream;
Stream<List<Score>> _peerScoresStream;
Stream<List<Score>> _selfScoresStream;
Stream<List<Notification>> _notificationsStream;

StreamSubscription<List<PublicUser>> _friendsSubscription;
StreamSubscription<List<FriendRequest>> _friendRequestsReceivedSubscription;
StreamSubscription<List<FriendRequest>> _friendRequestsSentSubscription;
StreamSubscription<List<Survey>> _surveysGivenSubscription;
StreamSubscription<List<Survey>> _surveysReceivedSubscription;
StreamSubscription<User> _userSubscription;
StreamSubscription<DeviceInfo> _deviceInfoSubscription;
StreamSubscription<List<Score>> _selfScoresSubscription;
StreamSubscription<List<Score>> _peerScoresSubscription;
StreamSubscription<List<Notification>> _notificationsSubscription;

SentryClient sentryClient;

void handleMiddlewareError(Store<AppState> store, Object error,
    [StackTrace stackTrace]) {
  print(error.toString());
  print(stackTrace.toString());
  store.dispatch(GlobalErrorAction(error, stackTrace));
  sentryClient?.captureException(exception: error, stackTrace: stackTrace);
}

createAuthAnalyticsMiddleware(
  AuthRepository authRepository,
  AnalyticsRepository analytics,
  DBRepository dbRepository,
  MessagesRepository messageRepository,
  PerformanceMonitoringRepository performance,
  SentryClient sentry,
) {
  sentryClient = sentry;
  return <Middleware<AppState>>[
    TypedMiddleware<AppState, InitAppAction>(
      _firestoreOnInit(
        authRepository,
        dbRepository,
        analytics,
        messageRepository,
        performance,
      ),
    ),
    TypedMiddleware<AppState, GlobalErrorAction>(_handleGlobalError()),
    TypedMiddleware<AppState, ResumeSubscriptions>(_resumeSubscriptions()),
    TypedMiddleware<AppState, PauseSubscriptions>(_pauseSubscriptions()),
    TypedMiddleware<AppState, SetNotificationToken>(
        _firestoreSetNotificationToken(dbRepository)),
    TypedMiddleware<AppState, PushNotificationReceived>(
        _firestoreResetNotificationsCount(dbRepository)),
    TypedMiddleware<AppState, UpdatePermission>(
        _firestoreUpdatePermission(dbRepository)),
    TypedMiddleware<AppState, UpdatePermissions>(
        _firestoreUpdatePermissions(dbRepository)),
    TypedMiddleware<AppState, GetSearchResults>(
        _getSearchResults(dbRepository)),
    TypedMiddleware<AppState, LoginAction>(
      _firestoreLoginWithUsernameAndPassword(
        authRepository,
        analytics,
        dbRepository,
        messageRepository,
        performance,
      ),
    ),
    TypedMiddleware<AppState, SetTheme>(_setTheme()),
    TypedMiddleware<AppState, ResetPassword>(_resetPassword(authRepository)),
    TypedMiddleware<AppState, OnboardingStart>(
        _firebaseOnboardingStart(analytics)),
    TypedMiddleware<AppState, OnboardingFinish>(
        _firestoreOnboardingFinish(analytics, dbRepository)),
    TypedMiddleware<AppState, NameAndNumberAction>(
        _signupWithPhoneNumber(dbRepository)),
    TypedMiddleware<AppState, UpdateGenderAction>(
        _firestoreUpdateGender(dbRepository)),
    TypedMiddleware<AppState, UpdateAgeAction>(
        _firestoreUpdateAge(dbRepository)),
    TypedMiddleware<AppState, RecordTopMindsets>(
        _firestoreRecordTopMindsets(dbRepository)),
    TypedMiddleware<AppState, AddFriendAction>(
        _firestoreAddFriend(authRepository, dbRepository)),
    TypedMiddleware<AppState, AcceptFriendAction>(
        _firstStoreAcceptFriendRequest(dbRepository)),
    TypedMiddleware<AppState, DenyFriendAction>(
        _firstStoreDenyFriendRequest(dbRepository)),
    TypedMiddleware<AppState, AddProfilePictureAction>(
        _firestoreUploadProfileImage(dbRepository)),
    TypedMiddleware<AppState, SetAppRating>(
        _firestoreSetAppRating(dbRepository)),
    TypedMiddleware<AppState, LogoutAction>(
        _firestoreLogout(authRepository, dbRepository, analytics)),
    TypedMiddleware<AppState, SendPhoneNumberVerification>(
        _sendPhoneNumberVerification()),
    TypedMiddleware<AppState, ResendPhoneNumberVerification>(
        _resendPhoneNumberVerification()),
    TypedMiddleware<AppState, EmailAndPasswordAction>(
      _signupWithEmail(
        authRepository,
        dbRepository,
        messageRepository,
        performance,
      ),
    ),
    TypedMiddleware<AppState, ResendEmailVerification>(
        _resendEmailVerification(authRepository)),
    TypedMiddleware<AppState, RecheckEmailVerification>(
        _recheckEmailVerification(dbRepository)),
    TypedMiddleware<AppState, GetFriendsForContacts>(
        _firestoreGetFriendsForContacts(dbRepository)),
    TypedMiddleware<AppState, VerifyPhoneNumberWithCode>(
        _linkPhoneNumberToUser(dbRepository)),
    TypedMiddleware<AppState, CheckPhoneVerified>(
        _checkIfPhoneNumberVerified(dbRepository)),
    TypedMiddleware<AppState, EnablePushNotifications>(
        _enablePushNotifications(messageRepository)),
    TypedMiddleware<AppState, GetAssessment>(
        _firestoreGetAssessment(dbRepository)),
    TypedMiddleware<AppState, SubmitAssessment>(
        _firestoreSubmitAssessment(dbRepository)),
    TypedMiddleware<AppState, UpdateOnboarding>(
        _firestoreUpdateOnboarding(dbRepository)),
    TypedMiddleware<AppState, UpdateBio>(_firestoreUpdateBio(dbRepository)),
    TypedMiddleware<AppState, UpdateNotificationRead>(
        _updateNotificationRead(dbRepository)),
    TypedMiddleware<AppState, ClearNotificationCount>(
        _clearNotificationCount(dbRepository)),
    TypedMiddleware<AppState, DeleteNotification>(
        _deleteNotification(dbRepository)),
    TypedMiddleware<AppState, UpdateCurrentTabAction>(
        _updateTabAction(dbRepository)),
    TypedMiddleware<AppState, UpdateProfileVisibility>(
        _updateProfileVisibility(dbRepository)),
    TypedMiddleware<AppState, UpdatePrivacySettings>(
        _firestoreUpdatePrivacySettings(dbRepository)),
  ];
}

_firestoreOnInit(
  AuthRepository auth,
  DBRepository db,
  AnalyticsRepository analytics,
  MessagesRepository messages,
  PerformanceMonitoringRepository performance,
) {
  return (Store<AppState> store, InitAppAction action, next) async {
    next(action);
    await performance.startTrace('load_all');
    // Don't wait for these things to complete
    db
        .loadMindsets()
        .then((mindsets) => store.dispatch(LoadMindsetsSuccess(mindsets)))
        .catchError(
            (error, stack) => handleMiddlewareError(store, error, stack));

    db
        .loadResources()
        .then((resources) => store.dispatch(SetAllResources(resources)))
        .catchError(
            (error, stack) => handleMiddlewareError(store, error, stack));

    db
        .loadQuestionSetStatistics()
        .then((questionSetStatistics) =>
            store.dispatch(SetQuestionSetStatistics(questionSetStatistics)))
        .catchError(
            (error, stack) => handleMiddlewareError(store, error, stack));

    // Get the logged in user
    // Then, and only then, perform necessary DB functions
    User user = await db.getLoggedInUser();
    if (user != null) {
      // Get device information
      await _configureDeviceInfo(store, db, performance);
      _configurePushNotifications(store, messages);
      _getUserDataAndSetListeners(auth, db, store);
    }
    store.dispatch(CheckLoggedInSuccess(user));
    await performance.stopTrace('load_all');
    // }
  };
}

_enablePushNotifications(MessagesRepository messages) {
  return (Store<AppState> store, EnablePushNotifications action, next) async {
    await _setupPushNotifications(store, messages);

    next(action);
  };
}

_handleGlobalError() {
  return (Store<AppState> store, GlobalErrorAction action, next) {
    next(action);

    String message;
    if (action.error is PlatformException) {
      var exception = action.error as PlatformException;
      message = exception.details ?? exception.message;
    } else {
      message = action.error.toString();
    }

    // When using Cupertino widgets for scaffolding, this will not work
    if (kIsAndroid || !loggedInSelector(store.state.auth)) {
      getCurrentScaffold(store.state)?.currentState?.showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 2, milliseconds: 500),
            ),
          );
    }

    Future
        .delayed(const Duration(milliseconds: 100))
        .then((_) => store.dispatch(ClearAuthError()));
  };
}

Future<void> _configureDeviceInfo(Store<AppState> store, DBRepository db,
    PerformanceMonitoringRepository performance) async {
  await performance.startTrace('load_platform_device_info');
  DeviceInfo deviceInfo =
      await db.updateDeviceInfo(buildInfo: getBuildInfo(store.state));
  await performance.stopTrace('load_platform_device_info');
  store.dispatch(SetDeviceInfo(deviceInfo));
  await performance.startTrace('load_platform_permissions');
  await _getAllPermissions(store);
  await performance.stopTrace('load_platform_permissions');
}

_setupPushNotifications(
  Store<AppState> store,
  MessagesRepository messages,
) async {
  messages.requestNotificationsPermission();
  String notificationToken = await messages.getNotificationToken();
  store.dispatch(SetNotificationToken(notificationToken));
  await _configurePushNotifications(store, messages);
}

_configurePushNotifications(
  Store<AppState> store,
  MessagesRepository messages,
) async {
  messages
      .getTokenStream()
      .listen((token) => store.dispatch(SetNotificationToken(token)));
  messages.getIosNotificationSettingsStream().listen((settings) {
    bool granted = settings.alert || settings.badge || settings.sound;
    store.dispatch(
      UpdatePermission(PermissionType.notifications,
          granted ? PermissionState.granted : PermissionState.denied),
    );
  });
  messages.configure(
      // App is in the foreground for all messsages
      // App is in the background for data message
      onMessage: (Map<String, dynamic> data) async {
    store.dispatch(PushNotificationReceived(data));
  },
      // App is terminated for notification messages
      // Fired when app is re-launched
      onLaunch: (Map<String, dynamic> data) async {
    store.dispatch(PushNotificationReceived(data));
    store.dispatch(UpdateInitialTabAction(AppTab.notifications));
  },
      // App is in the background for notification messages
      // Fired when app resumes
      onResume: (Map<String, dynamic> data) async {
    store.dispatch(PushNotificationReceived(data));
    store.dispatch(UpdateCurrentTabAction(AppTab.notifications));
  });
}

_getAllPermissions(Store<AppState> store) async {
  List<MapEntry<PermissionType, PermissionState>> mapEntries =
      await Future.wait(
    Permissions.allPermissions.map((permission) => Permissions
        .getPermissionState(permission)
        .then((state) => MapEntry(permission, state))),
  );
  store.dispatch(UpdatePermissions(mapEntries));
}

_firestoreSetNotificationToken(DBRepository db) {
  return (Store<AppState> store, SetNotificationToken action, next) {
    next(action);

    db
        .setNotificationToken(action.notificationToken)
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_firestoreResetNotificationsCount(DBRepository db) {
  return (Store<AppState> store, PushNotificationReceived action, next) {
    next(action);

    db
        .resetNotificationsCount()
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_resetPassword(AuthRepository auth) {
  return (Store<AppState> store, ResetPassword action, next) {
    next(action);

    auth
        .resetPassword(action.email)
        .then((_) => store.dispatch(ResetPasswordSuccess()))
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_getSearchResults(DBRepository db) {
  return (Store<AppState> store, GetSearchResults action, next) {
    next(action);

    db
        .getSearchResults(action.searchString)
        .then((results) => store.dispatch(UpdateSearchResults(results)))
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_getUserDataAndSetListeners(
    AuthRepository auth, DBRepository db, Store<AppState> store) async {
  print('Setting listeners!');

  // User stream (for score updating)
  _userStream = await db.getUserStream();
  _userSubscription = _userStream.listen(
    (newUserInfo) {
      store.dispatch(UpdateUserInfo(newUserInfo));
    },
    onError: (error, stackTrace) =>
        handleMiddlewareError(store, error, stackTrace),
  );

  // Device info stream (for changes in permissions, etc.)
  _deviceInfoStream = await db.getDeviceInfoStream();
  _deviceInfoSubscription = _deviceInfoStream.listen(
    (newDeviceInfo) {
      store.dispatch(SetDeviceInfo(newDeviceInfo));
    },
    onError: (error, stackTrace) =>
        handleMiddlewareError(store, error, stackTrace),
  );

  // Friend Requests Received
  _friendRequestsReceivedStream = await db.getFriendRequestsReceivedStream();
  _friendRequestsReceivedSubscription = _friendRequestsReceivedStream.listen(
    (friendRequestsReceived) {
      store.dispatch(UpdateFriendRequestsReceived(friendRequestsReceived));
    },
    onError: (error, stackTrace) =>
        handleMiddlewareError(store, error, stackTrace),
  );

  // Friend Requests Sent
  _friendRequestsSentStream = await db.getFriendRequestsSentStream();
  _friendRequestsSentSubscription = _friendRequestsSentStream.listen(
    (friendRequestsSent) {
      store.dispatch(UpdateFriendRequestsSent(friendRequestsSent));
    },
    onError: (error, stackTrace) =>
        handleMiddlewareError(store, error, stackTrace),
  );

  // Friends
  _friendsStream = await db.getFriendsStream();
  _friendsSubscription = _friendsStream.listen(
    (friends) {
      store.dispatch(UpdateFriends(friends));
    },
    onError: (error, stackTrace) =>
        handleMiddlewareError(store, error, stackTrace),
  );

  // Surveys Given
  _surveysGivenStream = await db.getSurveysGivenStream();
  _surveysGivenSubscription = _surveysGivenStream.listen(
    (surveysGiven) {
      store.dispatch(UpdateSurveysGiven(surveysGiven));
    },
    onError: (error, stackTrace) =>
        handleMiddlewareError(store, error, stackTrace),
  );

  // Surveys received
  _surveysReceivedStream = await db.getSurveysReceivedStream();
  _surveysReceivedSubscription = _surveysReceivedStream.listen(
    (surveysReceived) {
      store.dispatch(UpdateSurveysReceived(surveysReceived));
    },
    onError: (error, stackTrace) =>
        handleMiddlewareError(store, error, stackTrace),
  );

  _selfScoresStream = await db.getScoresStream(self: true);
  _selfScoresSubscription = _selfScoresStream.listen(
    (selfScores) {
      store.dispatch(UpdateScores(true, selfScores));
    },
    onError: (error, stackTrace) =>
        handleMiddlewareError(store, error, stackTrace),
  );

  _peerScoresStream = await db.getScoresStream(self: false);
  _peerScoresSubscription = _peerScoresStream.listen(
    (peerScores) {
      store.dispatch(UpdateScores(false, peerScores));
    },
    onError: (error, stackTrace) =>
        handleMiddlewareError(store, error, stackTrace),
  );

  _notificationsStream = await db.getNotificationsStream();
  _notificationsSubscription = _notificationsStream.listen(
    (notifications) {
      store.dispatch(UpdateNotifications(notifications));
    },
    onError: (error, stack) => handleMiddlewareError(store, error, stack),
  );

  print('Listeners set!');
}

_firestoreUpdatePermission(DBRepository db) {
  return (Store<AppState> store, UpdatePermission action, next) {
    next(action);

    db
        .updateDeviceInfo(updatePermissions: [
          MapEntry(action.permissionType, action.permissionState)
        ])
        .then((DeviceInfo deviceInfo) =>
            store.dispatch(SetDeviceInfo(deviceInfo)))
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_firestoreUpdatePermissions(DBRepository db) {
  return (Store<AppState> store, UpdatePermissions action, next) async {
    try {
      var deviceInfo = await db.updateDeviceInfo(
          updatePermissions: action.permissionUpdates);
      store.dispatch(SetDeviceInfo(deviceInfo));
    } catch (error, stack) {
      handleMiddlewareError(store, error, stack);
    } finally {
      next(action);
    }
  };
}

_firestoreUpdatePrivacySettings(DBRepository db) {
  return (Store<AppState> store, UpdatePrivacySettings action, next) async {
    await db.updatePrivacySettings(action.privacySettings);

    next(action);
  };
}

_resumeSubscriptions() {
  return (Store<AppState> store, ResumeSubscriptions action, next) {
    if (_userSubscription == null ||
        _friendsSubscription == null ||
        _friendRequestsSentSubscription == null ||
        _friendRequestsReceivedSubscription == null ||
        _surveysGivenSubscription == null ||
        _surveysReceivedSubscription == null ||
        _deviceInfoSubscription == null) return;

    next(action);

    if (_userSubscription.isPaused) _userSubscription.resume();
    if (_friendsSubscription.isPaused) _friendsSubscription.resume();
    if (_friendRequestsReceivedSubscription.isPaused)
      _friendRequestsReceivedSubscription.resume();
    if (_friendRequestsSentSubscription.isPaused)
      _friendRequestsSentSubscription.resume();
    if (_surveysGivenSubscription.isPaused) _surveysGivenSubscription.resume();
    if (_surveysReceivedSubscription.isPaused)
      _surveysReceivedSubscription.resume();
    if (_deviceInfoSubscription.isPaused) _deviceInfoSubscription.resume();
    if (_selfScoresSubscription.isPaused) _selfScoresSubscription.resume();
    if (_peerScoresSubscription.isPaused) _peerScoresSubscription.resume();
  };
}

_pauseSubscriptions() {
  return (Store<AppState> store, PauseSubscriptions action, next) {
    next(action);

    if (_userSubscription != null && !_userSubscription.isPaused)
      _userSubscription.pause();
    if (_friendsSubscription != null && !_friendsSubscription.isPaused)
      _friendsSubscription.pause();
    if (_friendRequestsReceivedSubscription != null &&
        !_friendRequestsReceivedSubscription.isPaused)
      _friendRequestsReceivedSubscription.pause();
    if (_friendRequestsSentSubscription != null &&
        !_friendRequestsSentSubscription.isPaused)
      _friendRequestsSentSubscription.pause();
    if (_surveysGivenSubscription != null &&
        !_surveysGivenSubscription.isPaused) _surveysGivenSubscription.pause();
    if (_surveysReceivedSubscription != null &&
        !_surveysReceivedSubscription.isPaused)
      _surveysReceivedSubscription.pause();
    if (_deviceInfoSubscription != null && !_deviceInfoSubscription.isPaused)
      _deviceInfoSubscription.pause();
    if (_selfScoresSubscription != null && !_selfScoresSubscription.isPaused) {
      _selfScoresSubscription.pause();
    }
    if (_peerScoresSubscription != null && !_peerScoresSubscription.isPaused) {
      _peerScoresSubscription.pause();
    }
  };
}

Future _cancelSubscriptions() async {
  print('Starting subscription cancel.');
  return await Future.wait([
    Future.value(true), // In case the following values are all null
    _userSubscription?.cancel(),
    _friendsSubscription?.cancel(),
    _friendRequestsReceivedSubscription?.cancel(),
    _friendRequestsSentSubscription?.cancel(),
    _surveysGivenSubscription?.cancel(),
    _surveysReceivedSubscription?.cancel(),
    _deviceInfoSubscription?.cancel(),
    _selfScoresSubscription?.cancel(),
    _peerScoresSubscription?.cancel(),
    _notificationsSubscription?.cancel(),
  ]);
}

_updateNotificationRead(DBRepository db) {
  return (Store<AppState> store, UpdateNotificationRead action, next) async {
    next(action);

    int notificationCount = getNotificationCount(store.state.auth);
    await db.updateNotificationRead(action.notification.id);
    await db.updateNotificationCount(notificationCount - 1);
  };
}

_clearNotificationCount(DBRepository db) {
  return (Store<AppState> store, ClearNotificationCount action, next) async {
    next(action);

    await db.clearNotificationCount();
  };
}

_deleteNotification(DBRepository db) {
  return (Store<AppState> store, DeleteNotification action, next) async {
    next(action);

    int notificationCount = getNotificationCount(store.state.auth);

    await db.deleteNotification(action.notification.id);
    if (!action.notification.read) {
      await db.updateNotificationCount(notificationCount - 1);
    }
  };
}

_resendEmailVerification(AuthRepository auth) {
  return (Store<AppState> store, ResendEmailVerification action, next) {
    next(action);

    auth
        .resendEmailVerification()
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_recheckEmailVerification(DBRepository db) {
  return (Store<AppState> store, RecheckEmailVerification action, next) {
    next(action);

    db
        .checkIfEmailVerified(getUserOnboarding(store.state.auth))
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_sendPhoneNumberVerification() {
  return (Store<AppState> store, SendPhoneNumberVerification action, next) {
    next(action);

    PhoneNumberVerification
        .getVerificationID(action.phoneNumber)
        .then((verificationId) =>
            store.dispatch(SetPhoneVerificationID(verificationId)))
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_resendPhoneNumberVerification() {
  return (Store<AppState> store, ResendPhoneNumberVerification action, next) {
    next(action);

    PhoneNumberVerification
        .getVerificationID(action.phoneNumber)
        .then((verificationId) =>
            store.dispatch(SetPhoneVerificationID(verificationId)))
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_linkPhoneNumberToUser(
  DBRepository db,
) {
  return (Store<AppState> store, VerifyPhoneNumberWithCode action, next) async {
    try {
      bool success = await PhoneNumberVerification.loginWithCredentials(
          action.verificationId, action.verificationCode);

      if (success) {
        await db.setPhoneNumberVerified(getUserOnboarding(store.state.auth));
      } else {
        print('Error linking phone number.');
        return;
      }
    } catch (error, stack) {
      handleMiddlewareError(store, error, stack);
    } finally {
      next(action);
    }
  };
}

_checkIfPhoneNumberVerified(DBRepository db) {
  return (Store<AppState> store, CheckPhoneVerified action, next) async {
    bool verified = await db.isPhoneVerified(isTestMode(store.state));

    if (verified) {
      await db.setPhoneNumberVerified(getUserOnboarding(store.state.auth));
    }

    next(action);
  };
}

_firestoreLoginWithUsernameAndPassword(
  AuthRepository auth,
  AnalyticsRepository analytics,
  DBRepository db,
  MessagesRepository messages,
  PerformanceMonitoringRepository performance,
) {
  return (Store<AppState> store, LoginAction action, next) async {
    try {
      await auth.loginWithEmailAndPassword(
          email: action.data.email, password: action.data.password);
      var user = await db.getLoggedInUser();
      if (user != null) {
        // Get device information like model, build, and permissions
        await _configureDeviceInfo(store, db, performance);

        // Setup push notifications
        await _configurePushNotifications(store, messages);

        analytics.logLogin();
        analytics.setUserId(user.id);

        // Can be run asynchronously
        _getUserDataAndSetListeners(auth, db, store);

        store.dispatch(LoginSuccess(user));
      }
    } catch (error, stack) {
      handleMiddlewareError(store, error, stack);
    } finally {
      next(action);
    }
  };
}

_firestoreGetFriendsForContacts(DBRepository db) {
  return (Store<AppState> store, GetFriendsForContacts action, next) async {
    try {
      var users = await db.getFriendsForContacts(
        action.contacts,
        isTest: getFlavor(store.state) == Flavor.development,
      );
      store.dispatch(GetFriendsForContactsResponse(users));
    } catch (error, stack) {
      handleMiddlewareError(store, error, stack);
    } finally {
      next(action);
    }
  };
}

_setTheme() {
  return (Store<AppState> store, SetTheme action, next) {
    next(action);

    store.state.handleThemeChange(action.newTheme);
  };
}

_signupWithPhoneNumber(DBRepository db) {
  return (Store<AppState> store, NameAndNumberAction action, next) {
    next(action);

    () async {
      try {
        await db.updateName(action.data.firstName, action.data.lastName);
        await db.updatePhoneNumber(action.data.phoneNumber);
      } catch (error, stack) {
        handleMiddlewareError(store, error, stack);
      }
    }();

    // store.dispatch(SendPhoneNumberVerification(action.data.phoneNumber));
  };
}

_signupWithEmail(
  AuthRepository auth,
  DBRepository db,
  MessagesRepository messages,
  PerformanceMonitoringRepository performance,
) {
  return (Store<AppState> store, EmailAndPasswordAction action, next) async {
    try {
      var userId = await auth.signupWithEmailAndPassword(
          email: action.data.email, password: action.data.password);
      if (userId != null) {
        await db.createUserInDatabase();
        User user = await db.getLoggedInUser();
        if (user != null) {
          // Configure device settings retrieval
          await _configureDeviceInfo(store, db, performance);

          // Setup push notifications
          await _configurePushNotifications(store, messages);

          // Can run asynchronously. Do not need to wait
          _getUserDataAndSetListeners(auth, db, store);

          store.dispatch(EmailAndPasswordSuccess(user));
        } else {
          store.dispatch(GlobalErrorAction("An unknown error occurred", null));
        }
      } else {
        store.dispatch(GlobalErrorAction("An unknown error occurred", null));
      }
    } catch (error, stack) {
      handleMiddlewareError(store, error, stack);
    } finally {
      next(action);
    }
  };
}

_firestoreUpdateGender(DBRepository db) {
  return (Store<AppState> store, UpdateGenderAction action, next) {
    next(action);
    db
        .updateGender(action.gender)
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_firestoreUpdateAge(DBRepository db) {
  return (Store<AppState> store, UpdateAgeAction action, next) {
    next(action);
    db
        .updateAge(action.age)
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_firebaseOnboardingStart(AnalyticsRepository analytics) {
  return (Store<AppState> store, OnboardingStart action, next) {
    next(action);
    analytics.logTutorialBegin();
  };
}

_firestoreOnboardingFinish(AnalyticsRepository analytics, DBRepository db) {
  return (Store<AppState> store, OnboardingFinish action, next) {
    next(action);
    analytics.logTutorialComplete();
    db
        .setOnboardingFinish(getUserOnboarding(store.state.auth))
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_firestoreRecordTopMindsets(DBRepository db) {
  return (Store<AppState> store, RecordTopMindsets action, next) {
    next(action);
    db
        .recordTopMindsets(action.data.topMindsets,
            isTestDB: getFlavor(store.state) == Flavor.development)
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_firestoreAddFriend(AuthRepository auth, DBRepository db) {
  return (Store<AppState> store, AddFriendAction action, next) {
    next(action);

    db
        .addFriend(action.friendId)
        .then((_) => store.dispatch(AddFriendResponse(action.friendId)))
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_firstStoreAcceptFriendRequest(DBRepository db) {
  return (Store<AppState> store, AcceptFriendAction action, next) {
    next(action);

    db
        .acceptFriendRequest(action.requestId)
        .then((_) => store.dispatch(AcceptFriendResponse(action.requestId)))
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_firstStoreDenyFriendRequest(DBRepository db) {
  return (Store<AppState> store, DenyFriendAction action, next) {
    next(action);

    db
        .denyFriendRequest(action.requestId)
        .then((_) => store.dispatch(DenyFriendResponse(action.requestId)))
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_firestoreUploadProfileImage(DBRepository db) {
  return (Store<AppState> store, AddProfilePictureAction action, next) {
    next(action);

    db.addProfilePicture(action.picture).then((success) {
      store.dispatch(AddProfilePictureSuccess());
    }).catchError((error) => handleMiddlewareError(store, error));
  };
}

_firestoreSetAppRating(DBRepository db) {
  return (Store<AppState> store, SetAppRating action, next) {
    next(action);

    db
        .setAppRating(action.rating)
        .then((_) => store.dispatch(SetAppRatingSuccess(action.rating)))
        .catchError((error) => handleMiddlewareError(store, error));
  };
}

_firestoreLogout(
  AuthRepository auth,
  DBRepository db,
  AnalyticsRepository analytics,
) {
  return (Store<AppState> store, LogoutAction action, next) async {
    try {
      await _cancelSubscriptions();
      print('Success ending services');
      // store.dispatch(SetTheme(HumbleMe.welcomeTheme, false));
      await auth.logout();
    } catch (error) {
      print('Error logging out: $error');
      // handleMiddlewareError(store, error, stack);
    } finally {
      next(action);
    }
  };
}

_firestoreGetAssessment(DBRepository db) {
  return (Store<AppState> store, GetAssessment action, next) async {
    Test test = await db.getQuiz(
      isTestDB: getFlavor(store.state) == Flavor.development,
      length: action.length,
      surveyInfo: action.surveyInfo,
    );
    store.dispatch(SetAssessment(test));

    next(action);
  };
}

_firestoreSubmitAssessment(DBRepository db) {
  return (Store<AppState> store, SubmitAssessment action, next) async {
    await db.submitQuiz(
      surveyInfo: action.surveyInfo,
      answers: action.answers,
      isTestDB: getFlavor(store.state) == Flavor.development,
      forUser: action.forUser,
      isSelfAssessment: action.isSelfAssessment,
    );

    next(action);
  };
}

_firestoreUpdateOnboarding(DBRepository db) {
  return (Store<AppState> store, UpdateOnboarding action, next) async {
    await db.updateOnboarding(action.onboarding);

    next(action);
  };
}

_firestoreUpdateBio(DBRepository db) {
  return (Store<AppState> store, UpdateBio action, next) async {
    await db.updateBio(action.bio);

    next(action);
  };
}

_updateTabAction(DBRepository db) {
  return (Store<AppState> store, UpdateCurrentTabAction action, next) async {
    AppTab currentTab = activeTabSelector(store.state);
    AppTab nextTab = action.newTab;

    next(action);

    // If user moves away from the notifications screen, mark all unread
    // notifications as read.
    if (currentTab == AppTab.notifications && nextTab != AppTab.notifications) {
      await db.clearNotificationCount();
      for (Notification notification
          in getUserNotifications(store.state.auth)) {
        if (!notification.read) {
          await db.updateNotificationRead(notification.id);
        }
      }
    }
  };
}

_updateProfileVisibility(DBRepository db) {
  return (Store<AppState> store, UpdateProfileVisibility action, next) async {
    await db.updateProfileVisibility(action.private);

    next(action);
  };
}
