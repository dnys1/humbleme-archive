import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../core/actions.dart';
import '../core/models.dart';
import '../routes.dart';
import '../selectors.dart';
import '../theme.dart';
import 'actions.dart';
import 'models.dart';
import 'view.dart';

/// This is the main container for the application. It presents the TabView to the user
/// and handles the routing for the main user experience.
///
/// When the user is no longer logged in, and the store var [isLoggedIn] is `false`,
/// such as when the user presses the logout button, the Navigator will pop the application
/// off the stack, leaving just the [WelcomeView].
class AppContainer extends StatefulWidget {
  AppContainer({Key key}) : super(key: key);

  @override
  createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'app');
  bool _pushed = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: HumbleMe.appTheme,
      isMaterialAppTheme: false,
      child: StoreConnector<AppState, _ViewModel>(
        onInit: (Store<AppState> store) =>
            store.dispatch(SetCurrentScaffold(_scaffoldKey)),
        onWillChange: (_ViewModel vm) {
          if (!vm.isLoggedIn && !_pushed) {
            _pushed = true;
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  Routes.routeBuilderFromPath(
                    context,
                    Routes.welcome,
                    transitionType: TransitionType.nativeModal,
                  ),
                  (Route<dynamic> route) => false,
                );
          }
        },
        rebuildOnChange: !_pushed,
        converter: _ViewModel.fromStore,
        builder: (BuildContext context, _ViewModel vm) {
          return AppView(
            activeTab: vm.initialTab ?? vm.activeTab,
            onTabSelected: vm.onTabSelected,
            scaffoldKey: _scaffoldKey,
            notificationCount: vm.notificationCount,
          );
        },
      ),
    );
  }
}

class _ViewModel {
  final bool isLoggedIn;
  final AppTab activeTab;
  final AppTab initialTab;
  final Function(int) onTabSelected;
  final int notificationCount;

  _ViewModel({
    @required this.activeTab,
    @required this.initialTab,
    @required this.onTabSelected,
    @required this.isLoggedIn,
    @required this.notificationCount,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      activeTab: activeTabSelector(store.state),
      initialTab: initialTabSelector(store.state),
      onTabSelected: (index) {
        store.dispatch(UpdateCurrentTabAction(AppTab.values[index]));
      },
      isLoggedIn: loggedInSelector(store.state.auth),
      notificationCount: getNotificationCount(store.state.auth),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          activeTab == other.activeTab &&
          initialTab == other.initialTab &&
          isLoggedIn == other.isLoggedIn &&
          notificationCount == other.notificationCount;

  @override
  int get hashCode =>
      activeTab.hashCode ^
      initialTab.hashCode ^
      isLoggedIn.hashCode ^
      notificationCount;
}
