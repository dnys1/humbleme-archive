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
import '../views/email_and_password_view.dart';

class EmailAndPasswordContainer extends StatefulWidget {
  EmailAndPasswordContainer({Key key}) : super(key: key);

  createState() => _EmailAndPasswordContainerState();
}

class _EmailAndPasswordContainerState extends State<EmailAndPasswordContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'emailAndPassword');
  bool _pushed = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (Store<AppState> store) =>
          store.dispatch(SetCurrentScaffold(_scaffoldKey)),
      rebuildOnChange: !_pushed,
      onWillChange: (_ViewModel vm) {
        if (vm.emailRegistered && !_pushed) {
          _pushed = true;
          Navigator.of(context).pushReplacementNamed(
              Routes.pickNextInFlow(user: vm.user, context: context));
        }
      },
      distinct: true,
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        return EmailAndPasswordView(
          onSignupSubmit: vm.onSignupSubmit,
          scaffoldKey: _scaffoldKey,
          errorOccurred: vm.errorOccurred,
        );
      },
    );
  }
}

class _ViewModel {
  final Function onSignupSubmit;
  final User user;
  final bool emailRegistered;
  final bool errorOccurred;

  _ViewModel({
    @required this.onSignupSubmit,
    @required this.user,
    this.emailRegistered = false,
    @required this.errorOccurred,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      onSignupSubmit: (data) {
        store.dispatch(EmailAndPasswordAction(data));
      },
      user: getCurrentUser(store.state.auth),
      emailRegistered: isEmailRegistered(store.state.auth),
      errorOccurred: getErrorHasOccurred(store.state),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          emailRegistered == other.emailRegistered &&
          errorOccurred == other.errorOccurred;

  @override
  int get hashCode =>
      emailRegistered.hashCode ^ errorOccurred.hashCode ^ user.hashCode;
}
