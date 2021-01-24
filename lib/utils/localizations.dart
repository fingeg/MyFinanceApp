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
      'logout': 'Sign out',
      'register': 'Sign up',
      'or': 'or',
      'password_length_condition':
          'The password has to be at least 5 characters long',
      'password_validation_condition': 'The passwords are unequal',
      'username_length_condition':
          'The username has to be between 4 and 10 characters',
      'username_character_condition': 'Only A-Z, a-z and 0-9 are allowed',
      'back': 'Back',
      'username': 'Username',
      'password': 'Password',
      'password_validation': 'Password validation',
      'offline_msg': 'You are offline',
      'username_exists': 'Username already exists',
      'wrong_password': 'Wrong password',
      'failed': 'Failed, please try again later',
      'settings': 'Settings',
      'new_category': 'New category',
      'edit_category': 'Edit category',
      'name': 'Name',
      'category_name': 'Category name',
      'shared_user': 'Share with user',
      'no_categories': 'No categories yet',
      'username_does_not_exist': 'Username does not exist',
      'payers': 'Payers',
      'payments': 'Payments',
      'amount': 'Amount',
      'pending_invoices': 'Pending invoices',
      'add_payment': 'New payment',
      'description': 'Description',
      'name_condition': 'The name must not by empty',
      'amount_condition': 'The amount must not by empty',
      'date': 'Date',
      'date_condition': 'Wrong date',
      'payer_condition': 'Payer must be set',
      'add': 'Add',
      'payer': 'Payer',
      'update': 'Update',
      'write_rights_required': 'You need at least write permissions',
      'owner_rights_required': 'You have to be the owner of the category',
      'delete_category': 'Delete category',
      'delete_category_confirmation': 'Do you really want do delete the category?',
      'delete_payment': 'Delete payment',
      'delete_payment_confirmation': 'Do you really want do delete the payment?',
      'yes': 'Yes',
      'no': 'No',
      'edit_payment': 'Edit payment',
      'revenue': 'Revenue',
      'expense': 'Expense',
      'splits': 'Split of the bill',
      'add_payer': 'Add person',
      'add_new_payer': 'Add new person',
      'name_or_username': 'Name/Username',
      'share': 'Share (%)',
      'percent_condition': 'The number has to be between 0 and 100',
      'me': 'Me',
      'no_persons': 'No persons yet',
      'split_name_condition': 'The user already has a share of the bill',
      'single_name_condition': 'The user already exists',
      'show_payed': 'Show all N payed payments...',
      'hide_payed': 'Hide all N payed payments...',
      'mark_payed': 'Mark complete bill as payed...',
      'mark_payed_confirmation_title': 'Mark all as payed?',
      'mark_payed_confirmation_text':
          'Do you really want to mark all payments in the listed categories as payed? \n\nThis can only be redone for single payments!',
    },
    'de': {
      'title': 'MyFinance',
      'logout': 'Abmelden',
      'login': 'Login',
      'login_page': 'Login Seite',
      'register': 'Registrieren',
      'or': 'oder',
      'password_length_condition':
          'Das Passwort muss mindestens 5 Zeichen Lang sein',
      'password_validation_condition': 'Die Passwörter sind ungleich',
      'username_length_condition':
          'Der Nutzername muss zwischen 4 und 10 Zeichen lang sein',
      'username_character_condition': 'Nur A-Z, a-z und 0-9 sind erlaubt',
      'back': 'Zurück',
      'username': 'Nutzername',
      'password': 'Passwort',
      'password_validation': 'Passwortbestätigung',
      'offline_msg': 'Du bist offline',
      'username_exists': 'Nutzername schon vergeben',
      'wrong_password': 'Falsches Password',
      'failed': 'Fehler, bitte später erneut versuchen',
      'settings': 'Einstellungen',
      'name': 'Name',
      'category_name': 'Kategorie Name',
      'new_category': 'Neue Kategorie',
      'edit_category': 'Kategorie bearbeiten',
      'shared_user': 'Mit Nutzern teilen',
      'no_categories': 'Noch keine Kategorien',
      'username_does_not_exist': 'Nutzername gibt es nicht',
      'payers': 'Zahler',
      'amount': 'Summe',
      'payments': 'Zahlungen',
      'pending_invoices': 'Ausstehende Rechnungen',
      'add_payment': 'Neue Bezahlung',
      'description': 'Beschreibung',
      'name_condition': 'Der Name darf nicht leer sein',
      'amount_condition': 'Der Betrag darf nicht leer sein',
      'date': 'Datum',
      'date_condition': 'Falsches Datum',
      'payer_condition': 'Zahler muss angegeben werden',
      'add': 'Hinzufügen',
      'payer': 'Zahler',
      'write_rights_required': 'Sie benötigen mindestens Schreibrechte',
      'owner_rights_required': 'Sie müssen der Inhaber der Kategorie sein',
      'update': 'Aktualisieren',
      'delete_payment': 'Zahlung löschen',
      'delete_payment_confirmation': 'Möchten Sie die Zahlung wirklich löschen?',
      'delete_category': 'Kategorie löschen',
      'delete_category_confirmation': 'Möchten Sie die Kategorie wirklich löschen?',
      'yes': 'Ja',
      'no': 'Nein',
      'edit_payment': 'Zahlung bearbeiten',
      'revenue': 'Einzahlung',
      'expanse': 'Ausgabe',
      'splits': 'Aufteilung der Rechnung',
      'add_payer': 'Person hinzufügen',
      'add_new_payer': 'Neue Person hinzufügen',
      'name_or_username': 'Name/Benutzername',
      'share': 'Anteil (%)',
      'me': 'Ich',
      'no_persons': 'Bisher keine Personen eingetragen',
      'percent_condition': 'Die zahl muss zwischen 0 und 100 sein',
      'split_name_condition': 'Der Nutzer trägt schon einen Teil der Rechnung',
      'single_name_condition': 'Den Nutzer gibt es bereits',
      'show_payed': 'Zeige alle N bezahlten Zahlungen...',
      'hide_payed': 'Verstecke alle N bezahlten Zahlungen...',
      'mark_payed': 'Gesamte Rechnung als bezahlt makieren...',
      'mark_payed_confirmation_title': 'Als bezahlt makieren?',
      'mark_payed_confirmation_text':
          'Möchten Sie wirklich alle Zahlungen der aufgelisteten Kategorien als bezahlt makieren? \n\nDies ist nur für die Zahlungen einzelnd rückgängig zu machen!',
    },
  };

  Map<String, String> get _locals => _localizedValues[locale.languageCode];

  String get title => _locals['title'];
  String get loginPage => _locals['login_page'];

  String get login => _locals['login'];

  String get logout => _locals['logout'];

  String get register => _locals['register'];
  String get or => _locals['or'];
  String get passwordLengthCondition => _locals['password_length_condition'];
  String get usernameLengthCondition => _locals['username_length_condition'];
  String get usernameCharacterCondition => _locals['username_character_condition'];
  String get back => _locals['back'];
  String get yes => _locals['yes'];
  String get no => _locals['no'];
  String get username => _locals['username'];
  String get password => _locals['password'];
  String get passwordValidation => _locals['password_validation'];
  String get passwordValidationCondition => _locals['password_validation_condition'];
  String get offlineMsg => _locals['offline_msg'];
  String get usernameExists => _locals['username_exists'];
  String get usernameDoesNotExist => _locals['username_does_not_exist'];
  String get wrongPassword => _locals['wrong_password'];
  String get failed => _locals['failed'];
  String get settings => _locals['settings'];
  String get newCategory => _locals['new_category'];
  String get name => _locals['name'];
  String get description => _locals['description'];
  String get categoryName => _locals['category_name'];
  String get sharedUser => _locals['shared_user'];
  String get noCategories => _locals['no_categories'];
  String get noPersons => _locals['no_persons'];
  String get payers => _locals['payers'];
  String get payments => _locals['payments'];
  String get amount => _locals['amount'];
  String get date => _locals['date'];
  String get addPayment => _locals['add_payment'];
  String get editPayment => _locals['edit_payment'];
  String get add => _locals['add'];
  String get update => _locals['update'];
  String get pendingInvoices => _locals['pending_invoices'];
  String get nameCondition => _locals['name_condition'];
  String get splitNameCondition => _locals['split_name_condition'];
  String get singleNameCondition => _locals['single_name_condition'];
  String get amountCondition => _locals['amount_condition'];
  String get dateCondition => _locals['date_condition'];
  String get payerCondition => _locals['payer_condition'];
  String get payer => _locals['payer'];
  String get writeRightsRequired => _locals['write_rights_required'];
  String get ownerRightsRequired => _locals['owner_rights_required'];
  String get editCategory => _locals['edit_category'];
  String get deleteCategory => _locals['delete_category'];
  String get deletePayment => _locals['delete_payment'];
  String get deleteCategoryConfirmation => _locals['delete_category_confirmation'];

  String get deletePaymentConfirmation =>
      _locals['delete_payment_confirmation'];

  String get revenue => _locals['revenue'];

  String get expense => _locals['expense'];

  String get splits => _locals['splits'];

  String get addPayer => _locals['add_payer'];

  String get addNewPayer => _locals['add_new_payer'];

  String get nameOrUsername => _locals['name_or_username'];

  String get share => _locals['share'];

  String get percentCondition => _locals['percent_condition'];

  String get me => _locals['me'];

  String get showPayed => _locals['show_payed'];

  String get hidePayed => _locals['hide_payed'];

  String get markPayed => _locals['mark_payed'];

  String get markPayedConfirmationTitle =>
      _locals['mark_payed_confirmation_title'];

  String get markPayedConfirmationText =>
      _locals['mark_payed_confirmation_text'];
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
