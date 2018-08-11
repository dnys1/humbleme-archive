import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../app/widgets/platform_loading_indicator.dart';
import '../../../auth/models/mindset.dart';
import '../../../theme.dart';
import '../models.dart';

final double kButtonFontSize = 14.0;
final double kPaddingSize = 10.0;

final double kInsetHeight = 65.0;

class TopMindsetsView extends StatefulWidget {
  final Function(TopMindsetsData) onSubmit;
  final List<Mindset> mindsets;

  TopMindsetsView({Key key, @required this.onSubmit, @required this.mindsets})
      : super(key: key);
  @override
  _TopMindsetsViewState createState() => _TopMindsetsViewState();
}

class _TopMindsetsViewState extends State<TopMindsetsView> {
  List<Mindset> _topMindsets = List<Mindset>();
  bool _loading = false;
  int _selected = 0;

  Widget _buildLoading() {
    return PlatformLoadingIndicator(color: Colors.white, forceMaterial: true);
  }

  List<Widget> _buildMindsetButtons() {
    TextStyle unselectedStyle = Theme.of(context).textTheme.body1.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: kButtonFontSize,
        );
    TextStyle selectedStyle = Theme.of(context).textTheme.body1.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: kButtonFontSize,
          color: HumbleMe.teal,
        );
    return widget.mindsets.map((mindset) {
      return Container(
        decoration: _topMindsets.contains(mindset)
            ? BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 0.0,
                  color: Colors.white,
                ),
                borderRadius: BorderRadius.circular(24.0),
              )
            : null,
        child: FlatButton(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Image.asset(
                      'images/mindsets/${mindset.getName().toLowerCase()}.png',
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Text(
                  mindset.getName(),
                  style: _topMindsets.contains(mindset)
                      ? selectedStyle
                      : unselectedStyle,
                ),
              ],
            ),
            onPressed: () {
              if (_topMindsets.contains(mindset)) {
                setState(() {
                  _topMindsets.remove(mindset);
                  _selected--;
                });
              } else if (_topMindsets.length < 5) {
                setState(() {
                  _topMindsets.add(mindset);
                  _selected++;
                });
              }
            }),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenAspectRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('$_selected / 5'),
        elevation: 0.0,
        actions: <Widget>[
          CupertinoButton(
            child: Row(children: <Widget>[
              Text(
                'Next',
                style: Theme.of(context).textTheme.body1.copyWith(
                      color: _selected != 5 ? Colors.white24 : Colors.white,
                    ),
              ),
              Icon(
                Icons.chevron_right,
                color: _selected != 5 ? Colors.white24 : Colors.white,
              ),
            ]),
            onPressed: _selected == 5 && !_loading
                ? () {
                    widget.onSubmit(TopMindsetsData(_topMindsets));
                    setState(() {
                      _loading = true;
                    });
                  }
                : null,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: HumbleMe.welcomeGradient,
        ),
        child: widget.mindsets != null && !_loading
            ? Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(27.0, kInsetHeight, 27.0, 0.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: screenAspectRatio,
                      mainAxisSpacing: 20.0,
                      crossAxisSpacing: 10.0,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      children: _buildMindsetButtons(),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).viewInsets.top,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      height: kInsetHeight,
                      // decoration: BoxDecoration(
                      //   border: Border(
                      //     top: BorderSide(width: 1.0, color: Colors.white24),
                      //     bottom: BorderSide(width: 1.0, color: Colors.white24),
                      //   ),
                      // ),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 12.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            'What qualities do you value most in other people?',
                            style: Theme.of(context).textTheme.title.copyWith(
                                  fontSize: 20.0,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _buildLoading(),
      ),
    );
  }
}
