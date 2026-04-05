import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    wOptions: WindowsOptions(),
  );

  static const _keySubscriptionKey = 'azure_subscription_key';
  static const _keyRegion            = 'azure_region';
  static const _keySelectedVoice     = 'azure_selected_voice';
  static const _keyDefaultVoice      = 'azure_default_voice';
  static const _keyFavoriteVoices    = 'azure_favorite_voices';

  // ── Credentials ─────────────────────────────────────────────────────────
  Future<void> saveCredentials(String key, String region) async {
    await _storage.write(key: _keySubscriptionKey, value: key);
    await _storage.write(key: _keyRegion, value: region);
  }

  Future<({String? key, String region})> loadCredentials() async {
    final key    = await _storage.read(key: _keySubscriptionKey);
    final region = await _storage.read(key: _keyRegion) ?? 'eastus';
    return (key: key, region: region);
  }

  // ── Selected voice (last used) ───────────────────────────────────────────
  Future<void> saveSelectedVoice(String voiceId) async {
    await _storage.write(key: _keySelectedVoice, value: voiceId);
  }

  Future<String?> loadSelectedVoice() async {
    return _storage.read(key: _keySelectedVoice);
  }

  // ── Default voice (pinned, loaded at startup) ────────────────────────────
  Future<void> saveDefaultVoice(String voiceId) async {
    await _storage.write(key: _keyDefaultVoice, value: voiceId);
  }

  Future<String?> loadDefaultVoice() async {
    return _storage.read(key: _keyDefaultVoice);
  }

  Future<void> clearDefaultVoice() async {
    await _storage.delete(key: _keyDefaultVoice);
  }

  // ── Favorites list (pipe-delimited IDs) ─────────────────────────────────
  Future<void> saveFavoriteVoices(List<String> ids) async {
    await _storage.write(key: _keyFavoriteVoices, value: ids.join('|'));
  }

  Future<List<String>> loadFavoriteVoices() async {
    final raw = await _storage.read(key: _keyFavoriteVoices);
    if (raw == null || raw.isEmpty) return [];
    return raw.split('|').where((s) => s.isNotEmpty).toList();
  }

  Future<void> toggleFavorite(String voiceId) async {
    final favs = await loadFavoriteVoices();
    if (favs.contains(voiceId)) {
      favs.remove(voiceId);
    } else {
      favs.add(voiceId);
    }
    await saveFavoriteVoices(favs);
  }

  // ── Nuke everything ──────────────────────────────────────────────────────
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
