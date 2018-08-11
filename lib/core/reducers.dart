import '../app/reducers.dart';
import '../auth/actions.dart';
import '../auth/reducers.dart';
import '../services/platform/actions.dart';
import 'actions.dart';
import 'models.dart';

/// We create the State reducer by combining many smaller reducers into one!
AppState coreReducer(AppState state, action) {
  /// Our small middleware for picking up past actions
  List<String> allActions = List<String>.from(state.allActions)
    ..add(action.toString());
  if (action is LogoutAction) {
    return state.reset();
  } else {
    return state.copyWith(
      isLoading: action is CheckLoggedInSuccess ? false : null,
      isLoadingUser: action is UpdatePermissions ? false : null,
      appThemeEnabled: action is SetTheme ? action.appTheme : null,
      activeTab: appReducer(state.activeTab, action),
      initialTab: appReducer(state.initialTab, action),
      auth: authReducer(state.auth, action),
      allActions: action is ClearAllActions ? const [] : allActions,
      handleThemeChange:
          action is SetThemeChangeHandler ? action.handler : null,
      buildInfo: action is SetBuildInfo ? action.buildInfo : null,
      deviceInfo: action is SetDeviceInfo ? action.deviceInfo : null,
      currentScaffold:
          action is SetCurrentScaffold ? action.currentScaffold : null,
      errorOccurred: action is GlobalErrorAction
          ? true
          : action is ClearAuthError ? false : null,
      resources: action is SetAllResources ? action.resources : null,
      questionSetStatistics: action is SetQuestionSetStatistics
          ? action.questionSetStatistics
          : null,
    );
  }
}
