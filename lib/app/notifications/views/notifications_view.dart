import 'package:flutter/cupertino.dart' hide Notification;
import 'package:flutter/material.dart' hide Notification;

import '../../../auth/models.dart';
import '../../../routes.dart';
import '../../../theme.dart';
import '../../models.dart';
import '../../profile/containers/profile.dart';
import '../../widgets/platform_loading_indicator.dart';
import '../../widgets/profile_circle_avatar.dart';

const double _notificationBubbleSize = 16.0;

class NotificationsView extends StatefulWidget {
  final List<Notification> notifications;
  final Function(Notification) updateNotificationRead;
  final Function(Notification) deleteNotification;
  final bool isLoading;

  NotificationsView({
    Key key,
    @required this.notifications,
    @required this.updateNotificationRead,
    @required this.deleteNotification,
    @required this.isLoading,
  }) : super(key: key);

  @override
  createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  static final RouteObserver routeObserver =
      Routes.appObservers[AppTab.notifications];

  List<String> _deletedNotifications = [];

  List<Notification> get notifications => widget.notifications
      .where((not) => !_deletedNotifications.contains(not.id))
      .toList();

  String _buildDateTimeString(DateTime dateTime) {
    var difference = dateTime.toLocal().difference(DateTime.now());
    if (difference.inDays.abs() < 1) {
      if (difference.inHours.abs() < 1) {
        var minutesAgo = difference.inMinutes.abs();
        if (minutesAgo < 1) {
          return 'Just now';
        }
        return '$minutesAgo minute${minutesAgo == 1 ? '' : 's'} ago';
      } else {
        int hoursAgo = difference.inHours.abs();
        return '$hoursAgo hour${hoursAgo == 1 ? '' : 's'} ago';
      }
    }

    int day = dateTime.day;
    int month = dateTime.month;
    int year = dateTime.year;
    int hour = dateTime.hour;
    int minutes = dateTime.minute;

    String monthString;
    switch (month) {
      case 1:
        monthString = 'January';
        break;
      case 2:
        monthString = 'February';
        break;
      case 3:
        monthString = 'March';
        break;
      case 4:
        monthString = 'April';
        break;
      case 5:
        monthString = 'May';
        break;
      case 6:
        monthString = 'June';
        break;
      case 7:
        monthString = 'July';
        break;
      case 8:
        monthString = 'August';
        break;
      case 9:
        monthString = 'September';
        break;
      case 10:
        monthString = 'October';
        break;
      case 11:
        monthString = 'November';
        break;
      case 12:
        monthString = 'December';
        break;
      default:
        return 'Unknown';
    }

    return '$monthString $day, $year at ${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Widget _notificationBubble(bool read) {
    return Icon(
      Icons.brightness_1,
      color: read ? Colors.transparent : Colors.blue,
      size: _notificationBubbleSize,
    );
  }

  Widget _notificationIcon(String icon, bool read) {
    if (icon == null) {
      return _notificationBubble(read);
    }

    List<String> parts = icon.split(':');
    String type = parts[0];

    Widget leadingIcon;
    switch (type) {
      case 'url':
        parts.removeAt(0);
        String url = parts.join(':');
        if (url == 'null') {
          url = null;
        }
        leadingIcon = ProfileCircleAvatar(
          key: ValueKey<String>(icon),
          photoUrl: url,
        );
        break;
      case 'icon':
        String icon = parts[1];
        if (icon == 'multiline_chart') {
          leadingIcon = Icon(Icons.multiline_chart);
        }
        break;
    }

    return leadingIcon ?? _notificationBubble(read);
  }

  Widget _buildNotificationsList() {
    return widget.isLoading
        ? PlatformLoadingIndicator()
        : notifications.length == 0
            ? Center(
                child: Text(
                  'You\'re all caught up! \u{1f389}',
                  style: Theme.of(context).textTheme.subhead,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(0.0),
                itemBuilder: (BuildContext context, int index) {
                  Notification notification = notifications[index];
                  return Material(
                    color: notification.read
                        ? Colors.transparent
                        : Colors.lightBlueAccent.withOpacity(0.15),
                    child: Dismissible(
                      key: ValueKey(notification.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (direction) {
                        widget.deleteNotification(notification);
                        setState(() {
                          _deletedNotifications.add(notification.id);
                        });
                      },
                      child: ListTile(
                          leading: _notificationIcon(
                              notification.data?.icon, notification.read),
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Text(notification.notification.body ??
                                notification.notification.title),
                          ),
                          subtitle:
                              Text(_buildDateTimeString(notification.dateTime)),
                          onTap: () {
                            if (!notification.read) {
                              widget.updateNotificationRead(notification);
                            }
                            Navigator.of(context).push(MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      ProfileContainer(
                                        profileId: notification.data.profile,
                                      ),
                                ));
                          }),
                    ),
                  );
                },
                itemCount: notifications.length,
              );
  }

  Widget _buildiOS() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Notifications',
          style: Theme.of(context).primaryTextTheme.title,
        ),
        backgroundColor: HumbleMe.teal,
      ),
      child: _buildNotificationsList(),
    );
  }

  Widget _buildAndroid() {
    return _buildNotificationsList();
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid ? _buildAndroid() : _buildiOS();
  }
}
