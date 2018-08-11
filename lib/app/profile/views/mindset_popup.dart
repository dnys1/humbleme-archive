import 'package:flutter/material.dart';

import '../../../auth/models.dart';
import 'mindset_score_bar.dart';

class MindsetPopup extends StatefulWidget {
  final Mindset mindset;
  final bool isPublicProfile;
  final List<Score> selfScores;
  final List<Score> peerScores;

  MindsetPopup({
    Key key,
    @required this.mindset,
    @required this.isPublicProfile,
    @required this.selfScores,
    @required this.peerScores,
  })  : assert(mindset != null),
        assert(isPublicProfile != null),
        assert(selfScores != null),
        assert(peerScores != null),
        super(key: key);

  @override
  createState() => _MindsetPopupState();
}

class _MindsetPopupState extends State<MindsetPopup> {
  String get assetName => widget.mindset.getName().toLowerCase();
  String get name => widget.mindset.getName();
  Mindsets get mindset => widget.mindset.name;
  double get latestPeerScore =>
      widget.peerScores.first.mindsetWeighted[mindset] ?? 0.0;
  double get latestSelfScore =>
      widget.selfScores.first.mindsetWeighted[mindset] ?? 0.0;

  bool get isPublicMindset =>
      widget.peerScores.first.privacySettings[mindset] ?? false;

  TextStyle get captionStyle => Theme.of(context).textTheme.caption;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: widget.isPublicProfile
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(isPublicMindset ? 'Public' : 'Private'),
                SizedBox(width: 5.0),
                Icon(isPublicMindset ? Icons.lock_open : Icons.lock),
              ],
            ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Image.asset('images/mindsets/$assetName.png',
              width: 90.0, height: 90.0),
        ),
        Center(child: Text(name)),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 10.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: <Widget>[
                  Text('Peer:', style: captionStyle),
                  SizedBox(width: 8.0),
                  MindsetScorebar(
                    self: false,
                    width: 200.0,
                    score: latestPeerScore,
                  )
                ],
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: <Widget>[
                  Text('Self:', style: captionStyle),
                  SizedBox(width: 8.0),
                  MindsetScorebar(
                    self: true,
                    width: 200.0,
                    score: latestSelfScore,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
