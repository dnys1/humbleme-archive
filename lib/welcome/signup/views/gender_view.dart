import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../auth/models/gender.dart';
import '../../../theme.dart';

class GenderView extends StatefulWidget {
  GenderView({
    Key key,
    @required this.onSubmit,
    @required this.scaffoldKey,
  }) : super(key: key);

  final Function(Gender) onSubmit;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _GenderViewState createState() => _GenderViewState();
}

class _GenderViewState extends State<GenderView> {
  Widget _buildButton(Gender type) {
    Widget icon;
    Widget text;
    const TextStyle style =
        const TextStyle(fontSize: 26.0, fontWeight: FontWeight.w600);
    switch (type) {
      case Gender.BOY:
        icon = Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Image.asset('images/m-superman.png'),
          ),
        );
        text = Expanded(
          child: const Text(
            'Boy',
            style: style,
            textAlign: TextAlign.center,
          ),
        );
        break;
      case Gender.GIRL:
        icon = Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Image.asset('images/f-superman.png'),
            ));
        text = Expanded(
          child: const Text(
            'Girl',
            style: style,
            textAlign: TextAlign.center,
          ),
        );
        break;
      case Gender.NA:
        icon = Container(width: 1.0, height: 1.0);
        text = const Text('Prefer not to answer',
            textAlign: TextAlign.center, style: style);
        break;
    }

    return Expanded(
      child: Center(
        child: Container(
          width: 180.0,
          height: 180.0,
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: FlatButton(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[icon, text],
              ),
            ),
            onPressed: () {
              widget.onSubmit(type);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: widget.scaffoldKey,
        appBar: AppBar(
          backgroundColor: HumbleMe.primaryTeal,
          elevation: 0.0,
        ),
        body: Container(
            padding: const EdgeInsets.only(bottom: 40.0),
            decoration: BoxDecoration(
              gradient: HumbleMe.welcomeGradient,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text('Which one are you?',
                      style: TextStyle(fontSize: 22.0)),
                ),
                _buildButton(Gender.BOY),
                _buildButton(Gender.GIRL),
                _buildButton(Gender.NA)
              ],
            )));
  }
}
