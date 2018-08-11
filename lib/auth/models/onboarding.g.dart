// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Onboarding _$OnboardingFromJson(Map<String, dynamic> json) => new Onboarding(
    onboardingComplete: json['onboardingComplete'] as bool,
    emailVerified: json['emailVerified'] as bool,
    phoneNumberVerified: json['phoneNumberVerified'] as bool,
    selfAssessmentsClicked: json['selfAssessmentsClicked'] as bool,
    addFriendsClicked: json['addFriendsClicked'] as bool,
    notificationsPermissionRequested:
        json['notificationsPermissionRequested'] as bool);

abstract class _$OnboardingSerializerMixin {
  bool get onboardingComplete;
  bool get emailVerified;
  bool get phoneNumberVerified;
  bool get selfAssessmentsClicked;
  bool get addFriendsClicked;
  bool get notificationsPermissionRequested;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'onboardingComplete': onboardingComplete,
        'emailVerified': emailVerified,
        'phoneNumberVerified': phoneNumberVerified,
        'selfAssessmentsClicked': selfAssessmentsClicked,
        'addFriendsClicked': addFriendsClicked,
        'notificationsPermissionRequested': notificationsPermissionRequested
      };
}
