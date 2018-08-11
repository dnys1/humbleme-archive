import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

const double _kDefaultAndroidIndicatorRadius = 40.0;
const double _kDefaultiOSIndicatorRadius = 10.0;
const Color _defaultColor = HumbleMe.blue;

class PlatformLoadingIndicator extends StatelessWidget {
  final Color color;
  final double size;
  final bool forceMaterial;

  PlatformLoadingIndicator({
    Key key,
    this.color,
    this.size,
    this.forceMaterial = false,
  }) : super(key: key);

  Color get _color => color ?? _defaultColor;

  Widget _buildAndroid() {
    return Center(
      child: SizedBox(
        height: size ?? _kDefaultAndroidIndicatorRadius,
        width: size ?? _kDefaultAndroidIndicatorRadius,
        child: Theme(
          data: ThemeData(
            accentColor: _color,
          ),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildiOS() {
    return Center(
      child: CupertinoActivityIndicator(
        radius: size ?? _kDefaultiOSIndicatorRadius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid || forceMaterial ? _buildAndroid() : _buildiOS();
  }
}
