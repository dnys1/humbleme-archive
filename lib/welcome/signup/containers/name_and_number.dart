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
import '../../../services/platform/actions.dart';
import '../models.dart';
import '../views/name_and_number_view.dart';

class NameAndNumberContainer extends StatefulWidget {
  NameAndNumberContainer();

  @override
  createState() => _NameAndNumberContainerState();
}

class _NameAndNumberContainerState extends State<NameAndNumberContainer> {
  bool _verificationSent = false;
  bool _pushed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'NameAndNumber');

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        onInit: (Store<AppState> store) {
          store.dispatch(SetCurrentScaffold(_scaffoldKey));
          // store.dispatch(CheckPhoneVerified());
        },
        rebuildOnChange: !_pushed,
        onWillChange: (_ViewModel vm) async {
          if (vm.nameAndNumberRegistered &&
              // vm.phoneNumberVerified &&
              !_pushed) {
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
          return NameAndNumberView(
            nameAndNumberRegistered: vm.nameAndNumberRegistered,
            verificationSent: _verificationSent,
            onSubmitNameAndNumber: (NameAndNumberData data) {
              vm.onSubmitNameAndNumber(data);
              // _verificationSent = true;
            },
            onSubmitVerification: vm.onSubmitVerification,
            resendVerification: vm.resendVerification,
            scaffoldKey: _scaffoldKey,
            signOut: vm.signOut,
            errorOccurred: vm.errorOccurred,
          );
        });
  }
}

class _ViewModel {
  final User user;
  final Function(NameAndNumberData) onSubmitNameAndNumber;
  final Function(String) onSubmitVerification;
  final Function(NameAndNumberData) resendVerification;
  final Function signOut;
  final bool nameAndNumberRegistered;
  final bool phoneNumberVerified;
  final bool errorOccurred;

  _ViewModel({
    @required this.user,
    @required this.onSubmitNameAndNumber,
    @required this.onSubmitVerification,
    @required this.resendVerification,
    @required this.nameAndNumberRegistered,
    @required this.phoneNumberVerified,
    @required this.signOut,
    @required this.errorOccurred,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    String verificationId = getVerificationId(store.state.auth);

    return _ViewModel(
      user: getCurrentUser(store.state.auth),
      onSubmitNameAndNumber: (NameAndNumberData data) {
        store.dispatch(NameAndNumberAction(data));
      },
      onSubmitVerification: (String verificationCode) {
        store.dispatch(VerifyPhoneNumberWithCode(
          verificationId: verificationId,
          verificationCode: verificationCode,
        ));
      },
      resendVerification: (NameAndNumberData data) {
        store.dispatch(ResendPhoneNumberVerification(data.phoneNumber));
      },
      nameAndNumberRegistered: isNameAndNumberRegistered(store.state.auth),
      phoneNumberVerified: isPhoneNumberVerified(store.state.auth),
      signOut: () => store.dispatch(LogoutAction()),
      errorOccurred: getErrorHasOccurred(store.state),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          nameAndNumberRegistered == other.nameAndNumberRegistered &&
          phoneNumberVerified == other.phoneNumberVerified &&
          errorOccurred == other.errorOccurred;

  @override
  int get hashCode =>
      user.hashCode ^
      nameAndNumberRegistered.hashCode ^
      phoneNumberVerified.hashCode ^
      errorOccurred.hashCode;
}
