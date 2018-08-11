import 'dart:async';

import 'package:flutter/services.dart';

class PhoneNumberVerification {
  static final methodChannelPhoneNumber =
      const MethodChannel('humbleme/verifyPhoneNumber');

  static Future<String> getVerificationID(String phoneNumber) async {
    String verificationId = await methodChannelPhoneNumber.invokeMethod(
        'sendVerificationCode', phoneNumber);
    return verificationId;
  }

  static Future<bool> loginWithCredentials(
      String verificationId, String verificationCode) async {
    await methodChannelPhoneNumber.invokeMethod(
        'loginWithPhoneNumber', [verificationId, verificationCode]);
    return true;
  }
}
