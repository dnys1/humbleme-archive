import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';

import 'app/container.dart';
import 'app/models.dart';
import 'app/notifications/containers/notifications.dart';
import 'app/profile/containers/profile_edit.dart';
import 'app/resources/containers/bookshelf.dart';
import 'app/resources/containers/stats.dart';
import 'app/search/containers/search.dart';
import 'app/self/containers/self.dart';
import 'app/settings/containers/settings.dart';
import 'auth/models/user.dart';
import 'core/models.dart';
import 'selectors.dart';
import 'theme.dart';
import 'welcome/container.dart';
import 'welcome/intro/containers/top_mindsets.dart';
import 'welcome/login/containers/login.dart';
import 'welcome/signup/containers/age.dart';
import 'welcome/signup/containers/email_and_password.dart';
import 'welcome/signup/containers/enable_permissions.dart';
import 'welcome/signup/containers/gender.dart';
import 'welcome/signup/containers/name_and_number.dart';
import 'welcome/signup/containers/onboard.dart';
import 'welcome/signup/containers/verify_email.dart';

enum TransitionType { native, nativeModal, inFromLeft, inFromRight }

class Routes {
  static final RouteObserver<PageRoute> rootObserver =
      RouteObserver<PageRoute>();

  static Map<AppTab, RouteObserver<PageRoute>> appObservers =
      Map<AppTab, RouteObserver<PageRoute>>.fromIterable(
    AppTab.values,
    key: (tab) => tab,
    value: (_) => RouteObserver<PageRoute>(),
  );

  static const String welcome = '/welcome';
  static const String login = '/welcome/login';
  static const String emailAndPassword = '/welcome/email_and_password';
  static const String verifyEmail = '/welcome/verify_email';
  static const String nameAndNumber = '/welcome/name_and_number';
  static const String enablePermissions = '/welcome/enable_permissions';
  static const String age = '/welcome/age';
  static const String gender = '/welcome/gender';
  static const String onboard = '/welcome/onboard';
  static const String topMindsets = '/welcome/topMindsets';
  static const String app = '/app';
  static const String appHome = '/app/home';
  static const String search = '/app/search';
  static const String stats = '/app/resources/stats';
  static const String bookshelf = 'app/resources/bookshelf';
  static const String settings = '/app/settings';
  static const String profile = '/app/profile';
  static const String editProfile = '/app/profile/edit';
  static const String surveys = '/app/surveys';
  static const String profile_info = '/app/profile/info';
  static const String friend_list = '/app/profile/friend_list';
  static const String selfAssessments = '/app/self';
  static const String notifications = '/app/notifications';

  static Map<String, WidgetBuilder> routes = {
    Routes.welcome: (context) => WelcomeContainer(),
    Routes.login: (context) => LoginContainer(),
    Routes.emailAndPassword: (context) => EmailAndPasswordContainer(),
    Routes.verifyEmail: (context) => VerifyEmailContainer(),
    Routes.nameAndNumber: (context) => NameAndNumberContainer(),
    Routes.enablePermissions: (context) => EnablePermissionsContainer(),
    Routes.age: (context) => AgeContainer(),
    Routes.gender: (context) => GenderContainer(),
    Routes.onboard: (context) => OnboardContainer(),
    Routes.topMindsets: (context) => TopMindsets(),
    Routes.app: (context) => AppContainer(),
    Routes.stats: (context) => StatsContainer(),
    Routes.bookshelf: (context) => BookshelfContainer(),
    Routes.settings: (context) => SettingsContainer(),
    Routes.search: (context) => SearchContainer(),
    Routes.selfAssessments: (context) => SelfContainer(),
    Routes.editProfile: (context) => ProfileEditContainer(),
    Routes.notifications: (context) => NotificationsContainer(),
  };

  static Route routeBuilderFromPath(
    BuildContext context,
    String path, {
    TransitionType transitionType = TransitionType.native,
  }) {
    if (transitionType == TransitionType.native ||
        transitionType == TransitionType.nativeModal) {
      if (kIsAndroid) {
        return MaterialPageRoute<dynamic>(
          settings: RouteSettings(name: path),
          fullscreenDialog: transitionType == TransitionType.nativeModal,
          builder: (BuildContext context) {
            if (routes[path] != null) {
              return routes[path](context);
            } else {
              throw Exception('PATH NOT FOUND');
            }
          },
        );
      } else {
        return CupertinoPageRoute(
            settings: RouteSettings(name: path),
            fullscreenDialog: transitionType == TransitionType.nativeModal,
            builder: (BuildContext context) {
              if (routes[path] != null) {
                return routes[path](context);
              } else {
                throw Exception('PATH NOT FOUND');
              }
            });
      }
    } else {
      var routeTransitionsBuilder;
      const Offset topLeft = const Offset(0.0, 0.0);
      const Offset topRight = const Offset(1.0, 0.0);
      const Offset bottomLeft = const Offset(0.0, 1.0);
      Offset startOffset = bottomLeft;
      Offset endOffset = topLeft;
      if (transitionType == TransitionType.inFromLeft) {
        startOffset = const Offset(-1.0, 0.0);
        endOffset = topLeft;
      } else if (transitionType == TransitionType.inFromRight) {
        startOffset = topRight;
        endOffset = topLeft;
      }

      routeTransitionsBuilder = (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      };

      return PageRouteBuilder<dynamic>(
        settings: RouteSettings(name: path),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          if (routes[path] != null) {
            return routes[path](context);
          } else {
            throw Exception('ROUTE NOT FOUND');
          }
        },
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: routeTransitionsBuilder,
      );
    }
  }

  static Route routeBuilderFromWidget(
    String path,
    WidgetBuilder builder, {
    TransitionType transitionType = TransitionType.native,
  }) {
    if (transitionType == TransitionType.native ||
        transitionType == TransitionType.nativeModal) {
      if (kIsAndroid) {
        return MaterialPageRoute<dynamic>(
          settings: RouteSettings(name: path),
          fullscreenDialog: transitionType == TransitionType.nativeModal,
          builder: builder,
        );
      } else {
        return CupertinoPageRoute(
          settings: RouteSettings(name: path),
          fullscreenDialog: transitionType == TransitionType.nativeModal,
          builder: builder,
        );
      }
    } else {
      var routeTransitionsBuilder;
      const Offset topLeft = const Offset(0.0, 0.0);
      const Offset topRight = const Offset(1.0, 0.0);
      const Offset bottomLeft = const Offset(0.0, 1.0);
      Offset startOffset = bottomLeft;
      Offset endOffset = topLeft;
      if (transitionType == TransitionType.inFromLeft) {
        startOffset = const Offset(-1.0, 0.0);
        endOffset = topLeft;
      } else if (transitionType == TransitionType.inFromRight) {
        startOffset = topRight;
        endOffset = topLeft;
      }

      routeTransitionsBuilder = (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      };

      return PageRouteBuilder<dynamic>(
        settings: RouteSettings(name: path),
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return builder(context);
        },
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: routeTransitionsBuilder,
      );
    }
  }

  static bool _permissionsEnabled(BuildContext context) {
    AppState state = StoreProvider.of<AppState>(context).state;
    return getPermissionsEnabled(state);
  }

  static String pickNextInFlow({
    @required User user,
    @required BuildContext context,
  }) {
    if (user == null) {
      return welcome;
    } else if (user.phoneNumber == null || user.displayName == null) {
      // || !user.onboarding.phoneNumberVerified) {
      return nameAndNumber;
    } else if (user.age == null) {
      return age;
    } else if (user.gender == null) {
      return gender;
      // } else if (!_permissionsEnabled(context)) {
      //   return enablePermissions;
    } else if (!user.onboarding.onboardingComplete) {
      return onboard;
    } else {
      return app;
    }
  }
}
