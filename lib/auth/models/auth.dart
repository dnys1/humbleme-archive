import 'package:flutter/material.dart' hide Notification;
import 'package:meta/meta.dart';

import 'friend_request.dart';
import 'mindset.dart';
import 'notification.dart';
import 'public_user.dart';
import 'survey.dart';
import 'test.dart';
import 'user.dart';

@immutable
class AuthState {
  final bool wasSuccessful;
  final bool imageUploading;
  final String error;
  final String searchText;
  final User user;
  final Survey currentSurvey;
  final Test currentTest;
  final List<Mindset> mindsets;
  final List<FriendRequest> friendRequestsSent;
  final List<FriendRequest> friendRequestsReceived;
  final List<Survey> surveysGiven;
  final List<Survey> surveysReceived;
  final List<PublicUser> searchResults;
  final List<PublicUser> friendsFromContacts;
  final List<Notification> notifications;
  final Image uploadImage;
  final String verificationId;
  final NotificationSettings notificationSettings;

  const AuthState({
    this.wasSuccessful = false,
    this.imageUploading = false,
    this.error,
    this.searchText = '',
    this.user,
    this.currentSurvey,
    this.currentTest,
    this.mindsets,
    this.friendRequestsReceived,
    this.friendRequestsSent,
    this.surveysGiven,
    this.surveysReceived,
    this.searchResults,
    this.friendsFromContacts,
    this.uploadImage,
    this.verificationId,
    this.notificationSettings = const NotificationSettings(),
    this.notifications,
  });

  AuthState copyWith({
    bool wasSuccessful,
    bool imageUploading,
    Survey currentSurvey,
    Test currentTest,
    String error,
    String searchText,
    User user,
    List<Mindset> mindsets,
    List<PublicUser> friends,
    List<FriendRequest> friendRequestsSent,
    List<FriendRequest> friendRequestsReceived,
    List<Survey> surveysGiven,
    List<Survey> surveysReceived,
    List<PublicUser> searchResults,
    List<PublicUser> friendsFromContacts,
    Image uploadImage,
    String verificationId,
    NotificationSettings notificationSettings,
    bool alert,
    bool badge,
    bool sound,
    List<Notification> notifications,
  }) {
    return AuthState(
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      imageUploading: imageUploading ?? this.imageUploading,
      error: error ?? this.error,
      searchText: searchText ?? this.searchText,
      user: user ?? this.user,
      currentSurvey: currentSurvey ?? this.currentSurvey,
      currentTest: currentTest ?? this.currentTest,
      mindsets: mindsets ?? this.mindsets,
      friendRequestsReceived:
          friendRequestsReceived ?? this.friendRequestsReceived,
      friendRequestsSent: friendRequestsSent ?? this.friendRequestsSent,
      surveysGiven: surveysGiven ?? this.surveysGiven,
      surveysReceived: surveysReceived ?? this.surveysReceived,
      searchResults: searchResults ?? this.searchResults,
      uploadImage: uploadImage ?? this.uploadImage,
      verificationId: verificationId ?? this.verificationId,
      friendsFromContacts: friendsFromContacts ?? this.friendsFromContacts,
      notificationSettings: notificationSettings ??
          NotificationSettings(
            alert: alert ?? this.notificationSettings.alert,
            badge: badge ?? this.notificationSettings.badge,
            sound: sound ?? this.notificationSettings.sound,
          ),
      notifications: notifications ?? this.notifications,
    );
  }

  AuthState reset() => AuthState().copyWith(
        mindsets: this.mindsets,
      );

  AuthState resetTest() => AuthState(
        wasSuccessful: this.wasSuccessful,
        imageUploading: this.imageUploading,
        error: this.error,
        searchText: this.searchText,
        user: this.user,
        currentSurvey: this.currentSurvey,
        currentTest: null,
        mindsets: this.mindsets,
        friendRequestsReceived: this.friendRequestsReceived,
        friendRequestsSent: this.friendRequestsSent,
        surveysGiven: this.surveysGiven,
        surveysReceived: this.surveysReceived,
        searchResults: this.searchResults,
        uploadImage: this.uploadImage,
        verificationId: this.verificationId,
        friendsFromContacts: this.friendsFromContacts,
        notificationSettings: this.notificationSettings,
        notifications: this.notifications,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          wasSuccessful == other.wasSuccessful &&
          imageUploading == other.imageUploading &&
          error == other.error &&
          searchText == other.searchText &&
          user == other.user &&
          currentSurvey == other.currentSurvey &&
          currentTest == other.currentTest &&
          mindsets == other.mindsets &&
          friendRequestsReceived == other.friendRequestsReceived &&
          friendRequestsSent == other.friendRequestsSent &&
          surveysGiven == other.surveysGiven &&
          surveysReceived == other.surveysReceived &&
          searchResults == other.searchResults &&
          friendsFromContacts == other.friendsFromContacts &&
          uploadImage == other.uploadImage &&
          verificationId == other.verificationId &&
          notificationSettings == other.notificationSettings &&
          notifications == other.notifications;

  @override
  int get hashCode =>
      error.hashCode ^
      searchText.hashCode ^
      user.hashCode ^
      wasSuccessful.hashCode ^
      imageUploading.hashCode ^
      currentSurvey.hashCode ^
      currentTest.hashCode ^
      mindsets.hashCode ^
      friendRequestsReceived.hashCode ^
      friendRequestsSent.hashCode ^
      surveysGiven.hashCode ^
      surveysReceived.hashCode ^
      searchResults.hashCode ^
      friendsFromContacts.hashCode ^
      uploadImage.hashCode ^
      verificationId.hashCode ^
      notificationSettings.hashCode ^
      notifications.hashCode;

  @override
  String toString() {
    return 'AuthState{wasSuccessful: $wasSuccessful, searchText: $searchText, imageUploading: $imageUploading, error: $error, user: $user, currentSurvey: $currentSurvey, friendRequestsReceived: ${friendRequestsReceived != null}, friendRequestsSent: ${friendRequestsSent != null}, surveysGiven: ${surveysGiven != null}, surveysReceived: ${surveysReceived != null}, searchResultsStream: ${searchResults != null}, notificationSettings: $notificationSettings}';
  }
}

class NotificationSettings {
  final bool alert;
  final bool badge;
  final bool sound;

  const NotificationSettings({
    this.alert = false,
    this.badge = false,
    this.sound = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettings &&
          runtimeType == other.runtimeType &&
          alert == other.alert &&
          badge == other.badge &&
          sound == other.sound;

  @override
  int get hashCode => alert.hashCode ^ badge.hashCode ^ sound.hashCode;

  @override
  String toString() {
    return 'NotificationSettings{alert: $alert, badge: $badge, sound: $sound}';
  }
}
