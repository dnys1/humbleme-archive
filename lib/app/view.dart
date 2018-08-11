import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme.dart';
import 'home/containers/home.dart';
import 'models.dart';
import 'notifications/containers/notifications.dart';
import 'play/containers/play.dart';
import 'profile/containers/profile.dart';
import 'profile/containers/profile_edit.dart';
import 'resources/containers/stats.dart';
import 'search/containers/search.dart';
import 'self/containers/self.dart';
import 'settings/containers/settings.dart';

class AppView extends StatefulWidget {
  final Function(int) onTabSelected;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final AppTab activeTab;
  final int notificationCount;

  AppView({
    @required this.onTabSelected,
    @required this.activeTab,
    @required this.scaffoldKey,
    @required this.notificationCount,
  });

  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  bool connected = true;

  static final List<String> tabLabels = [
    'Home',
    'Notifications',
    'Profile',
    'Play',
    'Stats',
  ];

  final List<Function> createTabScreen = [
    () => HomeContainer(),
    () => NotificationsContainer(),
    () => ProfileContainer(),
    () => PlayContainer(),
    () => StatsContainer(),
  ];

  static BottomNavigationBarItem _buildTabItem(
      {int count = 0, Text title, Icon icon}) {
    return count == 0
        ? BottomNavigationBarItem(
            title: FittedBox(child: title),
            icon: icon,
          )
        : BottomNavigationBarItem(
            title: title,
            icon: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                icon,
                Positioned(
                    top: -1.0,
                    right: -6.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.brightness_1,
                          size: 17.0,
                          color: Colors.redAccent,
                        ),
                        Text(
                          '$count',
                          style: TextStyle(
                            inherit: false,
                            color: CupertinoColors.white,
                            fontSize: 9.0,
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          );
  }

  Widget _buildAndroid(
      {BuildContext context, List<BottomNavigationBarItem> tabs}) {
    var actions, leading;
    switch (widget.activeTab) {
      case AppTab.home:
        actions = <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.of(context).pushNamed(Routes.search),
          ),
        ];
        leading = IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
        );
        break;
      case AppTab.surveys:
        actions = <Widget>[
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () => Navigator.of(context).pushNamed(Routes.search),
          )
        ];
        break;
      default:
        break;
    }
    return DefaultTabController(
      length: tabs.length,
      initialIndex: AppTab.home.index,
      child: Scaffold(
        key: widget.scaffoldKey,
        appBar: widget.activeTab == AppTab.profile
            ? null
            : AppBar(
                title: Text(
                    tabLabels[AppTab.values.indexOf(widget.activeTab)]),
                actions: actions,
                leading: leading,
              ),
        // Wrap with container to pad color
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: widget.activeTab.index,
          onTap: (int tabIndex) {
            widget.onTabSelected(tabIndex);
          },
          items: tabs,
        ),
        body: createTabScreen[widget.activeTab.index](),
      ),
    );
  }

  Widget _buildiOS({BuildContext context, List<BottomNavigationBarItem> tabs}) {
    return CupertinoTabScaffold(
      key: widget.scaffoldKey,
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.white,
        activeColor: HumbleMe.teal,
        currentIndex: widget.activeTab.index,
        onTap: (int tabIndex) {
          widget.onTabSelected(tabIndex);
        },
        items: tabs,
      ),
      tabBuilder: (BuildContext context, int index) {
        return DefaultTextStyle(
          style: const TextStyle(
            fontFamily: '.SF UI Text',
            fontSize: 17.0,
            color: CupertinoColors.black,
          ),
          child: CupertinoTabView(
            routes: {
              Routes.search: (BuildContext context) => SearchContainer(),
              Routes.settings: (BuildContext context) =>
                  SettingsContainer(),
              Routes.selfAssessments: (context) => SelfContainer(),
              Routes.editProfile: (context) => ProfileEditContainer(),
              Routes.notifications: (context) => NotificationsContainer(),
              Routes.stats: (context) => StatsContainer(),
            },
            builder: (BuildContext context) {
              return createTabScreen[widget.activeTab.index]();
            },
            navigatorObservers: [Routes.appObservers.values.elementAt(index)],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> tabs = [
      _buildTabItem(
        title: Text(tabLabels[0]),
        icon: kIsAndroid
            ? const Icon(Icons.home)
            : const Icon(CupertinoIcons.home),
      ),
      _buildTabItem(
        count: widget.notificationCount ?? 0,
        title: Text(tabLabels[1]),
        icon: kIsAndroid
            ? const Icon(Icons.info)
            : const Icon(IOSIcons.info_light),
      ),
      _buildTabItem(
        title: Text(tabLabels[2]),
        icon: kIsAndroid
            ? const Icon(Icons.person)
            : const Icon(CupertinoIcons.profile_circled),
      ),
      _buildTabItem(
        title: Text(tabLabels[3]),
        icon: kIsAndroid
            ? const Icon(Icons.star)
            : const Icon(IOSIcons.star_light),
      ),
      _buildTabItem(
        title: Text(tabLabels[4]),
        icon: kIsAndroid
            ? const Icon(Icons.language)
            : const Icon(IOSIcons.globe),
      ),
    ];
    return kIsAndroid
        ? _buildAndroid(
            context: context,
            tabs: tabs,
          )
        : _buildiOS(
            context: context,
            tabs: tabs,
          );
  }
}
