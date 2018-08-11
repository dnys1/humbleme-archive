import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models/gender.dart';
import '../../../auth/models/user.dart';
import '../../../core/actions.dart';
import '../../../core/models.dart';
import '../../../routes.dart';
import '../../../selectors.dart';
import '../views/gender_view.dart';

class GenderContainer extends StatefulWidget {
  GenderContainer();

  @override
  createState() => _GenderContainerState();
}

class _GenderContainerState extends State<GenderContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: 'gender');
  bool _pushed = false;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (Store<AppState> store) =>
          store.dispatch(SetCurrentScaffold(_scaffoldKey)),
      rebuildOnChange: !_pushed,
      onWillChange: (_ViewModel vm) {
        if (vm.user.gender != null && !_pushed) {
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
        return WillPopScope(
          onWillPop: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Wait!'),
                  content: Text(
                      'This will return you to the main screen. Are you sure you wish to do this?'),
                  actions: <Widget>[
                    ButtonBar(
                      children: <Widget>[
                        FlatButton.icon(
                          label: Text('Go Back'),
                          icon: Icon(Icons.thumb_down),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        FlatButton.icon(
                          label: Text('OK'),
                          icon: Icon(Icons.thumb_up),
                          onPressed: () => Navigator.of(context).pop(true),
                        )
                      ],
                    ),
                  ],
                );
              },
            );
          },
          child: GenderView(
            scaffoldKey: _scaffoldKey,
            onSubmit: vm.updateGender,
          ),
        );
      },
    );
  }
}

class _ViewModel {
  final Function updateGender;
  final User user;

  _ViewModel({
    @required this.updateGender,
    @required this.user,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      updateGender: (Gender gender) =>
          store.dispatch(UpdateGenderAction(gender)),
      user: getCurrentUser(store.state.auth),
    );
  }
}
