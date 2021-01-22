import 'package:flutter/material.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/static.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'title',
          child: Text(
            MyFinanceLocalizations.of(context).settings,
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          OutlineButton(
            onPressed: () {
              Static.storage.clearData();
              Static.storage.clearSensitiveData();
              Navigator.of(context).popAndPushNamed('/login');
            },
            child: Text(MyFinanceLocalizations.of(context).logout),
          ),
        ],
      ),
    );
  }
}
