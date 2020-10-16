
import 'dart:convert';

import 'package:encrypt/encrypt.dart';

enum Encoding {
  base16,
  base64,
}

Key getKey(String key, Encoding encoding) => encoding == Encoding.base16 ? Key.fromBase16(key) : Key.fromBase64(key);

String encrypt(String key, Encoding keyEncoding, String text) {
  final _key = getKey(key, keyEncoding);
  final iv = IV.fromLength(16);
  final encryptor = Encrypter(AES(_key));
  final msg = encryptor.encrypt(text, iv: iv).base16;
  return msg;
}

String decrypt(String key, Encoding keyEncoding, String text) {
  final _key = getKey(key, keyEncoding);
  final iv = IV.fromLength(16);
  final encryptor = Encrypter(AES(_key));
  final encrypted = Encrypted.fromBase16(text);
  final msg = encryptor.decrypt(encrypted, iv: iv);
  return msg;
}