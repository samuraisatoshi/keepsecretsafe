// lib/src/authentication_service.dart

import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'exceptions.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

/// Service responsible for authenticating with Google Cloud and obtaining access tokens.
class AuthenticationService {
  final String keyFilePath;
  late final String projectId;
  final Logger _logger = Logger();

  AuthenticationService({required this.keyFilePath}) {
    if (keyFilePath.isEmpty) {
      throw AuthenticationException('Key file path must not be empty');
    }
  }

  /// Initializes the service account credentials from the key file.
  Future<void> init() async {
    try {
      final keyJson = await rootBundle.loadString(keyFilePath);
      final keyMap = json.decode(keyJson);

      projectId = keyMap['project_id'];
      _logger.i('Project ID: $projectId');
    } catch (e) {
      throw AuthenticationException('Failed to read key file: $e');
    }
  }

  /// Obtains an access token using the provided service account key file.
  /// Throws an [AuthenticationException] if the credentials are invalid or the token cannot be obtained.
  Future<String> getToken() async {
    try {
      final keyJson = await rootBundle.loadString(keyFilePath);
      final keyMap = json.decode(keyJson);

      var accountCredentials = ServiceAccountCredentials.fromJson(keyMap);
      var scopes = ['https://www.googleapis.com/auth/cloud-platform'];
      var authClient =
          await clientViaServiceAccount(accountCredentials, scopes);

      return authClient.credentials.accessToken.data;
    } catch (e) {
      throw AuthenticationException('Failed to obtain access token: $e');
    }
  }
}
