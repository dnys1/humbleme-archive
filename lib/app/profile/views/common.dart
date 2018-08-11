import 'package:flutter/material.dart';

import '../../../theme.dart';

Color getScorebarColorForScore(double score) {
  if (score == null || score == 0) {
    return null;
  }

  if (score > 0) {
    if (score <= 1) {
      return Colors.red;
    } else if (score <= 2) {
      return Colors.orange;
    } else if (score <= 3) {
      return Colors.yellow;
    } else if (score <= 4) {
      return Colors.green;
    } else if (score <= 5) {
      return HumbleMe.blue;
    } else {
      throw 'Score cannot be greater than 5!';
    }
  } else {
    throw 'Score cannot be less than 0!';
  }
}

Widget getListTileWidgetForScore(double score, BuildContext context) {
  if (score == 0.0 || score == null) {
    return Text(
      'N/A',
      style: Theme.of(context).textTheme.caption,
    );
  }
  Color color = getScorebarColorForScore(score);
  return Text(score.toStringAsFixed(1),
      style: Theme.of(context).textTheme.body1.copyWith(color: color));
}
