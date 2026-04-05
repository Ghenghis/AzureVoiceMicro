import 'package:flutter/material.dart';
import '../models/azure_voice.dart';

class VoiceCard extends StatefulWidget {
  final AzureVoice voice;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  const VoiceCard({
    super.key,
    required this.voice,
    required this.selected,
    required this.onTap,
    this.onPreview,
  });

  @override
  State<VoiceCard> createState() => _VoiceCardState();
}

class _VoiceCardState extends State<VoiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: widget.selected
            ? primary.withOpacity(0.15)
            : _hovered
                ? theme.colorScheme.onSurface.withOpacity(0.05)
                : Colors.transparent,
        child: ListTile(
          leading: Icon(
            widget.selected
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
            color: widget.selected ? primary : null,
          ),
          title: Text(
            widget.voice.displayName,
            style: TextStyle(
              fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal,
              color: widget.selected ? primary : null,
            ),
          ),
          subtitle: Text(
            '${widget.voice.locale}  •  ${widget.voice.gender}',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: widget.onPreview != null
              ? IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  tooltip: 'Preview',
                  onPressed: widget.onPreview,
                )
              : null,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
