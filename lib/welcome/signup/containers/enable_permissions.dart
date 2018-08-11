import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/models/user.dart';
import '../../../core/actions.dart';
import '../../../core/models.dart';
import '../../../routes.dart';
import '../../../selectors.dart';
import '../../../services/platform/actions.dart';
import '../../../services/platform/permissions.dart';
import '../views/enable_permissions_view.dart';

class EnablePermissionsContainer extends StatefulWidget {
  EnablePermissionsContainer({Key key}) : super(key: key);

  @override
  createState() => _EnablePermissionsContainerState();
}

class _EnablePermissionsContainerState
    extends State<EnablePermissionsContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'enablePermissions');
  bool _pushed = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        onInit: (Store<AppState> store) =>
            store.dispatch(SetCurrentScaffold(_scaffoldKey)),
        rebuildOnChange: !_pushed,
        onWillChange: (_ViewModel vm) {
          if (vm.permissionsEnabled && !_pushed) {
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
          return EnablePermissionsView(
            scaffoldKey: _scaffoldKey,
            permissions: vm.permissions,
            updatePermission: vm.updatePermission,
          );
        });
  }
}

class _ViewModel {
  final Function(PermissionType, PermissionState) updatePermission;
  final Map<PermissionType, PermissionState> permissions;
  final bool permissionsEnabled;
  final User user;

  _ViewModel({
    this.permissions,
    this.updatePermission,
    this.permissionsEnabled,
    this.user,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      permissions: getPermissions(store.state),
      updatePermission: (type, state) =>
          store.dispatch(UpdatePermission(type, state)),
      permissionsEnabled: getPermissionsEnabled(store.state),
      user: getCurrentUser(store.state.auth),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          permissions == other.permissions &&
          permissionsEnabled == other.permissionsEnabled &&
          user == other.user;

  @override
  int get hashCode =>
      permissionsEnabled.hashCode ^ permissions.hashCode ^ user.hashCode;
}
