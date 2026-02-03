import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ───────── Illustration (vector-style) ─────────
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.circle,
                  size: 140,
                  color: accent.withOpacity(0.12),
                ),
                const Icon(
                  Icons.person_outline,
                  size: 72,
                  color: Colors.white54,
                ),
                Positioned(
                  bottom: 10,
                  right: 20,
                  child: Icon(
                    Icons.laptop_mac,
                    size: 32,
                    color: Colors.white38,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 32),

            // ───────── COMING SOON ─────────
            Text(
              'COMING SOON',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: accent,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 12),

            // ───────── Description ─────────
            const Text(
              'Overview of all tasks\nsorted by date',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white60,
                height: 1.4,
              ),
            ).animate().fadeIn(delay: 350.ms),
          ],
        ),
      ),
    );
  }
}
