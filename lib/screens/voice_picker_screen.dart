import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/azure_voice.dart';
import '../providers/voice_state.dart';
import '../widgets/voice_card.dart';

class VoicePickerScreen extends StatefulWidget {
  final String currentVoiceId;
  final Future<void> Function(AzureVoice) onSelect;

  const VoicePickerScreen({
    super.key,
    required this.currentVoiceId,
    required this.onSelect,
  });

  @override
  State<VoicePickerScreen> createState() => _VoicePickerScreenState();
}

class _VoicePickerScreenState extends State<VoicePickerScreen> {
  final _searchController = TextEditingController();
  List<AzureVoice> _filtered = azureEnglishVoices;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String q) {
    setState(() {
      _filtered = azureEnglishVoices
          .where((v) =>
              v.displayName.toLowerCase().contains(q.toLowerCase()) ||
              v.locale.toLowerCase().contains(q.toLowerCase()) ||
              v.gender.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  Future<void> _previewVoice(AzureVoice voice) async {
    final tts = context.read<VoiceState>().ttsService;
    if (tts == null) return;
    try {
      await tts.speak('Hello, I am ${voice.displayName}.', voice);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preview failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select AI Voice')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search voices...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final voice = _filtered[i];
                return VoiceCard(
                  voice: voice,
                  selected: voice.id == widget.currentVoiceId,
                  onTap: () async {
                    await widget.onSelect(voice);
                    if (mounted) Navigator.pop(context);
                  },
                  onPreview: () => _previewVoice(voice),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
