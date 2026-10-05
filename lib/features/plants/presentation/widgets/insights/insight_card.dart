import 'dart:ui';

import 'package:flutter/material.dart';

import 'insight_palette.dart';

class InsightHintText extends StatelessWidget {
  final String text;
  final InsightPalette palette;

  const InsightHintText(this.text, {super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(color: palette.inkSoft, fontSize: 12.5, height: 1.4),
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  final String title;
  final String? stat;
  final String? caption;
  final Widget child;
  final bool transparent;
  final InsightPalette palette;

  const InsightCard({
    super.key,
    required this.title,
    this.stat,
    this.caption,
    required this.child,
    required this.transparent,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: transparent
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transparent
                  ? Colors.black.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: transparent
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: palette.ink,
                        ),
                      ),
                    ),
                    if (stat != null)
                      Text(
                        stat!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: palette.ink,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                child,
                if (caption != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    caption!,
                    style: TextStyle(fontSize: 11.5, color: palette.inkSoft),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
