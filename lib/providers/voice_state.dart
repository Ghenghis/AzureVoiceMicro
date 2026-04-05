import 'package:flutter/foundation.dart';
import '../models/azure_voice.dart';
import '../services/azure_tts_service.dart';
import '../services/mic_service.dart';
import '../services/credential_service.dart';
import '../services/call_service.dart';

class VoiceState extends ChangeNotifier {
  final MicService _mic = MicService();
  final CredentialService _creds = CredentialService();
  final CallService _call = CallService();
  AzureTtsService? ttsService;

  AzureVoice selectedVoice = azureEnglishVoices.first;
  List<AzureVoice> voiceList = azureEnglishVoices;
  bool voiceListLoading = false;
  List<String> favoriteVoiceIds = [];
  String? defaultVoiceId;
  String transcript = '';
  String interimText = '';
  bool isListening = false;
  bool isSpeaking = false;
  bool isInCall = false;
  bool isReady = false;
  String? error;

  Future<void> initialize() async {
    final creds = await _creds.loadCredentials();
    if (creds.key == null || creds.key!.isEmpty) {
      error = 'No Azure credentials. Open Settings ⚙️ to configure.';
      notifyListeners();
      return;
    }

    ttsService = AzureTtsService(
      subscriptionKey: creds.key!,
      region: creds.region,
    );

    favoriteVoiceIds = await _creds.loadFavoriteVoices();
    defaultVoiceId   = await _creds.loadDefaultVoice();

    final voiceId = defaultVoiceId ?? await _creds.loadSelectedVoice();
    if (voiceId != null) {
      selectedVoice = azureEnglishVoices.firstWhere(
        (v) => v.id == voiceId,
        orElse: () => azureEnglishVoices.first,
      );
    }

    final micOk = await _mic.initialize();
    if (!micOk) {
      error = 'Microphone not available. Check permissions.';
      notifyListeners();
      return;
    }

    isReady = true;
    error = null;
    notifyListeners();
    _fetchVoiceList();
    await startListening();
  }

  Future<void> reinitialize(String key, String region) async {
    await _creds.saveCredentials(key, region);
    ttsService = AzureTtsService(subscriptionKey: key, region: region);
    isReady = true;
    error = null;
    notifyListeners();
    _fetchVoiceList();
    if (!isListening) await startListening();
  }

  Future<void> _fetchVoiceList() async {
    if (ttsService == null) return;
    voiceListLoading = true;
    notifyListeners();
    try {
      final fetched = await ttsService!.fetchVoiceList();
      if (fetched.isNotEmpty) {
        voiceList = fetched;
        final match = fetched.firstWhere(
          (v) => v.id == selectedVoice.id,
          orElse: () => fetched.first,
        );
        selectedVoice = match;
      }
    } catch (_) {
      // keep static fallback list
    } finally {
      voiceListLoading = false;
      notifyListeners();
    }
  }

  Future<void> startListening() async {
    if (!_mic.isAvailable) return;
    isListening = true;
    notifyListeners();

    await _mic.startListening(
      onResult: (text, isFinal) {
        interimText = isFinal ? '' : text;
        if (isFinal && text.isNotEmpty) {
          transcript += (transcript.isEmpty ? '' : '\n') + text;
          _speakText(text);
        }
        notifyListeners();
      },
    );
  }

  Future<void> _speakText(String text) async {
    if (ttsService == null) return;
    isSpeaking = true;
    notifyListeners();

    try {
      if (isInCall) {
        // Call mode: synthesize PCM and inject into audio path
        final pcm = await ttsService!.synthesizePcm(text, selectedVoice);
        await _call.injectAudio(pcm);
        // Also play locally so the user can monitor the output
        await ttsService!.speak(text, selectedVoice);
      } else {
        await ttsService!.speak(text, selectedVoice);
      }
    } catch (e) {
      error = 'TTS error: $e';
      notifyListeners();
    }

    isSpeaking = false;
    notifyListeners();

    if (isListening) await startListening();
  }

  Future<void> toggleCall() async {
    if (isInCall) {
      await _call.endCall();
      isInCall = false;
    } else {
      try {
        await _call.startCall();
        isInCall = true;
      } catch (e) {
        error = 'Call error: $e';
      }
    }
    notifyListeners();
  }

  Future<void> selectVoice(AzureVoice voice) async {
    selectedVoice = voice;
    await _creds.saveSelectedVoice(voice.id);
    notifyListeners();
  }

  Future<void> toggleFavorite(String voiceId) async {
    await _creds.toggleFavorite(voiceId);
    favoriteVoiceIds = await _creds.loadFavoriteVoices();
    notifyListeners();
  }

  bool isFavorite(String voiceId) => favoriteVoiceIds.contains(voiceId);

  Future<void> setDefaultVoice(AzureVoice voice) async {
    defaultVoiceId = voice.id;
    await _creds.saveDefaultVoice(voice.id);
    selectedVoice = voice;
    await _creds.saveSelectedVoice(voice.id);
    notifyListeners();
  }

  Future<void> clearDefaultVoice() async {
    defaultVoiceId = null;
    await _creds.clearDefaultVoice();
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (isListening) {
      await _mic.stopListening();
      isListening = false;
    } else {
      await startListening();
    }
    notifyListeners();
  }

  void clearTranscript() {
    transcript = '';
    interimText = '';
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _call.dispose();
    ttsService?.dispose();
    super.dispose();
  }
}
