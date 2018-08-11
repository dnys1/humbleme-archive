import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../auth/models/user.dart';
import '../core/models.dart';
import '../routes.dart';
import '../selectors.dart';
import '../welcome/container.dart';
import 'actions.dart';
import 'views/loading_view.dart';

/// This is the entry point of the application. Upon loading the application
/// in `main.dart`, this is the first "route" pushed to the stack. While the
/// state reads [isLoadingUser], a LoadingView is displayed, which is a [Container]
/// with a [CircleProgressIndicator] as a child.
///
/// The application is divided into roughly two "sections", [app] and [welcome]. [app]
/// includes views such as [ProfileView], [PulseView], etc., while [welcome] includes
/// the [LoginView] and [SignupView]. The project structure accomodates this by seperating
/// the components into two root folders.
///
/// Upon the [CheckSignInAction] being fired, the [isLoadingUser] variable is set
/// to false, at which time the widget chooses a route to push. If the [CheckSignInAction]
/// returned a signed in user, then the [ApplicationContainer] is pushed. If not
/// (i.e. if [user == null]), then the [WelcomeContainer] is pushed as the top-level
/// route, which shows the login and signup buttons.
class HMContainer extends StatefulWidget {
  final Function(ThemeData) handleThemeChange;

  HMContainer({
    @required this.handleThemeChange,
  }) : assert(handleThemeChange != null);

  @override
  _HMContainerState createState() => _HMContainerState();
}

class _HMContainerState extends State<HMContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'core');
  bool _pushed = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (Store<AppState> store) {
        store.dispatch(SetThemeChangeHandler(widget.handleThemeChange));
        store.dispatch(SetCurrentScaffold(_scaffoldKey));
      },
      onWillChange: (_ViewModel vm) {
        if (!vm.isLoading && !_pushed) {
          _pushed = true;
          String route = Routes.pickNextInFlow(
            user: vm.user,
            context: context,
          );
          Navigator.of(context).pushAndRemoveUntil(
              Routes.routeBuilderFromPath(context, route),
              (Route<dynamic> route) => false);
        }
      },
      rebuildOnChange: !_pushed,
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        return LoadingView(
          scaffoldKey: _scaffoldKey,
        );
      },
    );
  }
}

/// The view model for this container
class _ViewModel {
  final bool isLoading;
  final bool isLoadingUser;
  final bool loggedIn;
  final User user;
  final Function(ThemeData, bool) setTheme;

  _ViewModel(
      {this.isLoading,
      this.isLoadingUser,
      this.loggedIn,
      this.user,
      this.setTheme});

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      isLoading: isLoadingSelector(store.state),
      isLoadingUser: isLoadingUserSelector(store.state),
      loggedIn: loggedInSelector(store.state.auth),
      user: getCurrentUser(store.state.auth),
      setTheme: (theme, isAppTheme) =>
          store.dispatch(SetTheme(theme, isAppTheme)),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          loggedIn == other.loggedIn;

  @override
  int get hashCode => isLoading.hashCode ^ loggedIn.hashCode;
}
