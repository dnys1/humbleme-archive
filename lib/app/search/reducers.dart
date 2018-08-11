import 'package:redux/redux.dart';

import '../actions.dart';

final searchReducer = combineReducers<String>([
  TypedReducer<String, UpdateSearchText>(_searchBarReducer),
]);

String _searchBarReducer(String searchText, UpdateSearchText action) {
  return action.searchText;
}
