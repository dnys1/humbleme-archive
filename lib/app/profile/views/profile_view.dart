import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/models.dart';
import '../../../routes.dart';
import '../../../services/platform/permissions.dart';
import '../../../theme.dart';
import '../../search/containers/search.dart';
import '../../widgets/friendship_button.dart';
import '../../widgets/platform_loading_indicator.dart';
import '../../widgets/profile_circle_avatar.dart';
import '../containers/profile.dart';
import '../containers/profile_edit.dart';
import 'common.dart';
import 'mindset_popup.dart';
import 'profile_background.dart';
import 'profile_section.dart';

enum ProfileTab { overview, scores, friends }

const double _kFlexibleSpaceMaxHeight = 300.0;
const double _kProfileFontSize = 23.0;
const double _avatarSize = 40.0;

class ProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool imageUploading;
  final String displayName;
  final String photoUrl;
  final User user;
  final PublicUser publicUser;
  final Function pickProfilePicture;
  final List<PublicUser> friends;
  final List<Survey> surveysGiven;
  final List<Survey> surveysReceived;
  final double score;
  final Image uploadImage;
  final Function setScaffoldKey;
  final List<Mindset> mindsets;
  final bool errorLoadingProfile;
  final bool isPublicProfile;

  ProfileView({
    Key key,
    @required this.scaffoldKey,
    @required this.imageUploading,
    @required this.displayName,
    @required this.photoUrl,
    @required this.user,
    this.publicUser,
    @required this.pickProfilePicture,
    @required this.friends,
    @required this.score,
    @required this.surveysGiven,
    @required this.surveysReceived,
    @required this.uploadImage,
    @required this.setScaffoldKey,
    @required this.mindsets,
    @required this.errorLoadingProfile,
    @required this.isPublicProfile,
  })  : assert(scaffoldKey != null),
        super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  final RouteObserver<PageRoute> routeObserver =
      Routes.appObservers[ProfileContainer.tab];

  NetworkImage _profilePic;
  bool _imageLoading = true;
  bool _loadingModal = false;
  double _aspectRatio;
  Image _uploadImage;
  bool _imageUploading = false;

  @override
  didUpdateWidget(ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If user uploaded image and it is done uploading
    if (!isPublicProfile) {
      if (_imageUploading && !widget.imageUploading) {
        if (widget.user.photoUrl != oldWidget.user.photoUrl) {
          _profilePic = Image
              .network(
                widget.user.photoUrl,
                key: ValueKey<String>(userPhotoUrl),
              )
              .image
            ..resolve(ImageConfiguration()).addListener((image, test) {
              if (mounted) {
                setState(() {
                  _imageUploading = false;
                });
              }
            });
        }
      }
    } else {
      if (oldWidget.publicUser == null && widget.publicUser != null) {
        if (userPhotoUrl != null) {
          _profilePic = Image
              .network(
                userPhotoUrl,
                key: ValueKey<String>(userPhotoUrl),
              )
              .image
            ..resolve(ImageConfiguration()).addListener((image, test) {
              if (mounted) {
                setState(() {
                  _imageLoading = false;
                });
              }
            });
        } else {
          if (mounted) {
            setState(() {
              _imageLoading = false;
            });
          }
        }
      }
    }
  }

  bool get isPublicProfile => widget.isPublicProfile;
  PublicUser get profile => isPublicProfile ? widget.publicUser : widget.user;
  bool get userHasFriends => profile.friends.length != 0;
  Mindset getMindset(String mindsetName) =>
      widget.mindsets.firstWhere((m) => m.name == mindsetName, orElse: () {
        print('NO MINDSET: $mindsetName');
        return null;
      });
  bool get userHasScore => profile.score != null;
  double get userScore => profile.score ?? 0.0;
  Gender get userGender =>
      isPublicProfile ? profile.gender : widget.user.gender;
  String get userPhotoUrl => profile.photoUrl;

  List<String> get userProfilePictures => profile.profilePictures;

  bool get isLoadingProfile => isPublicProfile && profile == null;
  bool get isLoadingScores => profile?.peerScores == null;
  bool get isLoadingFriends => profile?.friends == null;

  bool get isPrivateProfile =>
      isPublicProfile && profile.isPrivateProfile && !areFriends;
  bool get areFriends =>
      widget.user.friends.map((friend) => friend.id).contains(profile.id);

  Widget getCharacterForScore(double score, BuildContext context,
      {double size = _avatarSize}) {
    String genderCode = userGender == Gender.BOY ? 'm' : 'f';
    switch (userGender) {
      case Gender.BOY:
      case Gender.GIRL:
        if (score == null || score == 0) {
          return Text(
            'N/A',
            style: Theme.of(context).textTheme.caption,
          );
        }
        if (score > 0) {
          if (score <= 1) {
            return Image.asset(
              'images/$genderCode-caveman.png',
              height: size,
              width: size,
            );
          } else if (score <= 2) {
            return Image.asset(
              'images/$genderCode-child.png',
              height: size,
              width: size,
            );
          } else if (score <= 3) {
            return Image.asset(
              'images/$genderCode-average.png',
              height: size,
              width: size,
            );
          } else if (score <= 4) {
            return Image.asset(
              'images/$genderCode-professional.png',
              height: size,
              width: size,
            );
          } else if (score <= 5) {
            return Image.asset(
              'images/$genderCode-superman.png',
              height: size,
              width: size,
            );
          } else {
            throw 'Score cannot be greater than 5!';
          }
        } else {
          throw 'Score cannot be less than 0!';
        }
        break;
      case Gender.NA:
      default:
        if (score < 0) {
          throw 'Score cannot be less than 0!';
        } else if (score > 5) {
          throw 'Score cannot be greater than 5!';
        }
        if (score == null || score == 0) {
          return Text(
            'N/A',
            style: Theme.of(context).textTheme.caption,
          );
        }
        Text displayScore = Text(score.toStringAsPrecision(1));
        return displayScore;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Will be called when profile edit view is popped off stack
  @override
  void didPopNext() {
    print('DID POP NEXT');
    widget.setScaffoldKey(widget.scaffoldKey);
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!isLoadingProfile) {
      if (userPhotoUrl != null) {
        _profilePic = Image
            .network(
              userPhotoUrl,
              key: ValueKey<String>(userPhotoUrl),
            )
            .image
          ..resolve(ImageConfiguration()).addListener((image, test) {
            if (mounted) {
              setState(() {
                _imageLoading = false;
              });
            }
          });
      } else {
        if (mounted) {
          setState(() {
            _imageLoading = false;
          });
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // User has returned from selecting image from library
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {
          _loadingModal = false;
        });
      }
    }
  }

  void _pickProfilePicture() async {
    if (mounted) {
      setState(() {
        _loadingModal = true;
      });
    }
    PermissionState currentState;
    if (kIsAndroid) {
      currentState =
          await Permissions.getPermissionState(PermissionType.storage);
      while (currentState != PermissionState.denied &&
          currentState != PermissionState.granted) {
        currentState =
            await Permissions.requestPermission(PermissionType.storage);
      }
    }
    if (!kIsAndroid || currentState == PermissionState.granted) {
      ImageSource selection = ImageSource.gallery;
      if (selection != null) {
        File image = await ImagePicker.pickImage(
          source: selection,
          maxHeight: 1000.0,
          maxWidth: 1000.0,
        );
        if (image != null) {
          Image
              .file(image)
              .image
              .resolve(ImageConfiguration())
              .addListener((ImageInfo info, bool _) {
            var width = info.image.width;
            var height = info.image.height;
            if (mounted) {
              setState(() {
                _aspectRatio = width / height;
                _uploadImage = Image.file(
                  image,
                );
                _imageUploading = true;
              });
            }
          });
          widget.pickProfilePicture(image);
        }
      }
    }
  }

  Widget _buildTab({int number, IconData icon, String text}) {
    return DefaultTextStyle(
      style: Theme.of(context).primaryTextTheme.body1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 3.0),
                  child: Icon(icon),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: FittedBox(child: Text(text)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabView({ProfileTab tab, BuildContext context}) {
    switch (tab) {
      case ProfileTab.overview:
        return isLoadingProfile
            ? _buildLoadingTab()
            : isPrivateProfile
                ? _buildPrivateProfileTab(context)
                : _buildBio(context);
      case ProfileTab.scores:
        return isPrivateProfile
            ? _buildPrivateProfileTab(context)
            : isLoadingScores ? _buildLoadingTab() : _buildScoresList(context);
      case ProfileTab.friends:
      default:
        return isPrivateProfile
            ? _buildPrivateProfileTab(context)
            : isLoadingFriends ? _buildLoadingTab() : _buildFriends(context);
    }
  }

  SliverList _buildPrivateProfileTab(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        <Widget>[
          SizedBox(height: 20.0),
          Icon(Icons.lock, size: 50.0),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'This profile is private\n\nAdd them as a friend to see their info',
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            height: 100.0,
            child: FriendshipButton(
              friendId: profile.id,
              condensed: false,
              profileView: true,
            ),
          ),
        ],
      ),
    );
  }

  SliverFillRemaining _buildLoadingTab() {
    return SliverFillRemaining(
      child: PlatformLoadingIndicator(),
    );
  }

  SliverList _buildBio(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        ProfileSection(
          title: 'Bio',
          body: profile.bio ??
              (isPublicProfile ? 'No bio' : 'Add a bio in the \'Edit\' menu'),
        ),
        profile.age == null
            ? Container()
            : ProfileSection(
                title: 'Age',
                body: profile.age == null
                    ? 'Add your age in the \'Edit\' menu'
                    : profile.age.toString(),
              ),
        isPublicProfile
            ? Container(
                height: 100.0,
                child: FriendshipButton(
                  friendId: profile.id,
                  condensed: false,
                  profileView: true,
                ),
              )
            : Container(),
      ]),
    );
  }

  RenderObjectWidget _buildFriends(BuildContext context) {
    return userHasFriends
        ? SliverFixedExtentList(
            itemExtent: 48.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                var friend = profile.friends[index];
                String youTag = '';
                // Show a little flair when seeing yourself in a friend's friend list
                if (isPublicProfile && friend.id == widget.user.id) {
                  youTag = ' (You)';
                }
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: ProfileCircleAvatar(
                      key: ValueKey<String>(profile.id),
                      photoUrl: friend.photoUrl,
                    ),
                    title: Text('${friend.displayName}$youTag'),
                  ),
                );
              },
              childCount: profile.friends.length,
            ),
          )
        : SliverList(
            delegate: SliverChildListDelegate(
              [
                Material(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(
                      'No friends yet!',
                      style: Theme
                          .of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                isPublicProfile
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 40.0,
                        ),
                        child: kIsAndroid
                            ? RaisedButton(
                                child: Text(
                                  'Add Friends',
                                  style: Theme.of(context).textTheme.button,
                                ),
                                onPressed: () => Navigator.of(context).push(
                                      Routes.routeBuilderFromWidget(
                                          Routes.search,
                                          (BuildContext context) =>
                                              SearchContainer()),
                                    ),
                              )
                            : RaisedButton(
                                color: HumbleMe.blue,
                                highlightColor: Colors.white.withOpacity(0.7),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.white,
                                    width: 0.0,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                child: Text(
                                  'Add Friends',
                                  style: Theme.of(context).textTheme.button,
                                ),
                                onPressed: () => Navigator.of(context).push(
                                      Routes.routeBuilderFromWidget(
                                          Routes.search,
                                          (BuildContext context) =>
                                              SearchContainer()),
                                    ),
                              ),
                      )
              ],
            ),
          );
  }

  Widget _buildScoreBar(double score, BuildContext context,
      {bool listTile = false}) {
    // We're building a makeshift mask using an image at a fixed size
    // We want to scale down the image but keep the same aspect ratio, while
    // knowing the height/width so we can display the Container correctly.
    // The original width / height
    double _scoreBarImageWidth = 684.0;
    double _scoreBarImageHeight = 31.0;
    // Necessary correction for border
    double _scoreBarBorderOverflow = 1.0;
    // Padding to give the score bar
    double _scoreBarHorizontalPadding = 18.0;

    double width, scaleFactor, height;

    if (!listTile) {
      width =
          MediaQuery.of(context).size.width - 2 * _scoreBarHorizontalPadding;
      scaleFactor = width / _scoreBarImageWidth;
      height = _scoreBarImageHeight * scaleFactor - _scoreBarBorderOverflow;
    } else {
      height = 4.0;
      scaleFactor = height / _scoreBarImageHeight;
      width = _scoreBarImageWidth * scaleFactor;
    }

    if (listTile && (score == 0.0 || score == null)) {
      return getCharacterForScore(score, context);
    }

    return Padding(
      padding: listTile
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(vertical: 20.0),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Positioned(
              left: _scoreBarBorderOverflow,
              child: SizedBox(
                height: height,
                width: width,
                child: LinearProgressIndicator(
                  value: score == null ? 0.0 : score / 5,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      getScorebarColorForScore(score)),
                ),
              ),
            ),
            Image.asset(
              'images/score_bar.png',
              height: _scoreBarImageHeight * scaleFactor,
              width: _scoreBarImageWidth * scaleFactor,
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildScoresList(BuildContext context) {
    var scoreObj = isPublicProfile
        ? profile.peerScores.first
        : widget.user.peerScores.first;
    var mindsetScores = scoreObj.mindsetWeighted;
    Map<Mindsets, bool> privacySettings = profile.peerScores[0].privacySettings;

    // Get only the mindsets the user has elected to show
    var mindsets = isPublicProfile
        ? widget.mindsets
            .where((mindset) => !(privacySettings[mindset] ?? false))
        : widget.mindsets;
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  'Surveys given: ${profile.surveysGiven}',
                  style: Theme
                      .of(context)
                      .textTheme
                      .body1
                      .copyWith(fontSize: 15.0),
                ),
                Text(
                  'Surveys received: ${profile.surveysReceived}',
                  style: Theme
                      .of(context)
                      .textTheme
                      .body1
                      .copyWith(fontSize: 15.0),
                ),
              ],
            ),
          ),
          Divider(),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 8.0),
              child: userHasScore
                  ? getCharacterForScore(
                      userScore,
                      context,
                      size: 80.0,
                    )
                  : Text(
                      'No Score Yet!',
                      style: Theme.of(context).textTheme.display1.copyWith(
                            color: Colors.grey[600],
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
            ),
          ),
          !isPublicProfile && profile.surveysReceived < 5
              ? Text(
                  'In order to get your score, 5 friends must answer the survey about you.',
                  style: Theme
                      .of(context)
                      .textTheme
                      .caption
                      .copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                )
              : Container(),
          _buildScoreBar(profile.score ?? 0.0, context),
        ]
          ..addAll(mindsets.map((mindset) {
            var mindsetName = mindset.getName();
            var assetName = mindsetName.toLowerCase();
            var score = mindsetScores[mindset.name];
            return Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.all(0.0),
                leading: Image.asset(
                  'images/mindsets/$assetName.png',
                  height: _avatarSize * 0.9,
                  width: _avatarSize * 0.9,
                  fit: BoxFit.contain,
                ),
                title: Text(mindsetName),
                trailing: _buildScoreBar(score, context, listTile: true),
                onTap: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MindsetPopup(
                        key: ValueKey<Mindsets>(mindset.name),
                        mindset: mindset,
                        isPublicProfile: isPublicProfile,
                        selfScores: profile.selfScores,
                        peerScores: profile.peerScores,
                      );
                    }),
              ),
            );
          }).toList())
          ..add(mindsets.length == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      'This user has chosen to not show any score breakdowns.',
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Container()),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    // Build it first so we can get its dimensions
    var tabBar = TabBar(
      isScrollable: true,
      indicatorColor: Colors.teal,
      tabs: [
        _buildTab(
          icon: Icons.assignment_ind,
          text: 'Overview',
        ),
        _buildTab(
          icon: IOSIcons.spedometer_light,
          text: 'Scores',
        ),
        _buildTab(
          icon: Icons.person_outline,
          number: 10,
          text: 'Friends',
        )
      ],
    );
    var totalTabBarHeight = tabBar.preferredSize.height + 20.0;
    var totalTabBarHeightWithText = totalTabBarHeight + _kProfileFontSize;
    return DefaultTabController(
      length: ProfileTab.values.length,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              child: SliverAppBar(
                automaticallyImplyLeading: isPublicProfile,
                pinned: true,
                elevation: 0.0,
                backgroundColor: HumbleMe.teal,
                forceElevated: innerBoxIsScrolled,
                expandedHeight: _kFlexibleSpaceMaxHeight,
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileBackground(
                    loadingModal: _loadingModal,
                    imageUploading: _imageUploading,
                    uploadImage: _uploadImage ?? widget.uploadImage,
                    aspectRatio: _aspectRatio,
                    pickProfilePicture:
                        isPublicProfile ? null : _pickProfilePicture,
                    displayName: profile?.displayName,
                    imageLoading: _imageLoading,
                    profilePic: _profilePic,
                    profilePictures:
                        isLoadingProfile ? [] : userProfilePictures,
                    minHeight: totalTabBarHeightWithText,
                    loadEditScreen: isPublicProfile
                        ? null
                        : () {
                            Navigator
                                .of(context)
                                .push(Routes.routeBuilderFromWidget(
                                    Routes.editProfile,
                                    (context) => ProfileEditContainer()))
                                .then((profileChanged) {
                              // Snackbar only availble with Scaffold
                              if (kIsAndroid) {
                                if (profileChanged ?? false) {
                                  widget.scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content:
                                        Text('Profile successfully updated'),
                                  ));
                                } else {
                                  widget.scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text('Profile not changed'),
                                  ));
                                }
                              }
                            });
                          },
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size(
                      tabBar.preferredSize.width, totalTabBarHeightWithText),
                  child: Stack(
                    overflow: Overflow.visible,
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      tabBar,
                      // Position the displayName 20 pixels above the top of the
                      // tab bar so it will persist when scrolling.
                      Positioned(
                        bottom: totalTabBarHeight,
                        left: 0.0,
                        right: 0.0,
                        child: Center(
                          child: Text(
                            profile?.displayName ?? '',
                            style: Theme
                                .of(context)
                                .primaryTextTheme
                                .body1
                                .copyWith(
                                  fontSize: _kProfileFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          children: ProfileTab.values.map((tab) {
            return SafeArea(
              top: false,
              bottom: false,
              child: Builder(
                builder: (BuildContext context) {
                  return CustomScrollView(
                    key: PageStorageKey<ProfileTab>(tab),
                    slivers: <Widget>[
                      SliverOverlapInjector(
                        handle: NestedScrollView
                            .sliverOverlapAbsorberHandleFor(context),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(18.0),
                        sliver: _buildTabView(tab: tab, context: context),
                      ),
                    ],
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid
        ? Theme(
            data: HumbleMe.appTheme,
            child: Builder(builder: (BuildContext context) {
              return Scaffold(
                key: widget.scaffoldKey,
                body: _buildScaffold(context),
              );
            }),
          )
        : CupertinoPageScaffold(
            key: widget.scaffoldKey,
            child: _buildScaffold(context),
          );
  }
}
