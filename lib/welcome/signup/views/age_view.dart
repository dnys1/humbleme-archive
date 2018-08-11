import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../theme.dart';

const double _kPickerItemHeight = 32.0;

class AgeView extends StatefulWidget {
  AgeView({
    Key key,
    @required this.onNext,
    @required this.scaffoldKey,
  })  : assert(onNext != null),
        super(key: key);

  final Function(int) onNext;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _AgeViewState createState() => _AgeViewState();
}

class _AgeViewState extends State<AgeView> {
  int _age = 18;

  @override
  Widget build(BuildContext context) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: 0);
    final TextStyle nextButtonStyle =
        TextStyle(color: Colors.white, fontSize: 18.0);

    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        actions: <Widget>[
          kIsAndroid
              ? FlatButton(
                  child: Text('Next', style: nextButtonStyle),
                  shape: RoundedRectangleBorder(),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () => widget.onNext(_age),
                )
              : CupertinoButton(
                  child: Text('Next', style: nextButtonStyle),
                  onPressed: () => widget.onNext(_age),
                )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: HumbleMe.welcomeGradient,
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child:
                        Image.asset('images/logo.png', fit: BoxFit.cover)),
              ),
            ),
            Expanded(
              child: Container(
                  child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('Please select your age',
                          style: TextStyle(fontSize: 22.0)),
                    )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: CupertinoColors.white,
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          color: CupertinoColors.black,
                          fontSize: 22.0,
                        ),
                        child: GestureDetector(
                          // Blocks taps from propagating to the modal sheet and popping.
                          onTap: () {},
                          child: SafeArea(
                            child: CupertinoPicker(
                              scrollController: scrollController,
                              itemExtent: _kPickerItemHeight,
                              backgroundColor: CupertinoColors.white,
                              onSelectedItemChanged: (int index) {
                                setState(() {
                                  _age = index + 18;
                                });
                              },
                              children:
                                  List<Widget>.generate(50, (int index) {
                                return Center(
                                    child: Text('${index+18}'));
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
