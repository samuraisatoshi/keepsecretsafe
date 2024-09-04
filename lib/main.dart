import 'package:flutter/material.dart';
import 'src/secret_service.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Logger _logger = Logger();

  final secretManager = SecretService(
    keyFilePath: 'assets/key.json',
  );

  await secretManager.init();

  try {
    final secrets =
        await secretManager.getSecretData(secretName: 'keep-secret-safe');
    _logger.i(secrets);
  } catch (e) {
    _logger.e('Failed to fetch secrets: $e');
  }
}
