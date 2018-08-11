import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models.dart';
import '../../../core/actions.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../../models.dart';
import '../views/profile_view.dart';

class ProfileContainer extends StatefulWidget {
  static AppTab tab = AppTab.profile;

  final PublicUser publicUser;
  final String profileId;

  ProfileContainer({
    this.publicUser,
    this.profileId,
  });

  @override
  createState() => _ProfileContainerState();
}

class _ProfileContainerState extends State<ProfileContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'profile');
  final Firestore firestore = Firestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  PublicUser _publicUser;
  bool _errorLoading = false;

  @override
  void initState() {
    super.initState();
    _publicUser = widget.publicUser;
  }

  bool get isPublicProfile =>
      widget.profileId != null || widget.publicUser != null;

  Future<void> loadProfile(bool isTest,
      {@required Function(String) areFriends}) async {
    if (!isPublicProfile) {
      return;
    }

    if (_publicUser != null &&
        _publicUser.peerScores != null &&
        _publicUser.friends != null) {
      return;
    }

    String profileId = _publicUser?.id ?? widget.profileId;

    assert(profileId != null);

    try {
      if (_publicUser == null) {
        // Get the user's essential data
        var doc = await firestore.collection('users').document(profileId).get();
        PublicUser user = PublicUser.fromJson(doc.data);
        // Load the essential data, then continue loading the rest
        if (mounted) {
          setState(() {
            _publicUser = user;
          });
        }
      }

      bool shouldLoadInfo =
          !_publicUser.isPrivateProfile || areFriends(profileId);

      if ((_publicUser.peerScores == null || _publicUser.selfScores == null) &&
          shouldLoadInfo) {
        var peerSnap = await firestore
            .collection('users')
            .document(profileId)
            .collection('scores')
            .orderBy('dateTime', descending: true)
            .where('self', isEqualTo: false)
            .limit(1)
            .getDocuments();

        var selfSnap = await firestore
            .collection('users')
            .document(profileId)
            .collection('scores')
            .orderBy('dateTime', descending: true)
            .where('self', isEqualTo: true)
            .limit(1)
            .getDocuments();

        List<Score> peerScores = [Score.fromJson(peerSnap.documents[0].data)];
        List<Score> selfScores = [Score.fromJson(selfSnap.documents[0].data)];

        print('Retrieved peerScores: $peerScores');
        print('Retrieved selfScores: $selfScores');

        if (mounted) {
          setState(() {
            _publicUser = _publicUser.copyWith(
              peerScores: peerScores,
              selfScores: selfScores,
            );
          });
        }
      }

      if (_publicUser.friends == null && shouldLoadInfo) {
        // Get the user's friends
        FirebaseUser currentUser = await firebaseAuth.currentUser();
        String endpoint = isTest
            ? 'https://us-central1-hmflutter-test.cloudfunctions.net/getUsersFriendList'
            : 'https://us-central1-hmflutter.cloudfunctions.net/getUsersFriendList';
        var res = await http.post(
          endpoint,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'idToken': await currentUser.getIdToken(),
            'uid': profileId,
          }),
        );

        List<MiniFriend> friends = [];
        if (res.statusCode == 200) {
          List data = json.decode(res.body);
          data.forEach((friend) {
            friends.add(MiniFriend.fromJson(friend));
          });
          if (mounted) {
            setState(() {
              _publicUser = _publicUser.copyWith(friends: friends);
            });
          }
        } else {
          print('Error occurred: (${res.statusCode}) ${res.body}');
          if (mounted) {
            setState(() {
              _errorLoading = true;
            });
          }
          return;
        }
      }
    } catch (err) {
      print('Error occurred: $err');
      if (mounted) {
        setState(() {
          _errorLoading = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (Store<AppState> store) {
        store.dispatch(SetCurrentScaffold(_scaffoldKey));
        bool isTest = getFlavor(store.state) == Flavor.development;
        List<PublicUser> friends = getFriends(store.state.auth);
        loadProfile(
          isTest,
          areFriends: (id) => friends.map((friend) => friend.id).contains(id),
        );
      },
      distinct: true,
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        return ProfileView(
          scaffoldKey: _scaffoldKey,
          uploadImage: vm.uploadImage,
          imageUploading: vm.imageUploading,
          displayName: vm.displayName,
          photoUrl: vm.photoUrl,
          pickProfilePicture: vm.pickProfilePicture,
          friends: vm.friends,
          score: vm.score,
          surveysGiven: vm.surveysGiven,
          surveysReceived: vm.surveysReceived,
          user: vm.user,
          setScaffoldKey: vm.setScaffoldKey,
          publicUser: _publicUser,
          mindsets: vm.mindsets,
          errorLoadingProfile: _errorLoading,
          isPublicProfile: isPublicProfile,
        );
      },
    );
  }
}

class _ViewModel {
  final bool imageUploading;
  final String displayName;
  final String photoUrl;
  final Function pickProfilePicture;
  final List<PublicUser> friends;
  final List<Survey> surveysGiven;
  final List<Survey> surveysReceived;
  final double score;
  final User user;
  final Image uploadImage;
  final Function setScaffoldKey;
  final List<Mindset> mindsets;

  _ViewModel({
    @required this.imageUploading,
    @required this.displayName,
    @required this.photoUrl,
    @required this.pickProfilePicture,
    @required this.friends,
    @required this.score,
    @required this.surveysGiven,
    @required this.surveysReceived,
    @required this.user,
    @required this.uploadImage,
    @required this.setScaffoldKey,
    @required this.mindsets,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      imageUploading: isImageUploading(store.state.auth),
      displayName: getUserDisplayName(store.state.auth),
      photoUrl: getUsersCurrentPhotoUrl(store.state.auth),
      pickProfilePicture: (File profilePicture) =>
          store.dispatch(AddProfilePictureAction(profilePicture)),
      friends: getFriends(store.state.auth),
      score: getScore(store.state.auth),
      surveysGiven: getSurveysGiven(store.state.auth),
      surveysReceived: getSurveysReceived(store.state.auth),
      user: getCurrentUser(store.state.auth),
      uploadImage: getUploadImage(store.state.auth),
      setScaffoldKey: (scaffoldKey) =>
          store.dispatch(SetCurrentScaffold(scaffoldKey)),
      mindsets: getMindsets(store.state.auth),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          imageUploading == other.imageUploading &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          friends == other.friends &&
          score == other.score &&
          surveysGiven == other.surveysGiven &&
          surveysReceived == other.surveysReceived &&
          user == other.user &&
          uploadImage == other.uploadImage &&
          mindsets == other.mindsets;

  @override
  int get hashCode =>
      displayName.hashCode ^
      imageUploading.hashCode ^
      photoUrl.hashCode ^
      friends.hashCode ^
      score.hashCode ^
      surveysGiven.hashCode ^
      surveysReceived.hashCode ^
      user.hashCode ^
      uploadImage.hashCode ^
      mindsets.hashCode;
}
