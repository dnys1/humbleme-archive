import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import '../app/actions.dart';
import '../services/platform/actions.dart';
import 'actions.dart';
import 'models.dart';

final authReducer = combineReducers<AuthState>([
  TypedReducer<AuthState, ClearAuthError>(_clearErrorReducer),
  TypedReducer<AuthState, UpdateSearchText>(_updateSearchText),
  TypedReducer<AuthState, UpdateSearchResults>(_updateSearchResults),
  TypedReducer<AuthState, ClearSearchResults>(_clearSearchResults),
  TypedReducer<AuthState, UpdateNotificationsSettings>(_notificationSettings),
  TypedReducer<AuthState, CheckLoggedInSuccess>(_getUserLoggedInSuccess),
  TypedReducer<AuthState, LoadMindsetsSuccess>(_loadMindsetsSuccessReducer),
  TypedReducer<AuthState, LoadMindsetsError>(_loadMindsetsErrorReducer),
  TypedReducer<AuthState, LoginSuccess>(_loginSuccessReducer),
  TypedReducer<AuthState, LoginError>(_loginErrorReducer),
  TypedReducer<AuthState, EmailAndPasswordSuccess>(_signupSuccessReducer),
  TypedReducer<AuthState, EmailAndPasswordError>(_signupErrorReducer),
  TypedReducer<AuthState, AddProfilePictureAction>(_addProfileImageInit),
  TypedReducer<AuthState, AddProfilePictureSuccess>(_addProfileImageSuccess),
  TypedReducer<AuthState, UpdateUserInfo>(_updateUserInfo),
  TypedReducer<AuthState, UpdateFriends>(_updateFriends),
  TypedReducer<AuthState, UpdateFriendRequestsReceived>(
      _updateFriendRequestsReceived),
  TypedReducer<AuthState, UpdateFriendRequestsSent>(_updateFriendRequestsSent),
  TypedReducer<AuthState, UpdateSurveysGiven>(_updateSurveysGiven),
  TypedReducer<AuthState, UpdateSurveysReceived>(_updateSurveysReceived),
  TypedReducer<AuthState, GetFriendsForContactsResponse>(
      _friendsForContactsReducer),
  TypedReducer<AuthState, LogoutAction>(_logoutReducer),
  TypedReducer<AuthState, SetAssessment>(_createTest),
  TypedReducer<AuthState, ClearAssessment>(_clearTest),
  TypedReducer<AuthState, SubmitAssessment>(_finishTest),
  TypedReducer<AuthState, SetPhoneVerificationID>(_setVerificationId),
  TypedReducer<AuthState, UpdateNotifications>(_updateNotifications),
  TypedReducer<AuthState, UpdateScores>(_updateScores),
]);

AuthState _updateSearchText(AuthState auth, UpdateSearchText action) {
  return auth.copyWith(
    searchText: action.searchText,
  );
}

AuthState _updateSearchResults(AuthState auth, UpdateSearchResults action) {
  return auth.copyWith(
    searchResults: action.results,
  );
}

AuthState _clearSearchResults(AuthState auth, ClearSearchResults action) {
  return auth.copyWith(
    searchResults: const [],
  );
}

AuthState _clearErrorReducer(AuthState auth, ClearAuthError action) {
  return auth.copyWith(
    error: '',
  );
}

AuthState _notificationSettings(
    AuthState auth, UpdateNotificationsSettings action) {
  return auth.copyWith(
    alert: action.alert,
    badge: action.badge,
    sound: action.sound,
  );
}

AuthState _getUserLoggedInSuccess(AuthState auth, CheckLoggedInSuccess action) {
  return auth.copyWith(
    user: action.user,
  );
}

AuthState _loadMindsetsSuccessReducer(
    AuthState auth, LoadMindsetsSuccess action) {
  return auth.copyWith(
    mindsets: action.mindsets,
  );
}

AuthState _loadMindsetsErrorReducer(AuthState auth, LoadMindsetsError action) {
  return auth.copyWith(
    error: action.error,
  );
}

AuthState _loginSuccessReducer(AuthState auth, LoginSuccess action) {
  return auth.copyWith(
    user: action.user,
  );
}

AuthState _loginErrorReducer(AuthState auth, LoginError action) {
  return auth.copyWith(
    error: action.error,
  );
}

AuthState _signupSuccessReducer(
    AuthState auth, EmailAndPasswordSuccess action) {
  return auth.copyWith(
    user: action.user,
    wasSuccessful: true,
  );
}

AuthState _signupErrorReducer(AuthState auth, EmailAndPasswordError action) {
  return auth.copyWith(
    error: action.error,
    wasSuccessful: false,
  );
}

AuthState _setVerificationId(AuthState auth, SetPhoneVerificationID action) {
  return auth.copyWith(
    verificationId: action.verificationId,
  );
}

AuthState _friendsForContactsReducer(
    AuthState auth, GetFriendsForContactsResponse action) {
  return auth.copyWith(
    friendsFromContacts: action.users,
  );
}

AuthState _createTest(AuthState auth, SetAssessment action) {
  return auth.copyWith(
    currentTest: action.test,
  );
}

AuthState _finishTest(AuthState auth, SubmitAssessment action) {
  return auth.resetTest();
}

AuthState _clearTest(AuthState auth, ClearAssessment action) {
  return auth.resetTest();
}

AuthState _updateUserInfo(AuthState auth, UpdateUserInfo action) {
  var newUser = action.user;
  return auth.copyWith(
    user: auth.user.copyWith(
      firstName: newUser.firstName,
      lastName: newUser.lastName,
      email: newUser.email,
      displayName: newUser.displayName,
      photoUrl: newUser.photoUrl,
      profilePictures: newUser.profilePictures,
      phoneNumber: newUser.phoneNumber,
      bio: newUser.bio,
      age: newUser.age,
      gender: newUser.gender,
      score: newUser.score,
      topMindsets: newUser.topMindsets,
      appRating: newUser.appRating,
      school: newUser.school,
      roles: newUser.roles,
      lastUsedDeviceId: newUser.lastUsedDeviceId,
      peerScores: newUser.peerScores,
      selfScores: newUser.selfScores,
      selfAssessmentsTaken: newUser.selfAssessmentsTaken,
      notificationCount: newUser.notificationCount,
      onboarding: newUser.onboarding,
      surveysGiven: newUser.surveysGiven,
      surveysReceived: newUser.surveysReceived,
    ),
  );
}

AuthState _updateScores(AuthState auth, UpdateScores action) {
  return auth.copyWith(
    user: action.self
        ? auth.user.copyWith(
            selfScores: action.scores,
          )
        : auth.user.copyWith(
            peerScores: action.scores,
          ),
  );
}

AuthState _updateFriends(AuthState auth, UpdateFriends action) {
  return auth.copyWith(
    user: auth.user.copyWith(
      friends: action.friends,
    ),
  );
}

AuthState _updateFriendRequestsReceived(
    AuthState auth, UpdateFriendRequestsReceived action) {
  return auth.copyWith(
    friendRequestsReceived: action.friendRequestsReceived,
  );
}

AuthState _updateFriendRequestsSent(
    AuthState auth, UpdateFriendRequestsSent action) {
  return auth.copyWith(
    friendRequestsSent: action.friendRequestsSent,
  );
}

AuthState _updateSurveysGiven(AuthState auth, UpdateSurveysGiven action) {
  return auth.copyWith(
    surveysGiven: action.surveys,
  );
}

AuthState _updateSurveysReceived(AuthState auth, UpdateSurveysReceived action) {
  return auth.copyWith(
    surveysReceived: action.surveys,
  );
}

AuthState _addProfileImageInit(AuthState auth, AddProfilePictureAction action) {
  return auth.copyWith(
    imageUploading: true,
    uploadImage: Image.file(action.picture),
  );
}

AuthState _addProfileImageSuccess(
    AuthState auth, AddProfilePictureSuccess action) {
  return auth.copyWith(
    imageUploading: false,
  );
}

AuthState _logoutReducer(AuthState auth, LogoutAction action) {
  return const AuthState().reset();
}

AuthState _updateNotifications(AuthState auth, UpdateNotifications action) {
  return auth.copyWith(
    notifications: action.notifications,
  );
}
