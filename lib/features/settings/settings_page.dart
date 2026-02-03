import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsPage extends StatelessWidget {
  final ValueChanged<Color> onAccentChange;
  const SettingsPage({super.key, required this.onAccentChange});

  @override
  Widget build(BuildContext context) {
    final colors = Colors.primaries;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn(),

          const SizedBox(height: 32),

          Text(
            'Accent Color',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 16,
            runSpacing: 16, 
            children: colors.map((c) {
              return GestureDetector(
                onTap: () => onAccentChange(c),
                child: CircleAvatar(radius: 18, backgroundColor: c),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 24),

          Text(
            'About',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nolio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Minimal calendar-based todo app',
                  style: TextStyle(color: Colors.white54),
                ),

                const SizedBox(height: 16),

                Row(
                  children: const [
                    Icon(Icons.code),
                    SizedBox(width: 8),
                    Text('Source code'),
                  ],
                ),

                const SizedBox(height: 6),
                const Text(
                  'github.com/Grey-007/nolio',
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Made by Grey-007',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}
