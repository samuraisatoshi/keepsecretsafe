import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepsecretsafe/src/authentication_service.dart';
import 'package:keepsecretsafe/src/exceptions.dart';
import 'package:keepsecretsafe/src/secret_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'dart:io';

class MockAuthenticationService extends Mock implements AuthenticationService {
  String projectId = 'your-project-id';

  @override
  Future<String> getToken() => super.noSuchMethod(
        Invocation.method(#getToken, []),
        returnValue: Future.value('mock-token'),
        returnValueForMissingStub: Future.value('mock-token'),
      );

  @override
  Future<void> init() async {
    final keyFile = File('./key.json');
    final keyJson = json.decode(await keyFile.readAsString());

    projectId = keyJson['project_id'];
  }
}

void main() {
  const mockToken = 'mock-token';

  setUpAll(() async {
    // Copia o arquivo key.json para o diretório de testes
    final keyFile = File('./key.json');
    final keyFileContent = await keyFile.readAsString();
    await File('test/key.json').writeAsString(keyFileContent);
  });

  group('SecretManager Tests', () {
    test('Test fetching secrets successfully', () async {
      final mockAuthService = MockAuthenticationService();
      await mockAuthService.init();
      when(mockAuthService.getToken()).thenAnswer((_) async => mockToken);

      final client = MockClient((request) async {
        return http.Response(
            json.encode({
              'payload': {'data': base64.encode(utf8.encode('secret-value'))}
            }),
            200);
      });

      final secretManager = SecretManager(
        authenticationService: mockAuthService,
        client: client,
      );

      try {
        final secrets = await secretManager.getSecrets(['api_key']);

        expect(secrets.containsKey('api_key'), true);
        expect(secrets['api_key'], 'secret-value');

        if (kDebugMode) print('Secrets fetched successfully.');
      } catch (e) {
        if (kDebugMode) print('Failed to fetch secrets: $e');
      }
    });

    test('Test fetching secrets with authentication failure', () async {
      final mockAuthService = MockAuthenticationService();
      await mockAuthService.init();
      when(mockAuthService.getToken())
          .thenThrow(AuthenticationException('Invalid credentials'));

      final secretManager = SecretManager(
        authenticationService: mockAuthService,
      );

      try {
        await secretManager.getSecrets(['api_key']);
        fail('Expected an AuthenticationException to be thrown');
      } catch (e) {
        expect(e is AuthenticationException, true);
        if (kDebugMode) print('Caught expected AuthenticationException.');
      }
    });

    test('Test fetching non-existent secret', () async {
      final mockAuthService = MockAuthenticationService();
      await mockAuthService.init();
      when(mockAuthService.getToken()).thenAnswer((_) async => mockToken);

      final client = MockClient((request) async {
        return http.Response('', 404);
      });

      final secretManager = SecretManager(
        authenticationService: mockAuthService,
        client: client,
      );

      try {
        await secretManager.getSecrets(['non_existent_secret']);
        fail('Expected a SecretNotFoundException to be thrown');
      } catch (e) {
        expect(e is SecretNotFoundException, true);
        if (kDebugMode) print('Caught expected SecretNotFoundException.');
      }
    });

    test('Test fetching secrets with access denied', () async {
      final mockAuthService = MockAuthenticationService();
      await mockAuthService.init();
      when(mockAuthService.getToken()).thenAnswer((_) async => mockToken);

      final client = MockClient((request) async {
        return http.Response('', 403);
      });

      final secretManager = SecretManager(
        authenticationService: mockAuthService,
        client: client,
      );

      try {
        await secretManager.getSecrets(['restricted_secret']);
        fail('Expected a SecretManagerException to be thrown');
      } catch (e) {
        expect(e is SecretManagerException, true);
        if (kDebugMode) print('Caught expected SecretManagerException.');
      }
    });

    test('Test fetching secrets with unknown error', () async {
      final mockAuthService = MockAuthenticationService();
      await mockAuthService.init();
      when(mockAuthService.getToken()).thenAnswer((_) async => mockToken);

      final client = MockClient((request) async {
        return http.Response('', 500);
      });

      final secretManager = SecretManager(
        authenticationService: mockAuthService,
        client: client,
      );

      try {
        await secretManager.getSecrets(['unknown_error_secret']);
        fail('Expected a SecretManagerException to be thrown');
      } catch (e) {
        expect(e is SecretManagerException, true);
        if (kDebugMode) print('Caught expected SecretManagerException.');
      }
    });
  });
}
