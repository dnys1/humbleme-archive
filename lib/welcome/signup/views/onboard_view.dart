import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../auth/models/public_user.dart';
import '../../../theme.dart';
import 'onboard_button.dart';
import 'onboard_indicator.dart';

final double kProfileExtent = 70.0;
final double kContainerHeight = 300.0;

class OnboardView extends StatefulWidget {
  OnboardView({
    Key key,
    @required this.onCompleteOnboarding,
    @required this.scaffoldKey,
    @required this.friendsFromContacts,
    @required this.addFriend,
    @required this.contactsPermissionEnabled,
  }) : super(key: key);

  final Function onCompleteOnboarding;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<PublicUser> friendsFromContacts;
  final Function(String) addFriend;
  final bool contactsPermissionEnabled;

  @override
  _OnboardViewState createState() => _OnboardViewState();
}

class _OnboardViewState extends State<OnboardView> {
  final PageController _pageController = PageController();
  bool lastPage = false;

  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  List<String> _requestsSentLoading = [];

  Widget _buildSmallBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
      child: Container(
          width: 130.0,
          height: 40.0,
          color: Colors.white,
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 20.0,
                height: 20.0,
                color: HumbleMe.primaryTeal,
              )
            ],
          )),
    );
  }

  Widget _buildLargeBox() {
    return Container(
        width: 250.0,
        height: 65.0,
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 25.0,
              height: 325.0,
              color: HumbleMe.primaryTeal,
            )
          ],
        ));
  }

  Widget _buildIconGroup({Icon icon}) {
    return Expanded(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          width: 140.0,
          height: 150.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[icon, icon],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[icon, icon],
              ),
            ],
          )),
    );
  }

  Widget _buildCheckBox({String type}) {
    return Container(
      width: 250.0,
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: type == 'close'
                ? Icon(Icons.close, size: 45.0)
                : Icon(Icons.check, size: 45.0),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Image.asset('images/line.png', fit: BoxFit.fitHeight),
          ))
        ],
      ),
    );
  }

  List<Widget> _buildPages() {
    List<Widget> pages = <Widget>[];

    // Welcome, Let's get Started!
    final welcome = Container(
      padding: const EdgeInsets.only(bottom: 110.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Welcome!', style: TextStyle(fontSize: 50.0)),
          Text("Let's get started.", style: TextStyle(fontSize: 32.0))
        ],
      ),
    );
    pages.add(welcome);

    int page = 1;

    // Step 1: Find out what you value!
    // if (widget.contactsPermissionEnabled) {
    //   final step1 = Container(
    //     padding: const EdgeInsets.only(bottom: 110.0),
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: <Widget>[
    //         Text((page++).toString(), style: TextStyle(fontSize: 50.0)),
    //         Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 20.0),
    //           child: Text(
    //             'Add friends you may know',
    //             style: TextStyle(fontSize: 20.0),
    //           ),
    //         ),
    //         widget.friendsFromContacts == null
    //             ? Padding(
    //                 padding: const EdgeInsets.all(10.0),
    //                 child: Theme(
    //                   data: ThemeData(
    //                     accentColor: Colors.white,
    //                   ),
    //                   child: Container(
    //                     child: SizedBox(
    //                       child: CircularProgressIndicator(),
    //                     ),
    //                   ),
    //                 ),
    //               )
    //             : Expanded(
    //                 child: widget.friendsFromContacts.isEmpty
    //                     ? Center(
    //                         child: Text(
    //                           'No friends found from contacts :(',
    //                           style: TextStyle(fontSize: 18.0),
    //                           textAlign: TextAlign.center,
    //                           softWrap: true,
    //                         ),
    //                       )
    //                     : ListView(
    //                         padding: const EdgeInsets.all(20.0),
    //                         itemExtent: 70.0,
    //                         children: widget.friendsFromContacts.map((profile) {
    //                           var button;
    //                           if (_requestsSentLoading.contains(profile.id)) {
    //                             button = FlatButton(
    //                               padding: const EdgeInsets.symmetric(
    //                                   horizontal: 10.0),
    //                               shape: RoundedRectangleBorder(
    //                                 side: BorderSide(
    //                                     width: 1.0, color: Colors.white),
    //                                 borderRadius:
    //                                     BorderRadius.circular(6.0),
    //                               ),
    //                               child: Text(
    //                                 'Request Sent',
    //                                 style: TextStyle(
    //                                   color: Colors.white,
    //                                 ),
    //                               ),
    //                               onPressed: null,
    //                             );
    //                           } else {
    //                             button = SizedBox(
    //                               width: 40.0,
    //                               child: FlatButton(
    //                                 padding: const EdgeInsets.all(3.0),
    //                                 shape: RoundedRectangleBorder(
    //                                   side: BorderSide(
    //                                       width: 1.0, color: Colors.white),
    //                                   borderRadius:
    //                                       BorderRadius.circular(6.0),
    //                                 ),
    //                                 highlightColor:
    //                                     Colors.green.withOpacity(0.9),
    //                                 child: _requestsSentLoading
    //                                         .contains(profile.id)
    //                                     ? PlatformLoadingIndicator()
    //                                     : Icon(Icons.person_add,
    //                                         color: Colors.white),
    //                                 onPressed: () {
    //                                   widget.addFriend(profile.id);
    //                                   setState(() {
    //                                     _requestsSentLoading.add(profile.id);
    //                                   });
    //                                 },
    //                               ),
    //                             );
    //                           }
    //                           return ListTile(
    //                             leading: CircleAvatar(
    //                               backgroundImage:
    //                                   profile.profilePictures?.first == null
    //                                       ? kDefaultProfile.image
    //                                       : NetworkImage(
    //                                           profile.profilePictures.first),
    //                             ),
    //                             title: Text(
    //                               profile.displayName,
    //                               style: Theme
    //                                   .of(context)
    //                                   .textTheme
    //                                   .body1
    //                                   .copyWith(
    //                                     fontSize: 20.0,
    //                                   ),
    //                             ),
    //                             trailing: button,
    //                           );
    //                         }).toList(),
    //                       ),
    //               ),
    //         widget.friendsFromContacts == null
    //             ? Expanded(
    //                 child: Container(),
    //               )
    //             : Container(),
    //       ],
    //     ),
    //   );
    //   pages.add(step1);
    // }

    // Step 2: Fill out anonymous surveys of your friends
    final step2 = Container(
      padding: const EdgeInsets.only(bottom: 110.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text((page++).toString(), style: TextStyle(fontSize: 50.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _buildSmallBox(),
                    _buildSmallBox(),
                    _buildSmallBox(),
                  ],
                ),
              ),
              _buildIconGroup(
                  icon: Icon(
                Icons.person,
                size: 70.0,
              )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
                'Fill out anonymous surveys of your friends, and get feedback from them',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0)),
          )
        ],
      ),
    );

    // Step 3: Get your results
    final step3 = Container(
      padding: const EdgeInsets.only(bottom: 110.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text((page++).toString(), style: TextStyle(fontSize: 50.0)),
          _buildCheckBox(type: 'check'),
          _buildCheckBox(type: 'close'),
          _buildCheckBox(type: 'close'),
          Text('Get your results!', style: TextStyle(fontSize: 20.0))
        ],
      ),
    );

    pages.add(step2);
    pages.add(step3);
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = _buildPages();
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: AppBar(backgroundColor: HumbleMe.primaryTeal, elevation: 0.0),
      body: Container(
        decoration: BoxDecoration(
          gradient: HumbleMe.welcomeGradient,
        ),
        child: Stack(
          children: <Widget>[
            PageView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _pageController,
              children: pages,
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    OnboardButton(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPressed: () => widget.onCompleteOnboarding(),
                    ),
                    DotsIndicator(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageSelected: (int page) {
                        _pageController.animateToPage(page,
                            duration: _kDuration, curve: _kCurve);
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
