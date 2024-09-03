# keepsecretsafe
Welcome to KeepSecretSafe, the ultimate solution for securely accessing Google Cloud Secret Manager from your Flutter applications! 🎉
=======
# Join the Security Revolution! 🌟
By using **`KeepSecretSafe`**, you're not just securing your apps; you're joining a community of developers committed to building secure, scalable, and efficient software. Let's make the digital world a safer place, one app at a time! 💼🔐✨

# KeepSecretSafe Library for Flutter 🚀🔒

Welcome to KeepSecretSafe, the ultimate solution for securely accessing Google Cloud Secret Manager from your Flutter applications! 🎉

## Why KeepSecretSafe? 🤔

In today's digital age, security is paramount. As developers, we need to ensure that our applications are secure, scalable, and efficient. KeepSecretSafe is designed to help you achieve just that by providing a seamless and secure way to access secrets stored in Google Cloud Secret Manager. Let's build secure apps together! 💪🔐

## Features ✨

- 🔒 Securely access secrets stored in Google Cloud Secret Manager.
- 🛡️ Uses Service Account authentication for robust security.
- 🐞 Handles errors gracefully and provides detailed logging for easier debugging.

## Installation 📦

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2
  googleapis_auth: ^1.6.0
  logger: ^2.4.0
  mockito: ^5.4.4
  flutter_dotenv: ^5.1.0
```

Then, run `flutter pub get` to install the dependencies.

# Usage 🚀
## Step 1: Setup Google Cloud Service Account 🔧
1. Go to the Google Cloud Console.
2. Create a new project or select an existing project.
3. Enable the Secret Manager API for your project.
4. Create a Service Account and download the JSON key file.
5. Store the Service Account credentials securely.

## Step 2: Initialize the Library 🔑
Use the `key.json` file to load the credentials:

```dart
import 'package:flutter/material.dart';
import 'package:keepsecretsafe/keepsecretsafe.dart';

void main() async {
  final authenticationService = AuthenticationService(
    keyFilePath: './key.json',
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
```
## Step 3: Fetch Secrets 🔍
Use the getSecrets method of SecretManager to fetch secrets from Google Cloud Secret Manager.

```dart
try {
  final secrets = await secretManager.getSecrets(['api_key', 'db_password']);
  print('API Key: ${secrets['api_key']}');
  print('DB Password: ${secrets['db_password']}');
} catch (e) {
  print('Failed to fetch secrets: $e');
}
```
# Error Handling 🚨
The library provides detailed error handling and logging for easier debugging.

* **AuthenticationException**: Thrown when there is an issue with authentication.
* **SecretNotFoundException**: Thrown when a specified secret is not found.
* **SecretManagerException**: Thrown for other errors related to fetching secrets.

# Logging 📋
The library uses the logger package for logging errors and important information. Logs are only printed in debug mode.

```dart
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:logger/logger.dart';

final Logger _logger = Logger();

void logError(String message, dynamic error) {
  if (kDebugMode) {
    _logger.e(message, error);
  }
}
```
# Secure Your Secrets in CI/CD Pipelines 🔐
To ensure the highest level of security, it's crucial to avoid storing your key.json file in the same repository as your source code. Instead, inject the key.json file during the CI/CD process. Below are examples of how to achieve this using Azure DevOps, GitHub Actions, and Google Cloud Build.

## Azure DevOps Example

In Azure DevOps, you can use secure files to store your key.json file and inject it during the build process.

1. **Upload `key.json` as a Secure File:**

* Go to your Azure DevOps project.
* Navigate to Pipelines > Library > Secure files.
* Upload your key.json file.

2. **Pipeline Script:**
```yaml
trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

steps:
- task: DownloadSecureFile@1
  name: downloadKeyJson
  inputs:
    secureFile: 'key.json'

- script: |
    mkdir -p $HOME/.config/gcloud
    cp $(downloadKeyJson.secureFilePath) $HOME/.config/gcloud/application_default_credentials.json
  displayName: 'Inject key.json'

- script: flutter test
  displayName: 'Run Tests'
```

## GitHub Actions Example

In GitHub Actions, you can use GitHub Secrets to store your key.json content and inject it during the build process.

1. **Add `key.json` Content as a GitHub Secret:**

* Go to your GitHub repository.
* Navigate to Settings > Secrets > Actions.
* Add a new secret with the name **GCP_KEY_JSON** and paste the content of your `key.json` file.

2. **Workflow Script:**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '2.5.3'

    - name: Inject key.json
      run: |
        echo "${{ secrets.GCP_KEY_JSON }}" > $HOME/.config/gcloud/application_default_credentials.json

    - name: Run Tests
      run: flutter test
```

## Google Cloud Build Example

In Google Cloud Build, you can use Secret Manager to securely store and inject your `key.json` file during the build process.

1. **Add `key.json` to Secret Manager:**
* Go to the Google Cloud Console.
* Navigate to Secret Manager.
* Create a new secret with the name `gcp-key-json` and upload the content of your `key.json` file.

2. **Cloud Build Script:**

```yaml
steps:
- name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
  entrypoint: 'bash'
  args:
  - '-c'
  - |
    echo $GCP_KEY_JSON | base64 --decode > /root/.config/gcloud/application_default_credentials.json

- name: 'gcr.io/cloud-builders/flutter'
  args: ['test']

secrets:
- kmsKeyName: projects/YOUR_PROJECT_ID/locations/global/keyRings/YOUR_KEYRING/cryptoKeys/YOUR_KEY
  secretEnv:
    GCP_KEY_JSON: projects/YOUR_PROJECT_ID/secrets/gcp-key-json/versions/latest
```
---
By following these guidelines, you ensure that your secrets are securely managed and not exposed in your code repository. Let's build secure and scalable applications together! 🌟🔒
---

# Contributing 🤝
Contributions are welcome! Please create an issue or submit a pull request with your changes.

# License 📄
This project is licensed under the MIT License – see the LICENSE file for details.
>>>>>>> 4c7ca45 (Initial commit)
