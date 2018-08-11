import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../theme.dart';
import '../models.dart';

class EmailAndPasswordView extends StatefulWidget {
  EmailAndPasswordView({
    Key key,
    @required this.onSignupSubmit,
    @required this.scaffoldKey,
    @required this.errorOccurred,
  }) : super(key: key);

  final Function onSignupSubmit;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool errorOccurred;

  @override
  _EmailAndPasswordViewState createState() => _EmailAndPasswordViewState();
}

class _EmailAndPasswordViewState extends State<EmailAndPasswordView> {
  String username = '';
  String email = '';
  String password = '';

  bool connected = true;
  bool _submitted = false;

  bool _autoCorrect = false;
  bool _autoValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();

  void _handleSignup() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;
      // if (isAndroid) {
      //   await showDialog<Null>(
      //       context: context,
      //       child: CupertinoAlertDialog(
      //         title: Text('Error'),
      //         content: const Text('Please fix errors in the form.'),
      //         actions: <Widget>[
      //           CupertinoButton(
      //               child: Text('OK'),
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               })
      //         ],
      //       ));
      // } else {
      // }
    } else {
      form.save();
      _autoValidate = false;
      widget.onSignupSubmit(EmailAndPasswordData(
        username: username,
        password: password,
        email: email,
      ));
      setState(() {
        _submitted = true;
      });
    }
  }

  String _validateUsername(String username) {
    if (username.isEmpty) return 'Username is required.';
    final RegExp usernameExp =
        RegExp(r'^[a-zA-Z0-9]([._](?![._])|[a-zA-Z0-9]){6,18}[a-zA-Z0-9]$');
    if (!usernameExp.hasMatch(username))
      return 'Username must follow the requirements.';
    return null;
  }

  String _validateEmail(String email) {
    if (email.isEmpty) return 'E-mail cannot be empty.';
    final RegExp emailExp =
        RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
    if (!emailExp.hasMatch(email)) return 'E-mail must be in correct format.';
    return null;
  }

  String _validatePassword(String password) {
    final FormFieldState<String> passwordField = _passwordFieldKey.currentState;
    if (password == null || password.isEmpty) return 'Password is required.';
    if (passwordField.value != password) return 'Passwords don\'t match';
    return null;
  }

  Widget _buildButton({String text, Function onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: _submitted
          ? Container(
              width: 48.0,
              height: 48.0,
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Theme(
                data: ThemeData(
                  accentColor: Colors.white,
                ),
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              ),
            )
          : FlatButton(
              child: Text(text,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  )),
              onPressed: onPressed),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      // onWillPop: _warnUserAboutInvalidData,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60.0),
          child: Column(children: <Widget>[
            // TextFormField(
            //   autocorrect: _autoCorrect,
            //   onSaved: (username) {
            //     setState(() {
            //       this.username = username.trim().toLowerCase();
            //     });
            //   },
            //   validator: _validateUsername,
            //   decoration: InputDecoration(
            //     labelText: 'Username',
            //     hintText: 'Pick a username',
            //   ),
            // ),
            TextFormField(
              autocorrect: _autoCorrect,
              onSaved: (email) {
                setState(() {
                  this.email = email.trim();
                });
              },
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: 'E-mail', hintText: 'Enter your e-mail'),
            ),
            TextFormField(
              key: _passwordFieldKey,
              autocorrect: _autoCorrect,
              obscureText: true,
              onSaved: (password) {
                setState(() {
                  this.password = password.trim();
                });
              },
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Pick a password',
              ),
            ),
            TextFormField(
              autocorrect: _autoCorrect,
              obscureText: true,
              validator: _validatePassword,
              onFieldSubmitted: (_) {
                _handleSignup();
              },
              decoration: InputDecoration(
                  labelText: 'Re-type password', hintText: 'Re-type password'),
            ),
          ])),
    );
  }

  @override
  void didUpdateWidget(EmailAndPasswordView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!(oldWidget.errorOccurred ?? false) && widget.errorOccurred) {
      setState(() {
        _submitted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          title: Text('Choose a password'),
          backgroundColor: HumbleMe.primaryTeal,
          elevation: 0.0),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Theme(
          data: Theme.of(context).copyWith(
              primaryColor: Colors.white,
              inputDecorationTheme: InputDecorationTheme(
                  labelStyle: TextStyle(color: Colors.white))),
          child: Container(
            decoration: BoxDecoration(
              gradient: HumbleMe.welcomeGradient,
            ),
            child: GestureDetector(
              onTapUp: (TapUpDetails details) {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: ListView(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                      child: Center(
                          child: Image.asset(
                        'images/logo.png',
                        fit: BoxFit.cover,
                        width: 250.0,
                      )),
                    ),
                    Center(
                      child: Column(
                        children: <Widget>[
                          _buildForm(),
                          _buildButton(
                            text: 'Sign Up',
                            onPressed: connected ? _handleSignup : null,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
