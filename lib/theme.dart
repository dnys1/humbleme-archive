import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

var test = CupertinoIcons.book;

// Will always be true in test mode
// Must set debug flag to change
// final debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
final bool kIsAndroid = defaultTargetPlatform == TargetPlatform.android;
final kIconSize = 26.0;

final Image kDefaultProfile = Image.asset(
  'images/default_profile.png',
  alignment: Alignment.topCenter,
);

const kiOSDefaultTextStyle = const TextStyle(
  fontFamily: '.SF UI Text',
  inherit: false,
  fontSize: 15.0,
  fontWeight: FontWeight.normal,
  color: CupertinoColors.black,
  textBaseline: TextBaseline.alphabetic,
);

class IOSIcons {
  static const IconData lightning_light = const IconData(0xf3e5,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData lightning_dark = const IconData(0xf3e6,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData settings_light = const IconData(0xf43c,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData settings_dark = const IconData(0xf43d,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData search_light = const IconData(0xf4a5,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData search_dark = const IconData(0xf4a4,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData star_light = const IconData(0xf4b2,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData star_dark = const IconData(0xf4b3,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData survey_light = const IconData(0xf453,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData survey_dark = const IconData(0xf454,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData check_circled_light = const IconData(0xf3fe,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData check_circled_dark = const IconData(0xf3ff,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData globe = const IconData(0xf38c,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData international_light = const IconData(0xf4d2,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData international_dark = const IconData(0xf4d3,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData spedometer_light = const IconData(0xf4af,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData spedometer_dark = const IconData(0xf4b0,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData info_light = const IconData(0xf44c,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData info_dark = const IconData(0xf44d,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData profile_light = const IconData(0xf47d,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData profile_dark = const IconData(0xf47e,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData group_light = const IconData(0xf47b,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData group_dark = const IconData(0xf47c,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData add_profile_light = const IconData(0xf47f,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData add_profile_dark = const IconData(0xf480,
      fontFamily: CupertinoIcons.iconFont,
      fontPackage: CupertinoIcons.iconFontPackage);

  static const IconData book_light = const IconData(
    0xf3e7,
    fontFamily: CupertinoIcons.iconFont,
    fontPackage: CupertinoIcons.iconFontPackage,
  );

  static const IconData book_dark = const IconData(
    0xf3e7,
    fontFamily: CupertinoIcons.iconFont,
    fontPackage: CupertinoIcons.iconFontPackage,
  );

  static List<Map<int, IconData>> get getAllIcons {
    var list = <Map<int, IconData>>[];
    for (var i = 0xf359; i <= 0xf4d3; i++) {
      var map = <int, IconData>{};
      map[i] = IconData(
        i,
        fontFamily: CupertinoIcons.iconFont,
        fontPackage: CupertinoIcons.iconFontPackage,
      );
      list.add(map);
    }
    return list;
  }

  static ListView get getIconListView => ListView(
        children: getAllIcons.map((icon) {
          return Row(
            children: <Widget>[
              Text(icon.keys.first.toRadixString(16),
                  style: kiOSDefaultTextStyle),
              Icon(
                icon.values.first,
                color: Colors.black,
              ),
            ],
          );
        }).toList(),
      );
}

class HumbleMe {
  static const int _tealPrimary = 0xFF38CECA;
  static const int _tealAccentPrimary = 0xFF9CE7E5;
  static const int _bluePrimary = 0xFF38CECA;
  static const int _blueAccentPrimary = 0xFF9CE7E5;

  static const primaryTeal = const Color(0xFF38CECA); // #38CECA
  static const primaryTealDark = const Color(0xFF009C99); // #009C99
  static const primaryTealLight = const Color(0xFF78FFFD); // #78FFFD
  static const accentBlue = const Color(0xFF31C2CE); // #31C2CE
  static const accentBlueLight = const Color(0xFF72F5FF); // #72F5FF
  static const accentBlueDark = const Color(0xFF00919D); // #00919D
  static const purple = const Color(0xFF3311CC); // #3311CC
  static const blueGray = const Color(0xFF587291); // #587291
  static const darkBlue = const Color(0xFF2F97C1); // #2f97c1
  static const purpleWhite = const Color(0xFFEFE9F4); // #efe9f4
  static const greenGray = const Color(0xFF404e4d); // #404e4d
  static const brown = const Color(0xFF63595c); // #63595c
  static const purpleGray = Color(0xFF646881); // #646881

  static const teal = const MaterialColor(_tealPrimary, const <int, Color>{
    50: const Color(0xFFE7F9F9), // #e7f9f9
    100: const Color(0xFFC3F0EF), // #c3f0ef
    200: const Color(0xFF9CE7E5), // #9ce7e5
    300: const Color(0xFF74DDDA), // #74ddda
    400: const Color(0xFF56D5D2), // #56d5d2
    500: const Color(_tealPrimary), // #38ceca
    600: const Color(0xFF32C9C5), // #32c9c5
    700: const Color(0xFF2BC2BD), // #2bc2bd
    800: const Color(0xFF24BCB7), // #24bcb7
    900: const Color(0xFF17B0AB), // #17b0ab
  });

  static const tealAccent =
      const MaterialAccentColor(_tealAccentPrimary, const <int, Color>{
    100: const Color(0xFFE4FFFE), // #e4fffe
    200: const Color(_tealAccentPrimary), // #b1fffc
    400: const Color(0xFF7EFFFA), // #7efffa
    700: const Color(0xFF64FFF9), // #64fff9
  });

  static const blue = const MaterialColor(_bluePrimary, const <int, Color>{
    50: const Color(0xFFE6F8F9), // #e6f8f9
    100: const Color(0xFFC1EDF0), // #c1edf0
    200: const Color(0xFF98E1E7), // #98e1e7
    300: const Color(0xFF6FD4DD), // #6fd4dd
    400: const Color(0xFF50CBD5), // #50cbd5
    500: const Color(_bluePrimary), // #31c2ce
    600: const Color(0xFF2CBCC9), // #2cbcc9
    700: const Color(0xFF25B4C2), // #25b4c2
    800: const Color(0xFF1FACBC), // #1facbc
    900: const Color(0xFF139FB0), // #139fb0
  });

  static const blueAccent =
      const MaterialAccentColor(_blueAccentPrimary, const <int, Color>{
    100: const Color(0xFFE1FBFF), // #e1fbff
    200: const Color(_blueAccentPrimary), // #aef5ff
    400: const Color(0xFF7BEFFF), // #7befff
    700: const Color(0xFF62ECFF), // #62ecff
  });

  static const LinearGradient welcomeGradient = const LinearGradient(
    colors: <Color>[primaryTeal, accentBlue],
    begin: Alignment.center,
    end: Alignment.bottomCenter,
  );

  static ThemeData get welcomeTheme {
    final darkTheme = ThemeData.dark();
    final darkTextTheme = darkTheme.textTheme;

    return darkTheme.copyWith(
      brightness: Brightness.dark,
      primaryColorBrightness: Brightness.dark,
      primaryColor: primaryTeal,
      primaryColorDark: primaryTealDark,
      primaryColorLight: primaryTealLight,
      accentColor: blue,
      accentColorBrightness: Brightness.dark,
      bottomAppBarColor: primaryTeal,
      textTheme: darkTextTheme.apply(
        fontFamily: 'Avenir',
      ),
      highlightColor: Colors.white70,
      splashColor: Colors.transparent,
      scaffoldBackgroundColor: primaryTeal,
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: const TextStyle(color: Colors.white),
      ),
      buttonTheme: const ButtonThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 12.0),
        shape: const RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white, width: 2.0),
          borderRadius: const BorderRadius.all(
            const Radius.circular(24.0),
          ),
        ),
      ),
    );
  }

  static ThemeData get appTheme {
    final lightTheme = ThemeData.light();
    var lightTextTheme = lightTheme.textTheme;
    var darkTextTheme = ThemeData.dark().textTheme;

    darkTextTheme = darkTextTheme.apply(
      fontFamily: kIsAndroid ? 'Avenir' : kiOSDefaultTextStyle.fontFamily,
    );
    lightTextTheme = lightTextTheme.apply(
      fontFamily: kIsAndroid ? 'Avenir' : kiOSDefaultTextStyle.fontFamily,
    );

    return lightTheme.copyWith(
      primaryColorBrightness: Brightness.dark,
      primaryColor: primaryTeal,
      primaryColorDark: primaryTealDark,
      primaryColorLight: primaryTealLight,
      accentColor: blue,
      accentColorBrightness: Brightness.dark,
      bottomAppBarColor: primaryTeal,
      buttonColor: blue,
      scaffoldBackgroundColor:
          kIsAndroid ? Colors.white : CupertinoColors.white,
      inputDecorationTheme: const InputDecorationTheme(),
      indicatorColor: Colors.white,
      primaryTextTheme: darkTextTheme.copyWith(
        title: darkTextTheme.title.copyWith(fontSize: 18.0),
      ),
      textTheme: lightTextTheme.copyWith(
        button: welcomeTheme.textTheme.button,
      ),
      buttonTheme: const ButtonThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 70.0, vertical: 12.0),
        shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(24.0),
          ),
        ),
      ),
    );
  }
}
