import 'package:flutter/material.dart';

import '../../theme.dart';

class LoadingView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  LoadingView({
    @required this.scaffoldKey,
  });

  @override
  _LoadingViewState createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget.scaffoldKey,
      body: Theme(
        data: ThemeData(
          accentColor: Colors.white,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: HumbleMe.welcomeGradient,
          ),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
