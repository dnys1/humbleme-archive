import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/models.dart';
import '../../../core/actions.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../../survey/containers/survey.dart';
import '../views/self_view.dart';

class SelfContainer extends StatefulWidget {
  SelfContainer();

  createState() => _SelfContainerState();
}

class _SelfContainerState extends State<SelfContainer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _pushed = false;

  void startTest(QuestionSet questionSet,
      Function(GlobalKey<ScaffoldState>) resetScaffold) async {
    // setState(() {
    _pushed = true;
    // });

    // Push to root navigator so that we don't have the tab controller at bottom
    // await so that when route is popped we can reset `_pushed` without disposing of the widget
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (context) {
        return SurveyContainer(
          surveyInfo: SurveyInfo.self(questionSet),
        );
      },
    ));
    resetScaffold(_scaffoldKey);
    _pushed = false;
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      onInit: (Store<AppState> store) =>
          store.dispatch(SetCurrentScaffold(_scaffoldKey)),
      converter: _ViewModel.fromStore,
      rebuildOnChange: !_pushed,
      distinct: true,
      onWillChange: (_ViewModel vm) {
        // If there is not a test that hasn't been taken
        // Return the user to the home screen
        // if (!vm.selfTestsTaken.containsValue(false)) {
        //   if (Navigator.of(context).canPop()) {
        //     Navigator.of(context).pop();
        //   }
        // }
      },
      builder: (BuildContext context, _ViewModel vm) {
        return SelfView(
          scaffoldKey: _scaffoldKey,
          selfTestsTaken: vm.selfTestsTaken,
          launchTest: (questionSet) => startTest(questionSet, vm.resetScaffold),
          selfScores: vm.selfScores,
          questionSetStatistics: vm.questionSetStatistics,
        );
      },
    );
  }
}

class _ViewModel {
  final Map<QuestionSet, bool> selfTestsTaken;
  final Function(GlobalKey<ScaffoldState>) resetScaffold;
  final List<Score> selfScores;
  final Map<QuestionSet, QuestionSetStatistics> questionSetStatistics;

  _ViewModel({
    @required this.selfTestsTaken,
    @required this.resetScaffold,
    @required this.selfScores,
    @required this.questionSetStatistics,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      selfTestsTaken: getSelfAssessmentsTaken(store.state.auth),
      resetScaffold: (GlobalKey<ScaffoldState> scaffoldKey) =>
          store.dispatch(SetCurrentScaffold(scaffoldKey)),
      selfScores: getSelfScores(store.state.auth),
      questionSetStatistics: getQuestionSetStatistics(store.state),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          selfTestsTaken == other.selfTestsTaken &&
          selfScores == other.selfScores &&
          questionSetStatistics == other.questionSetStatistics;

  @override
  int get hashCode =>
      hashValues(selfTestsTaken, selfScores, questionSetStatistics);
}
