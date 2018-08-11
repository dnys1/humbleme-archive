import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../theme.dart';

class ResourcesView extends StatefulWidget {
  ResourcesView({Key key}) : super(key: key);

  @override
  createState() => _ResourcesViewState();
}

class _ResourcesViewState extends State<ResourcesView> {
  Widget _buildPage(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildBookshelfHero(context),
            Divider(),
            _buildStatsHero(context),
          ],
        ));
  }

  Widget _buildBookshelfHero(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bookshelf',
              style: Theme.of(context).textTheme.title,
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: Image.asset(
                'images/bookshelf.png',
                key: ValueKey<String>('images/bookshelf.png'),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Boost your score with the best resources available!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            RaisedButton.icon(
              icon: Icon(
                Icons.arrow_right,
                color: Colors.white,
              ),
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.bookshelf),
              label: Text(
                'Go',
                style: Theme.of(context).primaryTextTheme.button,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHero(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Global Stats',
              style: Theme.of(context).textTheme.title,
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: Image.asset(
                'images/rankings.png',
                key: ValueKey<String>('images/rankings.png'),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'See what traits are most valued by people!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            RaisedButton.icon(
              icon: Icon(
                Icons.arrow_right,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pushNamed(Routes.stats),
              label: Text(
                'Go',
                style: Theme.of(context).primaryTextTheme.button,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAndroid() {
    return Theme(
      data: HumbleMe.appTheme,
      child: Builder(
        builder: (BuildContext context) {
          return _buildPage(context);
        },
      ),
    );
  }

  Widget _buildiOS() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: HumbleMe.teal,
        middle: Text(
          'Resources',
          style: Theme.of(context).primaryTextTheme.title,
        ),
      ),
      child: _buildPage(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return kIsAndroid ? _buildAndroid() : _buildiOS();
  }
}
