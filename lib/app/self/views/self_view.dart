import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../auth/models.dart';
import '../../../theme.dart';
import '../../widgets/distribution_curve.dart';

class SelfView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Map<QuestionSet, bool> selfTestsTaken;
  final Function(QuestionSet) launchTest;
  final List<Score> selfScores;
  final Map<QuestionSet, QuestionSetStatistics> questionSetStatistics;

  SelfView({
    Key key,
    @required this.scaffoldKey,
    @required this.selfTestsTaken,
    @required this.launchTest,
    @required this.selfScores,
    @required this.questionSetStatistics,
  }) : super(key: key);

  @override
  createState() => _SelfViewState();
}

class _SelfViewState extends State<SelfView> {
  Widget _buildAndroid() {
    return Theme(
      data: HumbleMe.appTheme,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            key: widget.scaffoldKey,
            appBar: AppBar(
              backgroundColor: HumbleMe.teal,
              title: Text('Self-Assessments'),
            ),
            body: _buildTestList(context),
          );
        },
      ),
    );
  }

  Widget _buildiOS() {
    return CupertinoPageScaffold(
      key: widget.scaffoldKey,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: HumbleMe.teal,
        actionsForegroundColor: CupertinoColors.white,
        middle: Text(
          'Self-Assessments',
          style: Theme.of(context).primaryTextTheme.title,
        ),
      ),
      child: Material(
        child: _buildTestList(context),
        color: Colors.white,
      ),
    );
  }

  Widget _buildTestList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10.0),
      children: QuestionSet.values.map((questionSet) {
        String text, description, resultsDescription;
        switch (questionSet) {
          case QuestionSet.MACHIV:
            text = 'Machiavellianism';
            description = 'Test your cunning and desire for duplicity';
            resultsDescription =
                'Higher scores mean you have a more machiavellian worldview.';
            break;
          case QuestionSet.NPI:
            text = 'Narcissism';
            description =
                'Test how much you envy your partner for getting to look at you all the time';
            resultsDescription =
                'Higher scores mean you exhibit more narcissistic tendencies.';
            break;
          case QuestionSet.OHBDS:
            text = 'Left-brained / Right-brained';
            description =
                'Test how much you side with your creative or logical persona';
            resultsDescription =
                'Higher scores mean you tend to be more left brain dominant.';
            break;
          case QuestionSet.IPIP:
            text = 'Core';
            description = 'Test the core attributes that make you who you are';
            resultsDescription =
                'Scores are calculated and shown in the \'Scores\' tab on your profile once you\'ve received 5 surveys from peers.';
            break;
        }
        if (widget.selfTestsTaken[questionSet] &&
            (widget.selfScores.first.questionSetWeighted[questionSet] != null ||
                questionSet == QuestionSet.IPIP)) {
          if (questionSet == QuestionSet.IPIP) {
            return ExpansionTile(
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Text(text),
                    SizedBox(width: 8.0),
                    Text(
                      'Complete',
                      style: const TextStyle(
                        fontSize: 10.0,
                        color: Colors.green,
                      ),
                    )
                  ],
                ),
              ),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    resultsDescription,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }
          double mean = widget.questionSetStatistics[questionSet].average;
          double stdDev =
              widget.questionSetStatistics[questionSet].standardDeviation;
          double score =
              widget.selfScores.first.questionSetWeighted[questionSet];
          double scoreStdDev = (score - mean) / stdDev;
          String higherLower = score < mean ? 'lower' : 'higher';
          double percentHigher =
              DistributionCurve.normalcdf(mean, stdDev, score) * 100;
          String percentage = score < mean
              ? (100 - percentHigher).toStringAsFixed(0)
              : percentHigher.toStringAsFixed(0);
          return ExpansionTile(
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: <Widget>[
                  Text(text),
                  SizedBox(width: 8.0),
                  Text(
                    'Complete',
                    style: const TextStyle(
                      fontSize: 10.0,
                      color: Colors.green,
                    ),
                  )
                ],
              ),
            ),
            children: <Widget>[
              DistributionCurve(
                width: 200.0,
                height: 120.0,
                fillColor: HumbleMe.primaryTeal.withOpacity(0.2),
                strokeColor: Colors.black,
                scoreStandardDeviation: scoreStdDev,
              ),
              SizedBox(height: 20.0),
              Text('You scored $higherLower than $percentage% of people!'),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  resultsDescription,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        } else {
          return ExpansionTile(
            title: Text(text),
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RaisedButton(
                  highlightColor: Colors.white.withOpacity(0.5),
                  textColor: Colors.white,
                  onHighlightChanged: (bool pressed) {},
                  child: Text('Take Test'),
                  onPressed: () {
                    widget.launchTest(questionSet);
                  },
                ),
              ),
            ],
            backgroundColor: Colors.transparent,
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid ? _buildAndroid() : _buildiOS();
  }
}
