import 'package:speech_to_text/speech_to_text.dart';

class MicService {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;

  Future<bool> initialize() async {
    _available = await _stt.initialize(
      onError: (e) => print('STT error: $e'),
      onStatus: (s) => print('STT status: $s'),
    );
    return _available;
  }

  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
  }) async {
    if (!_available) return;

    await _stt.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2),
      listenMode: ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    await _stt.stop();
  }

  bool get isListening => _stt.isListening;
  bool get isAvailable => _available;
}
