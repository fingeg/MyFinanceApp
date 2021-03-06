import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myfinance_app/pages/login/login_page.dart';
import 'package:myfinance_app/pages/settings/settings_page.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/static.dart';

import 'pages/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Static.storage.init();

  const textColor = Colors.white;
  const accentColor = Color.fromARGB(0xff, 0x36, 0xa3, 0x26);

  runApp(EventBusWidget(
    child: MaterialApp(
      title: 'MyFinance',
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColorBrightness: Brightness.dark,
          accentColor: accentColor,
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.grey[900],
            contentTextStyle: TextStyle(color: textColor),
          ),
          toggleableActiveColor: accentColor,
          buttonTheme: ButtonThemeData(
            colorScheme: ColorScheme.dark(
              primary: accentColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          textTheme: TextTheme(
            headline1: TextStyle(
              fontWeight: FontWeight.w100,
              color: textColor,
              fontSize: 25,
            ),
            headline6: TextStyle(
              fontWeight: FontWeight.w100,
              color: textColor,
              fontSize: 23,
            ),
            subtitle1: TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: 15,
              color: textColor.withAlpha(150),
            ),
            bodyText1: TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: 20,
              color: textColor,
            ),
            bodyText2: TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: 15,
              color: textColor,
            ),
          )),
      routes: <String, WidgetBuilder>{
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/settings': (context) => SettingsPage(),
      },
      localizationsDelegates: [
        MyFinanceLocalizationsDelegate(),
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('de'),
      ],
    ),
  ));
}
