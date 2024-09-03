import 'package:http/http.dart' as http;
import 'dart:convert';
import 'authentication_service.dart';
import 'exceptions.dart';
import 'package:logger/logger.dart';

/// Service responsible for interacting with Google Cloud Secret Manager.
class SecretManager {
  final AuthenticationService authenticationService;
  final Logger _logger = Logger();
  final http.Client client;

  SecretManager({required this.authenticationService, http.Client? client})
      : client = client ?? http.Client();

  /// Fetches the specified secrets from Google Cloud Secret Manager.
  /// Returns a map where the keys are the secret names and the values are the secret values.
  /// Throws a [SecretNotFoundException] if any of the secrets are not found,
  /// or a [SecretManagerException] for other errors.
  Future<Map<String, String>> getSecrets(List<String> secretNames) async {
    try {
      var token = await authenticationService.getToken();
      var secrets = <String, String>{};

      for (var secretName in secretNames) {
        var url = Uri.parse(
            'https://secretmanager.googleapis.com/v1/projects/${authenticationService.projectId}/secrets/$secretName/versions/latest:access');
        var response =
            await client.get(url, headers: {'Authorization': 'Bearer $token'});

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          var secretPayload = jsonResponse['payload']['data'];
          secrets[secretName] = utf8.decode(base64.decode(secretPayload));
        } else if (response.statusCode == 404) {
          throw SecretNotFoundException('Secret $secretName not found');
        } else if (response.statusCode == 403) {
          throw SecretManagerException('Access denied to secret $secretName');
        } else {
          throw SecretManagerException(
              'Failed to load secret $secretName with status code ${response.statusCode}');
        }
      }

      return secrets;
    } catch (e) {
      _logger.e('Error fetching secrets', error: e);
      if (e is SecretManagerException ||
          e is SecretNotFoundException ||
          e is AuthenticationException) rethrow;
      throw SecretManagerException(
          'An unknown error occurred while fetching secrets');
    }
  }
}
