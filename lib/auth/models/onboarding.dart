import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'onboarding.g.dart';

@JsonSerializable()
class Onboarding extends Object with _$OnboardingSerializerMixin {
  final bool onboardingComplete;
  final bool emailVerified;
  final bool phoneNumberVerified;

  // Home screen flags
  final bool selfAssessmentsClicked;
  final bool addFriendsClicked;
  final bool notificationsPermissionRequested;

  Onboarding({
    this.onboardingComplete = false,
    this.emailVerified = false,
    this.phoneNumberVerified = false,
    this.selfAssessmentsClicked = false,
    this.addFriendsClicked = false,
    this.notificationsPermissionRequested = false,
  });

  Onboarding copyWith({
    bool onboardingComplete,
    bool emailVerified,
    bool phoneNumberVerified,
    bool selfAssessmentsClicked,
    bool addFriendsClicked,
    bool notificationsPermissionRequested,
  }) {
    return Onboarding(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumberVerified: phoneNumberVerified ?? this.phoneNumberVerified,
      selfAssessmentsClicked:
          selfAssessmentsClicked ?? this.selfAssessmentsClicked,
      addFriendsClicked: addFriendsClicked ?? this.addFriendsClicked,
      notificationsPermissionRequested: notificationsPermissionRequested ??
          this.notificationsPermissionRequested,
    );
  }

  factory Onboarding.fromJson(Map json) => _$OnboardingFromJson(
      json.map((key, val) => MapEntry<String, dynamic>(key as String, val)));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Onboarding &&
          runtimeType == other.runtimeType &&
          onboardingComplete == other.onboardingComplete &&
          emailVerified == other.emailVerified &&
          phoneNumberVerified == other.phoneNumberVerified &&
          selfAssessmentsClicked == other.selfAssessmentsClicked &&
          addFriendsClicked == other.addFriendsClicked &&
          notificationsPermissionRequested ==
              other.notificationsPermissionRequested;

  @override
  int get hashCode => hashValues(
        onboardingComplete,
        emailVerified,
        phoneNumberVerified,
        selfAssessmentsClicked,
        addFriendsClicked,
        notificationsPermissionRequested,
      );

  @override
  String toString() {
    return 'Onboarding{complete: $onboardingComplete, email: $emailVerified, phone: $phoneNumberVerified, selfAssess: $selfAssessmentsClicked, addFriends: $addFriendsClicked, notifications: $notificationsPermissionRequested }';
  }
}
