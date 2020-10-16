import 'package:flutter/material.dart';
import 'package:myfinance_app/pages/login/login_page.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/static.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Static.storage.init();

  runApp(MaterialApp(
    title: 'MyFinance',
    theme: ThemeData(
      brightness: Brightness.dark,
      primaryColorBrightness: Brightness.dark,
      accentColor: Color.fromARGB(0xff, 0x36, 0xa3, 0x26),
    ),
    routes: <String, WidgetBuilder>{
      '/': (context) => HomePage(),
      '/login': (context) => LoginPage(),
    },
    localizationsDelegates: [
      MyFinanceLocalizationsDelegate(),
    ],
    supportedLocales: [
      const Locale('en'),
      const Locale('de'),
    ],
  ));
}
