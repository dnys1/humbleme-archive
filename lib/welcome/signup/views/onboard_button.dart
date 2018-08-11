import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../theme.dart';

class OnboardButton extends AnimatedWidget {
  OnboardButton({
    this.controller,
    this.itemCount,
    this.onPressed,
  }) : super(listenable: controller);

  final PageController controller;
  final int itemCount;
  final Function onPressed;

  static const _kFontSize = 16.0;
  static const _kContainerPadding = const EdgeInsets.only(bottom: 20.0);
  static const _kSkipPadding = const EdgeInsets.all(2.0);
  static const _kGetStartedPadding =
      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0);

  Widget _buildSkip() {
    double distance = min(1.0,
        (itemCount - 1.0 - (controller.page ?? controller.initialPage)).abs());
    double opacity = Curves.easeOut.transform(distance);
    Text text = Text('Skip',
        style: TextStyle(
            fontSize: _kFontSize, color: Colors.white.withOpacity(opacity)));
    return kIsAndroid
        ? Padding(
            padding: _kContainerPadding,
            child: FlatButton(
              padding: _kSkipPadding,
              child: text,
              onPressed: onPressed,
              shape: RoundedRectangleBorder(),
            ))
        : Padding(
            padding: _kContainerPadding,
            child: CupertinoButton(
              padding: _kSkipPadding,
              child: text,
              onPressed: onPressed,
            ));
  }

  Widget _buildGetStarted() {
    double distance = min(1.0,
        (itemCount - 1.0 - (controller.page ?? controller.initialPage)).abs());
    double opacity = Curves.easeOut.transform(distance);
    Text text = Text('Get Started',
        style: TextStyle(
            fontSize: _kFontSize,
            color: Colors.white.withOpacity(1.0 - opacity)));
    return kIsAndroid
        ? Padding(
            padding: _kContainerPadding,
            child: FlatButton(
              padding: _kGetStartedPadding,
              child: text,
              onPressed: onPressed,
              shape: RoundedRectangleBorder(),
            ))
        : Padding(
            padding: _kContainerPadding,
            child: CupertinoButton(
              padding: _kGetStartedPadding,
              child: text,
              onPressed: onPressed,
            ));
  }

  Widget build(BuildContext context) {
    return Stack(
        alignment: AlignmentDirectional.center,
        // For last page, switch order of stack to have "Get Started" on top
        children: (controller.page ?? controller.initialPage) >
                (itemCount - 1.5) // halfway to last page
            ? <Widget>[_buildSkip(), _buildGetStarted()]
            : <Widget>[_buildGetStarted(), _buildSkip()]);
  }
}
