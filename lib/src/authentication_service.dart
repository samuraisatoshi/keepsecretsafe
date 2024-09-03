import 'package:googleapis_auth/auth_io.dart';
import 'exceptions.dart';
import 'dart:io';
import 'dart:convert';

/// Service responsible for authenticating with Google Cloud and obtaining access tokens.
class AuthenticationService {
  final String keyFilePath;
  late final String projectId;

  AuthenticationService({required this.keyFilePath}) {
    if (keyFilePath.isEmpty) {
      throw AuthenticationException('Key file path must not be empty');
    }
  }

  /// Initializes the service account credentials from the key file.
  Future<void> init() async {
    final keyFile = File(keyFilePath);
    final keyJson = json.decode(await keyFile.readAsString());

    projectId = keyJson['project_id'];
  }

  /// Obtains an access token using the provided service account key file.
  /// Throws an [AuthenticationException] if the credentials are invalid or the token cannot be obtained.
  Future<String> getToken() async {
    try {
      final keyFile = File(keyFilePath);
      final keyJson = json.decode(await keyFile.readAsString());

      var accountCredentials = ServiceAccountCredentials.fromJson(keyJson);

      var scopes = ['https://www.googleapis.com/auth/cloud-platform'];
      var authClient =
          await clientViaServiceAccount(accountCredentials, scopes);

      return authClient.credentials.accessToken.data;
    } catch (e) {
      throw AuthenticationException('Failed to obtain access token: $e');
    }
  }
}
