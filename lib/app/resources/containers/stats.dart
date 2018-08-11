import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/models/mindset.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../views/stats_view.dart';

class StatsContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      builder: (BuildContext context, _ViewModel vm) {
        return StatsView(
          mindsets: vm.mindsets,
          topMindsets: vm.topMindsets,
        );
      },
    );
  }
}

class _ViewModel {
  final List<String> topMindsets;
  final List<Mindset> mindsets;

  _ViewModel({
    @required this.mindsets,
    @required this.topMindsets,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    // Sort the mindsets based on ranking
    List<Mindset> sortedMindsets = []
      ..addAll(getMindsets(store.state.auth))
      ..sort((a, b) => a.ranking.compareTo(b.ranking));
    return _ViewModel(
      topMindsets: getTopMindsets(store.state.auth),
      mindsets: sortedMindsets,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          topMindsets == other.topMindsets &&
          mindsets == other.mindsets;

  @override
  int get hashCode => topMindsets.hashCode ^ mindsets.hashCode;
}
