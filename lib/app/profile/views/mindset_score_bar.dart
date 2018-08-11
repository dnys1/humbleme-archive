import 'package:flutter/material.dart';

import 'common.dart';

// We're building a makeshift mask using an image at a fixed size
// We want to scale down the image but keep the same aspect ratio, while
// knowing the height/width so we can display the Container correctly.
// The original width / height
const double _scoreBarImageWidth = 684.0;
const double _scoreBarImageHeight = 31.0;
// Necessary correction for border
const double _scoreBarBorderOverflow = 1.0;

/// A small version of the larger score bar for display in `ListTile` widgets
/// and modal dialogs. Either `width` or `height` must be specified and `score`
/// cannot be null.
class MindsetScorebar extends StatelessWidget {
  /// Whether this is a self score or not.
  final bool self;

  /// The score for this mindset
  final double score;

  /// The height of the scorebar
  final double height;

  /// The width of the scorebar
  final double width;

  MindsetScorebar({
    Key key,
    @required this.self,
    @required this.score,
    this.width,
    this.height,
  })  : assert(self != null),
        assert(score != null),
        assert(width != null || height != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (score == null || score == 0.0) {
      return Text(
        'N/A',
        style: Theme.of(context).textTheme.caption,
      );
    }

    double _width, _height, _scaleFactor;
    if (height != null) {
      _height = height;
      _scaleFactor = _height / _scoreBarImageHeight;
      _width = _scaleFactor * _scoreBarImageWidth;
    } else {
      _width = width;
      _scaleFactor = _width / _scoreBarImageWidth;
      _height = _scaleFactor * _scoreBarImageHeight;
    }

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Tooltip(
        message: self ? 'How you see yourself' : 'How others see you',
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Positioned(
                left: _scoreBarBorderOverflow,
                child: SizedBox(
                  height: _height,
                  width: _width,
                  child: LinearProgressIndicator(
                    value: score / 5,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        getScorebarColorForScore(score)),
                  ),
                ),
              ),
              Image.asset(
                'images/score_bar.png',
                height: _scoreBarImageHeight * _scaleFactor,
                width: _scoreBarImageWidth * _scaleFactor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
