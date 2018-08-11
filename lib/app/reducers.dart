import 'package:redux/redux.dart';

import 'actions.dart';
import 'models.dart';

export 'search/reducers.dart';

final appReducer = combineReducers<AppTab>([
  TypedReducer<AppTab, UpdateCurrentTabAction>(_activeTabReducer),
  TypedReducer<AppTab, UpdateInitialTabAction>(_initialTabReducer),
]);

AppTab _activeTabReducer(AppTab activeTab, UpdateCurrentTabAction action) {
  return action.newTab;
}

AppTab _initialTabReducer(AppTab initialTab, UpdateInitialTabAction action) {
  return action.initialTab;
}
