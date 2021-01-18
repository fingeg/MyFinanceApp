import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myfinance_app/utils/encryption/encryption.dart';
import 'package:myfinance_app/utils/encryption/rsa.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/network.dart';
import 'package:myfinance_app/utils/static.dart';
import 'package:srp/client.dart';

class AuthenticationHandler {
  Future<ApiResponse<bool>> register(String username, String password) async {
    // Initialize keys for SRP (Secure remote password) authentication
    final salt = generateSalt();
    final String srpPrivateKey = derivePrivateKey(salt, username, password);
    final verifier = deriveVerifier(srpPrivateKey);

    // Initialize keys for RSA encryption
    final rsaKeys = RsaHelper.getRsaKeyPair();
    final rsaPrivateKey =
        RsaHelper.encodePrivateKeyToPemPKCS1(rsaKeys.privateKey, header: false);
    final rsaPublicKey =
        RsaHelper.encodePublicKeyToPemPKCS1(rsaKeys.publicKey, header: false);
    final encryptedRsaPrivateKey =
        encrypt(srpPrivateKey, Encoding.base16, rsaPrivateKey);

    final response = await request<bool>(
      '/user',
      HttpMethod.PUT,
      data: {
        'username': username,
        'salt': salt,
        'verifier': verifier,
        'publicKey': rsaPublicKey,
        'privateKey': encryptedRsaPrivateKey,
      },
      jsonParser: (json) => json['status'],
    );

    if (response.statusCode == StatusCode.success) {
      final storage = FlutterSecureStorage();
      Static.storage.storeSensitiveString(Keys.salt, salt);
      Static.storage.storeSensitiveString(Keys.username, username);
      Static.storage.storeSensitiveString(Keys.srpPrivateKey, srpPrivateKey);
      Static.storage.storeSensitiveString(Keys.rsaPublicKey, rsaPublicKey);
      Static.storage.storeSensitiveString(Keys.rsaPrivateKey, rsaPrivateKey);
    }

    return response;
  }

  Future<ApiResponse<void>> login(String username, String password) async {
    // Initialize keys for SRP (Secure remote password) authentication
    final ephemeral = generateEphemeral();

    // The first request sends the server the random ephemeral
    final res1 = await request<_LoginResponseOne>(
      '/user/login',
      HttpMethod.POST,
      data: {
        'username': username,
        'ephemeral': ephemeral.public,
      },
      jsonParser: (json) => _LoginResponseOne.fromJson(json),
    );

    // Only continue when the first step was successful
    if (res1.statusCode != StatusCode.success) {
      return res1;
    }

    // With the received data from step one, the session key can be generated
    try {
      final String srpPrivateKey =
          derivePrivateKey(res1.data.salt, username, password);
      final clientSession = deriveSession(
        ephemeral.secret,
        res1.data.serverEphemeral,
        res1.data.salt,
        username,
        srpPrivateKey,
      );

      // Send the proof of the session to the server to get verified
      final res2 = await request<_LoginResponseTwo>(
        '/user/login',
        HttpMethod.POST,
        data: {
          'username': username,
          'id': res1.data.loginID,
          'sessionProof': clientSession.proof,
        },
        jsonParser: (json) => _LoginResponseTwo.fromJson(json),
      );

      // Only proceed when the request was successful
      if (res2.statusCode != StatusCode.success) {
        return res2;
      }

      // Check if the server also has the correct proof
      try {
        verifySession(
            ephemeral.public, clientSession, res2.data.serverSessionProof);

        // Decrypt the received private key, to be able to decrypt all user data
        final rsaPrivateKey =
            decrypt(srpPrivateKey, Encoding.base16, res2.data.privateKey);

        // If verify session did not send an exception, than the login was correct
        // Save all session keys
        Static.storage.storeSensitiveString(Keys.username, username);
        Static.storage.storeSensitiveString(Keys.srpPrivateKey, srpPrivateKey);
        Static.storage
            .storeSensitiveString(Keys.rsaPublicKey, res2.data.publicKey);
        Static.storage.storeSensitiveString(Keys.rsaPrivateKey, rsaPrivateKey);
        Static.storage
            .storeSensitiveString(Keys.sessionProof, clientSession.proof);
        Static.storage
            .storeSensitiveString(Keys.sessionId, res1.data.loginID.toString());
        Static.storage.storeSensitiveString(Keys.salt, res1.data.salt);

        return res2;
      } catch (e) {
        return ApiResponse(statusCode: StatusCode.failed);
      }
    } catch (e) {
      return ApiResponse(statusCode: StatusCode.failed);
    }
  }

  static Future<Authentication> getAuthentication() async => Authentication(
        await Static.storage.getSensitiveString(Keys.username),
        await Static.storage.getSensitiveString(Keys.sessionProof),
        int.parse(await Static.storage.getSensitiveString(Keys.sessionId)),
      );
}

class _LoginResponseOne {
  final int loginID;
  final String serverEphemeral;
  final String salt;
  final bool status;

  _LoginResponseOne(this.loginID, this.serverEphemeral, this.salt, this.status);

  factory _LoginResponseOne.fromJson(Map<String, dynamic> json) =>
      _LoginResponseOne(
        json['loginID'] as int,
        json['serverEphemeral'] as String,
        json['salt'] as String,
        json['status'] as bool,
      );
}

class _LoginResponseTwo {
  final String serverSessionProof;
  final String privateKey;
  final String publicKey;
  final bool status;

  _LoginResponseTwo(
      this.serverSessionProof, this.privateKey, this.publicKey, this.status);

  factory _LoginResponseTwo.fromJson(Map<String, dynamic> json) =>
      _LoginResponseTwo(
        json['sessionProof'] as String,
        json['privateKey'] as String,
        json['publicKey'] as String,
        json['status'] as bool,
      );
}
