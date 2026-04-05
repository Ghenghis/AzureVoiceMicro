import 'package:flutter/foundation.dart';
import '../models/azure_voice.dart';
import '../services/azure_tts_service.dart';
import '../services/mic_service.dart';
import '../services/credential_service.dart';

class VoiceState extends ChangeNotifier {
  final MicService _mic = MicService();
  final CredentialService _creds = CredentialService();
  AzureTtsService? ttsService;

  AzureVoice selectedVoice = azureEnglishVoices.first;
  String transcript = '';
  String interimText = '';
  bool isListening = false;
  bool isSpeaking = false;
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

    final voiceId = await _creds.loadSelectedVoice();
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
    await startListening();
  }

  Future<void> reinitialize(String key, String region) async {
    await _creds.saveCredentials(key, region);
    ttsService = AzureTtsService(subscriptionKey: key, region: region);
    isReady = true;
    error = null;
    notifyListeners();
    if (!isListening) await startListening();
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
      await ttsService!.speak(text, selectedVoice);
    } catch (e) {
      error = 'TTS error: $e';
      notifyListeners();
    }

    isSpeaking = false;
    notifyListeners();

    if (isListening) await startListening();
  }

  Future<void> selectVoice(AzureVoice voice) async {
    selectedVoice = voice;
    await _creds.saveSelectedVoice(voice.id);
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
}
