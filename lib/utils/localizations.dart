import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyFinanceLocalizations {
  MyFinanceLocalizations(this.locale);

  final Locale locale;

  static MyFinanceLocalizations of(BuildContext context) {
    return Localizations.of<MyFinanceLocalizations>(context, MyFinanceLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'MyFinance',
      'login_page': 'Login Page',
      'login': 'Sign in',
      'register': 'Sign up',
      'or': 'or',
      'password_length_condition': 'The password has to be at least 5 characters long',
      'password_validation_condition': 'The passwords are unequal',
      'username_length_condition': 'The username has to be between 4 and 10 characters',
      'username_character_condition': 'Only A-Z, a-z and 0-9 are allowed',
      'back': 'Back',
      'username': 'Username',
      'password': 'Password',
      'password_validation': 'Password validation',
      'offline_msg': 'You are offline',
      'username_exists': 'Username already exists',
      'wrong_password': 'Wrong password',
      'failed': 'Failed, please try again later',
    },
    'de': {
      'title': 'MyFinance',
      'login_page': 'Login Seite',
      'register': 'Registrieren',
      'or': 'oder',
      'password_length_condition': 'Das Passwort muss mindestens 5 Zeichen Lang sein',
      'password_validation_condition': 'Die Passwörter sind ungleich',
      'username_length_condition': 'Der Nutzername muss zwischen 4 und 10 Zeichen lang sein',
      'username_character_condition': 'Nur A-Z, a-z und 0-9 sind erlaubt',
      'back': 'Zurück',
      'username': 'Nutzername',
      'password': 'Passwort',
      'password_validation': 'Passwortbestätigung',
      'offline_msg': 'Du bist offline',
      'username_exists': 'Nutzername schon vergeben',
      'wrong_password': 'Falsches Password',
      'failed': 'Fehler, bitte später erneut versuchen',
    },
  };

  Map<String, String> get _locals => _localizedValues[locale.languageCode];

  String get title => _locals['title'];
  String get loginPage => _locals['login_page'];
  String get login => _locals['login'];
  String get register => _locals['register'];
  String get or => _locals['or'];
  String get passwordLengthCondition => _locals['password_length_condition'];
  String get usernameLengthCondition => _locals['username_length_condition'];
  String get usernameCharacterCondition => _locals['username_character_condition'];
  String get back => _locals['back'];
  String get username => _locals['username'];
  String get password => _locals['password'];
  String get passwordValidation => _locals['password_validation'];
  String get passwordValidationCondition => _locals['password_validation_condition'];
  String get offlineMsg => _locals['offline_msg'];
  String get usernameExists => _locals['username_exists'];
  String get wrongPassword => _locals['wrong_password'];
  String get failed => _locals['failed'];
}

class MyFinanceLocalizationsDelegate extends LocalizationsDelegate<MyFinanceLocalizations> {
  const MyFinanceLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'de'].contains(locale.languageCode);

  @override
  Future<MyFinanceLocalizations> load(Locale locale) {
    return SynchronousFuture<MyFinanceLocalizations>(MyFinanceLocalizations(locale));
  }

  @override
  bool shouldReload(MyFinanceLocalizationsDelegate old) => false;
}
