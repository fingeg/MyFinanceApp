import 'package:flutter/material.dart';
import 'package:myfinance_app/utils/localizations.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MyFinanceLocalizations.of(context).settings,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: SafeArea(child: Text('Settings')),
    );
  }
}
