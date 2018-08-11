import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/models.dart';
import '../../../theme.dart';
import '../../../utils/html_parser.dart';

class BookDetailView extends StatefulWidget {
  final Resource resource;

  BookDetailView({Key key, @required this.resource})
      : assert(resource != null),
        super(key: key);

  @override
  createState() => _BookDetailViewState();
}

class _BookDetailViewState extends State<BookDetailView> {
  Resource get resource => widget.resource;

  void _launchResourceLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch.');
    }
  }

  Widget _buildDetail(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Image.network(
              resource.imageUrl,
              key: ValueKey<String>(resource.id),
              height: 180.0,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(resource.title, style: Theme.of(context).textTheme.headline),
          SizedBox(
            height: 10.0,
          ),
          resource.subtitle == null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    resource.subtitle,
                    style: Theme.of(context).textTheme.subhead,
                    textAlign: TextAlign.center,
                  ),
                ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            resource.author.split('|').join(' & '),
            style: Theme.of(context).textTheme.caption,
          ),
          SizedBox(
            height: 10.0,
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CupertinoButton(
                padding: const EdgeInsets.all(0.0),
                onPressed: () => _launchResourceLink(resource.url),
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.shopping_cart, size: 30.0),
                      Expanded(
                        child: FittedBox(
                          child: Text('Amazon',
                              style: Theme.of(context).textTheme.body1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          HtmlTextView(data: resource.description.replaceAll('\\n', '\n')),
        ],
      ),
    );
  }

  Widget _buildiOS() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: HumbleMe.teal,
        actionsForegroundColor: CupertinoColors.white,
        middle: Text(
          widget.resource.title,
          style: Theme.of(context).primaryTextTheme.title,
        ),
      ),
      child: _buildDetail(context),
    );
  }

  Widget _buildAndroid() {
    return Theme(
      data: HumbleMe.appTheme,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.resource.title),
            ),
            body: _buildDetail(context),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid ? _buildAndroid() : _buildiOS();
  }
}
