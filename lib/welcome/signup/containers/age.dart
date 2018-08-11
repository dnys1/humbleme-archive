import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models/user.dart';
import '../../../core/actions.dart';
import '../../../core/models.dart';
import '../../../routes.dart';
import '../../../selectors.dart';
import '../views/age_view.dart';

class AgeContainer extends StatefulWidget {
  AgeContainer();

  @override
  createState() => _AgeContainerState();
}

class _AgeContainerState extends State<AgeContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'age');
  bool _pushed = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
        onInit: (Store<AppState> store) =>
            store.dispatch(SetCurrentScaffold(_scaffoldKey)),
        rebuildOnChange: !_pushed,
        onWillChange: (_ViewModel vm) {
          if (vm.user.age != null && !_pushed) {
            _pushed = true;
            Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.pickNextInFlow(
                  user: vm.user,
                  context: context,
                ),
                (Route<dynamic> route) => false);
          }
        },
        converter: _ViewModel.fromStore,
        builder: (BuildContext context, _ViewModel vm) {
          return AgeView(
            scaffoldKey: _scaffoldKey,
            onNext: vm.onNext,
          );
        });
  }
}

class _ViewModel {
  final Function(int) onNext;
  final User user;
  final bool errorOccurred;

  _ViewModel({this.onNext, this.user, this.errorOccurred});

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      onNext: (age) => store.dispatch(UpdateAgeAction(age)),
      user: getCurrentUser(store.state.auth),
      errorOccurred: getErrorHasOccurred(store.state),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          errorOccurred == other.errorOccurred;

  @override
  int get hashCode => user.hashCode ^ errorOccurred.hashCode;
}
