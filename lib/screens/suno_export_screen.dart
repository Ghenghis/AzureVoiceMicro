import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/voice_state.dart';
import '../models/azure_voice.dart';

/// Generates a WAV voice sample using the selected Azure voice and saves it
/// to device storage so it can be uploaded to Suno's "Create a Voice" feature.
class SunoExportScreen extends StatefulWidget {
  const SunoExportScreen({super.key});

  @override
  State<SunoExportScreen> createState() => _SunoExportScreenState();
}

class _SunoExportScreenState extends State<SunoExportScreen> {
  static const _sunoPhrase =
      'Sing a joyful song beneath the shining moonlight. '
      'My voice rings clear and bright through the night sky. '
      'Every note I sing fills the air with pure delight.';

  static const _customPhraseHint =
      'Enter custom text (30+ seconds recommended for Suno)';

  final _customController = TextEditingController(text: _sunoPhrase);
  bool _generating = false;
  String? _savedPath;
  String? _errorMsg;
  double _progress = 0;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final state = context.read<VoiceState>();
    if (state.ttsService == null) {
      setState(() => _errorMsg = 'No Azure credentials. Configure in Settings.');
      return;
    }

    setState(() {
      _generating = true;
      _errorMsg = null;
      _savedPath = null;
      _progress = 0.1;
    });

    try {
      final text = _customController.text.trim().isEmpty
          ? _sunoPhrase
          : _customController.text.trim();

      setState(() => _progress = 0.3);
      final wavBytes = await state.ttsService!.synthesizeWav(text, state.selectedVoice);

      setState(() => _progress = 0.7);

      // Save to Downloads on Android, Documents on other platforms
      final dir = Platform.isAndroid
          ? Directory('/sdcard/Download')
          : await getApplicationDocumentsDirectory();

      if (!await dir.exists()) await dir.create(recursive: true);

      final voiceName = state.selectedVoice.id.replaceAll('-', '_').toLowerCase();
      final filename = 'suno_voice_${voiceName}_${DateTime.now().millisecondsSinceEpoch}.wav';
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(wavBytes);

      setState(() {
        _savedPath = file.path;
        _progress = 1.0;
      });
    } catch (e) {
      setState(() => _errorMsg = 'Generation failed: $e');
    } finally {
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VoiceState>();
    final theme = Theme.of(context);
    final voice = state.selectedVoice;

    return Scaffold(
      appBar: AppBar(title: const Text('Suno Voice Export')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HowItWorksCard(),
            const SizedBox(height: 20),
            _VoiceBadge(voice: voice),
            const SizedBox(height: 20),
            Text('Recording Script', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _customController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: _customPhraseHint,
                border: const OutlineInputBorder(),
                helperText: 'Suno needs ≥10 s. This script generates ~15–20 s.',
              ),
            ),
            const SizedBox(height: 20),
            if (_generating) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text(
                _progress < 0.5
                    ? 'Calling Azure TTS…'
                    : _progress < 0.9
                        ? 'Saving WAV file…'
                        : 'Done!',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],
            if (_errorMsg != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                ),
                child: Text(_errorMsg!, style: const TextStyle(color: Colors.red)),
              ),
            if (_savedPath != null) ...[
              _SavedCard(path: _savedPath!),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: _generating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.audio_file),
                label: Text(_generating ? 'Generating…' : 'Generate WAV for Suno'),
                onPressed: _generating ? null : _generate,
              ),
            ),
            const SizedBox(height: 24),
            _SunoStepsCard(),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.music_note, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Suno v5.5 Voice Clone Workaround',
                  style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            const Text(
              'Azure TTS generates a WAV file you upload to Suno\'s '
              '"Create a Voice" → "Upload Audio". Suno then uses the '
              'Azure voice characteristics for all your song generations.',
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceBadge extends StatelessWidget {
  final AzureVoice voice;
  const _VoiceBadge({required this.voice});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.record_voice_over, color: theme.colorScheme.secondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selected Voice',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary)),
              Text('${voice.displayName}  •  ${voice.locale}  •  ${voice.gender}',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final String path;
  const _SavedCard({required this.path});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WAV saved!',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  Text(path,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SunoStepsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = [
      ('1', 'Open suno.com/create in your browser'),
      ('2', 'Click "Create a Voice (Beta)" button'),
      ('3', 'Tap "Upload Audio" and select the saved .wav file'),
      ('4', 'Trim if needed → tap "Use Voice"'),
      ('5', 'For the phrase verification — play the WAV again while recording, or tap skip if available'),
      ('6', 'Your Azure voice is now Suno\'s voice model!'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How to use in Suno v5.5', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...steps.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: theme.colorScheme.primary,
                child: Text(s.$1,
                    style: const TextStyle(fontSize: 11, color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(s.$2)),
            ],
          ),
        )),
      ],
    );
  }
}
