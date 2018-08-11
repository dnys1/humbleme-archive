import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meta/meta.dart';

import '../api/models.dart';

typedef Future<dynamic> MessageHandler(Map<String, dynamic> message);

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth auth;
  final FirebaseMessaging messaging;

  const FirebaseAuthRepository({this.auth, this.messaging});

  @override
  Future<FirebaseUser> checkLoggedIn() async {
    final firebaseUser = await auth.currentUser();

    if (firebaseUser != null) {
      return firebaseUser;
    } else {
      return null;
    }
  }

  @override
  Future<FirebaseUser> linkEmailAndPassword(
      {@required String email, @required String password}) async {
    return await auth.linkWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<String> loginWithEmailAndPassword(
      {@required String email, @required String password}) async {
    final firebaseUser =
        await auth.signInWithEmailAndPassword(email: email, password: password);

    return firebaseUser.uid;
  }

  @override
  Future<String> signupWithEmailAndPassword(
      {String email, String password}) async {
    final firebaseUser = await auth.createUserWithEmailAndPassword(
        email: email, password: password);

    if (firebaseUser != null) {
      // await firebaseUser.sendEmailVerification();
      return firebaseUser.uid;
    } else {
      return null;
    }
  }

  @override
  Future<String> signupWithPhoneNumber(String phoneNumber) async {
    FirebaseUser _user;
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (FirebaseUser user) => _user = user,
      verificationFailed: (AuthException err) => throw err,
      codeSent: (String code, [int what]) => print('Code sent: $code $what'),
      codeAutoRetrievalTimeout: (String code) =>
          print('AutoRetrieval timeout: $code'),
    );
    return _user.uid;
  }

  @override
  Future<void> resendEmailVerification() async {
    final firebaseUser = await auth.currentUser();

    if (firebaseUser != null) {
      await firebaseUser.sendEmailVerification();
    }
  }

  @override
  Future<String> signInWithCustomToken(String token) async {
    final firebaseUser = await auth.signInWithCustomToken(token: token);

    if (firebaseUser != null) {
      return firebaseUser.uid;
    } else {
      return null;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
    return null;
  }

  @override
  Future<void> logout() async {
    await auth.signOut();
  }
}
