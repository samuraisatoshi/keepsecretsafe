import 'package:flutter/material.dart';
import 'package:keepsecretsafe/keepsecretsafe.dart';

import 'src/authentication_service.dart';
import 'src/secret_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authenticationService = AuthenticationService(
    keyFilePath: 'assets/key.json',
  );

  await authenticationService.init();

  final secretManager = SecretManager(
    authenticationService: authenticationService,
  );

  try {
    final secrets = await secretManager.getSecrets(['api_key', 'db_password']);
    print('API Key: ${secrets['api_key']}');
    print('DB Password: ${secrets['db_password']}');
  } catch (e) {
    print('Failed to fetch secrets: $e');
  }
}
