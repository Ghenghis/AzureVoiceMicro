import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    wOptions: WindowsOptions(),
  );

  static const _keySubscriptionKey = 'azure_subscription_key';
  static const _keyRegion = 'azure_region';
  static const _keySelectedVoice = 'azure_selected_voice';

  Future<void> saveCredentials(String key, String region) async {
    await _storage.write(key: _keySubscriptionKey, value: key);
    await _storage.write(key: _keyRegion, value: region);
  }

  Future<({String? key, String region})> loadCredentials() async {
    final key = await _storage.read(key: _keySubscriptionKey);
    final region = await _storage.read(key: _keyRegion) ?? 'eastus';
    return (key: key, region: region);
  }

  Future<void> saveSelectedVoice(String voiceId) async {
    await _storage.write(key: _keySelectedVoice, value: voiceId);
  }

  Future<String?> loadSelectedVoice() async {
    return _storage.read(key: _keySelectedVoice);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
