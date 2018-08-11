import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../theme.dart';

Widget buildiOSNavigationButton(
    {bool left = false, IconData iconData, Function onPressed}) {
  return CupertinoButton(
    minSize: kIconSize,
    padding: EdgeInsets.only(bottom: max(kIconSize - 24.0, 0.0)),
    child: Icon(
      iconData,
      size: kIconSize,
      color: CupertinoColors.white,
    ),
    onPressed: onPressed,
  );
}
