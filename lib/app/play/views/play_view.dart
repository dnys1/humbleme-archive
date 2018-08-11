import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../auth/models.dart';
import '../../../routes.dart';
import '../../../theme.dart';
import '../../common.dart';
import '../../search/containers/search.dart';
import '../../survey/containers/survey.dart';
import '../../survey/views/survey_info_dialog.dart';
import '../../widgets/platform_loading_indicator.dart';
import '../../widgets/profile_circle_avatar.dart';

class PlayView extends StatefulWidget {
  final Function startSurvey;
  final List<PublicUser> friends;
  final List<FriendRequest> friendRequestsReceived;
  final List<FriendRequest> friendRequestsSent;
  final List<Survey> surveysGiven;
  final List<Survey> surveysReceived;
  final Map<QuestionSet, bool> selfAssessmentsTaken;

  PlayView({
    Key key,
    @required this.startSurvey,
    @required this.friends,
    @required this.friendRequestsReceived,
    @required this.friendRequestsSent,
    @required this.surveysGiven,
    @required this.surveysReceived,
    @required this.selfAssessmentsTaken,
  });

  @override
  createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {
  bool get someSelfAssessmentsNotTaken =>
      widget.selfAssessmentsTaken.containsValue(false);
  bool get userHasNoFriends => widget.friends.length == 0;
  bool get isLoading =>
      widget.friends == null ||
      widget.friendRequestsSent == null ||
      widget.friendRequestsReceived == null ||
      widget.surveysGiven == null ||
      widget.surveysReceived == null;

  List<String> _surveysLoading = [];

  @override
  void didUpdateWidget(PlayView oldWidget) {
    super.didUpdateWidget(oldWidget);

    List<Survey> surveysCompleted = oldWidget.surveysGiven
        .toSet()
        .difference(widget.surveysGiven.toSet())
        .toList();
    if (surveysCompleted.isNotEmpty) {
      setState(() {
        surveysCompleted.forEach((s) {
          _surveysLoading.remove(s.toUser);
        });
      });
    }
  }

  Widget _buildSelfAssessmentsAlert(BuildContext context) {
    return Material(
      color: Colors.grey[50],
      child: Center(
        child: ListTile(
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.info, color: Colors.green),
                ),
                Text(
                  someSelfAssessmentsNotTaken
                      ? 'Take the self-assessments!'
                      : 'See your self-assessment scores!',
                  style: Theme
                      .of(context)
                      .textTheme
                      .body1
                      .copyWith(color: Colors.green, fontSize: 16.0),
                ),
              ],
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.green),
          onTap: () => Navigator.of(context).pushNamed(Routes.selfAssessments),
        ),
      ),
    );
  }

  Widget _buildNoFriendsPage(BuildContext context) {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildSelfAssessmentsAlert(context),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(
                  kIsAndroid ? Icons.search : CupertinoIcons.search,
                  color: Colors.grey[800],
                  size: 28.0,
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 45.0, vertical: 25.0),
                  child: new Text(
                    "There's nothing here yet! Add some friends to start surveying.",
                    textAlign: TextAlign.center,
                  ),
                ),
                kIsAndroid
                    ? new RaisedButton(
                        child: new Text('Add Friends',
                            style: Theme
                                .of(context)
                                .textTheme
                                .button
                                .copyWith(color: Colors.white)),
                        onPressed: () {
                          Navigator.of(context).push(
                                Routes.routeBuilderFromWidget(Routes.search,
                                    (BuildContext context) {
                                  return new SearchContainer();
                                }, transitionType: TransitionType.nativeModal),
                              );
                        },
                      )
                    : new RaisedButton(
                        color: HumbleMe.blue,
                        highlightColor: Colors.white.withOpacity(0.7),
                        shape: new RoundedRectangleBorder(
                          side: new BorderSide(
                            color: Colors.white,
                            width: 0.0,
                          ),
                          borderRadius: new BorderRadius.circular(24.0),
                        ),
                        child: new Text('Add Friends',
                            style: Theme.of(context).textTheme.button),
                        onPressed: () => Navigator.of(context).push(
                              Routes.routeBuilderFromWidget(
                                  Routes.search,
                                  (BuildContext context) =>
                                      new SearchContainer()),
                            ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(PublicUser profile) {
    int index = widget.friends.indexOf(profile);
    int surveyIndex =
        widget.surveysGiven.indexWhere((survey) => survey.toUser == profile.id);
    bool completed = false;
    if (surveyIndex != -1 && widget.surveysGiven[surveyIndex].completed) {
      completed = true;
    }
    bool surveyLoading = _surveysLoading.contains(profile.id);
    if (!completed) {
      if (surveyLoading) {
        return new FlatButton(
          padding: const EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
            side: new BorderSide(width: 1.0, color: Colors.green),
            borderRadius: new BorderRadius.circular(6.0),
          ),
          highlightColor: Colors.green.withOpacity(0.8),
          child: CupertinoActivityIndicator(),
          onPressed: null,
        );
      } else {
        return new FlatButton(
          padding: const EdgeInsets.all(0.0),
          shape: new RoundedRectangleBorder(
            side: new BorderSide(width: 1.0, color: Colors.green),
            borderRadius: new BorderRadius.circular(6.0),
          ),
          highlightColor: Colors.green.withOpacity(0.8),
          child: new Text('Start', style: new TextStyle(color: Colors.green)),
          onPressed: () async {
            SurveyInfo surveyInfo = await showDialog<SurveyInfo>(
                context: context,
                builder: (BuildContext context) {
                  return SurveyInfoDialog(userAge: profile.age);
                });
            if (surveyInfo != null) {
              await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return SurveyContainer(
                      surveyInfo: surveyInfo,
                      forUser: profile.id,
                    );
                  },
                ),
              );
              setState(() {
                _surveysLoading.add(profile.id);
              });
            }
          },
        );
      }
    } else {
      return new FlatButton(
        padding: const EdgeInsets.all(0.0),
        shape: new RoundedRectangleBorder(
          side: new BorderSide(width: 1.0, color: Colors.green),
          borderRadius: new BorderRadius.circular(6.0),
        ),
        disabledColor: Colors.green,
        child: new Text('Complete', style: new TextStyle(color: Colors.white)),
        onPressed: null,
      );
    }
  }

  Widget _buildFriendsList(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildSelfAssessmentsAlert(context),
      ]..addAll(widget.friends.map((profile) {
          return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Material(
              color: Colors.white,
              child: new ListTile(
                leading: ProfileCircleAvatar(
                  photoUrl: profile.photoUrl,
                ),
                title: new Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.body1.copyWith(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                ),
                trailing: _buildButton(profile),
              ),
            ),
          );
        })),
    );
  }

  Widget _buildLoading() {
    return PlatformLoadingIndicator();
  }

  Widget _buildiOS(BuildContext context) {
    return new CupertinoPageScaffold(
      navigationBar: new CupertinoNavigationBar(
        backgroundColor: HumbleMe.teal,
        middle: new Text(
          'Play',
          style: Theme.of(context).primaryTextTheme.title,
        ),
        trailing: buildiOSNavigationButton(
          iconData: IOSIcons.add_profile_light,
          onPressed: () {
            Navigator.of(context).push(
                  Routes.routeBuilderFromWidget(Routes.search,
                      (BuildContext context) {
                    return new SearchContainer();
                  }),
                );
          },
        ),
      ),
      child: isLoading
          ? _buildLoading()
          : userHasNoFriends
              ? _buildNoFriendsPage(context)
              : _buildFriendsList(context),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return isLoading
        ? _buildLoading()
        : userHasNoFriends
            ? _buildNoFriendsPage(context)
            : _buildFriendsList(context);
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid ? _buildAndroid(context) : _buildiOS(context);
  }
}
