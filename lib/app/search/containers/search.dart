import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/models.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../actions.dart';
import '../views/search_view.dart';

class SearchContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      onDispose: (Store<AppState> store) {
        store.dispatch(UpdateSearchText(''));
      },
      builder: (BuildContext context, _ViewModel vm) {
        return SearchView(
          user: vm.user,
          searchText: vm.searchText,
          searchResults: vm.searchResults,
          isLoadingUserData: vm.isLoadingUserData,
        );
      },
    );
  }
}

class _ViewModel {
  final User user;
  final String searchText;
  final List<PublicUser> searchResults;
  final bool isLoadingUserData;

  _ViewModel({
    @required this.user,
    @required this.searchText,
    @required this.searchResults,
    @required this.isLoadingUserData,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      user: getCurrentUser(store.state.auth),
      searchText: getSearchText(store.state.auth),
      searchResults: getSearchResultsStream(store.state.auth),
      isLoadingUserData: isLoadingUserSelector(store.state),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          searchText == other.searchText &&
          searchResults == other.searchResults &&
          isLoadingUserData == other.isLoadingUserData;

  @override
  int get hashCode =>
      hashValues(user, searchText, searchResults, isLoadingUserData);
}
