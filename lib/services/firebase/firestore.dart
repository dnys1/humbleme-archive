import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/models.dart';
import '../../core/models.dart';
import '../../services/platform/contacts.dart';
import '../../services/platform/permissions.dart';
import '../../theme.dart';
import '../../utils/uuid.dart';
import '../api/models.dart';
// import 'package:cloud_functions/cloud_functions.dart';

class CaptureErrorSink implements EventSink {
  final EventSink _outputSink;
  CaptureErrorSink(this._outputSink);

  void add(data) {
    _outputSink.add(data);
  }

  void addError(e, [st]) {
    _outputSink.addError(e, st);
  }

  void close() {
    _outputSink.close();
  }
}

class FirestoreRepository extends DBRepository {
  final Firestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage storage;
  final FirebasePerformance performanceMonitoring;

  FirestoreRepository({
    @required this.firestore,
    @required this.firebaseAuth,
    @required this.storage,
    @required this.performanceMonitoring,
  });

  @override
  Future<List<Mindset>> loadMindsets() async {
    var mindsets = List<Mindset>();

    var snapshot =
        await firestore.collection('mindsets').orderBy('name').getDocuments();
    snapshot.documents.forEach((mindset) {
      mindsets.add(Mindset.fromJson(mindset.data));
    });

    return mindsets;
  }

  @override
  Future<List<Resource>> loadResources() async {
    var resources = List<Resource>();

    var snap = await firestore
        .collection('resources')
        .orderBy('item_pos')
        .getDocuments();
    snap.documents.forEach((doc) => resources.add(Resource.fromJson(doc.data)));
    return resources;
  }

  @override
  Future<Map<QuestionSet, QuestionSetStatistics>>
      loadQuestionSetStatistics() async {
    var questionSetStatistics = Map<QuestionSet, QuestionSetStatistics>();

    var snap = await firestore.collection('global').document('stats').get();
    for (var key in snap.data.keys) {
      QuestionSet questionSet = QuestionSet.values
          .firstWhere((q) => q.toString().split('.')[1] == key);
      questionSetStatistics[questionSet] =
          QuestionSetStatistics.fromJson(snap.data[key] as Map);
    }

    return questionSetStatistics;
  }

  @override
  Future<bool> isLoggedIn() async {
    var user = await firebaseAuth.currentUser();
    if (user != null) return true;
    return false;
  }

  @override
  Future<bool> isNotLoggedIn() async {
    var user = await firebaseAuth.currentUser();
    await Future.delayed(Duration(milliseconds: 100));
    if (user != null) return false;
    return true;
  }

  @override
  Future<String> setNotificationToken(String token) async {
    if (!await isLoggedIn()) {
      return Future.error('(setNotificationToken) User not logged in.');
    }

    await updateDeviceInfo(notificationToken: token);

    return token;
  }

  @override
  Future<bool> resetNotificationsCount() async {
    if (!await isLoggedIn()) {
      return Future.error('(resetNotificationsCount) User not logged in.');
    }

    await resetDeviceInfo(notificationCount: true);

    return true;
  }

  @override
  Future<bool> deleteNotificationToken() async {
    if (!await isLoggedIn()) {
      return Future.error('(deleteNotificationToken) User not logged in.');
    }

    await resetDeviceInfo(notificationToken: true);

    return true;
  }

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    if (!await isLoggedIn()) {
      return Future.error('(getDeviceInfo) User not logged in.');
    }
    var userId = (await firebaseAuth.currentUser()).uid;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var deviceId = preferences.getString('deviceId');

    DeviceInfo deviceInfo;
    if (deviceId == null) {
      deviceInfo = await createDeviceInDb();
      await preferences.setString('deviceId', deviceInfo.deviceIdentifier);
    } else {
      var deviceJson = await firestore
          .collection('users')
          .document(userId)
          .collection('devices')
          .document(deviceId)
          .get();
      if (!deviceJson.exists) {
        deviceInfo = await createDeviceInDb();
        await preferences.setString('deviceId', deviceInfo.deviceIdentifier);
      } else {
        deviceInfo = DeviceInfo.fromJson(deviceJson.data);
      }
    }

    if (!deviceStructureUpToDate(deviceInfo)) {
      deviceInfo = await updateDeviceDbStructure(deviceInfo.deviceIdentifier);
    }

    await firestore.collection('users').document(userId).updateData({
      'lastUsedDeviceId': deviceInfo.deviceIdentifier,
    });

    return deviceInfo;
  }

  @override
  Future<Stream<DeviceInfo>> getDeviceInfoStream() async {
    if (!await isLoggedIn()) {
      return Future.error('(getDeviceInfoStream) User not logged in.');
    }
    var userId = (await firebaseAuth.currentUser()).uid;

    DeviceInfo deviceInfo = await getDeviceInfo();
    Stream<DeviceInfo> source = firestore
        .collection('users')
        .document(userId)
        .collection('devices')
        .document(deviceInfo.deviceIdentifier)
        .snapshots()
        .map((snap) => DeviceInfo.fromJson(snap.data));

    return Stream.eventTransformed(source, (sink) => CaptureErrorSink(sink));
  }

  @override
  Future<DeviceInfo> updateDeviceInfo({
    BuildInfo buildInfo,
    bool configuredNotifications,
    int notificationsCount,
    String notificationToken,
    AndroidDeviceInfo androidInfo,
    IosDeviceInfo iosInfo,
    List<MapEntry<PermissionType, PermissionState>> updatePermissions,
  }) async {
    if (!await isLoggedIn()) {
      return Future.error('(updateDeviceInDb) User not logged in.');
    }
    var userId = (await firebaseAuth.currentUser()).uid;

    DeviceInfo deviceInfo = await getDeviceInfo();
    deviceInfo = deviceInfo.copyWith(
      appVersion: buildInfo?.version,
      configuredNotifications: configuredNotifications,
      notificationCount: notificationsCount,
      notificationToken: notificationToken,
      androidSdk: androidInfo?.version?.sdkInt,
      systemVersion: deviceInfo.isAndroid
          ? androidInfo?.version?.release
          : iosInfo?.systemVersion,
      updatePermissions: updatePermissions,
    );

    await firestore
        .collection('users')
        .document(userId)
        .collection('devices')
        .document(deviceInfo.deviceIdentifier)
        .updateData(deviceInfo.toJson());

    return deviceInfo;
  }

  Future<DeviceInfo> resetDeviceInfo({
    bool configuredNotifications = false,
    bool notificationCount = false,
    bool notificationToken = false,
    bool permissions = false,
  }) async {
    if (!await isLoggedIn()) {
      return Future.error('(resetDeviceInfo) User not logged in.');
    }
    var userId = (await firebaseAuth.currentUser()).uid;

    DeviceInfo deviceInfo = await getDeviceInfo();
    deviceInfo = deviceInfo.reset(
      configuredNotifications: configuredNotifications,
      notificationCount: notificationCount,
      notificationToken: notificationToken,
      permissions: permissions,
    );

    await firestore
        .collection('users')
        .document(userId)
        .collection('devices')
        .document(deviceInfo.deviceIdentifier)
        .updateData(deviceInfo.toJson());

    return deviceInfo;
  }

  Future<DeviceInfo> createDeviceInDb() async {
    if (!await isLoggedIn()) {
      return Future.error('(createDeviceInDb) User not logged in.');
    }
    var userId = (await firebaseAuth.currentUser()).uid;

    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    DeviceInfo deviceInfo;
    String deviceId;

    if (kIsAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      deviceId = Uuid().generateV4();
      deviceInfo = DeviceInfo(
        isAndroid: true,
        deviceIdentifier: deviceId,
        systemVersion: androidDeviceInfo.version.release,
        androidSdk: androidDeviceInfo.version.sdkInt,
        isPhysicalDevice: androidDeviceInfo.isPhysicalDevice,
      );
      // Android emulators don't support phone verification, so let's just skip it.
      if (!androidDeviceInfo.isPhysicalDevice) {
        await setPhoneNumberVerified();
      }
    } else {
      IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      deviceId = iosDeviceInfo.identifierForVendor;
      deviceInfo = DeviceInfo(
        isAndroid: false,
        deviceIdentifier: deviceId,
        systemVersion: iosDeviceInfo.systemVersion,
        isPhysicalDevice: iosDeviceInfo.isPhysicalDevice,
      );
    }

    await firestore
        .collection('users')
        .document(userId)
        .collection('devices')
        .document(deviceInfo.deviceIdentifier)
        .setData(deviceInfo.toJson());

    await firestore.collection('users').document(userId).updateData({
      'lastUsedDeviceId': deviceInfo.deviceIdentifier,
    });

    return deviceInfo;
  }

  @override
  Future<bool> deviceCreatedInDb(String deviceId) async {
    if (!await isLoggedIn()) {
      return Future.error('(createDeviceInDb) User not logged in.');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    return (await firestore
            .collection('users')
            .document(userId)
            .collection('devices')
            .document(deviceId)
            .get())
        .exists;
  }

  @override
  bool deviceStructureUpToDate(DeviceInfo deviceInfo) {
    return deviceInfo
        .toJson()
        .keys
        .toSet()
        .containsAll(DeviceInfo().toJson().keys.toSet());
  }

  @override
  Future<DeviceInfo> updateDeviceDbStructure(String deviceId) async {
    if (!await isLoggedIn()) {
      return Future.error('(updateDeviceDbStructure) User not logged in.');
    }
    var userId = (await firebaseAuth.currentUser()).uid;

    var deviceJson = (await firestore
            .collection('users')
            .document(userId)
            .collection('devices')
            .document(deviceId)
            .get())
        .data;

    var deviceInfo = DeviceInfo.fromJson(deviceJson);

    await firestore
        .collection('users')
        .document(userId)
        .collection('devices')
        .document(deviceId)
        .setData(deviceInfo.toJson());

    return deviceInfo;
  }

  @override
  Future<bool> userCreatedInDb() async {
    if (!await isLoggedIn()) {
      return Future.error('(userCreatedInDb) User not logged in.');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    var exists =
        (await firestore.collection('users').document(userId).get()).exists;
    return exists;
  }

  @override
  Future<bool> createUserInDatabase({User user}) async {
    if (!await isLoggedIn()) {
      return Future.error('(createUserInDatabase) User is not logged in!');
    }
    var firebaseUser = await firebaseAuth.currentUser();
    var userId = firebaseUser.uid;
    var email = firebaseUser.email;
    User newUser;
    if (user != null) {
      newUser = user.copyWith(
        id: userId,
        email: email,
      );
    } else {
      newUser = User(id: userId, email: email);
    }
    await firestore
        .collection('users')
        .document(userId)
        .setData(newUser.toJson());
    return true;
  }

  @override
  Future<bool> dbStructureUpToDate() async {
    if (!await isLoggedIn()) {
      return Future.error('(dbStructureUpToDate) User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    var userJson =
        (await firestore.collection('users').document(userId).get()).data;

    return userJson.keys.toSet().containsAll(User().toJson().keys.toSet());
  }

  @override
  Future<bool> updateDbStructure() async {
    if (!await isLoggedIn()) {
      return Future.error('(updateDbStructure) User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    var userObj = User.fromJson(
        (await firestore.collection('users').document(userId).get()).data);
    await firestore
        .collection('users')
        .document(userId)
        .setData(userObj.toJson());
    return true;
  }

  @override
  Future<User> getUser(String id) async {
    if (!await isLoggedIn()) {
      return Future.error('(getUser) User is not logged in!');
    }
    var userId = id;
    if (id == null) {
      userId = (await firebaseAuth.currentUser()).uid;
    }
    var json = await firestore.collection('users').document(userId).get();
    return User.fromJson(json.data);
  }

  Future<List<Score>> getUserScores(
      {@required bool self, String userId}) async {
    if (!await isLoggedIn()) {
      return Future.error('(getUserScores) User is not logged in!');
    }
    var uid = userId ?? (await firebaseAuth.currentUser()).uid;

    if (userId != null && self) {
      return Future.error('Cannot request self scores for another user.');
    }

    List<Score> scores = [];
    var collectionRef =
        firestore.collection('users').document(uid).collection('scores');

    QuerySnapshot collectionSnap;

    // Requesting public profile
    if (userId != null) {
      collectionSnap = await collectionRef
          .where('self', isEqualTo: false)
          .orderBy('dateTime', descending: true)
          .limit(1)
          .getDocuments();
      if (collectionSnap.documents.isEmpty) {
        return Future.error(
            'This user\'s scores collection is empty. This shouldn\'t happen');
      }
    } else {
      collectionSnap = await collectionRef
          .where('self', isEqualTo: self)
          .orderBy('dateTime', descending: true)
          .getDocuments();

      // If no scores have been created yet, create a score
      if (collectionSnap.documents.isEmpty) {
        Score newScore = Score.init(self);
        var scoreRef = await collectionRef.add(newScore.toJson());
        await scoreRef.updateData({
          'id': scoreRef.documentID,
        });
        return [newScore.copyWith(id: scoreRef.documentID)];
      }
    }

    // If the collection is not empty, return the formatted docs.
    collectionSnap.documents
        .forEach((doc) => scores.add(Score.fromJson(doc.data)));

    return scores;
  }

  @override
  Future<bool> updateNotificationRead(String notificationId) async {
    if (!await isLoggedIn()) {
      return Future.error('(getNotificationsStream) User is not logged in!');
    }

    await firestore
        .collection('notifications')
        .document(notificationId)
        .updateData({
      'read': true,
    });
    return true;
  }

  @override
  Future<bool> updateNotificationCount(int count) async {
    if (!await isLoggedIn()) {
      return Future.error('(updateNotificationCount) User is not logged in!');
    }

    var userId = (await firebaseAuth.currentUser()).uid;

    await firestore.collection('users').document(userId).updateData({
      'notificationCount': max(count, 0),
    });

    return true;
  }

  @override
  Future<bool> clearNotificationCount() async {
    if (!await isLoggedIn()) {
      return Future.error('(clearNotificationCount) User is not logged in!');
    }

    var userId = (await firebaseAuth.currentUser()).uid;

    await firestore.collection('users').document(userId).updateData({
      'notificationCount': 0,
    });

    return true;
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    if (!await isLoggedIn()) {
      return Future.error('(deleteNotification) User is not logged in!');
    }

    await firestore
        .collection('notifications')
        .document(notificationId)
        .delete();

    return true;
  }

  @override
  Future<Stream<List<Notification>>> getNotificationsStream() async {
    if (!await isLoggedIn()) {
      return Future.error('(getNotificationsStream) User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;

    var source = firestore
        .collection('notifications')
        .where('toUser', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      List<Notification> notifications = [];
      snap.documents.forEach((notification) =>
          notifications.add(Notification.fromJson(notification.data)));
      return notifications;
    });

    return Stream.eventTransformed(source, (sink) => CaptureErrorSink(sink));
  }

  @override
  Future<Stream<List<Score>>> getScoresStream({@required bool self}) async {
    if (!await isLoggedIn()) {
      return Future.error('(getScoresStream) User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;

    var source = firestore
        .collection('users')
        .document(userId)
        .collection('scores')
        .where('self', isEqualTo: self)
        .orderBy('dateTime', descending: true)
        .limit(5) // Get only the last 5 scores
        .snapshots()
        .map((snap) {
      List<Score> scores = [];
      snap.documents.forEach((score) {
        scores.add(Score.fromJson(score.data));
      });
      return scores;
    });

    return Stream.eventTransformed(source, (sink) => CaptureErrorSink(sink));
  }

  @override
  Future<User> getLoggedInUser() async {
    var firebaseUser = await firebaseAuth.currentUser();
    if (firebaseUser == null) {
      return null;
    }
    if (!await userCreatedInDb()) await createUserInDatabase();
    if (!await dbStructureUpToDate()) await updateDbStructure();
    var user =
        await firestore.collection('users').document(firebaseUser.uid).get();
    var userData = user.data;

    // School information is stored as reference type
    if (userData['school'] != null) {
      userData['school'] =
          (await (userData['school'] as DocumentReference).get()).data;
    }

    // Get all scores for user
    List<Score> peerScores = await getUserScores(self: false);
    List<Score> selfScores = await getUserScores(self: true);

    return User
        .fromJson(userData)
        .copyWith(peerScores: peerScores, selfScores: selfScores);
  }

  @override
  Future<bool> checkIfEmailVerified(Onboarding onboarding) async {
    var firebaseUser = await firebaseAuth.currentUser();
    if (firebaseUser == null) {
      return null;
    }

    await firebaseUser.reload();
    if (!firebaseUser.isEmailVerified) {
      return false;
    }

    await firestore.collection('users').document(firebaseUser.uid).updateData({
      'onboarding': onboarding.copyWith(emailVerified: true).toJson(),
    });
    return true;
  }

  @override
  Future<List<PublicUser>> getSearchResults(String searchString) async {
    if (!await isLoggedIn()) {
      return Future.error('(getSearchResultsStream) User is not logged in!');
    }

    var userId = (await firebaseAuth.currentUser()).uid;

    if (searchString == '') {
      return const [];
    }

    var query = await firestore
        .collection('users')
        .orderBy('displayName')
        .startAt([searchString])
        .endAt([searchString + '\uf8ff'])
        .limit(10)
        .getDocuments();

    List<PublicUser> users = [];
    for (var doc in query.documents) {
      // Do not serialize the user's own document, even though it may be retrieved
      if (doc.documentID == userId) continue;
      if (doc.data['roles']['test'] ?? false) continue;
      users.add(PublicUser.fromJson(doc.data));
    }
    return users;
  }

  Future<List<MiniFriend>> getPublicUsersFriends(String userId,
      {bool isTest}) async {
    if (!await isLoggedIn()) {
      return Future.error('(getPublicUsersFriends) User is not logged in!');
    }

    var currentUser = await firebaseAuth.currentUser();

    if (isTest == null) {
      isTest = (await firestore.collection('global').document('isTest').get())
          .data['isTest'] as bool;
    }

    String endpoint;
    if (isTest) {
      endpoint =
          'https://us-central1-hmflutter-test.cloudfunctions.net/getUsersFriendList';
    } else {
      endpoint =
          'https://us-central1-hmflutter.cloudfunctions.net/getUsersFriendList';
    }

    var res = await http.post(
      endpoint,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'idToken': await currentUser.getIdToken(),
        'uid': userId,
      }),
    );

    if (res.statusCode == 200) {
      List data = json.decode(res.body);
      List<MiniFriend> friends = [];
      data.forEach((friend) {
        friends.add(MiniFriend.fromJson(friend));
      });

      return friends;
    } else {
      return Future.error(res.body);
    }
  }

  @override
  Future<Stream<User>> getUserStream() async {
    if (!await isLoggedIn()) {
      return Future.error('(createUserInDatabase) User is not logged in!');
    }
    var user = await firebaseAuth.currentUser();
    var userId = user.uid;
    Stream<User> source = firestore
        .collection('users')
        .document(userId)
        .snapshots()
        .map((doc) => User.fromJson(doc.data));

    return Stream.eventTransformed(source, (sink) => CaptureErrorSink(sink));
  }

  @override
  Stream<List<Mindset>> getGlobalStatsStream() {
    var source = firestore
        .collection('mindsets')
        .orderBy('ranking', descending: true)
        .limit(3)
        .snapshots()
        .map((mindsets) {
      var mindsetsArr = <Mindset>[];
      mindsets.documents.forEach((mindset) {
        mindsetsArr.add(Mindset.fromJson(mindset.data));
      });
      return mindsetsArr;
    });

    return Stream.eventTransformed(source, (sink) => CaptureErrorSink(sink));
  }

  @override
  Future<Stream<List<PublicUser>>> getFriendsStream() async {
    if (!await isLoggedIn()) {
      return Future.error('(getFriendsStream) User is not logged in!');
    }
    var user = await firebaseAuth.currentUser();
    var userId = user.uid;
    var source = firestore
        .collection('users')
        .document(userId)
        .collection('friends')
        .snapshots()
        .asyncMap((friends) async {
      var friendArray = <PublicUser>[];
      for (var friend in friends.documents) {
        var profile = await firestore
            .collection('users')
            .document(friend.data['friend'] as String)
            .get();
        friendArray.add(PublicUser.fromJson(profile.data));
      }
      return friendArray;
    });

    return Stream.eventTransformed(source, (sink) => CaptureErrorSink(sink));
  }

  @override
  Future<Stream<List<FriendRequest>>> getFriendRequestsSentStream() async {
    if (!await isLoggedIn()) {
      return Future
          .error('(getFriendRequestsSentStream) User is not logged in!');
    }
    var user = await firebaseAuth.currentUser();
    var userId = user.uid;
    var source = firestore
        .collection('friendRequests')
        .where('fromUser', isEqualTo: userId)
        .snapshots()
        .map((friendRequests) {
      var requestArr = <FriendRequest>[];
      for (var request in friendRequests.documents) {
        requestArr.add(FriendRequest.fromJson(request.data));
      }
      return requestArr;
    });

    return Stream.eventTransformed(source, (sink) => CaptureErrorSink(sink));
  }

  @override
  Future<Stream<List<FriendRequest>>> getFriendRequestsReceivedStream() async {
    if (!await isLoggedIn()) {
      return Future
          .error('(getFriendRequestsReceivedStream) User is not logged in!');
    }
    var user = await firebaseAuth.currentUser();
    var userId = user.uid;
    var source = firestore
        .collection('friendRequests')
        .where('toUser', isEqualTo: userId)
        .snapshots()
        .map((friendRequests) {
      var requestArr = <FriendRequest>[];
      for (var request in friendRequests.documents) {
        requestArr.add(FriendRequest.fromJson(request.data));
      }
      return requestArr;
    });

    return Stream.eventTransformed(source, (sink) => CaptureErrorSink(sink));
  }

  @override
  Future<Stream<List<Survey>>> getSurveysGivenStream() async {
    if (!await isLoggedIn()) {
      return Future.error('(getSurveysGivenStream) User is not logged in!');
    }
    var user = await firebaseAuth.currentUser();
    var userId = user.uid;
    var source = firestore
        .collection('surveys')
        .where('fromUser', isEqualTo: userId)
        .snapshots()
        .map((surveysGiven) {
      var surveyArr = <Survey>[];
      for (var survey in surveysGiven.documents) {
        surveyArr.add(Survey.fromJson(survey.data));
      }
      return surveyArr;
    });

    return Stream.eventTransformed(source, (sink) => CaptureErrorSink(sink));
  }

  @override
  Future<Stream<List<Survey>>> getSurveysReceivedStream() async {
    if (!await isLoggedIn()) {
      return Future.error('(getSurveysReceivedStream) User is not logged in!');
    }
    var user = await firebaseAuth.currentUser();
    var userId = user.uid;
    var source = firestore
        .collection('surveys')
        .where('toUser', isEqualTo: userId)
        .snapshots()
        .map((surveysReceived) {
      var surveyArr = <Survey>[];
      for (var survey in surveysReceived.documents) {
        surveyArr.add(Survey.fromJson(survey.data));
      }
      return surveyArr;
    });

    return Stream.eventTransformed(source, (sink) => CaptureErrorSink(sink));
  }

  @override
  Future<bool> updateAge(int age) async {
    if (!await isLoggedIn()) {
      return Future.error('(updateAge) User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    await firestore.collection('users').document(userId).updateData({
      'age': age,
    });

    return true;
  }

  @override
  Future<bool> updateEmail(String email) async {
    if (!await isLoggedIn()) {
      return Future.error('(updateEmail) User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    await firestore.collection('users').document(userId).updateData({
      'email': email,
    });

    return true;
  }

  @override
  Future<bool> updateGender(Gender gender) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    await firestore.collection('users').document(userId).updateData({
      'gender': User(id: userId, gender: gender).toJson()['gender'],
    });

    return true;
  }

  @override
  Future<bool> updateName(String firstName, String lastName,
      [String displayName]) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    await firestore.collection('users').document(userId).updateData({
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName ?? '$firstName $lastName'
    });

    return true;
  }

  Future<bool> updateUsername(String username) async {
    if (!await isLoggedIn()) {
      return Future.error('(updateUsername) User is not logged in!');
    }

    var userId = (await firebaseAuth.currentUser()).uid;
    await firestore.collection('users').document(userId).updateData({
      'username': username,
    });
    return true;
  }

  @override
  Future<bool> updatePhoneNumber(String phoneNumber) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    await firestore.collection('users').document(userId).updateData({
      'phoneNumber': phoneNumber,
    });

    return true;
  }

  @override
  Future<bool> updatePhoto(String photoUrl) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    await firestore
        .collection('users')
        .document(userId)
        .updateData({'photoUrl': photoUrl});

    return true;
  }

  @override
  Future<bool> updateProfile(
      {String firstName,
      String lastName,
      String displayName,
      String photoUrl,
      String phoneNumber,
      int age,
      Gender gender,
      String email}) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    if (firstName != null && lastName != null) {
      await updateName(firstName, lastName, displayName);
    }
    if (photoUrl != null) {
      await updatePhoto(photoUrl);
    }
    if (phoneNumber != null) {
      await updatePhoneNumber(phoneNumber);
    }
    if (age != null) {
      await updateAge(age);
    }
    if (gender != null) {
      await updateGender(gender);
    }
    if (email != null) {
      await updateEmail(email);
    }
    return true;
  }

  @override
  Future<bool> setOnboardingFinish(Onboarding onboarding) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    await firestore.collection('users').document(userId).updateData({
      'onboarding': onboarding.copyWith(onboardingComplete: true).toJson(),
    });

    return true;
  }

  @override
  Future<bool> recordTopMindsets(List<Mindset> mindsets,
      {@required bool isTestDB}) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    var currentUser = await firebaseAuth.currentUser();

    List<String> topMindsets = mindsets.map((mindset) => mindset.id).toList();

    String endpoint = isTestDB
        ? 'https://us-central1-hmflutter-test.cloudfunctions.net/recordTopMindsets'
        : 'https://us-central1-hmflutter.cloudfunctions.net/recordTopMindsets';

    var resp = await http.post(endpoint,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          'idToken': await currentUser.getIdToken(),
          'topMindsets': topMindsets,
        }));

    if (resp.statusCode == 200) {
      await firestore.collection('users').document(currentUser.uid).updateData({
        'topMindsets': topMindsets,
      });

      return true;
    } else {
      return Future
          .error('Error occurred recording top mindsets: ${resp.body}');
    }
  }

  @override
  Future<bool> sendUserActions(List<String> actions) async {
    if (!await isLoggedIn()) {
      return false;
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    await firestore
        .collection('users')
        .document(userId)
        .collection('actions')
        .add({
      "actions": actions,
      "dateTime": DateTime.now(),
    });

    return true;
  }

  @override
  Future<bool> submitSurvey(Survey survey) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    await firestore
        .collection('surveys')
        .document(survey.id)
        .setData(survey.toJson());

    return true;
  }

  @override
  Future<bool> acceptFriendRequest(String requestId) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }

    // It might seem redundant to set both values, but it's critical
    // we do, in case this request was originally denied.
    await firestore.collection('friendRequests').document(requestId).updateData(
      {
        'accepted': true,
        'denied': false,
      },
    );

    return true;
  }

  @override
  Future<bool> denyFriendRequest(String requestId) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }

    // Update both values for good measure. There shouldn't be a case where
    // the request was originally accepted, but then later denied.
    await firestore.collection('friendRequests').document(requestId).updateData(
      {
        'denied': true,
        'accepted': false,
      },
    );

    return true;
  }

  @override
  Future<bool> addFriend(String friendId) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    var requestId = Uuid().generateV4();

    // First, ensure that the same request has not already been made
    // and that is wasn't denied the first time.
    var res = await firestore
        .collection('friendRequests')
        .where('fromUser', isEqualTo: userId)
        .where('toUser', isEqualTo: friendId)
        .getDocuments();
    if (res.documents.isNotEmpty) {}

    await firestore
        .collection('friendRequests')
        .document(requestId)
        .setData(FriendRequest(
          id: requestId,
          fromUser: userId,
          toUser: friendId,
          dateTime: DateTime.now(),
        ).toJson());
    return true;
  }

  @override
  Future<bool> addProfilePicture(File picture) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    var currentPhotoUrl =
        (await firestore.collection('users').document(userId).get())
            .data['photoUrl'];
    var extension =
        picture.uri.path.substring(picture.uri.path.lastIndexOf('.'));
    var path = '$userId/profilePicture/';
    var fileName = '${DateTime.now().toIso8601String()}$extension';
    final StorageReference ref = storage.ref().child('$path$fileName');
    final StorageUploadTask task = ref.putFile(picture);
    await task.future;
    await firestore
        .collection('users')
        .document(userId)
        .snapshots()
        .where((snap) => snap.data['photoUrl'] != currentPhotoUrl)
        .first;
    return true;
  }

  // TODO: Update function or delete
  Future<List<String>> getProfilePictures(bool isTest, {String userId}) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    var currentUser = await firebaseAuth.currentUser();
    var uid = userId ?? currentUser.uid;

    String endpoint;
    if (isTest) {
      endpoint =
          'https://us-central1-hmflutter-test.cloudfunctions.net/getProfilePictures';
    } else {
      endpoint =
          'https://us-central1-hmflutter.cloudfunctions.net/getProfilePictures';
    }

    var res = await http.post(
      endpoint,
      headers: {"Content-Type": 'application/json'},
      body: json.encode({
        'idToken': await currentUser.getIdToken(),
        'uid': uid,
      }),
    );

    if (res.statusCode == 200) {
      List<String> photoUrls = (json.decode(res.body) as List).cast<String>();
      return photoUrls;
    } else {
      return Future.error(res.body);
    }
  }

  @override
  Future<bool> setAppRating(int appRating) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    var userId = (await firebaseAuth.currentUser()).uid;
    await firestore.collection('users').document(userId).updateData({
      'appRating': appRating,
    });

    return true;
  }

  @override
  Future<bool> linkEmailAndPassword({String email, String password}) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }
    var isTestDoc =
        await firestore.collection('global').document('isTest').get();
    bool isTest = isTestDoc.data['isTest'] as bool;

    String endpoint;
    if (isTest) {
      endpoint =
          'https://us-central1-hmflutter-test.cloudfunctions.net/linkEmailAndPassword';
    } else {
      endpoint =
          'https://us-central1-hmflutter.cloudfunctions.net/linkEmailAndPassword';
    }

    var res = await http.post(
      endpoint,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': email, 'password': password}),
    );

    if (res.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(res.body);
      var code = responseBody['code'] as String;
      if (code == 'ERROR') {
        return Future.error(responseBody['message'] as String);
      } else {
        return true;
      }
    } else {
      return Future.error('Network unavailable.');
    }
  }

  @override
  Future<List<PublicUser>> getFriendsForContacts(
    List<Contact> contacts, {
    isTest: false,
  }) async {
    if (!await isLoggedIn()) {
      return Future.error('User is not logged in!');
    }

    var currentUser = await firebaseAuth.currentUser();
    var uid = currentUser.uid;

    List<String> numbers = <String>[];
    for (var contact in contacts) {
      numbers.addAll(contact.numbers);
    }

    String endpoint;
    if (isTest) {
      endpoint =
          'https://us-central1-hmflutter-test.cloudfunctions.net/findFriends';
    } else {
      endpoint = 'https://us-central1-hmflutter.cloudfunctions.net/findFriends';
    }

    var res = await http.post(
      endpoint,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        'numbers': numbers,
        'uid': uid,
        'idToken': await currentUser.getIdToken(),
      }),
    );

    if (res.statusCode == 200) {
      List responseBody = json.decode(res.body);
      List<String> userIds = <String>[];
      responseBody.forEach((id) => userIds.add(id as String));
      List<PublicUser> users = [];
      for (var id in userIds) {
        var doc = await firestore.collection('users').document(id).get();
        if (doc.exists) {
          users.add(PublicUser.fromJson(doc.data));
        }
      }
      return users;
    } else {
      return Future.error(res.reasonPhrase);
    }
  }

  @override
  Future<bool> setPhoneNumberVerified([Onboarding onboarding]) async {
    if (!await isLoggedIn()) {
      return Future.error('(setPhoneNumberVerified) User is not logged in!');
    }

    var userId = (await firebaseAuth.currentUser()).uid;
    if (onboarding == null) {
      var onboardingData =
          await firestore.collection('users').document(userId).get();
      onboarding = Onboarding.fromJson(onboardingData.data['onboarding']);
    }

    await firestore.collection('users').document(userId).updateData({
      'onboarding': onboarding.copyWith(phoneNumberVerified: true).toJson()
    });

    return true;
  }

  @override
  Future<bool> isPhoneVerified(bool isTest) async {
    if (!await isLoggedIn()) {
      return Future.error('(isPhoneVerified) User is not logged in!');
    }

    var user = await firebaseAuth.currentUser();

    String endpoint;
    if (isTest) {
      endpoint =
          'https://us-central1-hmflutter-test.cloudfunctions.net/isPhoneVerified';
    } else {
      endpoint =
          'https://us-central1-hmflutter.cloudfunctions.net/isPhoneVerified';
    }

    var response = await http.post(
      endpoint,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        'idToken': await user.getIdToken(),
      }),
    );

    if (response.statusCode == 200) {
      return response.body == 'true';
    } else {
      return Future.error('${response.statusCode}: ${response.body}');
    }
  }

  @override
  Future<Test> getQuiz({
    @required SurveyInfo surveyInfo,
    @required int length,
    @required bool isTestDB,
  }) async {
    if (!await isLoggedIn()) {
      return Future.error('(getQuiz) User is not logged in!');
    }

    var currentUser = await firebaseAuth.currentUser();

    String endpoint;
    if (isTestDB) {
      endpoint =
          'https://us-central1-hmflutter-test.cloudfunctions.net/getQuiz';
    } else {
      endpoint = 'https://us-central1-hmflutter.cloudfunctions.net/getQuiz';
    }

    var body = {
      'idToken': await currentUser.getIdToken(),
      'questionSet': surveyInfo.questionSet.toString().split('.')[1],
      'testType': surveyInfo.testType.toString().split('.')[1],
    };

    var res = await http.post(
      endpoint,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(body),
    );

    if (res.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(res.body);
      List resQuestions = responseBody['questions'];
      List<Question> questions = <Question>[];
      questions.addAll(resQuestions
          .where((q) => q != null)
          .map((q) => Question.fromJson(Map.from(q))));
      return Test(
        id: Uuid().generateV4(),
        questionsRemaining: questions,
        surveyInfo: surveyInfo,
      ).moveToNextBatch(length);
    } else {
      return Future.error('${res.statusCode}: ${res.body}');
    }
  }

  @override
  Future<bool> submitQuiz({
    @required SurveyInfo surveyInfo,
    @required Map<Question, int> answers,
    @required bool isTestDB,
    @required bool isSelfAssessment,
    String forUser,
  }) async {
    if (!await isLoggedIn()) {
      return Future.error('(getQuiz) User is not logged in!');
    }

    var currentUser = await firebaseAuth.currentUser();

    List<Map> answersArr = [];
    answers.forEach((question, resp) {
      answersArr.add({
        'question': question.toJson(),
        'response': resp,
      });
    });

    String endpoint;
    if (isTestDB) {
      endpoint =
          'https://us-central1-hmflutter-test.cloudfunctions.net/submitQuiz';
    } else {
      endpoint = 'https://us-central1-hmflutter.cloudfunctions.net/submitQuiz';
    }

    var res = await http.post(
      endpoint,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        'idToken': await currentUser.getIdToken(),
        'surveyInfo': surveyInfo.toJson(),
        'answers': answersArr,
        'isSelfAssessment': isSelfAssessment,
        'forUser': forUser,
      }),
    );

    if (res.statusCode == 200) {
      return true;
    } else {
      return Future.error('${res.statusCode}: ${res.body}');
    }
  }

  @override
  Future<bool> updateOnboarding(Onboarding onboarding) async {
    if (!await isLoggedIn()) {
      return Future.error('(getQuiz) User is not logged in!');
    }

    var uid = (await firebaseAuth.currentUser()).uid;
    await firestore
        .collection('users')
        .document(uid)
        .updateData({'onboarding': onboarding.toJson()});

    return true;
  }

  @override
  Future<bool> updateBio(String bio) async {
    if (!await isLoggedIn()) {
      return Future.error('(updateBio) User is not logged in!');
    }

    var uid = (await firebaseAuth.currentUser()).uid;
    await firestore.collection('users').document(uid).updateData({
      'bio': bio,
    });

    return true;
  }

  @override
  Future<bool> updateProfileVisibility(bool private) async {
    if (!await isLoggedIn()) {
      return Future.error('(updateProfileVisibility) User is not logged in!');
    }

    var uid = (await firebaseAuth.currentUser()).uid;
    await firestore.collection('users').document(uid).updateData({
      'roles.private': private,
    });

    return true;
  }

  @override
  Future<bool> updatePrivacySettings(
      Map<Mindsets, bool> updatedSettings) async {
    if (!await isLoggedIn()) {
      return Future.error('(updatePrivacySettings) User is not logged in!');
    }

    var uid = (await firebaseAuth.currentUser()).uid;
    var query = await firestore
        .collection('users')
        .document(uid)
        .collection('scores')
        .where('self', isEqualTo: false)
        .orderBy('dateTime', descending: true)
        .limit(1)
        .getDocuments();
    Score latestScore = Score
        .fromJson(query.documents[0].data)
        .copyWith(privacySettings: updatedSettings);
    await firestore
        .collection('users')
        .document(uid)
        .collection('scores')
        .document(latestScore.id)
        .setData(latestScore.toJson());
    return true;
  }
}
