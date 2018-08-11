import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models/user.dart';
import '../../../core/actions.dart';
import '../../../core/models.dart';
import '../../../routes.dart';
import '../../../selectors.dart';
import '../views/verify_email_view.dart';

class VerifyEmailContainer extends StatefulWidget {
  VerifyEmailContainer();

  @override
  createState() => _VerifyEmailContainerState();
}

class _VerifyEmailContainerState extends State<VerifyEmailContainer> {
  bool _pushed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'verifyEmail');

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (Store<AppState> store) {
        store.dispatch(SetCurrentScaffold(_scaffoldKey));
        store.dispatch(RecheckEmailVerification());
      },
      converter: _ViewModel.fromStore,
      onWillChange: (_ViewModel vm) {
        if (!_pushed && vm.user.onboarding.emailVerified) {
          _pushed = true;
          Navigator.of(context).pushReplacementNamed(
              Routes.pickNextInFlow(user: vm.user, context: context));
        }
      },
      builder: (BuildContext context, _ViewModel vm) {
        return VerifyEmailView(
          resendEmailVerification: vm.resendEmailVerification,
          recheckEmailVerification: vm.recheckEmailVerification,
          scaffoldKey: _scaffoldKey,
        );
      },
    );
  }
}

class _ViewModel {
  final User user;
  final Function resendEmailVerification;
  final Function recheckEmailVerification;

  _ViewModel({
    @required this.user,
    @required this.resendEmailVerification,
    @required this.recheckEmailVerification,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      user: getCurrentUser(store.state.auth),
      resendEmailVerification: () =>
          store.dispatch(ResendEmailVerification()),
      recheckEmailVerification: () =>
          store.dispatch(RecheckEmailVerification()),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}
