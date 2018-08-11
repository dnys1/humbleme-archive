import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/models/resource.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../views/bookshelf_view.dart';

class BookshelfContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        return BookshelfView(
          resources: vm.resources,
        );
      },
    );
  }
}

class _ViewModel {
  final List<Resource> resources;

  _ViewModel({this.resources});

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      resources: getResources(store.state),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          resources == other.resources;

  @override
  int get hashCode => resources.hashCode;
}
