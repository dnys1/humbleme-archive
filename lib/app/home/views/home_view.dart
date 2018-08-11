import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes.dart';
import '../../../theme.dart';
import '../../../utils/invite_link.dart';
import '../../common.dart';
import '../../widgets/platform_loading_indicator.dart';

const double _kStarHeight = 40.0;
const double _kStarPadding = 4.0;

class HomeView extends StatefulWidget {
  final Function(int) onSubmitRating;
  final Function(int) buttonClicked;
  final Function enablePushNotifications;
  final int rating;
  final bool selfAssessmentClicked;
  final bool selfAssessmentsCompleted;
  final bool addFriendsClicked;
  final bool notificationsPermissionRequested;
  final bool notificationsPermissionGranted;
  final bool isLoading;

  HomeView({
    Key key,
    @required this.onSubmitRating,
    @required this.buttonClicked,
    @required this.rating,
    @required this.enablePushNotifications,
    @required this.selfAssessmentClicked,
    @required this.selfAssessmentsCompleted,
    @required this.addFriendsClicked,
    @required this.notificationsPermissionRequested,
    @required this.notificationsPermissionGranted,
    @required this.isLoading,
  }) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Widget _buildRating() {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'How do you like HumbleMe?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.body1.copyWith(
                  color: Colors.grey,
                  fontSize: 20.0,
                ),
          ),
          SizedBox(
            height: _kStarHeight + 2 * _kStarPadding,
            width: _kStarHeight * 5,
            child: ListView.builder(
              itemExtent: _kStarHeight,
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return CupertinoButton(
                  onPressed: widget.rating == null || widget.rating == 0
                      ? () => widget.onSubmitRating(index + 1)
                      : null,
                  padding: EdgeInsets.all(0.0),
                  child: Image.asset(
                    widget.rating == null || index + 1 > widget.rating
                        ? 'images/star_empty.png'
                        : 'images/star_full.png',
                    width: _kStarHeight,
                    height: _kStarHeight,
                  ),
                );
              },
              scrollDirection: Axis.horizontal,
            ),
          ),
          widget.rating != null && widget.rating != 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Thanks for the feedback!',
                    style: Theme.of(context).textTheme.body1.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                )
              : Container(
                  width: 0.0,
                  height: 0.0,
                ),
          SizedBox(height: 50.0),
          Theme(
            data: ThemeData.dark(),
            child: FlatButton(
              color: HumbleMe.blueGray,
              onPressed: () {
                String inviteLink = Invites.getInvite();
                Share.share(inviteLink);
              },
              child: Text('Invite Friends'),
            ),
          ),
          SizedBox(height: 15.0),
          Theme(
            data: ThemeData.dark(),
            child: FlatButton(
              color: HumbleMe.purpleGray,
              onPressed: () async {
                if (await canLaunch('mailto:humbleme@protonmail.com')) {
                  await launch('mailto:humbleme@protonmail.com');
                }
              },
              child: Text('Send Us Feedback'),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildiOS(BuildContext context) {
    bool allComplete = widget.selfAssessmentsCompleted &&
        widget.addFriendsClicked &&
        (widget.notificationsPermissionRequested ||
            widget.notificationsPermissionGranted);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        actionsForegroundColor: CupertinoColors.white,
        backgroundColor: HumbleMe.primaryTeal,
        leading: buildiOSNavigationButton(
          left: true,
          iconData: IOSIcons.settings_dark,
          onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
        ),
        middle: Text(
          'Home',
          style: Theme.of(context).primaryTextTheme.title,
        ),
        trailing: buildiOSNavigationButton(
          left: false,
          iconData: IOSIcons.search_dark,
          onPressed: () => Navigator.of(context).pushNamed(Routes.search),
        ),
      ),
      child: widget.isLoading
          ? _buildLoading()
          : allComplete ? _buildRating() : itemsList(),
    );
  }

  Widget itemsList() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildItem(
              '1',
              'Take the self-assessments',
              'Self-Assessments',
              () {
                Navigator.of(context).pushNamed(Routes.selfAssessments);
                if (!widget.selfAssessmentClicked) {
                  widget.buttonClicked(1);
                }
              },
              widget.selfAssessmentsCompleted,
            ),
            _buildItem(
              '2',
              'Add some friends to start building your score',
              'Add Friends',
              () {
                Navigator.of(context).pushNamed(Routes.search);
                if (!widget.addFriendsClicked) {
                  widget.buttonClicked(2);
                }
              },
              widget.addFriendsClicked,
            ),
            _buildItem(
              '3',
              'Enable notifications to get alerted when your score updates',
              'Enable Notifications',
              () {
                if (!widget.notificationsPermissionRequested) {
                  widget.buttonClicked(3);
                }
                widget.enablePushNotifications();
              },
              widget.notificationsPermissionRequested ||
                  widget.notificationsPermissionGranted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return PlatformLoadingIndicator();
  }

  Widget _buildItem(
    String number,
    String label,
    String buttonLabel,
    Function action,
    bool disabled,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                number,
                style: const TextStyle(
                  fontSize: 40.0,
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    label,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 5.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: RaisedButton(
                    color: HumbleMe.blue,
                    disabledColor: HumbleMe.purpleGray.withOpacity(0.4),
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          const BorderRadius.all(const Radius.circular(5.0)),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          buttonLabel,
                          style: Theme.of(context).textTheme.button,
                        ),
                        disabled
                            ? Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14.0,
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    onPressed: disabled ? null : action,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroid() {
    bool allComplete = widget.selfAssessmentsCompleted &&
        widget.addFriendsClicked &&
        (widget.notificationsPermissionRequested ||
            widget.notificationsPermissionGranted);
    return widget.isLoading
        ? _buildLoading()
        : allComplete ? _buildRating() : itemsList();
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid ? _buildAndroid() : _buildiOS(context);
  }
}
