import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models.dart';
import '../../../core/actions.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../../../theme.dart';
import '../views/survey_view.dart';

const int kDefaultQuizLength = 20;

class SurveyContainer extends StatefulWidget {
  final SurveyInfo surveyInfo;
  final String forUser;

  SurveyContainer({
    @required this.surveyInfo,
    this.forUser,
  });

  @override
  createState() => _SurveyContainerState();
}

class _SurveyContainerState extends State<SurveyContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<Question, int> answers = Map<Question, int>();
  Question currentQuestion;
  bool _testCompleted = false;
  bool _pushed = false;
  bool _loadingMoreQuestions = false;

  bool get selfAssessment => widget.forUser == null;
  TestType get testType => widget.surveyInfo.testType;
  QuestionSet get questionSet => widget.surveyInfo.questionSet;

  Question fixIPIPQuestion(Question ipipQ) {
    String self = ipipQ.self;
    if (self != null) {
      self = 'I ' + self.substring(0, 1).toLowerCase() + self.substring(1);
    }
    String peer = ipipQ.peer;
    if (peer != null) {
      peer = 'They ' + peer.substring(0, 1).toLowerCase() + peer.substring(1);
    }

    return ipipQ.copyWith(
      self: self,
      peer: peer,
    );
  }

  Future<bool> _showCompletedDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return !kIsAndroid
            ? CupertinoAlertDialog(
                title: Text(
                    'There are more questions you can answer. Do you want to keep going?'),
                actions: <Widget>[
                  CupertinoButton(
                    child: Text('Yes'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  CupertinoButton(
                    child: Text('No'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              )
            : AlertDialog(
                title: Text(
                    'There are more questions you can answer. Do you want to keep going?'),
                actions: <Widget>[
                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Text('Yes'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      FlatButton(
                        child: Text('No'),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                ],
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: HumbleMe.welcomeTheme,
      isMaterialAppTheme: true,
      child: StoreConnector<AppState, _ViewModel>(
        converter: _ViewModel.fromStore,
        onInit: (Store<AppState> store) {
          store.dispatch(
            GetAssessment(
              surveyInfo: widget.surveyInfo,
              length: kDefaultQuizLength,
            ),
          );
          store.dispatch(SetCurrentScaffold(_scaffoldKey));
        },
        onWillChange: (_ViewModel vm) {
          if (currentQuestion == null) {
            var firstQuestion = vm.questions[0];
            // Need to fix questions for IPIP since they're stored
            // as loose statements
            if (questionSet == QuestionSet.IPIP) {
              firstQuestion = fixIPIPQuestion(firstQuestion);
            }
            currentQuestion = firstQuestion;
          }

          // There are questions
          if (vm.questions.length > kDefaultQuizLength &&
              answers.length < vm.questions.length) {
            var nextQuestion = vm.questions?.firstWhere(
              (question) =>
                  answers.keys.singleWhere(
                    (q) => q.id == question.id,
                    orElse: () => null,
                  ) ==
                  null,
            );
            // Need to fix questions for IPIP since they're stored
            // as loose statements
            if (questionSet == QuestionSet.IPIP) {
              nextQuestion = fixIPIPQuestion(nextQuestion);
            }
            setState(() {
              _loadingMoreQuestions = false;
              currentQuestion = nextQuestion;
            });
          }
        },
        distinct: true,
        rebuildOnChange: !_testCompleted && !_pushed,
        builder: (BuildContext context, _ViewModel vm) {
          return SurveyView(
            scaffoldKey: _scaffoldKey,
            loading: vm.questions == null,
            loadingMoreQuestions: _loadingMoreQuestions,
            selfAssessment: selfAssessment,
            currentQuestion: currentQuestion,
            questionIndex: answers.length + 1,
            numQuestions: vm.questions?.length,
            onNext: (int res) async {
              answers.putIfAbsent(currentQuestion, () => res);
              if (answers.length == vm.questions?.length) {
                bool shouldPop;
                if (!vm.lastSetOfQuestions) {
                  shouldPop = await _showCompletedDialog(context);
                  if (shouldPop == null) {
                    return;
                  }
                } else {
                  // No more questions to answer
                  shouldPop = true;
                }

                if (shouldPop) {
                  vm.submitAnswers(
                    widget.surveyInfo,
                    answers,
                    widget.forUser,
                    selfAssessment,
                  );
                  setState(() {
                    _testCompleted = true;
                    _pushed = true;
                  });
                  Navigator.of(context, rootNavigator: true).pop();
                } else {
                  setState(() {
                    _loadingMoreQuestions = true;
                  });
                  vm.getMoreQuestions();
                }
              } else {
                var nextQuestion = vm.questions?.firstWhere(
                  (question) =>
                      answers.keys.singleWhere(
                        (q) => q.id == question.id,
                        orElse: () => null,
                      ) ==
                      null,
                );
                // Need to fix questions for IPIP since they're stored
                // as loose statements
                if (questionSet == QuestionSet.IPIP) {
                  nextQuestion = fixIPIPQuestion(nextQuestion);
                }
                setState(() {
                  currentQuestion = nextQuestion;
                });
              }
            },
            onExit: () {
              _pushed = true;
              Navigator.of(context, rootNavigator: true).pop();
            },
          );
        },
      ),
    );
  }
}

class _ViewModel {
  final List<Question> questions;
  final bool lastSetOfQuestions;
  final Function(SurveyInfo, Map<Question, int>, String, bool) submitAnswers;
  final Function getMoreQuestions;
  final Function clearTest;

  _ViewModel({
    @required this.questions,
    @required this.submitAnswers,
    @required this.clearTest,
    @required this.lastSetOfQuestions,
    @required this.getMoreQuestions,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    Test test = getCurrentTest(store.state.auth);
    List<Question> questions;
    if (test?.questions != null) {
      questions = [];
      questions.addAll(test.questions);
      questions.shuffle();
    }
    return _ViewModel(
      questions: questions,
      submitAnswers: (SurveyInfo surveyInfo, Map<Question, int> answers,
          String forUser, bool isSelfAssessment) {
        store.dispatch(
          SubmitAssessment(
            surveyInfo: surveyInfo,
            answers: answers,
            forUser: forUser,
            isSelfAssessment: isSelfAssessment,
          ),
        );
      },
      clearTest: () => store.dispatch(ClearAssessment()),
      lastSetOfQuestions: test?.lastSetOfQuestions ?? false,
      getMoreQuestions: () => store
          .dispatch(SetAssessment(test.moveToNextBatch(kDefaultQuizLength))),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          questions == other.questions &&
          lastSetOfQuestions == other.lastSetOfQuestions;

  @override
  int get hashCode => hashValues(questions, lastSetOfQuestions);
}
