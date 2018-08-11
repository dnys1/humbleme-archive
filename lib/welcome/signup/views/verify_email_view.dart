import 'package:flutter/material.dart';

import '../../../theme.dart';

class VerifyEmailView extends StatelessWidget {
  final Function resendEmailVerification;
  final Function recheckEmailVerification;
  final GlobalKey<ScaffoldState> scaffoldKey;

  VerifyEmailView({
    this.resendEmailVerification,
    this.scaffoldKey,
    this.recheckEmailVerification,
  });

  void showInSnackBar(String value) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
      duration: const Duration(seconds: 3),
    ));
  }

  Widget _buildButton({String text, Function onPressed, bool large: false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: FlatButton(
        highlightColor: Colors.white70,
        splashColor: Colors.white70,
        child: Text(
          text,
          style: TextStyle(fontSize: large ? 18.0 : 14.0),
        ),
        onPressed: onPressed,
        padding: EdgeInsets.symmetric(
            horizontal: large ? 40.0 : 30.0, vertical: large ? 10.0 : 0.0),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white, width: 2.0),
          borderRadius: const BorderRadius.all(
            const Radius.circular(24.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: HumbleMe.primaryTeal,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: HumbleMe.welcomeGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Please check your email for verification instructions, then click 'I've verified' when complete",
                style: Theme.of(context).textTheme.title,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text(
                "Note: It may take a few minutes for the email to arrive",
                style: Theme.of(context).textTheme.subhead,
                textAlign: TextAlign.center,
              ),
            ),
            _buildButton(
              large: true,
              text: "Okay, I've verified it!",
              onPressed: recheckEmailVerification,
            ),
            _buildButton(
              text: 'Resend Verification',
              onPressed: () {
                resendEmailVerification();
                showInSnackBar(
                    'Please check your email. Note: It may take a few minutes for it to arrive.');
              },
            ),
          ],
        ),
      ),
    );
  }
}
