import 'package:flutter/material.dart';
import '../models/azure_voice.dart';

class VoiceCard extends StatefulWidget {
  final AzureVoice voice;
  final bool selected;
  final bool isFavorite;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback? onPreview;
  final VoidCallback? onLongPress;

  const VoiceCard({
    super.key,
    required this.voice,
    required this.selected,
    this.isFavorite = false,
    this.isDefault = false,
    required this.onTap,
    this.onPreview,
    this.onLongPress,
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
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                widget.selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: widget.selected ? primary : null,
              ),
              if (widget.isDefault)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Icon(Icons.push_pin, size: 12,
                      color: theme.colorScheme.tertiary),
                ),
            ],
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  widget.voice.displayName,
                  style: TextStyle(
                    fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal,
                    color: widget.selected ? primary : null,
                  ),
                ),
              ),
              if (widget.isFavorite) ...[
                const SizedBox(width: 4),
                Icon(Icons.star, size: 14, color: Colors.amber.shade600),
              ],
              if (widget.isDefault) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('default',
                      style: TextStyle(fontSize: 10,
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ],
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
          onLongPress: widget.onLongPress,
        ),
      ),
    );
  }
}
