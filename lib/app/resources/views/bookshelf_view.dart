import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../auth/models/resource.dart';
import '../../../theme.dart';
import 'book_detail_view.dart';

class BookshelfView extends StatefulWidget {
  final List<Resource> resources;

  BookshelfView({Key key, this.resources})
      : assert(resources.isNotEmpty),
        super(key: key);

  @override
  createState() => _BookshelfViewState();
}

class _BookshelfViewState extends State<BookshelfView> {
  Widget _buildResourcesList(BuildContext context) {
    TextStyle _kHeaderTextStyle =
        Theme.of(context).primaryTextTheme.body1.copyWith(fontSize: 18.0);
    TextStyle _kTitleTextStyle = Theme.of(context).textTheme.subhead;
    TextStyle _kSubtitleTextStyle = Theme
        .of(context)
        .textTheme
        .body1
        .copyWith(color: Theme.of(context).textTheme.caption.color);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.resources.map((res) {
        return CupertinoButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  BookDetailView(resource: res))),
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Container(
            height: 175.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                LimitedBox(
                  maxWidth: 100.0,
                  child: AspectRatio(
                    aspectRatio: 2.0 / 3.0,
                    child: FadeInImage.assetNetwork(
                      placeholder: 'images/book_preview.png',
                      image: res.imageUrl,
                      key: ValueKey<String>(res.id),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          res.title,
                          style: _kTitleTextStyle,
                          softWrap: true,
                        ),
                        res.subtitle == null
                            ? Container()
                            : Text(
                                res.subtitle,
                                style: _kSubtitleTextStyle,
                                softWrap: true,
                              ),
                      ],
                    ),
                  ),
                ),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAndroid() {
    return Theme(
      data: HumbleMe.appTheme,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Bookshelf'),
            ),
            body: _buildResourcesList(context),
          );
        },
      ),
    );
  }

  Widget _buildiOS() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: HumbleMe.teal,
        actionsForegroundColor: CupertinoColors.white,
        middle: Text(
          'Bookshelf',
          style: Theme.of(context).primaryTextTheme.title,
        ),
      ),
      child: _buildResourcesList(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid ? _buildAndroid() : _buildiOS();
  }
}
