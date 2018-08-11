import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme.dart';

class WelcomeView extends StatelessWidget {
  WelcomeView({
    Key key,
    @required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  Widget _buildButton({String text, Function onPressed, Icon icon}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: FlatButton(
          child: icon == null
              ? Text(
                  text,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: icon,
                    ),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
          padding: icon == null
              ? const EdgeInsets.symmetric(horizontal: 70.0, vertical: 12.0)
              : const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
          onPressed: onPressed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(backgroundColor: HumbleMe.primaryTeal, elevation: 0.0),
      body: GestureDetector(
        onTapUp: (TapUpDetails details) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset('images/logo.png', fit: BoxFit.cover)),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: HumbleMe.welcomeGradient,
                ),
                padding: const EdgeInsets.only(top: 32.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _buildButton(
                        text: 'Login',
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.login);
                        },
                      ),
                      _buildButton(
                        text: 'Sign Up',
                        onPressed: () {
                          Navigator
                              .of(context)
                              .pushNamed(Routes.emailAndPassword);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
