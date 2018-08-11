import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../auth/models/public_user.dart';
import '../../../auth/models/user.dart';
import '../../../routes.dart';
import '../../../theme.dart';
import '../../common.dart';
import '../../profile/containers/profile.dart';
import '../../widgets/friendship_button.dart';
import '../../widgets/platform_loading_indicator.dart';
import '../../widgets/profile_circle_avatar.dart';
import '../containers/search_bar.dart';

class SearchView extends StatefulWidget {
  final User user;
  final String searchText;
  final List<PublicUser> searchResults;
  final bool isLoadingUserData;

  SearchView({
    Key key,
    @required this.user,
    @required this.searchText,
    @required this.searchResults,
    @required this.isLoadingUserData,
  }) : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  TextEditingController _searchTextController;
  FocusNode _searchFocusNode = FocusNode();

  bool _resultsLoading = false;
  List<bool> _imageLoading = [];

  Animation _animation;
  AnimationController _animationController;

  @override
  initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    _searchFocusNode.addListener(() {
      if (!_animationController.isAnimating) {
        _animationController.forward();
      }
    });
    _searchTextController = TextEditingController
        .fromValue(TextEditingValue(text: widget.searchText));
  }

  @override
  void didUpdateWidget(SearchView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.searchResults != widget.searchResults) {
      setState(() {
        _resultsLoading = false;
        _imageLoading = List<bool>.filled(widget.searchResults.length, true);
      });
    }
  }

  Widget _buildLoading() {
    return PlatformLoadingIndicator();
  }

  /// Pass the BuildContext so that Theme.of(context) returns the correct theme
  /// i.e. for Android, the Theme from the Theme widget
  Widget _buildUserList(BuildContext context) {
    if (_resultsLoading || widget.isLoadingUserData) {
      return _buildLoading();
    } else if (widget.searchResults == null || widget.searchResults.isEmpty) {
      return Center(
        child: Text(
          'No results',
          style: Theme.of(context).textTheme.body1,
        ),
      );
    } else {
      return ListView.builder(
          itemCount: widget.searchResults.length,
          itemBuilder: (BuildContext context, int index) {
            var profile = widget.searchResults[index];

            // Return the profile tile with appropriate buttons
            return Material(
              color: Colors.transparent,
              child: ListTile(
                leading: ProfileCircleAvatar(
                  key: ValueKey<String>(profile.id),
                  photoUrl: profile.photoUrl,
                ),
                title: Row(
                  children: <Widget>[
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          profile.displayName,
                          style: Theme.of(context).textTheme.body1.copyWith(
                                fontSize: 20.0,
                              ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
                trailing: FriendshipButton(
                  friendId: profile.id,
                  condensed: true,
                ),
                onTap: () => Navigator.of(context).push(
                      Routes.routeBuilderFromWidget(
                        'profile/${profile.id}',
                        (context) => ProfileContainer(
                              publicUser: profile,
                            ),
                      ),
                    ),
              ),
            );
          });
    }
  }

  Widget _buildAndroid() {
    return Theme(
      data: HumbleMe.appTheme,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: (widget.isLoadingUserData
                  ? []
                  : <Widget>[
                      SearchBarContainer(
                        controller: _searchTextController,
                        focusNode: _searchFocusNode,
                        onCancel: () {
                          _searchTextController.clear();
                          _searchFocusNode.unfocus();
                          _animationController.reverse();
                        },
                        onClear: () {
                          _searchTextController.clear();
                        },
                        onSubmit: () => setState(() {
                              _resultsLoading = true;
                            }),
                      ),
                      SizedBox(height: 20.0)
                    ])
                ..add(Expanded(
                  child: GestureDetector(
                    onTapUp: (TapUpDetails _) {
                      _searchFocusNode.unfocus();
                    },
                    child: _buildUserList(context),
                  ),
                )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildiOS() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        actionsForegroundColor: CupertinoColors.white,
        backgroundColor: HumbleMe.primaryTeal,
        leading: buildiOSNavigationButton(
            iconData: Icons.close,
            left: true,
            onPressed: () {
              Navigator.of(context).pop();
            }),
        middle: SearchBarContainer(
          controller: _searchTextController,
          focusNode: _searchFocusNode,
          animation: _animation,
          onCancel: () {
            _searchTextController.clear();
            _searchFocusNode.unfocus();
            _animationController.reverse();
          },
          onClear: () {
            _searchTextController.clear();
          },
          onSubmit: () => setState(() {
                _resultsLoading = true;
              }),
        ),
      ),
      child: GestureDetector(
        onTapUp: (TapUpDetails _) {
          _searchFocusNode.unfocus();
          if (_searchTextController.text == '') {
            _animationController.reverse();
          }
        },
        child: _buildUserList(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid ? _buildAndroid() : _buildiOS();
  }
}
