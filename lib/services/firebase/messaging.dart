import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart' hide MessageHandler;

import '../../auth/models.dart';
import '../api/models.dart';

class FirebaseMessagingRepository extends MessagesRepository {
  final FirebaseMessaging messaging;

  FirebaseMessagingRepository(this.messaging);

  @override
  Future<String> getNotificationToken() async {
    return await messaging
        .getToken()
        .timeout(Duration(milliseconds: 500), onTimeout: () => null);
  }

  @override
  void requestNotificationsPermission() {
    messaging.requestNotificationPermissions();
  }

  @override
  Stream<String> getTokenStream() {
    return messaging.onTokenRefresh;
  }

  @override
  Stream<NotificationSettings> getIosNotificationSettingsStream() {
    return messaging.onIosSettingsRegistered
        .map((settings) => NotificationSettings(
              badge: settings.badge,
              alert: settings.alert,
              sound: settings.sound,
            ));
  }

  @override
  void configure({
    MessageHandler onMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
  }) {
    messaging.configure(
      onMessage: onMessage,
      onLaunch: onLaunch,
      onResume: onResume,
    );
  }
}
