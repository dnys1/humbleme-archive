import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

final Image _kDefaultProfile = Image.asset(
  'images/default_profile.png',
  key: ValueKey<String>('defaultProfile'),
  alignment: Alignment.topCenter,
  height: _kDefaultProfileImageHeight,
  width: _kDefaultProfileImageWidth,
);

const double _kDefaultProfileImageHeight = 720.0;
const double _kDefaultProfileImageWidth = 720.0;

class ProfileCircleAvatar extends StatelessWidget {
  /// The required url to load the picture from.
  final String photoUrl;

  /// Optional radius value
  final double radius;

  static const double _defaultRadius = 20.0;

  ProfileCircleAvatar({Key key, @required this.photoUrl, this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CircleAvatar(
          radius: radius ?? _defaultRadius,
          backgroundColor: Colors.transparent,
          child: CupertinoActivityIndicator(),
        ),
        CircleAvatar(
          radius: radius ?? _defaultRadius,
          backgroundColor: Colors.transparent,
          backgroundImage: photoUrl == null
              ? _kDefaultProfile.image
              : FadeInImage
                  .memoryNetwork(
                    placeholder: kTransparentImage,
                    image: photoUrl,
                    key: ValueKey<String>(photoUrl),
                  )
                  .image,
        ),
      ],
    );
  }
}
