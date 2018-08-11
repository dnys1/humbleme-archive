import 'dart:math';

import 'package:flutter/material.dart';

const Duration _kShowDuration = Duration(milliseconds: 700);

class DistributionCurve extends StatefulWidget {
  final EdgeInsets padding;
  final double scoreStandardDeviation;
  final Color fillColor;
  final Color strokeColor;
  final double width;
  final double height;

  DistributionCurve({
    Key key,
    @required this.width,
    @required this.height,
    @required this.scoreStandardDeviation,
    @required this.fillColor,
    @required this.strokeColor,
    this.padding = const EdgeInsets.only(top: 15.0),
  })  : assert(width != null),
        assert(height != null),
        assert(padding != null),
        assert(scoreStandardDeviation != null),
        assert(fillColor != null),
        super(key: key);

  @override
  createState() => _DistributionCurveState();

  static double abs(double x) {
    if (x.sign == 1.0) {
      return x;
    } else {
      return -x;
    }
  }

  /// Calculates the cumulative probability of a person having value `x`
  /// for a normal distribution defined by `mean` and `sigma`
  /// Code from: https://stackoverflow.com/questions/5259421/cumulative-distribution-function-in-javascript
  static double normalcdf(double mean, double sigma, double x) {
    double z = (x - mean) / sqrt(2 * sigma * sigma);
    double t = 1 / (1 + 0.3275911 * abs(z));
    double a1 = 0.254829592;
    double a2 = -0.284496736;
    double a3 = 1.421413741;
    double a4 = -1.453152027;
    double a5 = 1.061405429;
    double erf =
        1 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-z * z);
    int sign = 1;
    if (z < 0) {
      sign = -1;
    }
    return (1 / 2) * (1 + sign * erf);
  }
}

class _DistributionCurveState extends State<DistributionCurve>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animatedWidth;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: _kShowDuration, vsync: this);
    _animatedWidth = CurvedAnimation(parent: _controller, curve: Curves.linear);

    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.view,
      builder: (BuildContext context, Widget child) {
        return Stack(
          children: <Widget>[
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: child,
            ),
            // ),
            Positioned(
              top: 0.0,
              bottom: 0.0,
              left: widget.width * _animatedWidth.value,
              child: Container(
                color: Colors.white,
                child: SizedBox(
                  height: widget.height,
                  width: widget.width,
                ),
              ),
            ),
          ],
        );
      },
      child: CustomPaint(
        painter: _DistributionCurvePainter(
          padding: widget.padding,
          scoreStandardDeviation: widget.scoreStandardDeviation,
          fillColor: widget.fillColor,
          strokeColor: widget.strokeColor,
        ),
      ),
    );
  }
}

class _DistributionCurvePainter extends CustomPainter {
  final EdgeInsets padding;
  final double scoreStandardDeviation;
  final Color fillColor;
  final Color strokeColor;

  _DistributionCurvePainter({
    this.scoreStandardDeviation,
    this.fillColor,
    this.strokeColor,
    this.padding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Get the bounding dimensions
    double height = size.height;
    double width = size.width;

    Path curve = Path();
    Path shader = Path();
    // Evaluate the gaussian curve along the whole of size
    const int numPoints = 100;

    // Normal distribution values
    double dx = width / numPoints;
    double zero = width / 2;
    double y = 0.0;
    double numberOfStdDevs = 3.0;

    double distributionHeight = 1 / sqrt(2 * pi);
    double curveY = 0.0;

    var mapX = (double x) => numberOfStdDevs * (x - zero) / zero;
    var invX = (double x) => (x * zero) / numberOfStdDevs + zero;
    bool hasStartedDrawingShader = scoreStandardDeviation >= 0.0;

    if (hasStartedDrawingShader) {
      for (double x = 0.0; x < width; x += dx) {
        double evalX = mapX(x);
        double f = exp(-pow(evalX, 2) / 2) / sqrt(2 * pi);
        double dy = (y - f) * (height - padding.top) / distributionHeight;
        // First step, just move in place
        if (x == 0.0) {
          curve.moveTo(0.0, height);
          shader.moveTo(invX(scoreStandardDeviation), height);
          shader.lineTo(0.0, height);
          y = f;
          curveY = dy;
          continue;
        }

        if (hasStartedDrawingShader && evalX > scoreStandardDeviation) {
          hasStartedDrawingShader = false;
          // shader.moveTo(x - dx, height);
          // shader.relativeLineTo(0.0, -curveY);
        }
        curve.relativeLineTo(dx, dy);
        if (hasStartedDrawingShader) {
          shader.relativeLineTo(dx, dy);
        }
        curveY -= dy;
        y = f;
      }
    } else {
      for (double x = 0.0; x < width; x += dx) {
        double evalX = mapX(x);
        double f = exp(-pow(evalX, 2) / 2) / sqrt(2 * pi);
        double dy = (y - f) * (height - padding.top) / distributionHeight;
        // First step, just move in place
        if (x == 0.0) {
          curve.moveTo(0.0, (height - dy));
          y = f;
          curveY = dy;
          continue;
        }

        if (!hasStartedDrawingShader && evalX > scoreStandardDeviation) {
          hasStartedDrawingShader = true;
          shader.moveTo(x - dx, height);
          shader.relativeLineTo(0.0, -curveY);
        }
        curve.relativeLineTo(dx, dy);
        if (hasStartedDrawingShader) {
          shader.relativeLineTo(dx, dy);
        }
        curveY -= dy;
        y = f;
      }
    }

    canvas.drawPath(
      shader,
      Paint()..color = fillColor,
    );

    canvas.drawPath(
      curve,
      Paint()
        ..color = strokeColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    double curveHeight =
        exp(-pow(scoreStandardDeviation, 2) / 2) / sqrt(2 * pi);
    double dy = height - ((height - padding.top) * curveHeight);

    // Position the point halfway between steps at at the middle of the curve
    Offset pointOffset = Offset(invX(scoreStandardDeviation), dy);

    canvas.drawCircle(pointOffset, 3.0, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
