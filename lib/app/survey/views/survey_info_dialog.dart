import 'package:flutter/material.dart';

import '../../../auth/models.dart';

class SurveyInfoDialog extends StatefulWidget {
  final int userAge;

  SurveyInfoDialog({Key key, @required this.userAge}) : super(key: key);

  @override
  createState() => _SurveyInfoDialogState();
}

class _SurveyInfoDialogState extends State<SurveyInfoDialog> {
  double _discreteValue = 0.0;
  int _yearsKnown = 0;
  RelationshipType _relationshipType = RelationshipType.FRIEND;

  String getRelationshipStringFromType(RelationshipType type) {
    switch (type) {
      case RelationshipType.ACQUAINTANCE:
        return 'Acquaintance';
      case RelationshipType.BEST_FRIEND:
        return 'Best Friend';
      case RelationshipType.COWORKER:
        return 'Co-worker';
      case RelationshipType.FRIEND:
        return 'Friend';
      case RelationshipType.PARTNER:
        return 'Partner';
      case RelationshipType.RELATIVE:
        return 'Relative';
      default:
        throw AssertionError("'type' is not a RelationshipType");
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle headerStyle = Theme.of(context).textTheme.subhead;
    final TextStyle dropdownStyle = Theme.of(context).textTheme.body1;
    return SimpleDialog(
      title: Text('Survey Info'),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
      children: <Widget>[
        Text('How many years have you known this person?', style: headerStyle),
        SizedBox(height: 10.0),
        Center(
          child: Text('$_yearsKnown', style: headerStyle),
        ),
        Slider(
          value: _discreteValue,
          onChanged: (double val) {
            setState(() {
              _discreteValue = val;
              _yearsKnown = _discreteValue.round();
            });
          },
          min: 0.0,
          max: widget.userAge.toDouble(),
          divisions: widget.userAge,
        ),
        SizedBox(height: 10.0),
        Text('What\'s your relationship with this person?', style: headerStyle),
        SizedBox(height: 10.0),
        Center(
          child: DropdownButton<RelationshipType>(
            value: _relationshipType,
            onChanged: (RelationshipType newVal) {
              setState(() {
                _relationshipType = newVal;
              });
            },
            items: RelationshipType.values.map((type) {
              return DropdownMenuItem<RelationshipType>(
                key: ValueKey<RelationshipType>(type),
                value: type,
                child: Text(getRelationshipStringFromType(type),
                    style: dropdownStyle),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 20.0),
        FlatButton(
          child: Text('Continue'),
          color: Colors.grey[200],
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop(SurveyInfo(
                relationshipType: _relationshipType, yearsKnown: _yearsKnown));
          },
        )
      ],
    );
  }
}
