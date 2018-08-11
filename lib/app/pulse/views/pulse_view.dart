import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../theme.dart';

class PulseView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style:
          kIsAndroid ? Theme.of(context).textTheme.body1 : kiOSDefaultTextStyle,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              kIsAndroid ? Icons.search : CupertinoIcons.search,
              color: Colors.black,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
              child: Text(
                "There's nothing here yet! Add some friends to see your feed",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            kIsAndroid
                ? RaisedButton(
                    child: Text('Add Friends',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {},
                  )
                : CupertinoButton(
                    child: Text('Add Friends'),
                    onPressed: () {},
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  ),
          ],
        ),
      ),
    );
  }
}
