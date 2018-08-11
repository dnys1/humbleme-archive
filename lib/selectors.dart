import 'package:flutter/material.dart' hide Notification;

import 'app/models.dart';
import 'auth/models.dart';
import 'core/models.dart';
import 'services/platform/permissions.dart';

AppTab activeTabSelector(AppState state) => state.activeTab;
AppTab initialTabSelector(AppState state) => state.initialTab;

bool isLoadingSelector(AppState state) => state.isLoading;
bool isLoadingUserSelector(AppState state) => state.isLoadingUser;

bool getErrorHasOccurred(AppState state) => state.errorOccurred;

GlobalKey<ScaffoldState> getCurrentScaffold(AppState state) =>
    state.currentScaffold;

List<String> getLastActions(AppState state) => state.allActions;

bool isEmailRegistered(AuthState state) => state.user?.email != null ?? false;
bool isEmailVerified(AuthState state) =>
    state.user?.onboarding?.emailVerified ?? false;
String getVerificationId(AuthState state) => state.verificationId;
User getCurrentUser(AuthState auth) => auth.user;
bool loggedInSelector(AuthState auth) => auth.user != null;
bool signupWasSuccessful(AuthState auth) => auth.wasSuccessful;
bool isImageUploading(AuthState auth) => auth.imageUploading;
bool isPhoneNumberVerified(AuthState auth) =>
    auth.user?.onboarding?.phoneNumberVerified ?? false;

bool hasTakenSingleSelfAssessment(AuthState auth) =>
    (auth.user?.selfAssessmentsTaken?.containsValue(true) ?? false);
bool hasTakenAllSelfAssessments(AuthState auth) =>
    !(auth.user?.selfAssessmentsTaken?.containsValue(false) ?? true);
bool hasClickedSelfAssessments(AuthState auth) =>
    auth.user?.onboarding?.selfAssessmentsClicked ?? false;
bool hasAddFriendsClicked(AuthState auth) =>
    auth.user?.onboarding?.addFriendsClicked ?? false;
bool hasNotificationPermissionsRequested(AuthState auth) =>
    auth.user?.onboarding?.notificationsPermissionRequested ?? false;

Onboarding getUserOnboarding(AuthState auth) => auth.user?.onboarding;

String authError(AuthState auth) => auth.error;
Gender getUserGender(AuthState auth) => auth.user?.gender;
String getUserDisplayName(AuthState auth) => auth.user?.displayName;
String getUsersCurrentPhotoUrl(AuthState auth) => auth.user?.photoUrl;
List<String> getUserPhotoUrls(AuthState auth) => auth.user?.profilePictures;
bool isNameAndNumberRegistered(AuthState auth) =>
    (auth.user?.firstName != null &&
        auth.user?.lastName != null &&
        auth.user?.phoneNumber != null);
List<Mindset> getMindsets(AuthState auth) => auth.mindsets;
List<String> getTopMindsets(AuthState auth) => auth.user?.topMindsets;
Survey getCurrentSurvey(AuthState auth) => auth.currentSurvey;
double getScore(AuthState auth) => auth.user?.score;
int getAppRating(AuthState auth) => auth.user?.appRating;

List<PublicUser> getFriends(AuthState auth) => auth.user?.friends;

List<FriendRequest> getFriendRequestsReceived(AuthState auth) =>
    auth.friendRequestsReceived;
List<FriendRequest> getFriendRequestsSent(AuthState auth) =>
    auth.friendRequestsSent;
List<Survey> getSurveysGiven(AuthState auth) => auth.surveysGiven;
List<Survey> getSurveysReceived(AuthState auth) => auth.surveysReceived;
String getSearchText(AuthState auth) => auth.searchText;
List<PublicUser> getSearchResultsStream(AuthState auth) => auth.searchResults;
Image getUploadImage(AuthState auth) => auth.uploadImage;

bool hasConfiguredNotifications(AppState state) =>
    getDeviceInfo(state).notificationToken != null;
NotificationSettings getNotificationSettings(AuthState auth) =>
    auth.notificationSettings;
String getNotificationToken(AppState state) =>
    getDeviceInfo(state).notificationToken;

Flavor getFlavor(AppState state) => state.buildInfo.flavor;
bool isTestMode(AppState state) => getFlavor(state) == Flavor.development;
BuildInfo getBuildInfo(AppState state) => state.buildInfo;
DeviceInfo getDeviceInfo(AppState state) => state.deviceInfo;
Map<PermissionType, PermissionState> getPermissions(AppState state) =>
    getDeviceInfo(state).permissions;
int getNotificationCount(AuthState auth) => auth.user?.notificationCount;
bool getNotificationsPermissionGranted(AppState state) =>
    getDeviceInfo(state).permissions[PermissionType.notifications] ==
    PermissionState.granted;
bool getPermissionsEnabled(AppState state) {
  DeviceInfo deviceInfo = getDeviceInfo(state);
  return (deviceInfo.permissions[PermissionType.contacts] !=
              PermissionState.unknown &&
          deviceInfo.permissions[PermissionType.contacts] !=
              PermissionState.showRationale) &&
      (deviceInfo.permissions[PermissionType.locationWhenInUse] !=
              PermissionState.unknown &&
          deviceInfo.permissions[PermissionType.locationWhenInUse] !=
              PermissionState.showRationale);
}

List<PublicUser> getFriendsFromContacts(AuthState auth) =>
    auth.friendsFromContacts;

List<Resource> getResources(AppState state) => state.resources;
Test getCurrentTest(AuthState auth) => auth.currentTest;
Map<QuestionSet, bool> getSelfAssessmentsTaken(AuthState auth) =>
    getCurrentUser(auth).selfAssessmentsTaken;

bool appThemeEnabled(AppState state) => state.appThemeEnabled;

List<Score> getScores(AuthState auth) => auth.user?.peerScores;
List<Score> getSelfScores(AuthState auth) => auth.user?.selfScores;
Score getMostRecentScore(AuthState auth) => getScores(auth).first;
Map<Mindsets, bool> getPrivacySettings(AuthState auth) =>
    getMostRecentScore(auth).privacySettings;

List<Notification> getUserNotifications(AuthState auth) => auth.notifications;

Map<QuestionSet, QuestionSetStatistics> getQuestionSetStatistics(
        AppState state) =>
    state.questionSetStatistics;

bool getIsProfilePrivate(AuthState auth) =>
    auth.user?.roles['private'] ?? false;
