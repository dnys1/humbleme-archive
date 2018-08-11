import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../auth/actions.dart';
import '../../../auth/models.dart';
import '../../../core/models.dart';
import '../../../selectors.dart';
import '../views/notifications_view.dart';

class NotificationsContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector(
      converter: _ViewModel.fromStore,
      distinct: true,
      builder: (BuildContext context, _ViewModel vm) {
        return NotificationsView(
          notifications: vm.notifications,
          updateNotificationRead: vm.updateNotificationRead,
          deleteNotification: vm.deleteNotification,
          isLoading: vm.isLoading,
        );
      },
    );
  }
}

class _ViewModel {
  final List<Notification> notifications;
  final Function(Notification) updateNotificationRead;
  final Function(Notification) deleteNotification;
  final bool isLoading;

  _ViewModel({
    @required this.notifications,
    @required this.updateNotificationRead,
    @required this.deleteNotification,
    @required this.isLoading,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    List<Notification> notifications = getUserNotifications(store.state.auth);
    notifications.sort((a, b) {
      return -a.dateTime.compareTo(b.dateTime);
    });
    return _ViewModel(
      notifications: notifications,
      updateNotificationRead: (Notification notification) {
        store.dispatch(UpdateNotificationRead(notification));
      },
      deleteNotification: (Notification notification) =>
          store.dispatch(DeleteNotification(notification)),
      isLoading: getUserNotifications(store.state.auth) == null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          notifications == other.notifications;

  @override
  int get hashCode => notifications.hashCode;
}
