import 'dart:async';
import 'dart:developer' show Timeline, Flow;
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart' hide Flow;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Flow;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide Flow;

import '../../../theme.dart';

class LicensePage extends StatefulWidget {
  /// Creates a page that shows licenses for software used by the application.
  ///
  /// The arguments are all optional. The application name, if omitted, will be
  /// derived from the nearest [Title] widget. The version and legalese values
  /// default to the empty string.
  ///
  /// The licenses shown on the [LicensePage] are those returned by the
  /// [LicenseRegistry] API, which can be used to add more licenses to the list.
  const LicensePage({
    Key key,
    this.applicationName = 'HumbleMe',
    this.applicationVersion = 'Version 0.0.1',
    this.applicationLegalese = '\u00A9 2018 HumbleMe, Inc.',
  }) : super(key: key);

  /// The name of the application.
  ///
  /// Defaults to the value of [Title.title], if a [Title] widget can be found.
  /// Otherwise, defaults to [Platform.resolvedExecutable].
  final String applicationName;

  /// The version of this build of the application.
  ///
  /// This string is shown under the application name.
  ///
  /// Defaults to the empty string.
  final String applicationVersion;

  /// A string to show in small print.
  ///
  /// Typically this is a copyright notice.
  ///
  /// Defaults to the empty string.
  final String applicationLegalese;

  @override
  _LicensePageState createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  @override
  void initState() {
    super.initState();
    _initLicenses();
  }

  final List<Widget> _licenses = <Widget>[];
  bool _loaded = false;

  Future<Null> _initLicenses() async {
    final Flow flow = Flow.begin();
    Timeline.timeSync('_initLicenses()', () {}, flow: flow);
    await for (LicenseEntry license in LicenseRegistry.licenses) {
      if (!mounted) return;
      Timeline.timeSync('_initLicenses()', () {}, flow: Flow.step(flow.id));
      final List<LicenseParagraph> paragraphs =
          await SchedulerBinding.instance.scheduleTask<List<LicenseParagraph>>(
        () => license.paragraphs.toList(),
        Priority.animation,
        debugLabel: 'License',
        flow: flow,
      );
      setState(() {
        _licenses.add(const Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: const Text(
                '🍀‬', // That's U+1F340. Could also use U+2766 (❦) if U+1F340 doesn't work everywhere.
                textAlign: TextAlign.center)));
        _licenses.add(Container(
            decoration: const BoxDecoration(
                border: const Border(bottom: const BorderSide(width: 0.0))),
            child: Text(license.packages.join(', '),
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)));
        for (LicenseParagraph paragraph in paragraphs) {
          if (paragraph.indent == LicenseParagraph.centeredIndent) {
            _licenses.add(Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(paragraph.text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)));
          } else {
            assert(paragraph.indent >= 0);
            _licenses.add(Padding(
                padding: EdgeInsetsDirectional.only(
                    top: 8.0, start: 16.0 * paragraph.indent),
                child: Text(paragraph.text)));
          }
        }
      });
    }
    setState(() {
      _loaded = true;
    });
    Timeline.timeSync('Build scheduled', () {}, flow: Flow.end(flow.id));
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.applicationName;
    final String version = widget.applicationVersion;
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final List<Widget> contents = <Widget>[
      Text(name,
          style: Theme
              .of(context)
              .textTheme
              .headline
              .copyWith(color: Colors.black),
          textAlign: TextAlign.center),
      Text(version,
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.black),
          textAlign: TextAlign.center),
      Container(height: 18.0),
      Text(widget.applicationLegalese ?? '',
          style: Theme
              .of(context)
              .textTheme
              .caption
              .copyWith(color: Colors.grey[800]),
          textAlign: TextAlign.center),
      Container(height: 18.0),
      Text('Powered by Flutter',
          style:
              Theme.of(context).textTheme.body1.copyWith(color: Colors.black),
          textAlign: TextAlign.center),
      Container(height: 24.0),
    ];
    contents.addAll(_licenses);
    if (!_loaded) {
      contents.add(const Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: const Center(child: const CircularProgressIndicator())));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.licensesPageTitle),
        elevation: kIsAndroid ? 4.0 : 0.0,
      ),
      // All of the licenses page text is English. We don't want localized text
      // or text direction.
      body: Localizations.override(
        locale: const Locale('en', 'US'),
        context: context,
        child: DefaultTextStyle(
          style: Theme
              .of(context)
              .textTheme
              .caption
              .copyWith(color: Colors.grey[800]),
          child: Scrollbar(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              children: contents,
            ),
          ),
        ),
      ),
    );
  }
}
