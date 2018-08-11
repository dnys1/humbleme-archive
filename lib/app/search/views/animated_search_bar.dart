import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedSearchBar extends AnimatedWidget {
  AnimatedSearchBar({
    Key key,
    @required Animation<double> animation,
    @required this.controller,
    @required this.focusNode,
    @required this.searchText,
    this.onCancel,
    this.onClear,
    this.onSubmit,
    this.onUpdate,
  })  : assert(controller != null),
        assert(focusNode != null),
        super(key: key, listenable: animation);

  final TextEditingController controller;
  final FocusNode focusNode;
  final Function onCancel;
  final Function onClear;
  final Function(String) onUpdate;
  final Function(String) onSubmit;
  final String searchText;

  // static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final GlobalKey<FormFieldState<String>> _searchKey =
      GlobalKey<FormFieldState<String>>();

  static final _opacityTween = Tween(begin: 1.0, end: 0.0);
  static final _paddingTween = Tween(begin: 0.0, end: 60.0);
  static final _kFontSize = 13.0;

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 0.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                border:
                    Border.all(width: 0.0, color: CupertinoColors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 4.0, 1.0),
                        child: Icon(
                          CupertinoIcons.search,
                          color: CupertinoColors.inactiveGray,
                          size: _kFontSize + 2.0,
                        ),
                      ),
                      Text(
                        'Search',
                        style: TextStyle(
                          inherit: false,
                          color: CupertinoColors.inactiveGray
                              .withOpacity(_opacityTween.evaluate(animation)),
                          fontSize: _kFontSize,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: EditableText(
                            key: _searchKey,
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: onUpdate,
                            onSubmitted: onSubmit,
                            style: TextStyle(
                              color: CupertinoColors.black,
                              inherit: false,
                              fontSize: _kFontSize,
                            ),
                            cursorColor: CupertinoColors.black,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        minSize: 10.0,
                        padding: const EdgeInsets.all(1.0),
                        borderRadius: BorderRadius.circular(30.0),
                        color: CupertinoColors.inactiveGray.withOpacity(
                          1.0 - _opacityTween.evaluate(animation),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 8.0,
                          color: CupertinoColors.white,
                        ),
                        onPressed: () {
                          if (animation.isDismissed)
                            return;
                          else
                            onClear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: _paddingTween.evaluate(animation),
            child: CupertinoButton(
              padding: const EdgeInsets.only(left: 8.0),
              onPressed: onCancel,
              child: Text(
                'Cancel',
                softWrap: false,
                style: TextStyle(
                  inherit: false,
                  color: CupertinoColors.white,
                  fontSize: _kFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
