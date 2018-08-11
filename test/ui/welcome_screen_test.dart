import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:humbleme/theme.dart';
import 'package:humbleme/welcome/view.dart';

void main() {
  testWidgets('test home screen', (WidgetTester tester) async {
    var screenKey = UniqueKey();
    var scaffoldKey = GlobalKey<ScaffoldState>();

    ThemeData welcomeTheme = HumbleMe.welcomeTheme;
    await tester.pumpWidget(MaterialApp(
      theme: welcomeTheme,
      home: WelcomeView(
        key: screenKey,
        scaffoldKey: scaffoldKey,
      ),
    ));

    ThemeData renderedTheme = Theme.of(tester.element(find.byKey(screenKey)));
    expect(renderedTheme.scaffoldBackgroundColor,
        equals(welcomeTheme.scaffoldBackgroundColor));
    expect(renderedTheme.primaryColor, equals(welcomeTheme.primaryColor));
  });
}
