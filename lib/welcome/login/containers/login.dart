import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models/user.dart';
import '../../../core/actions.dart';
import '../../../core/models.dart';
import '../../../routes.dart';
import '../../../selectors.dart';
import '../views/login_view.dart';

/// The onWillChange method detects when the store is updated with the
/// [isLoggedin] flag, i.e. when [AuthState.user]`!= false`. It then removes
/// all routes on the stack and pushes the app container route, defined in
/// [Routes] and [HumbleMeApp].

class LoginContainer extends StatefulWidget {
  LoginContainer({Key key}) : super(key: key);

  @override
  createState() => _LoginContainerState();
}

class _LoginContainerState extends State<LoginContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'login');
  bool _pushed = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (Store<AppState> store) =>
          store.dispatch(SetCurrentScaffold(_scaffoldKey)),
      onWillChange: (_ViewModel vm) {
        /// Select the appropriate next step based off how much of the signup process
        /// the user has completed. If they exit part of the way through the signup
        /// process, for example, some of these values will be null and we'll need
        /// to collect them.
        if (!vm.isLoading && !vm.isLoadingUser && !_pushed) {
          _pushed = true;

          String route = Routes.pickNextInFlow(
            user: vm.user,
            context: context,
          );
          Navigator.of(context).pushAndRemoveUntil(
              Routes.routeBuilderFromPath(
                context,
                route,
              ),
              (Route<dynamic> route) => false);
        }
      },
      distinct: true,
      rebuildOnChange: !_pushed,
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        return LoginView(
          scaffoldKey: _scaffoldKey,
          loginCallback: vm.onSubmitLogin,
          resetPassword: vm.resetPassword,
          errorOccurred: vm.errorOccurred,
        );
      },
    );
  }
}

class _ViewModel {
  final bool isLoading;
  final bool isLoadingUser;
  final User user;
  final OnSubmitLoginCallback onSubmitLogin;
  final Function(String) resetPassword;
  final bool errorOccurred;

  _ViewModel({
    @required this.isLoading,
    @required this.isLoadingUser,
    @required this.onSubmitLogin,
    this.user,
    @required this.resetPassword,
    @required this.errorOccurred,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      isLoading: isLoadingSelector(store.state),
      isLoadingUser: isLoadingUserSelector(store.state),
      onSubmitLogin: (data) {
        store.dispatch(LoginAction(data));
      },
      user: getCurrentUser(store.state.auth),
      resetPassword: (email) => store.dispatch(ResetPassword(email)),
      errorOccurred: getErrorHasOccurred(store.state),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          errorOccurred == other.errorOccurred &&
          user == other.user;

  @override
  int get hashCode =>
      isLoading.hashCode ^ errorOccurred.hashCode ^ user.hashCode;
}
