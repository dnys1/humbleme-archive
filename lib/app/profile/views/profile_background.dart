import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme.dart';
import 'profile_picture_view.dart';

const double _kFlexibleSpaceMaxHeight = 300.0;
const double _kProfileRadius = 80.0;

class ProfileBackground extends StatelessWidget {
  final bool imageLoading;
  final bool imageUploading;
  final bool loadingModal;
  final Function pickProfilePicture;
  final String displayName;
  final Image uploadImage;
  final double aspectRatio;
  final NetworkImage profilePic;
  final double minHeight;
  final Function loadEditScreen;
  final List<String> profilePictures;

  bool get isPublicProfile =>
      loadEditScreen == null || pickProfilePicture == null;
  ImageProvider get currentImage => imageUploading && uploadImage != null
      ? uploadImage.image
      : profilePic ?? kDefaultProfile.image;
  bool get shouldShowProfilePictureModal =>
      !imageUploading && profilePictures != null && profilePictures.length > 0;

  ProfileBackground({
    @required this.imageLoading,
    @required this.loadingModal,
    @required this.pickProfilePicture,
    @required this.displayName,
    @required this.minHeight,
    @required this.loadEditScreen,
    @required this.profilePictures,
    this.aspectRatio,
    this.imageUploading,
    this.uploadImage,
    this.profilePic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Make it half the size of the viewport
      height: (MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              kToolbarHeight) /
          2,
      // Pad from the bottom naivagtion bar and status bar
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      decoration: BoxDecoration(
        gradient: HumbleMe.welcomeGradient,
      ),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          // Don't show edit icon for public profiles
          isPublicProfile
              ? Container()
              : Positioned(
                  top: MediaQuery.of(context).padding.top,
                  right: 10.0,
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(0.0),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    onPressed: loadEditScreen,
                  ),
                ),
          imageLoading
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircleAvatar(
                    radius: _kProfileRadius,
                    child: CupertinoActivityIndicator(),
                  ),
                )
              : Stack(
                  key: ValueKey(currentImage),
                  alignment: Alignment.center,
                  children: <Widget>[
                    CupertinoButton(
                      pressedOpacity: 0.9,
                      padding: const EdgeInsets.all(0.0),
                      onPressed: shouldShowProfilePictureModal
                          ? () => Navigator
                              .of(context, rootNavigator: true)
                              .push(PageRouteBuilder(
                                  pageBuilder: (BuildContext context, _, __) {
                                    return ProfilePictureView(
                                      profilePictures: profilePictures,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 250),
                                  transitionsBuilder: (BuildContext context,
                                      Animation<double> animation,
                                      _,
                                      Widget child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  }))
                          : null,
                      child: imageUploading && uploadImage != null
                          ? SizedBox(
                              width: _kProfileRadius * 2,
                              height: _kProfileRadius * 2,
                              child: ClipOval(
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      alignment: FractionalOffset.topCenter,
                                      image: uploadImage.image,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage:
                                  profilePic ?? kDefaultProfile.image,
                              radius: _kProfileRadius,
                            ),
                    ),
                    isPublicProfile
                        ? Container()
                        : Positioned(
                            bottom: 0.0,
                            right: 0.0,
                            child: CupertinoButton(
                              pressedOpacity: 0.9,
                              onPressed: pickProfilePicture,
                              padding: const EdgeInsets.all(0.0),
                              child: CircleAvatar(
                                radius: 16.0,
                                child: loadingModal
                                    ? CupertinoActivityIndicator()
                                    : Icon(Icons.add_circle),
                                backgroundColor: HumbleMe.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                  ],
                ),
        ],
      ),
    );
  }
}
