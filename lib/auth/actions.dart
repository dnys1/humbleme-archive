import 'dart:io';

import 'package:meta/meta.dart';

import '../welcome/intro/models.dart';
import '../welcome/login/models.dart';
import '../welcome/signup/models.dart';
import 'models.dart';

class CheckLoggedInSuccess {
  final User user;

  CheckLoggedInSuccess(this.user);

  @override
  String toString() {
    return 'CheckLoggedInSuccess{userData: $user}';
  }
}

class CheckLoggedInError {
  final String error;

  CheckLoggedInError(this.error);

  @override
  String toString() {
    return 'CheckLoggedInError{error: $error}';
  }
}

class PushNotificationReceived {
  Map<String, dynamic> data;

  PushNotificationReceived(this.data);

  @override
  String toString() {
    return 'PushNotificationReceived{data: $data}';
  }
}

class SetNotificationToken {
  String notificationToken;

  SetNotificationToken(this.notificationToken);

  @override
  String toString() {
    return 'SetNotificationToken{}';
  }
}

class SetNotificationTokenResponse {
  String notificationToken;

  SetNotificationTokenResponse(this.notificationToken);

  @override
  String toString() {
    return 'SetNotificationTokenResponse{}';
  }
}

class RequestPushNotifications {
  RequestPushNotifications();

  @override
  String toString() {
    return 'RequestPushNotifications{}';
  }
}

class RequestPushNotificationsResponse {
  bool success;

  RequestPushNotificationsResponse(this.success);

  @override
  String toString() {
    return 'RequestPushNotificationsResponse{success: $success}';
  }
}

class UpdateNotificationsSettings {
  bool alert;
  bool badge;
  bool sound;

  UpdateNotificationsSettings({this.alert, this.badge, this.sound});

  @override
  String toString() {
    return 'UpdateNotificationsSettings{alert: $alert, badge: $badge, sound: $sound}';
  }
}

class LoadMindsetsSuccess {
  List<Mindset> mindsets;

  LoadMindsetsSuccess(this.mindsets);

  @override
  String toString() {
    return 'LoadMindsetsSuccess{mindsets: ${mindsets != null && mindsets != []}}';
  }
}

class LoadMindsetsError {
  String error;

  LoadMindsetsError(this.error);

  @override
  String toString() {
    return 'LoadMindsetsError{error: $error}';
  }
}

class RecordTopMindsets {
  TopMindsetsData data;

  RecordTopMindsets(this.data);

  @override
  String toString() {
    return 'RecordTopMindsets{data: $data}';
  }
}

class LoginAction {
  LoginData data;

  LoginAction(this.data);

  @override
  String toString() {
    return 'LoginAction{data: $data}';
  }
}

class LoginSuccess {
  User user;

  LoginSuccess(this.user);

  @override
  String toString() {
    return 'LoginSuccess{user: $user}';
  }
}

class LoginError {
  String error;

  LoginError(this.error);

  @override
  String toString() {
    return 'LoginError{message: $error}';
  }
}

class EmailAndPasswordAction {
  EmailAndPasswordData data;

  EmailAndPasswordAction(this.data);

  @override
  String toString() {
    return 'EmailAndPasswordAction{data: $data}';
  }
}

class EmailAndPasswordSuccess {
  User user;

  EmailAndPasswordSuccess(this.user);

  @override
  String toString() {
    return 'EmailAndPasswordSuccess{userData: $user}';
  }
}

class EmailAndPasswordError {
  final String error;

  EmailAndPasswordError(this.error);

  @override
  String toString() {
    return 'EmailAndPasswordError{error: $error}';
  }
}

class ResetPassword {
  String email;

  ResetPassword(this.email);

  @override
  String toString() {
    return 'ResetPassword{email: $email}';
  }
}

class ResetPasswordSuccess {
  ResetPasswordSuccess();

  @override
  String toString() {
    return 'ResetPasswordSuccess{}';
  }
}

class ResetPasswordError {
  String error;

  ResetPasswordError(this.error);

  @override
  String toString() {
    return 'ResetPasswordError{error: $error}';
  }
}

class LogoutAction {
  LogoutAction();

  @override
  String toString() {
    return 'LogoutAction{}';
  }
}

class NameAndNumberAction {
  NameAndNumberData data;

  NameAndNumberAction(this.data);

  @override
  String toString() {
    return 'NameAndNumberAction{data: $data}';
  }
}

class OnboardingStart {
  OnboardingStart();

  @override
  String toString() {
    return 'OnboardingStart{}';
  }
}

class OnboardingFinish {
  OnboardingFinish();

  @override
  String toString() {
    return 'OnboardingFinish{}';
  }
}

class UpdateGenderAction {
  Gender gender;

  UpdateGenderAction(this.gender);

  @override
  String toString() {
    return 'UpdateGender{gender: $gender}';
  }
}

class UpdateAgeAction {
  int age;

  UpdateAgeAction(this.age);

  @override
  String toString() {
    return 'UpdateAgeAction{age: $age}';
  }
}

class GetSearchResults {
  String searchString;

  GetSearchResults(this.searchString);

  @override
  String toString() {
    return 'GetSearchResults{searchString: $searchString}';
  }
}

class UpdateSearchResults {
  List<PublicUser> results;

  UpdateSearchResults(this.results);

  @override
  String toString() {
    return 'UpdateSearchResults{results: ${results != null}}';
  }
}

class ClearSearchResults {
  ClearSearchResults();

  @override
  String toString() {
    return 'ClearSearchResults{}';
  }
}

class ClearAuthError {
  ClearAuthError();

  @override
  String toString() {
    return 'ClearAuthError{}';
  }
}

class CreateSurvey {
  String toUser;
  String fromUser;

  CreateSurvey({
    this.toUser,
    this.fromUser,
  });

  @override
  String toString() {
    return 'CreateSurvey{toUser: $toUser, fromUser: $fromUser}';
  }
}

class ClearSurvey {
  ClearSurvey();

  @override
  String toString() {
    return 'ClearSurvey{}';
  }
}

class SubmitSurvey {
  Survey survey;

  SubmitSurvey(this.survey);

  @override
  String toString() {
    return 'SubmitSurvey{toUser: $survey}';
  }
}

class SubmitSurveyResponse {
  SubmitSurveyResponse();

  @override
  String toString() {
    return 'SubmitSurveyResponse{}';
  }
}

class SubmitSurveyError {
  String error;

  SubmitSurveyError(this.error);

  @override
  String toString() {
    return 'SubmitSurveyError{error: $error}';
  }
}

class RecordSurveyAnswer {
  String mindsetId;
  int selectedCharacter;
  bool completed;

  RecordSurveyAnswer({
    this.mindsetId,
    this.selectedCharacter,
    this.completed = false,
  });

  @override
  String toString() {
    return 'RecordSurveyAnswer{mindset: $mindsetId, selectedCharacter: $selectedCharacter, completed: $completed}';
  }
}

// class RecordSurveyAnswerResponse {
//   String mindsetId;
//   int selectedCharacter;

//   RecordSurveyAnswerResponse({this.mindsetId, this.selectedCharacter});

//   @override
//   String toString() {
//     return 'RecordSurveyAnswerResponse{mindset: $mindsetId, selectedCharacter: $selectedCharacter}';
//   }
// }

class UpdateSurveyAnswer {
  String mindsetId;
  int selectedCharacter;

  UpdateSurveyAnswer({this.mindsetId, this.selectedCharacter});

  @override
  String toString() {
    return 'UpdateSurveyAnswer{mindset: $mindsetId, selectedCharacter: $selectedCharacter}';
  }
}

class UpdateSurveyAnswerResponse {
  String mindsetId;
  int selectedCharacter;

  UpdateSurveyAnswerResponse({this.mindsetId, this.selectedCharacter});

  @override
  String toString() {
    return 'UpdateSurveyAnswer{mindset: $mindsetId, selectedCharacter: $selectedCharacter}';
  }
}

class AddProfilePictureAction {
  File picture;

  AddProfilePictureAction(this.picture);

  @override
  String toString() {
    return 'AddProfilePictureAction{}';
  }
}

class AddProfilePictureSuccess {
  AddProfilePictureSuccess();

  @override
  String toString() {
    return 'AddProfilePictureSuccess{}';
  }
}

class AddProfilePictureError {
  String error;

  AddProfilePictureError(this.error);

  @override
  String toString() {
    return 'AddProfilePictureError{error: $error}';
  }
}

class AddFriendAction {
  String friendId;

  AddFriendAction(this.friendId);

  @override
  String toString() {
    return 'AddFriendAction{friendId: $friendId}';
  }
}

class AddFriendResponse {
  String friendId;

  AddFriendResponse(this.friendId);

  @override
  String toString() {
    return 'AddFriendResponse{friendId: $friendId}';
  }
}

class AddFriendError {
  String friendId;

  AddFriendError(this.friendId);

  @override
  String toString() {
    return 'AddFriendError{friendId: $friendId}';
  }
}

class DenyFriendAction {
  String requestId;

  DenyFriendAction(this.requestId);

  @override
  String toString() {
    return 'DenyFriendAction{friendId: $requestId}';
  }
}

class DenyFriendResponse {
  String requestId;

  DenyFriendResponse(this.requestId);

  @override
  String toString() {
    return 'DenyFriendResponse{friendId: $requestId}';
  }
}

class DenyFriendError {
  String error;

  DenyFriendError(this.error);

  @override
  String toString() {
    return 'DenyFriendError{error: $error}';
  }
}

class AcceptFriendAction {
  String requestId;

  AcceptFriendAction(this.requestId);

  @override
  String toString() {
    return 'AcceptFriendAction{friendId: $requestId}';
  }
}

class AcceptFriendResponse {
  String requestId;

  AcceptFriendResponse(this.requestId);

  @override
  String toString() {
    return 'AcceptFriendResponse{friendId: $requestId}';
  }
}

class AcceptFriendError {
  String friendId;

  AcceptFriendError(this.friendId);

  @override
  String toString() {
    return 'AcceptFriendError{friendId: $friendId}';
  }
}

class SetAppRating {
  int rating;

  SetAppRating(this.rating);

  @override
  String toString() {
    return 'SetAppRating{rating: $rating}';
  }
}

class SetAppRatingSuccess {
  int rating;

  SetAppRatingSuccess(this.rating);

  @override
  String toString() {
    return 'SetAppRatingSuccess{rating: $rating}';
  }
}

class SetAppRatingError {
  String error;

  SetAppRatingError(this.error);

  @override
  String toString() {
    return 'SetAppRatingError{error: $error}';
  }
}

class UpdateUserInfo {
  User user;

  UpdateUserInfo(this.user);

  @override
  String toString() {
    return 'UpdateUserInfo{}';
  }
}

class UpdateFriends {
  List<PublicUser> friends;

  UpdateFriends(this.friends);

  @override
  String toString() {
    return 'UpdateFriends{friends: $friends}';
  }
}

class UpdateFriendRequestsSent {
  List<FriendRequest> friendRequestsSent;

  UpdateFriendRequestsSent(this.friendRequestsSent);

  @override
  String toString() {
    return 'UpdateFriendRequestsSent{friends: $friendRequestsSent}';
  }
}

class UpdateFriendRequestsReceived {
  List<FriendRequest> friendRequestsReceived;

  UpdateFriendRequestsReceived(this.friendRequestsReceived);

  @override
  String toString() {
    return 'UpdateFriendRequestsReceived{friends: $friendRequestsReceived}';
  }
}

class UpdateSurveysGiven {
  List<Survey> surveys;

  UpdateSurveysGiven(this.surveys);

  @override
  String toString() {
    return 'UpdateSurveysGiven{}';
  }
}

class UpdateSurveysReceived {
  List<Survey> surveys;

  UpdateSurveysReceived(this.surveys);

  @override
  String toString() {
    return 'UpdateSurveysReceived{}';
  }
}

class UpdateScores {
  List<Score> scores;
  bool self;

  UpdateScores(this.self, this.scores);

  @override
  String toString() {
    return 'UpdateScores{self: $self, scores: $scores}';
  }
}

class UpdateGlobalStats {
  List<Mindset> stats;

  UpdateGlobalStats(this.stats);

  @override
  String toString() {
    return 'UpdateGlobalStats{stats: $stats}';
  }
}

class PauseSubscriptions {
  PauseSubscriptions();

  @override
  String toString() {
    return 'PauseSubscriptions{}';
  }
}

class ResumeSubscriptions {
  ResumeSubscriptions();

  @override
  String toString() {
    return 'ResumeSubscriptions{}';
  }
}

class ResendEmailVerification {
  ResendEmailVerification();

  @override
  String toString() {
    return 'ResendEmailVerification{}';
  }
}

class RecheckEmailVerification {
  RecheckEmailVerification();

  @override
  String toString() {
    return 'RecheckEmailVerification{}';
  }
}

class EnablePushNotifications {
  EnablePushNotifications();

  @override
  String toString() {
    return 'EnablePushNotifications{}';
  }
}

class GetAllResources {
  GetAllResources();

  @override
  String toString() {
    return 'GetAllResources{}';
  }
}

class SetAllResources {
  List<Resource> resources;

  SetAllResources(this.resources);

  @override
  String toString() {
    return 'SetAllResources{resources: $resources}';
  }
}

class GetAssessment {
  SurveyInfo surveyInfo;
  int length;

  GetAssessment({
    @required this.surveyInfo,
    @required this.length,
  });

  @override
  String toString() {
    return 'GetSelfAssessment{type: $surveyInfo, length: $length}';
  }
}

class SetAssessment {
  Test test;

  SetAssessment(this.test);

  @override
  String toString() {
    return 'SetSelfAssessment{test: $test}';
  }
}

class ClearAssessment {
  ClearAssessment();

  @override
  String toString() {
    return 'ClearSelfAssessment{}';
  }
}

class SubmitAssessment {
  String forUser;
  SurveyInfo surveyInfo;
  Map<Question, int> answers;
  bool isSelfAssessment;

  SubmitAssessment({
    @required this.surveyInfo,
    @required this.answers,
    @required this.isSelfAssessment,
    this.forUser,
  });

  @override
  String toString() {
    return 'SubmitSelfAssessment{forUser: $forUser, info: $surveyInfo, answers: $answers}';
  }
}

class SetSurveyInfo {
  SurveyInfo surveyInfo;

  SetSurveyInfo(this.surveyInfo);

  @override
  String toString() {
    return 'SetSurveyInfo{surveyInfo: $surveyInfo}';
  }
}

class UpdateOnboarding {
  Onboarding onboarding;

  UpdateOnboarding(this.onboarding);

  @override
  String toString() {
    return 'UpdateOnboarding{}';
  }
}

class UpdateBio {
  String bio;

  UpdateBio(this.bio);

  @override
  String toString() {
    return 'UpdateBio{bio: $bio}';
  }
}

class GetProfilePictures {
  GetProfilePictures();

  @override
  String toString() {
    return 'GetProfilePictures{}';
  }
}

class SetProfilePictures {
  List<String> photoUrls;

  SetProfilePictures(this.photoUrls);

  @override
  String toString() {
    return 'SetProfilePictures{photoUrls: $photoUrls}';
  }
}

class UpdateNotifications {
  List<Notification> notifications;

  UpdateNotifications(this.notifications);

  @override
  String toString() {
    return 'UpdateNotifications{notifications: $notifications}';
  }
}

class UpdateNotificationRead {
  Notification notification;

  UpdateNotificationRead(this.notification);

  @override
  String toString() {
    return 'UpdateNotificationRead{notification: $notification}';
  }
}

class ClearNotificationCount {
  ClearNotificationCount();

  @override
  String toString() {
    return 'ClearNotificationCount{}';
  }
}

class DeleteNotification {
  Notification notification;

  DeleteNotification(this.notification);

  @override
  String toString() {
    return 'DeleteNotification{notification: $notification}';
  }
}

class SetQuestionSetStatistics {
  Map<QuestionSet, QuestionSetStatistics> questionSetStatistics;

  SetQuestionSetStatistics(this.questionSetStatistics);

  @override
  String toString() {
    return 'SetQuestionSetStatistics{statistics: $questionSetStatistics}';
  }
}

class UpdatePrivacySettings {
  Map<Mindsets, bool> privacySettings;

  UpdatePrivacySettings(this.privacySettings);

  @override
  String toString() {
    return 'UpdatePrivacySettings{privacySettings: $privacySettings}';
  }
}

class UpdateProfileVisibility {
  bool private;

  UpdateProfileVisibility(this.private);

  @override
  String toString() {
    return 'UpdateProfileVisibility{private: $private}';
  }
}
