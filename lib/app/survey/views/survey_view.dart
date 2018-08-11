import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../auth/models.dart';
import '../../../theme.dart';

const double kResponseHeight = 80.0;
const double kResponsePadding = 10.0;
const double kResponseFontSize = 18.0;

class SurveyView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Question currentQuestion;
  final int questionIndex;
  final int numQuestions;
  final Function(int) onNext;
  final Function onExit;
  final bool loading;
  final bool loadingMoreQuestions;
  final bool selfAssessment;

  SurveyView({
    Key key,
    @required this.scaffoldKey,
    @required this.currentQuestion,
    @required this.numQuestions,
    @required this.questionIndex,
    @required this.onNext,
    @required this.onExit,
    @required this.loading,
    @required this.loadingMoreQuestions,
    @required this.selfAssessment,
  }) : super(key: key);

  @override
  createState() => _SurveyViewState();
}

class _SurveyViewState extends State<SurveyView> {
  final List<String> responses = const [
    'No way, Jose',
    'Meh, not really',
    'Kind of',
    'Mostly true',
    'Totally agree',
  ].reversed.toList();

  List<Widget> _buildButtons() {
    return responses.map((response) {
      int index = 5 - responses.indexOf(response);
      return Expanded(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: CupertinoButton(
            padding: const EdgeInsets.all(0.0),
            pressedOpacity: 0.23,
            onPressed:
                widget.loadingMoreQuestions ? null : () => widget.onNext(index),
            child: Container(
              height: kResponseHeight / 2 + 2 * kResponsePadding,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                vertical: kResponsePadding,
                horizontal: kResponsePadding * 7,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(
                  color: Colors.white,
                ),
              ),
              child: Text(
                response,
                style: Theme.of(context).primaryTextTheme.body1.copyWith(
                      fontSize: 14.0 + MediaQuery.of(context).textScaleFactor,
                    ),
              ),
            ),
          ),
        ),
      );
    }).toList()
      ..add(
        Expanded(
          child: kIsAndroid
              ? Theme(
                  data: ThemeData.dark(),
                  child: FlatButton(
                    child: Text('Skip'),
                    onPressed: widget.loadingMoreQuestions
                        ? null
                        : () => widget.onNext(-1),
                  ),
                )
              : CupertinoButton(
                  child: Text('Skip',
                      style: Theme.of(context).primaryTextTheme.button),
                  onPressed: widget.loadingMoreQuestions
                      ? null
                      : () => widget.onNext(-1),
                ),
        ),
      );
  }

  Widget _buildLoading() {
    return Theme(
      data: ThemeData(
        accentColor: Colors.white,
      ),
      child: Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody(bool loading) {
    if (loading) {
      return _buildLoading();
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: 2.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: widget.loadingMoreQuestions
                    ? _buildLoading()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 10.0),
                        child: Center(
                          child: Text(
                            '${widget.selfAssessment ? widget.currentQuestion.self : widget.currentQuestion.peer}',
                            style: Theme
                                .of(context)
                                .primaryTextTheme
                                .body1
                                .copyWith(fontSize: 17.0),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ),
              Expanded(
                flex: 2,
                // padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _buildButtons(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return !kIsAndroid
            ? CupertinoAlertDialog(
                title: Text(
                    'You are about to exit the survey. Do you wish to continue?'),
                actions: <Widget>[
                  CupertinoButton(
                    child: Text('Yes'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                  CupertinoButton(
                    child: Text('No'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              )
            : AlertDialog(
                title: Text(
                    'You are about to exit the survey. Do you wish to continue?'),
                actions: <Widget>[
                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Text('Yes'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                      FlatButton(
                        child: Text('No'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                ],
              );
      },
    ).then((res) {
      if (res ?? false) {
        widget.onExit();
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool loading = widget.loading || widget.currentQuestion == null;
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          loading ? 'Loading' : 'Play',
          style: Theme
              .of(context)
              .primaryTextTheme
              .title
              .copyWith(fontWeight: FontWeight.bold),
        ),
        leading: CupertinoButton(
          child: Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: loading
                  ? Container()
                  : Text(
                      // Assign minimum value so that questionIndex is never > numQuestions
                      // This will happen because the widget will update after the final
                      // answer is added to the Map and there's no way to stop the update
                      '${min(widget.questionIndex, widget.numQuestions)} / ${widget.numQuestions}',
                      style: Theme.of(context).primaryTextTheme.title,
                    ),
            ),
          ),
        ],
      ),
      body: _buildBody(loading),
    );
  }
}
