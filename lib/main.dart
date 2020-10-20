import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:myfinance_app/pages/login/login_page.dart';
import 'package:myfinance_app/pages/settings/settings_page.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/static.dart';
import 'pages/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Static.storage.init();

  runApp(EventBusWidget(
    child: MaterialApp(
      title: 'MyFinance',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColorBrightness: Brightness.dark,
        accentColor: Color.fromARGB(0xff, 0x36, 0xa3, 0x26),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey[900],
          contentTextStyle: TextStyle(color: Colors.white),
        )
      ),
      routes: <String, WidgetBuilder>{
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/settings': (context) => SettingsPage(),
      },
      localizationsDelegates: [
        MyFinanceLocalizationsDelegate(),
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('de'),
      ],
    ),
  ));
}
