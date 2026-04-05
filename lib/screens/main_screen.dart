import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_state.dart';
import '../widgets/mic_indicator.dart';
import '../widgets/transcript_display.dart';
import 'voice_picker_screen.dart';
import 'settings_screen.dart';
import 'suno_export_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VoiceState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Azure Voice Micro'),
        actions: [
          if (state.transcript.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear transcript',
              onPressed: state.clearTranscript,
            ),
          IconButton(
            icon: const Icon(Icons.music_note),
            tooltip: 'Export voice for Suno',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SunoExportScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.error != null)
            MaterialBanner(
              content: Text(state.error!),
              leading: const Icon(Icons.warning_amber_rounded,
                  color: Colors.amber),
              actions: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  ),
                  child: const Text('Open Settings'),
                ),
                TextButton(
                  onPressed: state.clearError,
                  child: const Text('Dismiss'),
                ),
              ],
            ),

          const Spacer(),

          MicIndicator(
            isListening: state.isListening,
            isSpeaking: state.isSpeaking,
            onTap: state.isReady ? state.toggleListening : () {},
          ),

          const SizedBox(height: 8),
          Text(
            state.isSpeaking
                ? 'Speaking...'
                : state.isListening
                    ? 'Listening...'
                    : 'Tap mic to start',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
          ),

          const SizedBox(height: 24),

          TranscriptDisplay(
            text: state.transcript,
            interim: state.interimText,
          ),

          const Spacer(),

          _CallRow(state: state),
          const SizedBox(height: 12),
          _VoiceRow(state: state),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CallRow extends StatelessWidget {
  final VoiceState state;
  const _CallRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = state.isInCall;
    final color = active ? Colors.red : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: ListTile(
          leading: Icon(
            active ? Icons.call_end : Icons.call,
            color: color,
          ),
          title: Text(
            active ? 'Call Active — AI voice injecting' : 'Call Mode',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          subtitle: Text(
            active
                ? 'TTS is being injected into audio path'
                : 'Tap to activate voice-changer call mode',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.55),
            ),
          ),
          trailing: Switch(
            value: active,
            activeColor: color,
            onChanged: state.isReady ? (_) => state.toggleCall() : null,
          ),
          onTap: state.isReady ? state.toggleCall : null,
        ),
      ),
    );
  }
}

class _VoiceRow extends StatelessWidget {
  final VoiceState state;
  const _VoiceRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Icon(Icons.graphic_eq),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${state.selectedVoice.displayName}  •  ${state.selectedVoice.locale}',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text('Change Voice'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VoicePickerScreen(
                  currentVoiceId: state.selectedVoice.id,
                  onSelect: state.selectVoice,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
