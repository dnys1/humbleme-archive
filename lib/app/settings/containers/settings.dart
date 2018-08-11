import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../views/settings_view.dart';

class SettingsContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        converter: _ViewModel.fromStore,
        builder: (BuildContext context, _ViewModel vm) {
          return SettingsView(
            logout: vm.logout,
            buildInfo: vm.buildInfo,
          );
        });
  }
}

class _ViewModel {
  final Function logout;
  final BuildInfo buildInfo;

  _ViewModel({@required this.logout, @required this.buildInfo});

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      logout: () => store.dispatch(LogoutAction()),
      buildInfo: getBuildInfo(store.state),
    );
  }

  @override
  int get hashCode => buildInfo.hashCode;

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          buildInfo == other.buildInfo;
}
