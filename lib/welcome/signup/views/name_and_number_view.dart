import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme.dart';
import '../models.dart';

final kVerificationCodeLength = 6;

class NameAndNumberView extends StatefulWidget {
  final Function onSubmitNameAndNumber;
  final Function onSubmitVerification;
  final Function resendVerification;
  final Function signOut;
  final bool nameAndNumberRegistered;
  final bool verificationSent;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool errorOccurred;

  NameAndNumberView({
    @required this.onSubmitNameAndNumber,
    @required this.onSubmitVerification,
    @required this.resendVerification,
    @required this.signOut,
    @required this.nameAndNumberRegistered,
    @required this.scaffoldKey,
    @required this.verificationSent,
    @required this.errorOccurred,
  }) : assert(scaffoldKey != null);

  @override
  _NameAndNumberViewState createState() => _NameAndNumberViewState();
}

class _NameAndNumberViewState extends State<NameAndNumberView> {
  NameAndNumberData _data = NameAndNumberData();
  String _verificationCode;
  bool _submitted = false;

  void showInSnackBar(String value) {
    widget.scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  void didUpdateWidget(NameAndNumberView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!(oldWidget.errorOccurred ?? false) && widget.errorOccurred) {
      setState(() {
        _submitted = false;
      });
    }
  }

  bool _autoCorrect = false;
  bool _autoValidate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _UsNumberTextInputFormatter _phoneNumberFormatter =
      _UsNumberTextInputFormatter();

  void _handleNameAndNumberSave() async {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true;
      if (kIsAndroid) {
        await showDialog<Null>(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text('Error'),
                  content: const Text('Please fix errors in the form.'),
                  actions: <Widget>[
                    CupertinoButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ],
                ));
      } else {
        showInSnackBar('Please fix errors in the form.');
      }
    } else {
      form.save();
      form.reset();
      widget.onSubmitNameAndNumber(_data);
      setState(() {
        _submitted = true;
      });
      // showInSnackBar('SMS Verification Code sent.');
    }
  }

  void _handleVerifyPhoneNumber() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      showInSnackBar('Incorrect code format. Please try again.');
    } else {
      form.save();
      setState(() {
        _submitted = true;
      });
      widget.onSubmitVerification(_verificationCode);
    }
  }

  void _resendVerification() {
    widget.resendVerification(_data);
    showInSnackBar('SMS Verification Code resent.');
  }

  String _validateVerificationCode(String verificationCode) {
    if (verificationCode.isEmpty) return 'Cannot be empty.';
    if (verificationCode.length != kVerificationCodeLength)
      return 'Please enter $kVerificationCodeLength digits only.';
    return null;
  }

  String _validateName(String name) {
    if (name.isEmpty) return 'Name is required.';
    if (name.split(' ').length != 2) {
      return 'Please enter first and last name.';
    }
    final RegExp nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(name))
      return 'Please enter only alphabetical characters.';
    return null;
  }

  String _validatePhoneNumber(String number) {
    // number = number.splitMapJoin(
    //   (RegExp(r'\d')),
    //   onMatch: (m) => '${m.group(0)}',
    //   onNonMatch: (n) => '',
    // );
    // print(number);
    if (number.length != 10) {
      return 'Please enter a 10-digit US number.';
    }
    final RegExp phoneExp = RegExp(r'^\d\d\d\d\d\d\d\d\d\d$');
    if (!phoneExp.hasMatch(number))
      return '(###) ###-#### - Please enter a valid US number.';
    return null;
  }

  Widget _buildButton({String text, Function onPressed}) {
    return _submitted
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
        : Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: FlatButton(
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
      // onWillPop: _warnUserAboutInvalidData,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(60.0, 35.0, 60.0, 30.0),
        child: Column(
          children: widget.nameAndNumberRegistered && widget.verificationSent
              ? <Widget>[
                  TextFormField(
                    autocorrect: _autoCorrect,
                    onSaved: (String code) {
                      _verificationCode = code;
                    },
                    keyboardType: TextInputType.number,
                    validator: _validateVerificationCode,
                    decoration: InputDecoration(
                      labelText: 'SMS verification code',
                      hintText: 'Enter the verification code',
                    ),
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                  )
                ]
              : <Widget>[
                  TextFormField(
                    autocorrect: _autoCorrect,
                    onSaved: (String value) {
                      var name = value.trim();
                      _data.firstName = name.split(' ')[0];
                      _data.lastName = name.split(' ')[1];
                    },
                    validator: _validateName,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                    ),
                  ),
                  TextFormField(
                    autocorrect: _autoCorrect,
                    validator: _validatePhoneNumber,
                    onSaved: (String value) {
                      // value = value.splitMapJoin(
                      //   (RegExp(r'\d')),
                      //   onMatch: (m) => '${m.group(0)}',
                      //   onNonMatch: (n) => '',
                      // );
                      _data.phoneNumber = '+1$value';
                    },
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixText: '+1 ',
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly,
                      // _phoneNumberFormatter,
                    ],
                  ),
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: HumbleMe.primaryTeal,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Theme(
          data: Theme.of(context).copyWith(
                primaryColor: Colors.white,
                inputDecorationTheme: InputDecorationTheme(
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
          child: GestureDetector(
            onTapUp: (TapUpDetails details) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: HumbleMe.welcomeGradient,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Stack(
                    children: [
                      ListView(
                        physics: kIsAndroid
                            ? ClampingScrollPhysics()
                            : BouncingScrollPhysics(),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              'Just a few more steps!',
                              style: TextStyle(fontSize: 40.0),
                            ),
                          ),
                          _buildForm(),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              children: <Widget>[
                                widget.nameAndNumberRegistered &&
                                        widget.verificationSent
                                    ? _buildButton(
                                        text: 'Verify',
                                        onPressed: _handleVerifyPhoneNumber)
                                    : _buildButton(
                                        text: 'Submit',
                                        onPressed: _handleNameAndNumberSave),
                                widget.nameAndNumberRegistered &&
                                        widget.verificationSent
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 12.0),
                                        child: FlatButton(
                                          highlightColor: Colors.white70,
                                          splashColor: Colors.white70,
                                          child: Text('Resend'),
                                          onPressed: _resendVerification,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30.0),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                            borderRadius:
                                                const BorderRadius.all(
                                              const Radius.circular(24.0),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          )
                        ],
                      ),
                      // Positioned(
                      //   bottom: 0.0,
                      //   left: 0.0,
                      //   right: 0.0,
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(20.0),
                      //     child: CupertinoButton(
                      //       child: Text('Sign Out',
                      //           style: Theme
                      //               .of(context)
                      //               .textTheme
                      //               .body1
                      //               .copyWith(color: Colors.white)),
                      //       onPressed: widget.signOut,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Format incoming numeric text to fit the format of (###) ###-#### ##...
class _UsNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();
    if (newTextLength >= 1) {
      newText.write('(');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    if (newTextLength >= 4) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 3) + ') ');
      if (newValue.selection.end >= 3) selectionIndex += 2;
    }
    if (newTextLength >= 7) {
      newText.write(newValue.text.substring(3, usedSubstringIndex = 6) + '-');
      if (newValue.selection.end >= 6) selectionIndex++;
    }
    if (newTextLength >= 11) {
      newText.write(newValue.text.substring(6, usedSubstringIndex = 10) + ' ');
      if (newValue.selection.end >= 10) selectionIndex++;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
