import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class PlatformAlertDialog extends StatelessWidget {
  final String title;
  final List<Map<String, Function>> actions;

  PlatformAlertDialog({
    Key key,
    @required this.title,
    @required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !kIsAndroid
        ? CupertinoAlertDialog(
            title: Text(title),
            actions: <Widget>[
              CupertinoButton(
                child: Text('Yes'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              CupertinoButton(
                child: Text('No'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          )
        : AlertDialog(
            title: Text(
                'You are about to exit the survey. Do you wish to continue?'),
            actions: <Widget>[
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                  FlatButton(
                    child: Text('No'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ],
          );
  }
}
