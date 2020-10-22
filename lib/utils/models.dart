import 'package:myfinance_app/utils/encryption/encryption.dart';
import 'package:myfinance_app/utils/encryption/rsa.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/static.dart';

class Category {
  final int id;
  final String name;
  final String description;
  final Permission permission;
  final List<Payment> payments;
  final List<Split> splits;
  final String encryptionKey;

  Category(this.id, this.name, this.description, this.permission, this.payments,
      this.splits, this.encryptionKey);

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        json['id'],
        json['name'],
        json['description'],
        Permission.values[json['permission']],
        json['payments'].map((json) => Payment.fromJson(json)).toList(),
        json['splits']?.map((json) => Split.fromJson(json))?.toList() ?? [],
        json['encryptionKey'],
      );

  factory Category.fromEncryptedJson(
      Map<String, dynamic> json, String rsaPrivateKey) {
    final encryptedKey = json['encryptionKey'] as String;
    final privateKey = RsaHelper.parsePrivateKeyFromPem(rsaPrivateKey);
    final decryptedKey = RsaHelper.decrypt(privateKey, encryptedKey);
    return Category(
      json['id'],
      decrypt(decryptedKey, Encoding.base64, json['name']),
      decrypt(decryptedKey, Encoding.base64, json['description']),
      Permission.values[json['permission']],
      json['payments']
          .map<Payment>((json) => Payment.fromEncryptedJson(json, decryptedKey))
          .toList(),
      json['splits']?.map<Split>((json) => Split.fromJson(json))?.toList() ??
          [],
      decryptedKey,
    );
  }

  bool get isSplit => splits.isNotEmpty;

  double get amount {
    final unpaidAmounts = payments.where((p) => !p.payed).map((p) => p.amount);

    return unpaidAmounts.isEmpty
        ? 0
        : unpaidAmounts.reduce((v1, v2) => v1 + v2);
  }

  double getAmountForPerson(String name) {
    final unpaidAmounts =
        payments.where((p) => !p.payed && p.payer == name).map((p) => p.amount);

    return unpaidAmounts.isEmpty
        ? 0
        : unpaidAmounts.reduce((v1, v2) => v1 + v2);
  }

  List<String> getAllPayers() =>
      payments.where((p) => !p.payed).map((p) => p.payer).toSet().toList();
}

class Payment {
  int id;
  final String name;
  final String description;
  final int categoryID;
  final double amount;
  final DateTime date;
  final String payer;
  final bool payed;

  Payment(this.id, this.name, this.description, this.categoryID, this.amount,
      this.date, this.payer, this.payed);

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        json['id'],
        json['name'],
        json['description'],
        json['categoryID'],
        json['amount'],
        DateTime.parse(json['date']),
        json['payer'],
        json['payed'],
      );

  factory Payment.fromEncryptedJson(
          Map<String, dynamic> json, String categoryKey) =>
      Payment(
        json['id'],
        decrypt(categoryKey, Encoding.base64, json['name']),
        decrypt(categoryKey, Encoding.base64, json['description']),
        json['categoryID'],
        double.parse(decrypt(categoryKey, Encoding.base64, json['amount'])),
        DateTime.parse(json['date']),
        decrypt(categoryKey, Encoding.base64, json['payer']),
        json['payed'] as bool,
      );

  Map<String, dynamic> toEncryptedMap(String categoryKey) {
    return {
      'id': id,
      'name': encrypt(categoryKey, Encoding.base64, name),
      'description': encrypt(categoryKey, Encoding.base64, description),
      'categoryID': categoryID,
      'amount': encrypt(categoryKey, Encoding.base64, amount.toString()),
      'date': date.toIso8601String(),
      'payer': encrypt(categoryKey, Encoding.base64, payer),
      'payed': payed,
    };
  }
}

class Split {
  final String username;
  final double share;
  final bool isPlatformUser;

  Split(this.username, this.share, this.isPlatformUser);

  factory Split.fromJson(Map<String, dynamic> json) => Split(
        json['username'],
        json['share'],
        json['isPlatformUser'],
      );
}

enum Permission { read, readWrite, owner }
