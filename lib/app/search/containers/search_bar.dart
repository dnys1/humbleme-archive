import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../../../theme.dart';
import '../../actions.dart';
import '../views/animated_search_bar.dart';
import '../views/static_search_bar.dart';

class SearchBarContainer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Animation<double> animation;
  final Function onCancel;
  final Function onClear;
  final Function onSubmit;

  SearchBarContainer(
      {Key key,
      @required this.controller,
      @required this.focusNode,
      @required this.onSubmit,
      this.animation,
      this.onCancel,
      this.onClear})
      : assert(controller != null),
        assert(focusNode != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        return kIsAndroid
            ? StaticSearchBar(
                controller: controller,
                focusNode: focusNode,
                searchText: vm.searchText,
                onSubmit: (String searchText) {
                  vm.onSubmit(searchText);
                  onSubmit();
                },
                onUpdate: vm.onUpdate,
                onCancel: onCancel,
                onClear: () {
                  this.onClear();
                  vm.onClear();
                },
              )
            : AnimatedSearchBar(
                controller: controller,
                focusNode: focusNode,
                searchText: vm.searchText,
                animation: animation,
                onSubmit: (String searchText) {
                  vm.onSubmit(searchText);
                  onSubmit();
                },
                onUpdate: vm.onUpdate,
                onCancel: () {
                  this.onCancel();
                  vm.onClear();
                },
                onClear: () {
                  this.onClear();
                  vm.onClear();
                },
              );
      },
    );
  }
}

class _ViewModel {
  final String searchText;
  final Function onClear;
  final Function(String) onUpdate;
  final Function(String) onSubmit;

  _ViewModel(
      {@required this.searchText,
      @required this.onUpdate,
      @required this.onSubmit,
      @required this.onClear});

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      searchText: getSearchText(store.state.auth),
      onUpdate: (text) {
        // store.dispatch(UpdateSearchText(text));
        // store.dispatch(GetSearchResults(text));
      },
      onSubmit: (text) {
        store.dispatch(UpdateSearchText(text));
        store.dispatch(GetSearchResults(text));
      },
      onClear: () {
        store.dispatch(UpdateSearchText(''));
        store.dispatch(ClearSearchResults());
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          searchText == other.searchText;

  @override
  int get hashCode => searchText.hashCode;
}
