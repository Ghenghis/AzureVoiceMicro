import 'package:flutter/material.dart';

class MicIndicator extends StatefulWidget {
  final bool isListening;
  final bool isSpeaking;
  final VoidCallback onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const MicIndicator({
    super.key,
    required this.isListening,
    required this.isSpeaking,
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  State<MicIndicator> createState() => _MicIndicatorState();
}

class _MicIndicatorState extends State<MicIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSpeaking
        ? Colors.green
        : widget.isListening
            ? Colors.blue
            : Colors.grey.shade600;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPressStart: (_) => widget.onLongPressStart?.call(),
        onLongPressEnd: (_) => widget.onLongPressEnd?.call(),
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) {
            final active = widget.isListening || widget.isSpeaking;
            final scale = active
                ? 1.0 + _pulse.value * 0.15
                : _hovering
                    ? 1.05
                    : 1.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border: Border.all(color: color, width: 3),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 20 + _pulse.value * 20,
                            spreadRadius: 4,
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  widget.isSpeaking
                      ? Icons.volume_up
                      : widget.isListening
                          ? Icons.mic
                          : Icons.mic_none,
                  size: 48,
                  color: color,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
