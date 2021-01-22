library storage;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_base.dart';

/// Storage class
/// handles storage on mobile and desktop devices
class Storage extends StorageBase {
  static SharedPreferences _sharedPreferences;
  static FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  Future init() async =>
      _sharedPreferences = await SharedPreferences.getInstance();

  @override
  int getInt(String key, {int defaultValue}) => _sharedPreferences.getInt(key);

  @override
  void setInt(String key, int value) => _sharedPreferences.setInt(key, value);

  @override
  String getString(String key) => _sharedPreferences.getString(key);

  @override
  void setString(String key, String value) =>
      _sharedPreferences.setString(key, value);

  @override
  bool getBool(String key) => _sharedPreferences.getBool(key);

  @override
  void setBool(String key, bool value) =>
      _sharedPreferences.setBool(key, value);

  @override
  dynamic getJSON(String key) {
    final raw = getString(key);
    return raw != null ? json.decode(raw) : null;
  }

  @override
  // ignore: type_annotate_public_apis
  void setJSON(String key, value) => setString(key, json.encode(value));

  @override
  List<String> getKeys() => _sharedPreferences.getKeys().toList();

  @override
  void remove(String key) => _sharedPreferences.remove(key);

  @override
  bool has(String key) => _sharedPreferences.containsKey(key);

  @override
  Future reload() => _sharedPreferences.reload();

  void clearData() => getKeys().forEach((key) => remove(key));

  @override
  Future<void> storeSensitiveString(String key, String value) =>
      _secureStorage.write(key: key, value: value);

  @override
  Future<String> getSensitiveString(String key) =>
      _secureStorage.read(key: key);

  Future<void> clearSensitiveData() => _secureStorage.deleteAll();
}
