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

class _VoicePickerScreenState extends State<VoicePickerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchController = TextEditingController();
  String _query = '';
  String _localeFilter = 'All';

  static const _localeTabs = [
    'All', 'Favorites', 'en-US', 'en-GB', 'en-AU',
    'en-CA', 'en-IN', 'en-IE', 'en-NZ', 'en-SG',
    'en-ZA', 'en-HK', 'en-PH', 'en-KE', 'en-NG', 'en-TZ',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<AzureVoice> _filtered(List<AzureVoice> source, List<String> favIds) {
    var list = source;

    if (_localeFilter == 'Favorites') {
      list = list.where((v) => favIds.contains(v.id)).toList();
    } else if (_localeFilter != 'All') {
      list = list.where((v) => v.locale == _localeFilter).toList();
    }

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((v) =>
              v.displayName.toLowerCase().contains(q) ||
              v.locale.toLowerCase().contains(q) ||
              v.gender.toLowerCase().contains(q))
          .toList();
    }

    // Favorites float to top within the list
    if (_localeFilter != 'Favorites') {
      list = [
        ...list.where((v) => favIds.contains(v.id)),
        ...list.where((v) => !favIds.contains(v.id)),
      ];
    }

    return list;
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

  void _showVoiceMenu(BuildContext context, AzureVoice voice, VoiceState state) {
    final isDefault = state.defaultVoiceId == voice.id;
    final isFav = state.isFavorite(voice.id);

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(isFav ? Icons.star : Icons.star_border),
              title: Text(isFav ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                state.toggleFavorite(voice.id);
              },
            ),
            ListTile(
              leading: Icon(
                isDefault ? Icons.push_pin : Icons.push_pin_outlined,
                color: isDefault ? Theme.of(context).colorScheme.primary : null,
              ),
              title: Text(isDefault ? 'Clear Default Voice' : 'Set as Default Voice'),
              subtitle: isDefault
                  ? Text('Currently default', style: TextStyle(
                      color: Theme.of(context).colorScheme.primary))
                  : null,
              onTap: () {
                Navigator.pop(context);
                if (isDefault) {
                  state.clearDefaultVoice();
                } else {
                  state.setDefaultVoice(voice);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${voice.displayName} set as default')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Preview Voice'),
              onTap: () {
                Navigator.pop(context);
                _previewVoice(voice);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = context.watch<VoiceState>();
    final loading = voiceState.voiceListLoading;
    final filtered = _filtered(voiceState.voiceList, voiceState.favoriteVoiceIds);
    final favCount = voiceState.favoriteVoiceIds.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('AI Voices (${voiceState.voiceList.length})'),
        actions: [
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search voices...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (q) => setState(() => _query = q),
                ),
              ),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: _localeTabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (ctx, i) {
                    final tab = _localeTabs[i];
                    final selected = _localeFilter == tab;
                    final label = tab == 'Favorites'
                        ? 'Favorites ($favCount)'
                        : tab;
                    return FilterChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) => setState(() => _localeFilter = tab),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: filtered.isEmpty
          ? Center(
              child: Text(
                loading
                    ? 'Loading voices from Azure…'
                    : _localeFilter == 'Favorites' && favCount == 0
                        ? 'No favorites yet.\nLong-press a voice to star it.'
                        : 'No voices match your search.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final voice = filtered[i];
                final isFav = voiceState.isFavorite(voice.id);
                final isDefault = voiceState.defaultVoiceId == voice.id;
                return VoiceCard(
                  voice: voice,
                  selected: voice.id == widget.currentVoiceId,
                  isFavorite: isFav,
                  isDefault: isDefault,
                  onTap: () async {
                    await widget.onSelect(voice);
                    if (mounted) Navigator.pop(context);
                  },
                  onPreview: () => _previewVoice(voice),
                  onLongPress: () => _showVoiceMenu(ctx, voice, voiceState),
                );
              },
            ),
    );
  }
}
