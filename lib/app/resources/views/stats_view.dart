import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../auth/models/mindset.dart';
import '../../../theme.dart';
import '../../../welcome/intro/containers/top_mindsets.dart';
import '../../widgets/platform_loading_indicator.dart';

const double _avatarSize = 40.0;

class StatsView extends StatefulWidget {
  final List<String> topMindsets;
  final List<Mindset> mindsets;

  StatsView({
    Key key,
    @required this.topMindsets,
    @required this.mindsets,
  }) : super(key: key);

  @override
  _StatsViewState createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  bool get isLoading => widget.mindsets == null;

  Widget _buildStream(BuildContext context) {
    List<Widget> header = [
      Center(
        child: Text(
          'Mindsets Ranked!',
          style: Theme.of(context).textTheme.body1.copyWith(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          'These are the mindsets which users admire most in others',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subhead,
        ),
      ),
    ];

    if (widget.topMindsets == null || widget.topMindsets.isEmpty) {
      header.add(ListTile(
        title: FlatButton(
            color: HumbleMe.blue,
            onPressed: () {
              Navigator
                  .of(context, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return TopMindsets();
              }));
            },
            child: Text(
              'Submit your ratings',
              style: Theme.of(context).primaryTextTheme.button,
            )),
      ));
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      itemExtent: 56.0,
      children: header
        ..addAll(widget.mindsets.map((mindset) => Material(
              color: Colors.transparent,
              child: ListTile(
                trailing: Image.asset(
                  'images/mindsets/${mindset.getName().toLowerCase()}.png',
                  height: _avatarSize * 0.9,
                  width: _avatarSize * 0.9,
                  fit: BoxFit.contain,
                ),
                title: Text(mindset.getName()),
                leading: CircleAvatar(
                  maxRadius: 17.0,
                  backgroundColor: HumbleMe.greenGray.withOpacity(0.5),
                  foregroundColor: Colors.white,
                  child:
                      Text((widget.mindsets.indexOf(mindset) + 1).toString()),
                ),
              ),
            ))),
    );
  }

  Widget _buildLoading() {
    return PlatformLoadingIndicator();
  }

  Widget _buildiOS() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: HumbleMe.teal,
        actionsForegroundColor: CupertinoColors.white,
        middle: Text(
          'Global Stats',
          style: Theme.of(context).primaryTextTheme.title,
        ),
      ),
      child: isLoading
          ? _buildLoading()
          : Material(
              color: Colors.transparent,
              child: _buildStream(context),
            ),
    );
  }

  Widget _buildAndroid() {
    return isLoading ? _buildLoading() : _buildStream(context);
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid ? _buildAndroid() : _buildiOS();
  }
}
