import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../theme.dart';
import '../models.dart';

typedef OnSubmitLoginCallback = Function(LoginData);

class LoginView extends StatefulWidget {
  final OnSubmitLoginCallback loginCallback;
  final Function(String) resetPassword;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool errorOccurred;

  LoginView({
    Key key,
    @required this.loginCallback,
    @required this.resetPassword,
    @required this.scaffoldKey,
    @required this.errorOccurred,
  }) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  LoginData data = LoginData();

  void showInSnackBar(String value) {
    widget.scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
    setState(() {
      _submitted = false;
    });
  }

  bool _autoCorrect = false;
  bool _autoValidate = false;
  bool _submitted = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // final GlobalKey<FormFieldState<String>> _passwordFieldKey = GlobalKey<FormFieldState<String>>();

  void _handleLogin() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;
      showInSnackBar('Please fix errors in the form.');
    } else {
      form.save();
      _autoValidate = false;
      widget.loginCallback(data);
      setState(() {
        _submitted = true;
      });
    }
  }

  void _handleResetPassword() {
    _formKey.currentState.save();
    String validation = _validateEmail(data.email);
    if (validation != null) {
      showInSnackBar(validation);
    } else {
      widget.resetPassword(data.email);
      showInSnackBar(
          'Forgot password link sent. Please check your email for password reset instructions.');
    }
  }

  String _validateEmail(String email) {
    if (email == null || email.isEmpty) return 'Email is required.';
    final RegExp emailExp =
        RegExp(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
    if (!emailExp.hasMatch(email)) return 'Please enter a valid email.';
    return null;
  }

  String _validatePassword(String password) {
    if (password == null || password.isEmpty) return 'Password is required.';
    return null;
  }

  Widget _buildButton({String text, Function onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
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
                    color: Colors.white,
                  )),
              onPressed: onPressed),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              autocorrect: _autoCorrect,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              onSaved: (email) {
                data.email = email.trim().toLowerCase();
              },
              decoration: InputDecoration(
                  labelText: 'Email', hintText: 'Enter your email'),
            ),
            TextFormField(
              autocorrect: _autoCorrect,
              obscureText: true,
              validator: _validatePassword,
              onSaved: (password) {
                data.password = password.trim();
              },
              onFieldSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgot() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CupertinoButton(
        padding: const EdgeInsets.all(10.0),
        child: Text('Forgot password?',
            style: Theme.of(context).textTheme.body1.copyWith(fontSize: 12.0)),
        onPressed: _handleResetPassword,
      ),
    );
  }

  @override
  void didUpdateWidget(LoginView oldWidget) {
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
          title: Text('Login'),
          backgroundColor: HumbleMe.primaryTeal,
          elevation: 0.0),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: HumbleMe.welcomeGradient,
          ),
          child: GestureDetector(
            onTapUp: (TapUpDetails details) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: ListView(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                          child: Image.asset('images/logo.png',
                              fit: BoxFit.contain,
                              width: min(250.0,
                                  MediaQuery.of(context).size.width - 160))),
                    ),
                    Container(
                        child: Column(
                      children: <Widget>[
                        _buildForm(),
                        _buildButton(
                          text: 'Login',
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _handleLogin();
                          },
                        ),
                        _buildForgot(),
                      ],
                    ))
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
