import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/platform_loading_indicator.dart';

class ProfilePictureView extends StatefulWidget {
  final List<String> profilePictures;

  ProfilePictureView({
    Key key,
    @required this.profilePictures,
  }) : super(key: key);

  @override
  createState() => _ProfilePictureViewState();
}

class _ProfilePictureViewState extends State<ProfilePictureView> {
  int _index = 1;
  DateTime _dateTime;

  /// Retrieve the date and time of the picture based off the url,
  /// because we store pictures with the date and time as their name.
  DateTime _parseUrl(String url) {
    List<String> parts = url.split('/').last.split('.');
    parts.removeLast();
    url = parts.join('.');
    return DateTime.parse(url);
  }

  String _buildDateTimeString(DateTime dateTime) {
    assert(dateTime != null);

    if (dateTime == null) {
      return '';
    }

    int day = dateTime.day;
    int month = dateTime.month;
    int year = dateTime.year;

    assert(month >= 1 && month <= 12);

    if (month < 1 || month > 12) {
      return '';
    }

    String monthS = () {
      switch (month) {
        case 1:
          return 'January';
        case 2:
          return 'February';
        case 3:
          return 'March';
        case 4:
          return 'April';
        case 5:
          return 'May';
        case 6:
          return 'June';
        case 7:
          return 'July';
        case 8:
          return 'August';
        case 9:
          return 'September';
        case 10:
          return 'October';
        case 11:
          return 'November';
        case 12:
          return 'December';
      }
    }();

    return '$monthS $day, $year';
  }

  /// We want to load images and then cache them. This is the best way
  /// I can think to do it.
  Widget _loadImage(BuildContext context, int index) {
    CachedNetworkImageProvider(widget.profilePictures[index])
      ..resolve(ImageConfiguration()).addListener((imageInfo, _) {
        RawImage image = RawImage(
          image: imageInfo?.image,
          scale: imageInfo?.scale ?? 1.0,
        );
        PageStorage.of(context).writeState(context, image);
        if (mounted) {
          setState(() {});
        }
      });
    return PlatformLoadingIndicator(color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Stack(
          children: <Widget>[
            PageView.builder(
              itemCount: widget.profilePictures.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  key: PageStorageKey<String>('picture-$index'),
                  padding: const EdgeInsets.all(10.0),
                  child: Builder(
                    builder: (BuildContext context) {
                      return PageStorage.of(context).readState(context) ??
                          _loadImage(context, index);
                    },
                  ),
                );
              },
              onPageChanged: (int index) {
                String url = widget.profilePictures[index];
                setState(() {
                  _index = index + 1; // No 0
                });
              },
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top,
              right: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  '$_index / ${widget.profilePictures.length}',
                  style: Theme.of(context).primaryTextTheme.title,
                ),
              ),
            ),
            _dateTime != null
                ? Positioned(
                    top: MediaQuery.of(context).padding.top,
                    left: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        _buildDateTimeString(_dateTime),
                        style: Theme.of(context).primaryTextTheme.title,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
