import 'package:flutter/material.dart';

class TranscriptDisplay extends StatelessWidget {
  final String text;
  final String interim;

  const TranscriptDisplay({
    super.key,
    required this.text,
    required this.interim,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = text.isNotEmpty || interim.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 80, maxHeight: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: hasContent
            ? SingleChildScrollView(
                reverse: true,
                child: RichText(
                  text: TextSpan(
                    children: [
                      if (text.isNotEmpty)
                        TextSpan(
                          text: text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      if (text.isNotEmpty && interim.isNotEmpty)
                        const TextSpan(text: '\n'),
                      if (interim.isNotEmpty)
                        TextSpan(
                          text: interim,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : Text(
                'Listening... speak to begin',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.35),
                  fontStyle: FontStyle.italic,
                ),
              ),
      ),
    );
  }
}
