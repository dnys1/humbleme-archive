import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models/onboarding.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../views/home_view.dart';

class HomeContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: _ViewModel.fromStore,
      ignoreChange: (AppState state) => !loggedInSelector(state.auth),
      builder: (BuildContext context, _ViewModel vm) {
        return HomeView(
          buttonClicked: vm.buttonClicked,
          enablePushNotifications: vm.enableNotifications,
          onSubmitRating: vm.onSubmitRating,
          rating: vm.rating,
          selfAssessmentClicked: vm.selfAssessmentClicked,
          selfAssessmentsCompleted: vm.selfAssessmentsCompleted,
          addFriendsClicked: vm.addFriendsClicked,
          notificationsPermissionRequested: vm.notificationsPermissionRequested,
          notificationsPermissionGranted: vm.notificationsPermissionGranted,
          isLoading: vm.isLoading,
        );
      },
    );
  }
}

class _ViewModel {
  final Function onSubmitRating;
  final Function enableNotifications;
  final Function(int) buttonClicked;
  final bool selfAssessmentClicked;
  final bool selfAssessmentsCompleted;
  final bool addFriendsClicked;
  final bool notificationsPermissionRequested;
  final bool notificationsPermissionGranted;
  final int rating;
  final bool isLoading;

  _ViewModel({
    @required this.buttonClicked,
    @required this.onSubmitRating,
    @required this.rating,
    @required this.enableNotifications,
    @required this.selfAssessmentClicked,
    @required this.selfAssessmentsCompleted,
    @required this.notificationsPermissionRequested,
    @required this.notificationsPermissionGranted,
    @required this.addFriendsClicked,
    @required this.isLoading,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    Onboarding onboarding = getUserOnboarding(store.state.auth);

    return _ViewModel(
      onSubmitRating: (rating) => store.dispatch(SetAppRating(rating)),
      rating: getAppRating(store.state.auth),
      enableNotifications: () => store.dispatch(EnablePushNotifications()),
      selfAssessmentClicked: hasClickedSelfAssessments(store.state.auth),
      selfAssessmentsCompleted: hasTakenAllSelfAssessments(store.state.auth),
      addFriendsClicked: hasAddFriendsClicked(store.state.auth),
      notificationsPermissionRequested:
          hasNotificationPermissionsRequested(store.state.auth),
      buttonClicked: (int index) {
        Onboarding newOnboarding;
        switch (index) {
          case 1:
            newOnboarding = onboarding.copyWith(selfAssessmentsClicked: true);
            break;
          case 2:
            newOnboarding = onboarding.copyWith(addFriendsClicked: true);
            break;
          case 3:
            newOnboarding =
                onboarding.copyWith(notificationsPermissionRequested: true);
            break;
          default:
            return;
        }

        store.dispatch(UpdateOnboarding(newOnboarding));
      },
      notificationsPermissionGranted:
          getNotificationsPermissionGranted(store.state),
      isLoading:
          isLoadingSelector(store.state) && isLoadingUserSelector(store.state),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          rating == other.rating &&
          selfAssessmentClicked == other.selfAssessmentClicked &&
          addFriendsClicked == other.addFriendsClicked &&
          notificationsPermissionRequested ==
              other.notificationsPermissionRequested;

  @override
  int get hashCode =>
      rating.hashCode ^
      selfAssessmentClicked.hashCode ^
      addFriendsClicked.hashCode ^
      notificationsPermissionRequested.hashCode;
}
