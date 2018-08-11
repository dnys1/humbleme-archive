import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:meta/meta.dart';

import '../../auth/models.dart';
import '../../core/models.dart';
import '../../services/platform/contacts.dart';
import '../../services/platform/permissions.dart';

typedef Future<dynamic> MessageHandler(Map<String, dynamic> message);

/// A class that sends push notifications
abstract class MessagesRepository {
  Future<String> getNotificationToken();
  void requestNotificationsPermission();
  Stream<String> getTokenStream();
  Stream<NotificationSettings> getIosNotificationSettingsStream();
  void configure({
    MessageHandler onMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
  });
}

abstract class PerformanceMonitoringRepository {
  dynamic getInstance();
  Future<void> startTrace(String name);
  Future<void> stopTrace(String name);
}

/// A class that loads and registers users
abstract class AuthRepository {
  Future<dynamic> checkLoggedIn();
  Future<dynamic> linkEmailAndPassword(
      {@required String email, @required String password});
  Future<String> loginWithEmailAndPassword(
      {@required String email, @required String password});
  Future<String> signupWithEmailAndPassword(
      {@required String email, @required String password});
  Future<void> resendEmailVerification();
  Future<String> signInWithCustomToken(String token);
  Future<void> resetPassword(String email);
  Future<String> signupWithPhoneNumber(String phoneNumber);
  Future<void> logout();
}

abstract class AnalyticsRepository {
  Future<Null> logAnalyticsEvent(
      {String name, Map<String, dynamic> parameters});
  Future<Null> setUserId(String userId);
  Future<Null> setCurrentScreen(
      {String screenName, String screenClassOverride});
  Future<Null> setAnalyticsCollectionEnabled(bool enabled);
  Future<Null> setMinimumSessionDuration(int milliseconds);
  Future<Null> setUserProperty({String name, String value});
  Future<Null> logAppOpen();
  Future<Null> logLogin();
  Future<Null> logSignUp({String signUpMethod});
  Future<Null> logTutorialBegin();
  Future<Null> logTutorialComplete();
}

abstract class DBRepository {
  Future<bool> isLoggedIn();
  Future<bool> isNotLoggedIn();
  Future<String> setNotificationToken(String token);
  Future<bool> resetNotificationsCount();
  Future<bool> deleteNotificationToken();
  Future<List<Mindset>> loadMindsets();
  Future<bool> userCreatedInDb();
  Future<bool> dbStructureUpToDate();
  Future<bool> updateDbStructure();
  Future<bool> deviceCreatedInDb(String deviceId);
  Future<DeviceInfo> getDeviceInfo();
  Future<Stream<DeviceInfo>> getDeviceInfoStream();
  Future<DeviceInfo> updateDeviceInfo({
    BuildInfo buildInfo,
    bool configuredNotifications,
    int notificationsCount,
    String notificationToken,
    AndroidDeviceInfo androidInfo,
    IosDeviceInfo iosInfo,
    List<MapEntry<PermissionType, PermissionState>> updatePermissions,
  });
  bool deviceStructureUpToDate(DeviceInfo deviceInfo);
  Future<DeviceInfo> updateDeviceDbStructure(String deviceId);
  Future<User> getLoggedInUser();
  Future<Stream<User>> getUserStream();
  Future<Stream<List<PublicUser>>> getFriendsStream();
  Future<Stream<List<FriendRequest>>> getFriendRequestsReceivedStream();
  Future<Stream<List<FriendRequest>>> getFriendRequestsSentStream();
  Future<Stream<List<Survey>>> getSurveysGivenStream();
  Future<Stream<List<Survey>>> getSurveysReceivedStream();
  Future<Stream<List<Score>>> getScoresStream({@required bool self});
  Future<List<PublicUser>> getSearchResults(String searchString);
  Stream<List<Mindset>> getGlobalStatsStream();
  Future<Stream<List<Notification>>> getNotificationsStream();
  Future<bool> updateNotificationRead(String notificationId);
  Future<bool> updateNotificationCount(int count);
  Future<bool> clearNotificationCount();
  Future<bool> deleteNotification(String notificationId);
  Future<bool> checkIfEmailVerified(Onboarding onobarding);
  Future<bool> createUserInDatabase({User user});
  Future<bool> updateName(String firstName, String lastName,
      [String displayName]);
  Future<bool> updatePhoneNumber(String phoneNumber);
  Future<bool> updateGender(Gender gender);
  Future<bool> updatePhoto(String photoUrl);
  Future<bool> updateAge(int age);
  Future<bool> updateEmail(String email);
  Future<bool> updateProfile({
    String firstName,
    String lastName,
    String displayName,
    String photoUrl,
    String phoneNumber,
    int age,
    Gender gender,
    String email,
  });
  Future<User> getUser(String id);
  Future<bool> sendUserActions(List<String> actions);
  Future<bool> setOnboardingFinish(Onboarding onboarding);
  Future<bool> recordTopMindsets(List<Mindset> mindsets,
      {@required bool isTestDB});
  Future<bool> submitSurvey(Survey survey);
  Future<bool> addFriend(String friendId);
  Future<bool> acceptFriendRequest(String requestId);
  Future<bool> denyFriendRequest(String requestId);
  Future<bool> setAppRating(int appRating);
  Future<bool> addProfilePicture(File picture);
  Future<List<PublicUser>> getFriendsForContacts(List<Contact> contacts,
      {bool isTest: false});
  Future<bool> linkEmailAndPassword({String email, String password});
  Future<bool> isPhoneVerified(bool isTest);
  Future<bool> setPhoneNumberVerified([Onboarding onboarding]);
  Future<Test> getQuiz({
    @required SurveyInfo surveyInfo,
    @required int length,
    @required bool isTestDB,
  });
  Future<bool> submitQuiz({
    @required SurveyInfo surveyInfo,
    @required Map<Question, int> answers,
    @required bool isTestDB,
    @required bool isSelfAssessment,
    String forUser,
  });
  Future<Map<QuestionSet, QuestionSetStatistics>> loadQuestionSetStatistics();
  Future<List<Resource>> loadResources();
  Future<bool> updateOnboarding(Onboarding onboarding);
  Future<bool> updateBio(String bio);
  Future<bool> updatePrivacySettings(Map<Mindsets, bool> updatedSettings);
  Future<List<String>> getProfilePictures(bool isTest, {String userId});
  Future<bool> updateProfileVisibility(bool private);
}
