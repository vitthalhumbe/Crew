// lib/widgets/progress_ring.dart
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0..1
  final double size;
  final String? label; // optional center label

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 64,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = ((progress * 100).toInt()).toString() + "%";
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: size * 0.12,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(display, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              if (label != null) Text(label!, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
