import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models.dart';
import '../../../theme.dart';
import 'cupertino_settings.dart';
import 'licenses_view.dart';

class SettingsView extends StatefulWidget {
  final Function logout;
  final BuildInfo buildInfo;

  SettingsView({@required this.logout, @required this.buildInfo});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final buildSettingsStyle = kiOSDefaultTextStyle.copyWith(
      color: CS_HEADER_TEXT_COLOR, fontSize: 12.0);

  void _launchPrivacyPolicy() async {
    if (await canLaunch('https://www.humbleme.us/privacy.html')) {
      await launch('https://www.humbleme.us/privacy.html');
    } else {
      print('Could not launch url');
    }
  }

  Widget _buildAndroid() {
    return Theme(
      data: HumbleMe.appTheme.copyWith(
        buttonTheme: ThemeData.dark().buttonTheme,
      ),
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: HumbleMe.primaryTeal,
              title: Text('Settings'),
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Center(
                      child: RaisedButton(
                        color: HumbleMe.blueGray,
                        child: Text(
                          'Show Licenses',
                          style: Theme.of(context).primaryTextTheme.body1,
                        ),
                        onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => Theme(
                                      data: HumbleMe.appTheme,
                                      child: Builder(
                                        builder: (BuildContext context) {
                                          return LicensePage(
                                            applicationName:
                                                widget.buildInfo.appName,
                                            applicationVersion:
                                                '${widget.buildInfo.version} (${widget.buildInfo.buildNumber})',
                                          );
                                        },
                                      ),
                                    ),
                              ),
                            ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Center(
                      child: RaisedButton(
                        color: HumbleMe.greenGray,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Privacy Policy',
                              style: Theme.of(context).primaryTextTheme.body1,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                                vertical: 0.0,
                              ),
                              child: Icon(
                                Icons.launch,
                                color: Colors.white,
                                size: Theme
                                    .of(context)
                                    .primaryTextTheme
                                    .body1
                                    .fontSize,
                              ),
                            ),
                          ],
                        ),
                        onPressed: _launchPrivacyPolicy,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Center(
                      child: RaisedButton(
                        color: Colors.red[400],
                        child: Text(
                          'Logout',
                          style: Theme.of(context).primaryTextTheme.body1,
                        ),
                        onPressed: widget.logout,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Text(
                            widget.buildInfo.appName,
                            style: buildSettingsStyle,
                          ),
                          Text(
                            'Version: ${widget.buildInfo.version} (${widget.buildInfo.buildNumber})',
                            style: buildSettingsStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    _buildCredits(),
                    textAlign: TextAlign.center,
                    style: buildSettingsStyle,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _buildCredits() {
    String authors = [
      'Freepik',
    ].join(', ');
    String credits = [
      'Credits:',
      'Icons by $authors from FlatIcon.com',
    ].join('\n');
    return credits;
  }

  Widget _buildiOS() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        actionsForegroundColor: CupertinoColors.white,
        backgroundColor: HumbleMe.primaryTeal,
        middle: Text(
          'Settings',
          style: Theme.of(context).primaryTextTheme.title,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(0.0),
        child: CupertinoSettings(
          <Widget>[
            CSDivider(),
            CSButton(CSButtonType.DEFAULT_CENTER, 'Privacy Policy',
                _launchPrivacyPolicy),
            CSButton(
                CSButtonType.DEFAULT_CENTER,
                'Show Licenses',
                () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (BuildContext context) => LicensePage(
                              applicationName: widget.buildInfo.appName,
                              applicationVersion:
                                  '${widget.buildInfo.version} (${widget.buildInfo.buildNumber})',
                            ),
                      ),
                    )),
            CSSpacer(),
            CSButton(CSButtonType.DESTRUCTIVE, 'Logout', widget.logout),
            CSSpacer(
              bottom: false,
              height: 30.0,
            ),
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    widget.buildInfo.appName,
                    style: buildSettingsStyle,
                  ),
                  Text(
                    'Version: ${widget.buildInfo.version} (${widget.buildInfo.buildNumber})',
                    style: buildSettingsStyle,
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    _buildCredits(),
                    textAlign: TextAlign.center,
                    style: buildSettingsStyle,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid ? _buildAndroid() : _buildiOS();
  }
}
