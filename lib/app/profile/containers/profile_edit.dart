import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models.dart';
import '../../../core/actions.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../views/profile_edit_view.dart';

class ProfileEditContainer extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'profileEdit');

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (Store<AppState> store) =>
          store.dispatch(SetCurrentScaffold(_scaffoldKey)),
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        return ProfileEditView(
          scaffoldKey: _scaffoldKey,
          updateBio: vm.updateBio,
          updateMindsetScorePrivacy: vm.updateMindsetScorePrivacy,
          scores: vm.scores.first,
          mindsets: vm.mindsets,
          profileVisibility: vm.profileVisibility,
          updateProfileVisibility: vm.setProfileVisibility,
          user: vm.user,
        );
      },
    );
  }
}

class _ViewModel {
  final Function(String) updateBio;
  final Function(Map<Mindsets, bool>) updateMindsetScorePrivacy;
  final Function(bool) setProfileVisibility;
  final bool profileVisibility;
  final List<Mindset> mindsets;
  final List<Score> scores;
  final User user;

  _ViewModel({
    @required this.updateBio,
    @required this.updateMindsetScorePrivacy,
    @required this.mindsets,
    @required this.scores,
    @required this.profileVisibility,
    @required this.setProfileVisibility,
    @required this.user,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      updateBio: (String bio) => store.dispatch(UpdateBio(bio)),
      updateMindsetScorePrivacy: (Map<Mindsets, bool> privacySettings) =>
          store.dispatch(UpdatePrivacySettings(privacySettings)),
      mindsets: getMindsets(store.state.auth),
      scores: getScores(store.state.auth),
      profileVisibility: getIsProfilePrivate(store.state.auth),
      setProfileVisibility: (bool private) =>
          store.dispatch(UpdateProfileVisibility(private)),
      user: getCurrentUser(store.state.auth),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          scores == other.scores &&
          profileVisibility == other.profileVisibility &&
          mindsets == other.mindsets &&
          user == other.user;

  @override
  int get hashCode => hashValues(mindsets, scores, profileVisibility, user);
}
