import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../views/play_view.dart';

class PlayContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      distinct: true,
      builder: (BuildContext context, _ViewModel vm) {
        return PlayView(
          startSurvey: vm.startSurvey,
          surveysGiven: vm.surveysGiven,
          surveysReceived: vm.surveysReceived,
          friends: vm.friends,
          friendRequestsReceived: vm.friendRequestsReceived,
          friendRequestsSent: vm.friendRequestsSent,
          selfAssessmentsTaken: vm.selfAssessmentsTaken,
        );
      },
    );
  }
}

class _ViewModel {
  final Function(String) startSurvey;
  final Survey currentSurvey;
  final List<Survey> surveysGiven;
  final List<Survey> surveysReceived;
  final List<PublicUser> friends;
  final List<FriendRequest> friendRequestsReceived;
  final List<FriendRequest> friendRequestsSent;
  final Map<QuestionSet, bool> selfAssessmentsTaken;

  _ViewModel({
    @required this.startSurvey,
    @required this.currentSurvey,
    @required this.surveysGiven,
    @required this.surveysReceived,
    @required this.friends,
    @required this.friendRequestsReceived,
    @required this.friendRequestsSent,
    @required this.selfAssessmentsTaken,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      startSurvey: (friendId) => store.dispatch(CreateSurvey(
          toUser: friendId, fromUser: getCurrentUser(store.state.auth).id)),
      currentSurvey: getCurrentSurvey(store.state.auth),
      surveysGiven: getSurveysGiven(store.state.auth),
      surveysReceived: getSurveysReceived(store.state.auth),
      friends: getFriends(store.state.auth),
      friendRequestsReceived: getFriendRequestsReceived(store.state.auth),
      friendRequestsSent: getFriendRequestsSent(store.state.auth),
      selfAssessmentsTaken: getSelfAssessmentsTaken(store.state.auth),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          currentSurvey == other.currentSurvey &&
          friends == other.friends &&
          friendRequestsReceived == other.friendRequestsReceived &&
          friendRequestsSent == other.friendRequestsSent &&
          surveysGiven == other.surveysGiven &&
          surveysReceived == other.surveysReceived &&
          selfAssessmentsTaken == other.selfAssessmentsTaken;

  @override
  int get hashCode =>
      currentSurvey.hashCode ^
      friends.hashCode ^
      friendRequestsReceived.hashCode ^
      friendRequestsSent.hashCode ^
      surveysGiven.hashCode ^
      surveysReceived.hashCode ^
      selfAssessmentsTaken.hashCode;
}
