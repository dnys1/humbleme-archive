import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models/public_user.dart';
import '../../../auth/models/user.dart';
import '../../../core/actions.dart';
import '../../../core/models.dart';
import '../../../routes.dart';
import '../../../selectors.dart';
import '../../../services/platform/actions.dart';
import '../../../services/platform/permissions.dart';
import '../views/onboard_view.dart';

class OnboardContainer extends StatefulWidget {
  OnboardContainer();

  @override
  createState() => _OnboardContainerState();
}

class _OnboardContainerState extends State<OnboardContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'onboard');
  bool _pushed = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (Store<AppState> store) {
        store.dispatch(SetCurrentScaffold(_scaffoldKey));
        store.dispatch(GetContacts());
      },
      rebuildOnChange: !_pushed,
      onWillChange: (_ViewModel vm) {
        if (vm.user.onboarding.onboardingComplete && !_pushed) {
          _pushed = true;
          Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.pickNextInFlow(
                user: vm.user,
                context: context,
              ),
              (Route<dynamic> route) => false);
        }
      },
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        return OnboardView(
          scaffoldKey: _scaffoldKey,
          onCompleteOnboarding: vm.onCompleteOnboarding,
          friendsFromContacts: vm.friendsFromContacts,
          addFriend: vm.addFriend,
          contactsPermissionEnabled: vm.contactsPermissionEnabled,
        );
      },
    );
  }
}

class _ViewModel {
  final Function onCompleteOnboarding;
  final User user;
  final List<PublicUser> friendsFromContacts;
  final Function(String) addFriend;
  final bool contactsPermissionEnabled;

  _ViewModel({
    this.onCompleteOnboarding,
    this.user,
    this.friendsFromContacts,
    this.addFriend,
    this.contactsPermissionEnabled,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      onCompleteOnboarding: () => store.dispatch(OnboardingFinish()),
      user: getCurrentUser(store.state.auth),
      friendsFromContacts: getFriendsFromContacts(store.state.auth),
      addFriend: (friendId) => store.dispatch(AddFriendAction(friendId)),
      contactsPermissionEnabled:
          getPermissions(store.state)[PermissionType.contacts] ==
              PermissionState.granted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          user == other.user &&
          friendsFromContacts == other.friendsFromContacts &&
          contactsPermissionEnabled == other.contactsPermissionEnabled;

  @override
  int get hashCode =>
      user.hashCode ^
      friendsFromContacts.hashCode ^
      contactsPermissionEnabled.hashCode;
}
