import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'gender.dart';
import 'mini_friend.dart';
import 'school.dart';
import 'score.dart';

part 'public_user.g.dart';

@immutable
@JsonSerializable()
class PublicUser extends Object
    with _$PublicUserSerializerMixin
    implements MiniFriend {
  final String id;
  final String firstName;
  final String lastName;
  final String displayName;
  final String photoUrl;
  final List<String> profilePictures;
  final String email;
  final String phoneNumber;
  final Gender gender;
  final int age;
  final String bio;
  final School school;
  final Map<String, bool> roles;

  /// A list of this user's friends containing only
  /// the necessary information to display a friends list
  @JsonKey(ignore: true)
  final List<MiniFriend> friends;

  /// The user's peer scores
  ///
  /// Length will always be 1, and we ignore it from the serializer
  /// because it has to be retrieved and serialized independently
  /// (i.e. it's not part of the user's document, it's in a subcollection)
  @JsonKey(ignore: true)
  final List<Score> peerScores;

  /// The user's self scores
  ///
  /// Length will always be 1, and we ignore it from the serializer
  /// because it has to be retrieved and serialized independently
  /// (i.e. it's not part of the user's document, it's in a subcollection)
  @JsonKey(ignore: true)
  final List<Score> selfScores;

  /// The user's overall score
  final double score;

  /// Keeps track of how many surveys a user has received.
  final int surveysReceived;

  /// Keeps track of how many surveys a user has given.
  final int surveysGiven;

  /// Whether the user has made their profile private.
  ///
  /// If enabled, only friends can view their information.
  bool get isPrivateProfile => roles['private'] ?? false;

  PublicUser({
    @required this.id,
    this.displayName,
    this.profilePictures,
    this.photoUrl,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.age,
    this.gender,
    this.bio,
    this.school,
    this.peerScores,
    this.selfScores,
    this.score,
    int surveysReceived,
    int surveysGiven,
    this.friends,
    this.roles,
  })  : surveysReceived = surveysReceived ?? 0,
        surveysGiven = surveysGiven ?? 0;

  PublicUser copyWith({
    String displayName,
    List<String> profilePictures,
    String photoUrl,
    String firstName,
    String lastName,
    String email,
    String phoneNumber,
    int age,
    Gender gender,
    String bio,
    School school,
    List<Score> peerScores,
    List<Score> selfScores,
    int surveysReceived,
    int surveysGiven,
    double score,
    List<MiniFriend> friends,
    Map<String, bool> roles,
  }) {
    return PublicUser(
      id: this.id,
      displayName: displayName ?? this.displayName,
      profilePictures: profilePictures ?? this.profilePictures,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      school: school ?? this.school,
      peerScores: peerScores ?? this.peerScores,
      selfScores: selfScores ?? this.selfScores,
      surveysReceived: surveysReceived ?? this.surveysReceived,
      surveysGiven: surveysGiven ?? this.surveysGiven,
      score: score ?? this.score,
      friends: friends ?? this.friends,
      photoUrl: photoUrl ?? this.photoUrl,
      roles: roles ?? this.roles,
    );
  }

  factory PublicUser.fromJson(Map<String, dynamic> json) =>
      _$PublicUserFromJson(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          profilePictures == other.profilePictures &&
          photoUrl == other.photoUrl &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          phoneNumber == other.phoneNumber &&
          age == other.age &&
          gender == other.gender &&
          bio == other.bio &&
          school == other.school &&
          peerScores == other.peerScores &&
          selfScores == other.selfScores &&
          surveysReceived == other.surveysReceived &&
          surveysGiven == other.surveysGiven &&
          score == other.score &&
          friends == other.friends &&
          roles == other.roles;

  @override
  int get hashCode =>
      id.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      profilePictures.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      email.hashCode ^
      phoneNumber.hashCode ^
      age.hashCode ^
      gender.hashCode ^
      bio.hashCode ^
      school.hashCode ^
      peerScores.hashCode ^
      selfScores.hashCode ^
      surveysReceived.hashCode ^
      surveysGiven.hashCode ^
      score.hashCode ^
      friends.hashCode ^
      roles.hashCode;

  @override
  String toString() {
    return 'PublicUser{id: $id, displayName: $displayName, roles: $roles, bio: $bio, school: $school, score: $score, photoUrl: $photoUrl, profilePictures: $profilePictures, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, age: $age, gender: $gender, given: $surveysGiven, received: $surveysReceived}';
  }
}
