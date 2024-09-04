import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:google_secret_manager/google_secret_manager.dart';
import 'exceptions.dart';
import 'package:logger/logger.dart';

class SecretService {
  final String keyFilePath;
  late final String projectId;
  final Logger _logger = Logger();

  SecretService({required this.keyFilePath}) {
    if (keyFilePath.isEmpty) {
      throw SecretServiceException('Key file path must not be empty');
    }
  }

  Future<void> init() async {
    try {
      final keyJson = await rootBundle.loadString(keyFilePath);
      await GoogleSecretManagerInitializer.initViaServiceAccountJson(keyJson);
    } catch (e) {
      throw SecretServiceException('Failed to read key file: $e');
    }
  }

  Future<String?> getSecretData({required String secretName}) async {
    if (secretName.isEmpty) {
      throw SecretServiceException("SECRET NAME can't be empty.");
    }

    final response = await GoogleSecretManager.instance.get(secretName);

    if (response == null) {
      _logger.e('Failed to get secret data');
      throw SecretNotFoundException("Failed to get secret data");
    }
    final base64EncodedValue = response.payload?.data;
    final bytes = base64.decode(base64EncodedValue!);
    final secretValue = utf8.decode(bytes);

    _logger.i("Payload as String: $secretValue");

    return secretValue;
  }
}
