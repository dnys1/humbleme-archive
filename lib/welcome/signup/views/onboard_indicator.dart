import 'dart:math';
import 'package:flutter/material.dart';

class DotsIndicator extends AnimatedWidget {
  DotsIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.white,
  }) : super(listenable: controller);

  final PageController controller;
  final int itemCount;
  final ValueChanged<int> onPageSelected;
  final Color color;

  static const double _kDotSize = 6.0;
  static const double _kMaxZoom = 1.5;
  static const double _kDotSpacing = 25.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(max(0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs()));
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return Container(
        width: _kDotSpacing,
        child: Center(
            child: Material(
          borderRadius: BorderRadius.circular(_kDotSize * zoom / 2),
          color: color,
          child: Container(
              width: _kDotSize * zoom,
              height: _kDotSize * zoom,
              child: InkWell(onTap: () => onPageSelected(index))),
        )));
  }

  Widget build(BuildContext context) {
    return Container(
      height:
          _kDotSize * 2, // put in fixed container to avoid "bouncing" on resize
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(itemCount, _buildDot),
      ),
    );
  }
}
