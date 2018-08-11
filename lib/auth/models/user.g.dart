// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => new User(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    email: json['email'] as String,
    photoUrl: json['photoUrl'] as String,
    phoneNumber: json['phoneNumber'] as String,
    bio: json['bio'] as String,
    age: json['age'] as int,
    gender: json['gender'] == null
        ? null
        : Gender.values
            .singleWhere((x) => x.toString() == 'Gender.${json['gender']}'),
    topMindsets:
        (json['topMindsets'] as List)?.map((e) => e as String)?.toList(),
    score: (json['score'] as num)?.toDouble(),
    appRating: json['appRating'] as int,
    school: json['school'] == null
        ? null
        : new School.fromJson(json['school'] as Map<String, dynamic>),
    roles: json['roles'] == null ? null : rolesFromJson(json['roles']),
    lastUsedDeviceId: json['lastUsedDeviceId'] as String,
    selfAssessmentsTaken: json['selfAssessmentsTaken'] == null
        ? null
        : testTakenFromJson(json['selfAssessmentsTaken']),
    notificationCount: json['notificationCount'] as int,
    onboarding: json['onboarding'] == null
        ? null
        : new Onboarding.fromJson(json['onboarding'] as Map<dynamic, dynamic>),
    surveysReceived: json['surveysReceived'] as int,
    surveysGiven: json['surveysGiven'] as int,
    profilePictures:
        (json['profilePictures'] as List)?.map((e) => e as String)?.toList());

abstract class _$UserSerializerMixin {
  String get id;
  String get firstName;
  String get lastName;
  String get photoUrl;
  List<String> get profilePictures;
  String get displayName;
  String get email;
  String get phoneNumber;
  String get bio;
  Gender get gender;
  int get age;
  List<String> get topMindsets;
  double get score;
  int get appRating;
  School get school;
  Map<String, bool> get roles;
  String get lastUsedDeviceId;
  int get surveysReceived;
  int get surveysGiven;
  Map<QuestionSet, bool> get selfAssessmentsTaken;
  int get notificationCount;
  Onboarding get onboarding;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'photoUrl': photoUrl,
        'profilePictures': profilePictures,
        'displayName': displayName,
        'email': email,
        'phoneNumber': phoneNumber,
        'bio': bio,
        'gender': gender == null ? null : gender.toString().split('.')[1],
        'age': age,
        'topMindsets': topMindsets,
        'score': score,
        'appRating': appRating,
        'school': school,
        'roles': roles,
        'lastUsedDeviceId': lastUsedDeviceId,
        'surveysReceived': surveysReceived,
        'surveysGiven': surveysGiven,
        'selfAssessmentsTaken': selfAssessmentsTaken == null
            ? null
            : testTakenToJson(selfAssessmentsTaken),
        'notificationCount': notificationCount,
        'onboarding': onboarding == null ? null : onboardingToJson(onboarding)
      };
}
