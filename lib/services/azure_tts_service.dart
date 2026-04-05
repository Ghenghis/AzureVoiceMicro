import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import '../models/azure_voice.dart';

class AzureTtsService {
  final String subscriptionKey;
  final String region;

  final AudioPlayer _player = AudioPlayer();

  AzureTtsService({required this.subscriptionKey, required this.region});

  Future<void> speak(String text, AzureVoice voice) async {
    if (text.trim().isEmpty) return;

    final ssml = '''<speak version="1.0" xml:lang="${voice.locale}">
  <voice name="${voice.id}">${_escapeXml(text)}</voice>
</speak>''';

    final url = Uri.parse(
      'https://$region.tts.speech.microsoft.com/cognitiveservices/v1',
    );

    final response = await http.post(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key': subscriptionKey,
        'Content-Type': 'application/ssml+xml',
        'X-Microsoft-OutputFormat': 'audio-16khz-128kbitrate-mono-mp3',
        'User-Agent': 'AzureVoiceMicro/1.0',
      },
      body: ssml,
    );

    if (response.statusCode != 200) {
      throw Exception('Azure TTS error ${response.statusCode}: ${response.body}');
    }

    await _player.stop();
    await _player.setAudioSource(
      _BytesAudioSource(response.bodyBytes),
    );
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  bool get isPlaying => _player.playing;

  String _escapeXml(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');

  /// Returns a proper WAV file (RIFF header + 16 kHz 16-bit mono PCM).
  /// Use for Suno "Upload Audio" — saves directly to a .wav file.
  Future<Uint8List> synthesizeWav(String text, AzureVoice voice) async {
    if (text.trim().isEmpty) return Uint8List(0);

    final ssml = '''<speak version="1.0" xml:lang="${voice.locale}">
  <voice name="${voice.id}">${_escapeXml(text)}</voice>
</speak>''';

    final url = Uri.parse(
      'https://$region.tts.speech.microsoft.com/cognitiveservices/v1',
    );

    final response = await http.post(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key': subscriptionKey,
        'Content-Type': 'application/ssml+xml',
        'X-Microsoft-OutputFormat': 'riff-16khz-16bit-mono-pcm',
        'User-Agent': 'AzureVoiceMicro/1.0',
      },
      body: ssml,
    );

    if (response.statusCode != 200) {
      throw Exception('Azure TTS WAV error ${response.statusCode}: ${response.body}');
    }
    return response.bodyBytes;
  }

  /// Returns raw 16 kHz 16-bit mono PCM bytes — for WebRTC call injection.
  Future<Uint8List> synthesizePcm(String text, AzureVoice voice) async {
    if (text.trim().isEmpty) return Uint8List(0);

    final ssml = '''<speak version="1.0" xml:lang="${voice.locale}">
  <voice name="${voice.id}">${_escapeXml(text)}</voice>
</speak>''';

    final url = Uri.parse(
      'https://$region.tts.speech.microsoft.com/cognitiveservices/v1',
    );

    final response = await http.post(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key': subscriptionKey,
        'Content-Type': 'application/ssml+xml',
        'X-Microsoft-OutputFormat': 'raw-16khz-16bit-mono-pcm',
        'User-Agent': 'AzureVoiceMicro/1.0',
      },
      body: ssml,
    );

    if (response.statusCode != 200) {
      throw Exception('Azure TTS PCM error ${response.statusCode}: ${response.body}');
    }
    return response.bodyBytes;
  }

  Future<List<AzureVoice>> fetchVoiceList() async {
    final url = Uri.parse(
      'https://$region.tts.speech.microsoft.com/cognitiveservices/voices/list',
    );
    final response = await http.get(url, headers: {
      'Ocp-Apim-Subscription-Key': subscriptionKey,
    });
    if (response.statusCode != 200) return [];

    final List<dynamic> json = jsonDecode(response.body);
    return json
        .where((v) => (v['Locale'] as String).startsWith('en-'))
        .map((v) => AzureVoice(
              id: v['ShortName'] as String,
              displayName: v['LocalName'] as String,
              locale: v['Locale'] as String,
              gender: v['Gender'] as String,
            ))
        .toList();
  }

  void dispose() {
    _player.dispose();
  }
}

class _BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;
  _BytesAudioSource(this._bytes) : super(tag: 'azure-tts');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
