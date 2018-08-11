import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'gender.dart';
import 'mini_friend.dart';
import 'onboarding.dart';
import 'public_user.dart';
import 'question_set.dart';
import 'school.dart';
import 'score.dart';
import 'util.dart';

part 'user.g.dart';

// To build: flutter packages pub run build_runner build

@immutable
@JsonSerializable()
class User extends Object with _$UserSerializerMixin implements PublicUser {
  final String id;
  final String firstName;
  final String lastName;
  final String photoUrl;
  final List<String> profilePictures;
  final String displayName;
  final String email;
  final String phoneNumber;
  final String bio;
  final Gender gender;
  final int age;
  final List<String> topMindsets;
  final double score;
  final int appRating;
  final School school;

  @JsonKey(fromJson: rolesFromJson)
  final Map<String, bool> roles;
  final String lastUsedDeviceId;

  // Self-Assessment scores
  @JsonKey(ignore: true)
  final List<Score> selfScores;
  // Scores from others
  @JsonKey(ignore: true)
  final List<Score> peerScores;

  /// Keeps track of how many surveys a user has received.
  final int surveysReceived;

  /// Keeps track of how many surveys a user has given.
  final int surveysGiven;

  @JsonKey(toJson: testTakenToJson, fromJson: testTakenFromJson)
  final Map<QuestionSet, bool> selfAssessmentsTaken;

  /// A list of this user's friends
  @JsonKey(ignore: true)
  final List<PublicUser> friends;

  final int notificationCount;

  /// Flags
  @JsonKey(toJson: onboardingToJson)
  final Onboarding onboarding;

  bool get isPrivateProfile => roles['private'] ?? false;

  User({
    this.id,
    this.displayName,
    this.firstName,
    this.lastName,
    this.email,
    this.photoUrl,
    this.phoneNumber,
    this.bio,
    this.age,
    this.gender,
    this.topMindsets,
    this.score,
    int appRating,
    this.school,
    Map<String, dynamic> roles,
    this.lastUsedDeviceId,
    this.peerScores,
    this.selfScores,
    Map<QuestionSet, bool> selfAssessmentsTaken,
    int notificationCount,
    Onboarding onboarding,
    int surveysReceived,
    int surveysGiven,
    this.friends = const [],
    this.profilePictures = const [],
  })  : onboarding = onboarding ?? Onboarding(),
        appRating = appRating ?? 0,
        roles = roles ?? defaultRoles,
        selfAssessmentsTaken = selfAssessmentsTaken ??
            Map.fromIterable(QuestionSet.values, value: (_) => false),
        notificationCount = notificationCount ?? 0,
        surveysReceived = surveysReceived ?? 0,
        surveysGiven = surveysGiven ?? 0;

  User copyWith({
    String id,
    String displayName,
    String firstName,
    String lastName,
    String photoUrl,
    String email,
    String phoneNumber,
    String bio,
    int age,
    Gender gender,
    List<String> topMindsets,
    double score,
    int appRating,
    School school,
    Map<String, bool> roles,
    String lastUsedDeviceId,
    int notificationCount,
    List<Score> peerScores,
    List<Score> selfScores,
    Map<QuestionSet, bool> selfAssessmentsTaken,
    Onboarding onboarding,
    int surveysGiven,
    int surveysReceived,
    List<MiniFriend> friends,
    List<String> profilePictures,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      profilePictures: profilePictures ?? this.profilePictures,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      score: score ?? this.score,
      topMindsets: topMindsets ?? this.topMindsets,
      appRating: appRating ?? this.appRating,
      school: school ?? this.school,
      roles: roles ?? this.roles,
      lastUsedDeviceId: lastUsedDeviceId ?? this.lastUsedDeviceId,
      peerScores: peerScores ?? this.peerScores,
      selfScores: selfScores ?? this.selfScores,
      selfAssessmentsTaken: selfAssessmentsTaken ?? this.selfAssessmentsTaken,
      notificationCount: notificationCount ?? this.notificationCount,
      onboarding: onboarding ?? this.onboarding,
      surveysGiven: surveysGiven ?? this.surveysGiven,
      surveysReceived: surveysReceived ?? this.surveysReceived,
      friends: friends ?? this.friends,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          phoneNumber == other.phoneNumber &&
          bio == other.bio &&
          age == other.age &&
          gender == other.gender &&
          onboarding == other.onboarding &&
          topMindsets == other.topMindsets &&
          score == other.score &&
          appRating == other.appRating &&
          school == other.school &&
          roles == other.roles &&
          lastUsedDeviceId == other.lastUsedDeviceId &&
          peerScores == other.peerScores &&
          selfScores == other.selfScores &&
          selfAssessmentsTaken == other.selfAssessmentsTaken &&
          notificationCount == other.notificationCount &&
          surveysGiven == other.surveysGiven &&
          surveysReceived == other.surveysReceived &&
          friends == other.friends &&
          profilePictures == other.profilePictures &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode =>
      id.hashCode ^
      displayName.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      email.hashCode ^
      phoneNumber.hashCode ^
      bio.hashCode ^
      age.hashCode ^
      gender.hashCode ^
      topMindsets.hashCode ^
      score.hashCode ^
      appRating.hashCode ^
      school.hashCode ^
      roles.hashCode ^
      lastUsedDeviceId.hashCode ^
      peerScores.hashCode ^
      selfScores.hashCode ^
      selfAssessmentsTaken.hashCode ^
      notificationCount.hashCode ^
      onboarding.hashCode ^
      surveysGiven.hashCode ^
      surveysReceived.hashCode ^
      friends.hashCode ^
      profilePictures.hashCode ^
      photoUrl.hashCode;

  @override
  String toString() {
    return 'User{id: $id, displayName: $displayName, photoUrl: $photoUrl, notificationCount: $notificationCount, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, bio: $bio, age: $age, gender: $gender, score: $score, selfAssessmentsTaken: $selfAssessmentsTaken, school: $school, onboarding: $onboarding, scores: $peerScores, selfScores: $selfScores }';
  }
}
