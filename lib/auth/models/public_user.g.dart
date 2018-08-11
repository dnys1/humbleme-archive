// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicUser _$PublicUserFromJson(Map<String, dynamic> json) => new PublicUser(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    profilePictures:
        (json['profilePictures'] as List)?.map((e) => e as String)?.toList(),
    photoUrl: json['photoUrl'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String,
    age: json['age'] as int,
    gender: json['gender'] == null
        ? null
        : Gender.values
            .singleWhere((x) => x.toString() == 'Gender.${json['gender']}'),
    bio: json['bio'] as String,
    school: json['school'] == null
        ? null
        : new School.fromJson(json['school'] as Map<String, dynamic>),
    score: (json['score'] as num)?.toDouble(),
    surveysReceived: json['surveysReceived'] as int,
    surveysGiven: json['surveysGiven'] as int,
    roles: json['roles'] == null
        ? null
        : new Map<String, bool>.from(json['roles'] as Map));

abstract class _$PublicUserSerializerMixin {
  String get id;
  String get firstName;
  String get lastName;
  String get displayName;
  String get photoUrl;
  List<String> get profilePictures;
  String get email;
  String get phoneNumber;
  Gender get gender;
  int get age;
  String get bio;
  School get school;
  Map<String, bool> get roles;
  double get score;
  int get surveysReceived;
  int get surveysGiven;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'profilePictures': profilePictures,
        'email': email,
        'phoneNumber': phoneNumber,
        'gender': gender == null ? null : gender.toString().split('.')[1],
        'age': age,
        'bio': bio,
        'school': school,
        'roles': roles,
        'score': score,
        'surveysReceived': surveysReceived,
        'surveysGiven': surveysGiven
      };
}
