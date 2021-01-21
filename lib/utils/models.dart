import 'package:myfinance_app/utils/encryption/encryption.dart';
import 'package:myfinance_app/utils/encryption/rsa.dart';
import 'package:myfinance_app/utils/utils.dart';

/// One category with all payments and splits
class Category {
  final int id;
  final String name;
  final String description;
  final Permission permission;
  final List<Payment> payments;
  final List<Split> splits;
  final String encryptionKey;

  /// When the category was edited (This includes payments and splits)
  final DateTime lastEdited;

  Category(this.id, this.name, this.description, this.permission, this.payments,
      this.splits, this.encryptionKey, this.lastEdited);

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        json['id'],
        nameCaseCorrection(json['name']),
        json['description'],
        Permission.values[json['permission']],
        json['payments'].map((json) => Payment.fromJson(json)).toList(),
        json['splits']?.map((json) => Split.fromJson(json))?.toList() ?? [],
        json['encryptionKey'],
        DateTime.fromMillisecondsSinceEpoch(json['lastEdited']),
      );

  factory Category.fromEncryptedJson(
      Map<String, dynamic> json, String rsaPrivateKey) {
    final encryptedKey = json['encryptionKey'] as String;
    final privateKey = RsaHelper.parsePrivateKeyFromPem(rsaPrivateKey);
    final decryptedKey = RsaHelper.decrypt(privateKey, encryptedKey);
    return Category(
      json['id'],
      nameCaseCorrection(decrypt(decryptedKey, Encoding.base64, json['name'])),
      (json['description'] as String).isNotEmpty
          ? decrypt(decryptedKey, Encoding.base64, json['description'])
          : '',
      Permission.values[json['permission']],
      json['payments']
          .map<Payment>((json) => Payment.fromEncryptedJson(json, decryptedKey))
          .toList(),
      json['splits']?.map<Split>((json) => Split.fromJson(json))?.toList() ??
          [],
      decryptedKey,
      DateTime.fromMillisecondsSinceEpoch(json['lastEdited']),
    );
  }

  Map<String, dynamic> toEncryptedJson(String rsaPublicKey) {
    final publicKey = RsaHelper.parsePublicKeyFromPem(rsaPublicKey);
    final encryptedKey = RsaHelper.encrypt(publicKey, encryptionKey);
    return {
      'id': id,
      'name': encrypt(encryptionKey, Encoding.base64, name),
      'description': description.isNotEmpty
          ? encrypt(encryptionKey, Encoding.base64, description)
          : '',
      'permission': permission.index,
      'payments':
          payments.map((p) => p.toEncryptedJson(encryptionKey)).toList(),
      'splits': splits.map((s) => s.toJson()).toList(),
      'isSplit': splits.isNotEmpty,
      'encryptionKey': encryptedKey,
      'lastEdited': lastEdited?.millisecondsSinceEpoch,
    };
  }

  bool get isSplit => splits.isNotEmpty;

  double get amount {
    final unpaidAmounts = payments.where((p) => !p.payed).map((p) => p.amount);

    return unpaidAmounts.isEmpty
        ? 0
        : unpaidAmounts.reduce((v1, v2) => v1 + v2);
  }

  // Returns the payed/invested amount for a user in a category
  double getAmountForPerson(String name) {
    final unpaidAmounts =
        payments.where((p) => !p.payed && p.payer == name).map((p) => p.amount);

    return unpaidAmounts.isEmpty
        ? 0
        : unpaidAmounts.reduce((v1, v2) => v1 + v2);
  }

  // Returns the share of a bill of a given person
  double getBillForPerson(String name) {
    final split = splits.where((split) =>
        split.username.trim().toLowerCase() == name.trim().toLowerCase());

    if (split.length != 1) return null;

    return amount * split.single.share;
  }

  List<String> getAllPayers() =>
      payments.where((p) => !p.payed).map((p) => p.payer).toSet().toList();

  List<Payment> get sortedPayments => payments
    ..sort((p1, p2) {
      final compared = p2.date.compareTo(p1.date);
      if (compared == 0) {
        return p2.lastEdited.compareTo(p1.lastEdited);
      }
      return compared;
    });
}

/// One payment
class Payment {
  int id;
  final String name;
  final String description;
  final int categoryID;
  final double amount;
  final Date date;
  final String payer;
  final bool payed;
  final DateTime lastEdited;

  Payment(this.id, this.name, this.description, this.categoryID, this.amount,
      this.date, this.payer, this.payed, this.lastEdited);

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        json['id'],
        json['name'],
        json['description'],
        json['categoryID'],
        json['amount'],
        Date.parse(json['date']),
        json['payer'],
        json['payed'],
        DateTime.fromMillisecondsSinceEpoch(json['lastEdited']),
      );

  factory Payment.fromEncryptedJson(
          Map<String, dynamic> json, String categoryKey) =>
      Payment(
        json['id'],
        decrypt(categoryKey, Encoding.base64, json['name']),
        (json['description'] as String).isNotEmpty
            ? decrypt(categoryKey, Encoding.base64, json['description'])
            : '',
        json['categoryID'],
        double.parse(decrypt(categoryKey, Encoding.base64, json['amount'])),
        Date.parse(json['date']),
        nameCaseCorrection(
            decrypt(categoryKey, Encoding.base64, json['payer'])),
        json['payed'] as bool,
        DateTime.fromMillisecondsSinceEpoch(json['lastEdited']),
      );

  Map<String, dynamic> toEncryptedJson(String categoryKey) {
    return {
      'id': id,
      'name': encrypt(categoryKey, Encoding.base64, name),
      'description': description.isNotEmpty
          ? encrypt(categoryKey, Encoding.base64, description)
          : '',
      'categoryID': categoryID,
      'amount': encrypt(categoryKey, Encoding.base64, amount.toString()),
      'date': date.toDateString(),
      'payer': encrypt(categoryKey, Encoding.base64, payer),
      'payed': payed,
      'lastEdited': lastEdited?.millisecondsSinceEpoch,
    };
  }
}

/// One split
///
/// Describes the share of a user in a category bill
class Split {
  final String username;

  /// The share from 0 to 1
  double share;
  final bool isPlatformUser;
  final DateTime lastEdited;

  Split(this.username, this.share, this.isPlatformUser, this.lastEdited);

  factory Split.fromJson(Map<String, dynamic> json) => Split(
        nameCaseCorrection(json['username']),
        json['share'] *
            1.0, // The multiplication is for the conversion to double
        json['isPlatformUser'],
        DateTime.fromMillisecondsSinceEpoch(json['lastEdited']),
      );

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'share': share,
      'isPlatformUser': isPlatformUser,
      'lastEdited': lastEdited?.millisecondsSinceEpoch
    };
  }
}

/// The category permission
///
/// For requests, the enum has to be converted into an index
enum Permission { read, readWrite, owner }

/// This is the same data as in categories, but sorted by persons
class Person {
  final String name;
  final List<Category> categories;

  Person({this.name, this.categories});

  double get amount => categories.isNotEmpty
      ? categories
          .map((c) => c.getBillForPerson(name))
          .reduce((v1, v2) => v1 + v2)
      : 0.0;
}

class Date {
  int year;
  int month;
  int day;

  Date(this.year, this.month, this.day);

  factory Date.parse(String day) {
    final fragments = day.split('-');
    return Date(
      int.parse(fragments[0]),
      int.parse(fragments[1]),
      int.parse(fragments[2]),
    );
  }

  factory Date.now() {
    final now = DateTime.now();
    return Date(
      now.year,
      now.month,
      now.day,
    );
  }

  String toDateString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  int compareTo(Date date) => toDateTime().compareTo(date.toDateTime());

  DateTime toDateTime() => DateTime(year, month, day);
}
