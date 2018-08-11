import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../app/widgets/platform_loading_indicator.dart';
import '../../../auth/models.dart';
import '../../../theme.dart';

const double _avatarSize = 40.0;

class ProfileEditView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(String) updateBio;
  final Function(Map<Mindsets, bool>) updateMindsetScorePrivacy;
  final Function(bool) updateProfileVisibility;
  final bool profileVisibility;
  final List<Mindset> mindsets;
  final Score scores;
  final User user;

  ProfileEditView({
    Key key,
    @required this.updateBio,
    @required this.scaffoldKey,
    @required this.updateMindsetScorePrivacy,
    @required this.profileVisibility,
    @required this.updateProfileVisibility,
    @required this.scores,
    @required this.mindsets,
    @required this.user,
  })  : assert(scores != null),
        assert(scores.privacySettings != null),
        super(key: key);

  @override
  createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<Mindsets, bool> _updatedPrivacySettings;
  String _bio;

  bool get isPublicProfile => !widget.profileVisibility;
  bool get userLoading => user == null;
  User get user => widget.user;

  @override
  initState() {
    super.initState();
    // Make a copy so we can compare against the original
    _updatedPrivacySettings = {}..addAll(widget.scores.privacySettings);
  }

  bool get privacySettingsChanged {
    bool _privacySettingsChanged = false;
    _updatedPrivacySettings.entries.forEach((entry) {
      if (widget.scores.privacySettings[entry.key] != entry.value) {
        _privacySettingsChanged = true;
      }
    });
    return _privacySettingsChanged;
  }

  _submitForm() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      bool updated = false;
      if (_bio != null) {
        widget.updateBio(_bio);
        updated = true;
      }
      if (privacySettingsChanged) {
        widget.updateMindsetScorePrivacy(_updatedPrivacySettings);
        updated = true;
      }
      // Return to profile screen whether anything was
      // updated or not
      Navigator.of(context).pop(updated);
    }
  }

  _setProfileVisibility() async {
    String makePrivate =
        'This will make your profile private. You will still appear in search results, but only your friends may view your profile. Are you sure you want to enable this?';
    String makePublic =
        'This will make your profile public. Your profile will be visible to anyone. Are you sure you want to continue?';
    bool shouldUpdateVisibility = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return kIsAndroid
              ? AlertDialog(
                  title: Text('Are you sure?'),
                  content: Text(isPublicProfile ? makePrivate : makePublic),
                  actions: <Widget>[
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                            child: Text('Yes'),
                            onPressed: () => Navigator.of(context).pop(true)),
                        FlatButton(
                            child: Text('No'),
                            onPressed: () => Navigator.of(context).pop(false)),
                      ],
                    )
                  ],
                )
              : CupertinoAlertDialog(
                  title: Text('Are you sure?'),
                  content: Text(
                      'This will make your profile private. You will still appear in search results, but only your friends may view your profile. Are you sure you want to enable this?'),
                  actions: <Widget>[
                    CupertinoButton(
                        child: Text('Yes'),
                        onPressed: () => Navigator.of(context).pop(true)),
                    CupertinoButton(
                        child: Text('No'),
                        onPressed: () => Navigator.of(context).pop(false)),
                  ],
                );
        });
    if (shouldUpdateVisibility ?? false) {
      widget.updateProfileVisibility(!widget.profileVisibility);
    }
  }

  _updatePrivacySetting(Mindsets mindset, bool updatedVal) {
    setState(() {
      _updatedPrivacySettings[mindset] = updatedVal;
    });
  }

  List<Mindset> get getUserMindsets => widget.mindsets;

  _buildLoading() {
    return PlatformLoadingIndicator(color: HumbleMe.teal);
  }

  /// We pass in context so that Theme.of(context) returns
  /// the correct context for Android, because we need to wrap with Theme
  _buildForm(BuildContext context) {
    return Material(
      child: Form(
        key: _formKey,
        onWillPop: () async {
          if (privacySettingsChanged || _bio != null) {
            return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return kIsAndroid
                        ? AlertDialog(
                            title: Text(
                                'Are you sure you want to discard changes?'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('No'),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              FlatButton(
                                child: Text('Yes'),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          )
                        : CupertinoAlertDialog(
                            title: Text(
                                'Are you sure you want to discard changes?'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text('No'),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              CupertinoDialogAction(
                                child: Text('Yes'),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                  },
                ) ??
                false;
          }
          return true;
        },
        child: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.all(15.0),
              children: <Widget>[
                TextFormField(
                  maxLines: 3,
                  initialValue: user.bio,
                  onSaved: (String bio) => _bio = (bio != '') ? bio : null,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Bio',
                    hintText: 'Tell us about yourself.',
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                FlatButton(
                  onPressed: _setProfileVisibility,
                  color: HumbleMe.blue,
                  child: Text(
                    'Make Profile ${isPublicProfile ? 'Private' : 'Public'}',
                    style: Theme.of(context).primaryTextTheme.button,
                  ),
                ),
                Divider(),
                Container(
                  // decoration: BoxDecoration(
                  //     border: Border(
                  //         bottom: BorderSide(color: Colors.grey, width: 1.0))),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      dense: true,
                      // title: Padding(
                      //   padding: const EdgeInsets.all(0.0),
                      //   child: Text('Privacy',
                      //       style: Theme
                      //           .of(context)
                      //           .textTheme
                      //           .body1
                      //           .copyWith(fontSize: 19.0)),
                      // ),
                      trailing: Text(
                        'Show\non profile',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ),
                ),
              ]
                ..addAll(getUserMindsets.map((mindset) {
                  var mindsetName = mindset.name;
                  var assetName = mindset.getName().toLowerCase();
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                        leading: Image.asset(
                          'images/mindsets/$assetName.png',
                          height: _avatarSize * 0.9,
                          width: _avatarSize * 0.9,
                          fit: BoxFit.contain,
                        ),
                        title: Text('${mindset.getName()}',
                            style: Theme.of(context).textTheme.subhead),
                        trailing: kIsAndroid
                            ? Switch(
                                activeColor: HumbleMe.teal[700],
                                activeTrackColor: HumbleMe.teal[200],
                                inactiveThumbColor: Colors.grey[50],
                                value: _updatedPrivacySettings[mindsetName],
                                onChanged: (bool updatedVal) =>
                                    _updatePrivacySetting(
                                        mindsetName, updatedVal),
                              )
                            : CupertinoSwitch(
                                activeColor: HumbleMe.teal[700],
                                value: _updatedPrivacySettings[mindsetName],
                                onChanged: (bool updatedVal) =>
                                    _updatePrivacySetting(
                                        mindsetName, updatedVal),
                              )),
                  );
                }).toList())
                ..add(SizedBox(
                  height: 60.0,
                )),
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                // color: Colors.grey[50],
                padding: const EdgeInsets.all(20.0),
                child: RaisedButton(
                  onPressed: _submitForm,
                  child: Text('Submit',
                      style: Theme.of(context).primaryTextTheme.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildAndroid() {
    return Theme(
      data: HumbleMe.appTheme,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: HumbleMe.teal,
              title: Text('Edit Profile'),
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: userLoading ? _buildLoading() : _buildForm(context),
            ),
          );
        },
      ),
    );
  }

  _buildiOS() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: HumbleMe.teal,
        actionsForegroundColor: CupertinoColors.white,
        middle: Text(
          'Edit Profile',
          style: Theme.of(context).primaryTextTheme.title,
        ),
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: userLoading ? _buildLoading() : _buildForm(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid ? _buildAndroid() : _buildiOS();
  }
}
