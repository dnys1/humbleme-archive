import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../services/platform/permissions.dart';
import '../../../theme.dart';

class EnablePermissionsView extends StatefulWidget {
  final Map<PermissionType, PermissionState> permissions;
  final PermissionState contactsPermission;
  final PermissionState locationPermission;
  final Function(PermissionType, PermissionState) updatePermission;
  final GlobalKey<ScaffoldState> scaffoldKey;

  EnablePermissionsView({
    Key key,
    @required this.permissions,
    @required this.updatePermission,
    @required this.scaffoldKey,
  })  : contactsPermission = permissions[PermissionType.contacts],
        locationPermission = permissions[PermissionType.locationWhenInUse],
        super(key: key);

  @override
  _EnablePermissionsViewState createState() => _EnablePermissionsViewState();
}

class _EnablePermissionsViewState extends State<EnablePermissionsView> {
  bool get _contactsGranted =>
      widget.contactsPermission == PermissionState.granted;
  bool get _locationGranted =>
      widget.locationPermission == PermissionState.granted;

  bool get _contactsDenied =>
      widget.contactsPermission == PermissionState.denied;
  bool get _locationDenied =>
      widget.locationPermission == PermissionState.denied;

  void _enableLocation() async {
    final PermissionState permissionState =
        await Permissions.requestPermission(PermissionType.locationWhenInUse);
    switch (permissionState) {
      case PermissionState.granted:
        print('Success getting location permission!');
        break;
      case PermissionState.showRationale:
        // For android, show rationale for usage, then request again
        if (kIsAndroid) {
          await Future.delayed(Duration(milliseconds: 50)).then((_) {
            showDialog<Null>(
                context: widget.scaffoldKey.currentContext,
                barrierDismissible: false,
                builder: (BuildContext context) => AlertDialog(
                      title: Text('Location Permission'),
                      content: SingleChildScrollView(
                          child: ListBody(
                        children: <Widget>[
                          Text(
                              'We use your location to help you find friends in your area.')
                        ],
                      )),
                      actions: <Widget>[
                        FlatButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator
                                  .of(widget.scaffoldKey.currentContext)
                                  .pop();
                              _enableLocation();
                            })
                      ],
                    ));
          });
        }
        // For iOS, this means the function has been diabled system-wide.
        // Prompt users to enable it in Settings
        else {}
        break;
      case PermissionState.denied:
      default:
        print('Error requesting permission');
        // TODO: Add "Go to Settings dialog for iOS"
        break;
    }
    widget.updatePermission(PermissionType.locationWhenInUse, permissionState);
  }

  void _enableContacts() async {
    final PermissionState permissionState =
        await Permissions.requestPermission(PermissionType.contacts);

    switch (permissionState) {
      case PermissionState.granted:
        print('Success getting contacts permission!');
        break;
      case PermissionState.showRationale:
        if (kIsAndroid) {
          await Future.delayed(Duration(milliseconds: 50)).then((_) {
            showDialog<Null>(
                context: widget.scaffoldKey.currentContext,
                barrierDismissible: false,
                builder: (BuildContext context) => AlertDialog(
                      title: Text('Contacts Permission'),
                      content: SingleChildScrollView(
                          child: ListBody(
                        children: <Widget>[
                          Text('We use contacts to find friends on the app.')
                        ],
                      )),
                      actions: <Widget>[
                        FlatButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator
                                  .of(widget.scaffoldKey.currentContext)
                                  .pop();
                              _enableContacts();
                            })
                      ],
                    ));
          });
        }
        break;
      case PermissionState.denied:
      default:
        print('Error requesting permission');
        // TODO: Add "Go to Settings dialog for iOS"
        break;
    }
    widget.updatePermission(PermissionType.contacts, permissionState);
  }

  Widget _buildButton({String text, Function onPressed, int index}) {
    var padding = index == 1
        ? const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0)
        : const EdgeInsets.symmetric(horizontal: 35.0, vertical: 12.0);
    Color successColor = Colors.green;
    Color deniedColor = Colors.red;
    var side, icon;
    TextStyle style = TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    );
    if (index == 1) {
      padding = EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0);
      switch (widget.locationPermission) {
        case PermissionState.granted:
          side = BorderSide(color: successColor, width: 2.0);
          icon = Icon(Icons.check, color: successColor);
          style = style.copyWith(color: successColor);
          break;
        case PermissionState.denied:
          side = BorderSide(color: deniedColor, width: 2.0);
          icon = Icon(Icons.close, color: deniedColor);
          style = style.copyWith(color: deniedColor);
          break;
        default:
          side = BorderSide(color: Colors.white, width: 2.0);
          icon = Icon(Icons.location_on);
          break;
      }
    } else if (index == 2) {
      padding = EdgeInsets.symmetric(horizontal: 35.0, vertical: 12.0);
      switch (widget.contactsPermission) {
        case PermissionState.granted:
          side = BorderSide(color: successColor, width: 2.0);
          icon = Icon(Icons.check, color: successColor);
          style = style.copyWith(color: successColor);
          break;
        case PermissionState.denied:
          side = BorderSide(color: deniedColor, width: 2.0);
          icon = Icon(Icons.close, color: deniedColor);
          style = style.copyWith(color: deniedColor);
          break;
        default:
          side = BorderSide(color: Colors.white, width: 2.0);
          icon = Icon(Icons.import_contacts);
          break;
      }
    }

    return Container(
      child: FlatButton(
          padding: padding,
          shape: RoundedRectangleBorder(
              side: side,
              borderRadius:
                  const BorderRadius.all(const Radius.circular(24.0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: icon,
              ),
              Text(text, style: style),
            ],
          ),
          onPressed: onPressed),
    );
  }

  Widget _buildPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: HumbleMe.welcomeGradient,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Image.asset('images/logo.png',
                      fit: BoxFit.cover, height: 280.0)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.info_outline),
                        onPressed: () async {
                          showModalBottomSheet(
                            context: widget.scaffoldKey.currentContext,
                            builder: (BuildContext context) => Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    'Your privacy is important. We use contacts to find friends you may already known and location to find nearby schools to join.',
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                          );
                        },
                      ),
                      Text('Why do you need this info?',
                          style: Theme.of(context).textTheme.subhead),
                    ],
                  ),
                  _buildButton(
                      text: 'Enable Location',
                      onPressed: (_locationGranted || _locationDenied)
                          ? null
                          : _enableLocation,
                      index: 1),
                  _buildButton(
                      text: 'Enable Contacts',
                      onPressed: (_contactsGranted || _contactsDenied)
                          ? null
                          : _enableContacts,
                      index: 2),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
    // final TextStyle skipButtonStyle =
    //     TextStyle(color: Colors.white, fontSize: 18.0);
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        backgroundColor: HumbleMe.primaryTeal,
        elevation: 0.0,
        // actions: <Widget>[
        //   isAndroid
        //       ? FlatButton(
        //           child: Text('Skip', style: skipButtonStyle),
        //           onPressed: () {
        //             Navigator.of(context).pushNamed('/welcome/age');
        //           },
        //         )
        //       : CupertinoButton(
        //           child: Text('Skip', style: skipButtonStyle),
        //           onPressed: () {
        //             Navigator.of(context).pushNamed('/welcome/age');
        //           },
        //         )
        // ],
      ),
      body: _buildPage(),
    );
  }
}
