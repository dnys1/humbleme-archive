import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../auth/actions.dart';
import '../../auth/models.dart';
import '../../core/models.dart';
import '../../selectors.dart';

enum FriendshipStatus {
  loading,
  friendsAlready,
  youReceivedRequest,
  youDeniedRequest,
  requestSentToThem,
  theyDeniedRequest,
  noRequestsSent,
}

const double _condensedButtonWidth = 40.0;

class _FriendshipButtonView extends StatefulWidget {
  /// The status of the friendship. Used to determine which buttons
  final FriendshipStatus status;

  /// Whether or not the buttons should be condensed or expanded in their row.
  final bool condensed;

  /// Whether to build buttons for display on a profile or not.
  /// Defaults to `false`.
  final bool profileView;

  /// The function to call when there is only one choice;
  final Function onTap;

  /// The function to call when the request is accepted.
  final Function onTapAccept;

  /// The function to call when the request is denied.
  final Function onTapDeny;

  /// Padding for the widget which will wrap the row.
  final EdgeInsets padding;

  _FriendshipButtonView({
    Key key,
    @required this.status,
    @required this.condensed,
    this.profileView = false,
    this.onTap,
    this.onTapAccept,
    this.onTapDeny,
    this.padding,
  })  : assert(status != null),
        assert(condensed != null),
        super(key: key);

  @override
  _FriendshipButtonViewState createState() => _FriendshipButtonViewState();
}

class _FriendshipButtonViewState extends State<_FriendshipButtonView> {
  bool _requestLoading = false;
  bool _acceptLoading = false;
  bool _denyLoading = false;

  bool get condensed => widget.condensed;
  FriendshipStatus get status => widget.status;
  Function get onTap => widget.onTap;
  Function get onTapDeny => widget.onTapDeny;

  @override
  void didUpdateWidget(_FriendshipButtonView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Remove from temporary loading lists the values that cleared
    // First, calculate which requests that were loading last update
    // are now completed this update
    bool requestLoaded = oldWidget.status == FriendshipStatus.noRequestsSent &&
        widget.status == FriendshipStatus.requestSentToThem;
    bool acceptLoaded =
        oldWidget.status == FriendshipStatus.youReceivedRequest &&
            widget.status == FriendshipStatus.friendsAlready;
    bool denyLoaded = oldWidget.status == FriendshipStatus.youReceivedRequest &&
        widget.status == FriendshipStatus.youDeniedRequest;

    setState(() {
      // Then, remove from the loading lists the ones that already loaded.
      if (requestLoaded) {
        _requestLoading = false;
      }
      if (acceptLoaded) {
        _acceptLoading = false;
      }
      if (denyLoaded) {
        _denyLoading = false;
      }
    });
  }

  List<Widget> _buildButtons() {
    List<Widget> buttons = [];
    switch (widget.status) {
      case FriendshipStatus.loading:
        buttons.add(SizedBox(
          width: _condensedButtonWidth,
          child: CupertinoActivityIndicator(),
        ));
        break;
      case FriendshipStatus.friendsAlready:
        buttons.add(SizedBox(
          width: _condensedButtonWidth,
          child: FlatButton(
            padding: const EdgeInsets.all(3.0),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.0, color: Colors.green),
              borderRadius: BorderRadius.circular(6.0),
            ),
            color: Colors.green,
            disabledColor: Colors.green,
            highlightColor: Colors.white.withOpacity(0.8),
            child: Icon(Icons.check, color: Colors.white),
            onPressed: null,
          ),
        ));
        break;
      case FriendshipStatus.requestSentToThem:
      case FriendshipStatus.theyDeniedRequest:
        buttons.add(
          FlatButton(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.0, color: Colors.green),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              'Request Sent',
              style: TextStyle(
                color: Colors.green,
              ),
            ),
            onPressed: null,
          ),
        );
        break;
      case FriendshipStatus.youDeniedRequest:
        buttons.add(SizedBox(
          width: _condensedButtonWidth,
          child: FlatButton(
            padding: const EdgeInsets.all(3.0),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.0, color: Colors.green),
              borderRadius: BorderRadius.circular(6.0),
            ),
            highlightColor: Colors.green.withOpacity(0.9),
            child: _acceptLoading
                ? CupertinoActivityIndicator()
                : Icon(Icons.person_add, color: Colors.green),
            onPressed: () {
              widget.onTap();
              setState(() {
                _acceptLoading = true;
              });
            },
          ),
        ));
        break;
      case FriendshipStatus.youReceivedRequest:
        buttons.add(
          SizedBox(
            width: _condensedButtonWidth,
            child: FlatButton(
              padding: const EdgeInsets.all(3.0),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.0, color: Colors.red),
                borderRadius: BorderRadius.circular(6.0),
              ),
              highlightColor: Colors.red.withOpacity(0.9),
              child: _denyLoading
                  ? CupertinoActivityIndicator()
                  : Icon(Icons.close, color: Colors.red),
              onPressed: () {
                widget.onTapDeny();
                setState(() {
                  _denyLoading = true;
                });
              },
            ),
          ),
        );
        if (!condensed) {
          buttons.add(SizedBox(
            width: 20.0,
          ));
        }
        buttons.add(
          SizedBox(
            width: _condensedButtonWidth,
            child: FlatButton(
              padding: const EdgeInsets.all(3.0),
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.0, color: Colors.green),
                borderRadius: BorderRadius.circular(6.0),
              ),
              highlightColor: Colors.green.withOpacity(0.9),
              child: _acceptLoading
                  ? CupertinoActivityIndicator()
                  : Icon(Icons.check, color: Colors.green),
              onPressed: () {
                widget.onTapAccept();
                setState(() {
                  _acceptLoading = true;
                });
              },
            ),
          ),
        );
        break;
      case FriendshipStatus.noRequestsSent:
        buttons.add(SizedBox(
          width: _condensedButtonWidth,
          child: FlatButton(
            padding: const EdgeInsets.all(3.0),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.0, color: Colors.green),
              borderRadius: BorderRadius.circular(6.0),
            ),
            highlightColor: Colors.green.withOpacity(0.9),
            child: _requestLoading
                ? CupertinoActivityIndicator()
                : Icon(Icons.person_add, color: Colors.green),
            onPressed: () {
              widget.onTap();
              setState(() {
                _requestLoading = true;
              });
            },
          ),
        ));
    }
    return buttons;
  }

  List<Widget> _buildProfileButtons() {
    List<Widget> buttons = [];
    switch (status) {
      case FriendshipStatus.loading:
        return buttons
          ..add(FloatingActionButton(
            backgroundColor: Colors.grey,
            onPressed: null,
            child: CupertinoActivityIndicator(),
          ));
      case FriendshipStatus.friendsAlready:
        return buttons;
      case FriendshipStatus.requestSentToThem:
      case FriendshipStatus.theyDeniedRequest:
        return buttons
          ..add(Center(
            child: Text('Friend Request Sent',
                style: Theme
                    .of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.green)),
          ));
      case FriendshipStatus.youDeniedRequest:
        return buttons
          ..add(Center(
            child: FloatingActionButton(
              onPressed: _acceptLoading
                  ? null
                  : () {
                      widget.onTap();
                      setState(() {
                        _acceptLoading = true;
                      });
                    },
              child: _acceptLoading
                  ? CupertinoActivityIndicator()
                  : Icon(Icons.person_add),
            ),
          ));
      case FriendshipStatus.youReceivedRequest:
        return buttons
          ..addAll([
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: _requestLoading
                    ? null
                    : () {
                        widget.onTapDeny();
                        setState(() {
                          _denyLoading = true;
                        });
                      },
                child: _denyLoading
                    ? CupertinoActivityIndicator()
                    : Icon(Icons.close),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: _acceptLoading
                    ? null
                    : () {
                        widget.onTapAccept();
                        setState(() {
                          _acceptLoading = true;
                        });
                      },
                child: _acceptLoading
                    ? CupertinoActivityIndicator()
                    : Icon(Icons.check),
              ),
            ),
          ]);
      case FriendshipStatus.noRequestsSent:
      default:
        return buttons
          ..add(Center(
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: _requestLoading
                  ? null
                  : () {
                      widget.onTap();
                      setState(() {
                        _requestLoading = true;
                      });
                    },
              child: _requestLoading
                  ? CupertinoActivityIndicator()
                  : Icon(Icons.person_add),
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisAlignment:
            condensed ? MainAxisAlignment.end : MainAxisAlignment.center,
        mainAxisSize: condensed ? MainAxisSize.min : MainAxisSize.max,
        children: widget.profileView ? _buildProfileButtons() : _buildButtons(),
      ),
    );
  }
}

class FriendshipButton extends StatelessWidget {
  /// The id of the friend
  final String friendId;

  /// Whether or not the buttons should be condensed or expanded in their row.
  final bool condensed;

  /// Whether or not these buttons will be displayed on a public profile.
  /// Defaults to `false`.
  final bool profileView;

  /// The padding for the widget. Defaults to none.
  final EdgeInsets padding;

  FriendshipButton({
    @required this.friendId,
    @required this.condensed,
    this.profileView = false,
    this.padding = const EdgeInsets.all(0.0),
  });

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      converter: (Store<AppState> store) =>
          _ViewModel.fromStore(store, friendId),
      builder: (BuildContext context, _ViewModel vm) {
        return _FriendshipButtonView(
          status: vm.status,
          condensed: condensed,
          profileView: profileView,
          onTap: vm.onTap,
          onTapAccept: vm.onTapAccept,
          onTapDeny: vm.onTapDeny,
          padding: padding,
        );
      },
    );
  }
}

class _ViewModel {
  final Function onTap;
  final Function onTapAccept;
  final Function onTapDeny;
  final FriendshipStatus status;

  _ViewModel({
    @required this.onTap,
    @required this.onTapAccept,
    @required this.onTapDeny,
    @required this.status,
  });

  static _ViewModel fromStore(Store<AppState> store, String friendId) {
    List<FriendRequest> friendRequestsSent =
        getFriendRequestsSent(store.state.auth);
    List<FriendRequest> friendRequestsReceived =
        getFriendRequestsReceived(store.state.auth);
    List<PublicUser> friends = getFriends(store.state.auth);

    assert(friendRequestsReceived != null);
    assert(friendRequestsSent != null);
    assert(friends != null);

    FriendshipStatus status;
    if (friendRequestsReceived != null &&
        friendRequestsSent != null &&
        friends != null) {
      bool friendsAlready =
          friends.indexWhere((friend) => friend.id == friendId) != -1;
      bool requestSentToThem =
          friendRequestsSent.indexWhere((req) => req.toUser == friendId) != -1;
      bool theyDeniedRequest = requestSentToThem &&
          friendRequestsSent.firstWhere((req) => req.toUser == friendId).denied;
      bool youReceivedRequest = friendRequestsReceived
              .indexWhere((req) => req.fromUser == friendId) !=
          -1;
      bool youDeniedRequest = youReceivedRequest &&
          friendRequestsReceived
              .firstWhere((req) => req.fromUser == friendId)
              .denied;
      if (friendsAlready) {
        status = FriendshipStatus.friendsAlready;
      } else if (requestSentToThem) {
        if (theyDeniedRequest) {
          status = FriendshipStatus.theyDeniedRequest;
        } else {
          status = FriendshipStatus.requestSentToThem;
        }
      } else if (youReceivedRequest) {
        if (youDeniedRequest) {
          status = FriendshipStatus.youDeniedRequest;
        } else {
          status = FriendshipStatus.youReceivedRequest;
        }
      } else {
        status = FriendshipStatus.noRequestsSent;
      }
    }

    Function onTap;
    Function onTapAccept;
    Function onTapDeny;
    switch (status) {
      case FriendshipStatus.loading:
        onTap = onTapAccept = onTapDeny = null;
        break;
      case FriendshipStatus.friendsAlready:
        onTap = onTapAccept = onTapDeny = null;
        break;
      case FriendshipStatus.noRequestsSent:
        onTap = () => store.dispatch(AddFriendAction(friendId));
        onTapAccept = onTapDeny = null;
        break;
      case FriendshipStatus.requestSentToThem:
      case FriendshipStatus.theyDeniedRequest:
        onTap = onTapAccept = onTapDeny = null;
        break;
      case FriendshipStatus.youReceivedRequest:
        FriendRequest request = friendRequestsReceived
            .firstWhere((req) => req.fromUser == friendId);
        onTap = null;
        onTapAccept = () => store.dispatch(AcceptFriendAction(request.id));
        onTapDeny = () => store.dispatch(DenyFriendAction(request.id));
        break;
      case FriendshipStatus.youDeniedRequest:
        FriendRequest request = friendRequestsReceived
            .firstWhere((req) => req.fromUser == friendId);
        onTap = () => store.dispatch(AcceptFriendAction(request.id));
        onTapAccept = onTapDeny = null;
        break;
    }

    return _ViewModel(
      onTap: onTap,
      onTapAccept: onTapAccept,
      onTapDeny: onTapDeny,
      status: status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ViewModel &&
          runtimeType == other.runtimeType &&
          status == other.status;

  @override
  int get hashCode => status.hashCode;
}
