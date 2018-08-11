import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models/mindset.dart';
import '../../../auth/models/user.dart';
import '../../../core/actions.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../../../theme.dart';
import '../views/top_mindsets_view.dart';

class TopMindsets extends StatefulWidget {
  TopMindsets();

  @override
  createState() => _TopMindsetsState();
}

class _TopMindsetsState extends State<TopMindsets> {
  bool _pushed = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        onWillChange: (_ViewModel vm) {
          if (vm.user.topMindsets != null && !_pushed) {
            setState(() {
              _pushed = true;
            });

            Navigator.of(context, rootNavigator: true).pop();
          }
        },
        distinct: true,
        rebuildOnChange: !_pushed,
        converter: _ViewModel.fromStore,
        builder: (BuildContext context, _ViewModel vm) {
          return TopMindsetsView(
            mindsets: vm.mindsets,
            onSubmit: vm.onSubmit,
          );
        });
  }
}

class _ViewModel {
  final User user;
  final List<Mindset> mindsets;
  final Function onSubmit;
  final Function setAppTheme;

  _ViewModel({
    @required this.mindsets,
    @required this.onSubmit,
    @required this.user,
    @required this.setAppTheme,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      user: getCurrentUser(store.state.auth),
      mindsets: getMindsets(store.state.auth),
      onSubmit: (data) => store.dispatch(RecordTopMindsets(data)),
      setAppTheme: () => store.dispatch(SetTheme(HumbleMe.appTheme, true)),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          mindsets == other.mindsets &&
          user == other.user;

  @override
  int get hashCode => mindsets.hashCode ^ user.hashCode;
}
