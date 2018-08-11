import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../core/actions.dart';
import '../core/models.dart';
import 'view.dart';

class WelcomeContainer extends StatelessWidget {
  WelcomeContainer({Key key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'welcome');

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Null>(
      onInit: (Store<AppState> store) =>
          store.dispatch(SetCurrentScaffold(_scaffoldKey)),
      converter: (Store<AppState> store) => null,
      builder: (BuildContext context, _) {
        return WelcomeView(
          scaffoldKey: _scaffoldKey,
        );
      },
    );
  }
}
