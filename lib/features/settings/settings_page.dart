import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/nolio_theme.dart';

class SettingsPage extends StatelessWidget {
  final NolioThemeId themeId;
  final ValueChanged<NolioThemeId> onThemeChange;
  final Color defaultAccent;
  final ValueChanged<Color> onAccentChange;
  const SettingsPage({
    super.key,
    required this.themeId,
    required this.onThemeChange,
    required this.defaultAccent,
    required this.onAccentChange,
  });

  bool get _showAccentPicker => themeId == NolioThemeId.defaultTheme;

  List<NolioThemeId> get _themes => const [
        NolioThemeId.defaultTheme,
        NolioThemeId.amoled,
        NolioThemeId.gruvbox,
        NolioThemeId.everforest,
        NolioThemeId.nord,
        NolioThemeId.tokyoNight,
        NolioThemeId.catppuccin,
      ];

  @override
  Widget build(BuildContext context) {
    final colors = Colors.primaries;
    final accent = Theme.of(context).colorScheme.primary;

    final tiles = _themes
        .map(
          (t) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: t == themeId
                    ? accent.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: RadioListTile<NolioThemeId>(
              value: t,
              activeColor: accent,
              title: Text(t.label),
              subtitle: Text(
                switch (t) {
                  NolioThemeId.defaultTheme =>
                    'Seeded accent + pick your color',
                  NolioThemeId.amoled => 'Pure black + glass panels',
                  _ => 'Fixed palette',
                },
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ),
          ),
        )
        .toList();

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
            'Theme',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          RadioGroup<NolioThemeId>(
            groupValue: themeId,
            onChanged: (v) {
              if (v != null) onThemeChange(v);
            },
            child: Column(children: tiles),
          ),

          if (_showAccentPicker) ...[
            const SizedBox(height: 16),
            Text(
              'Accent Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: colors.map((c) {
                final selected = c.toARGB32() == defaultAccent.toARGB32();
                return GestureDetector(
                  onTap: () => onAccentChange(c),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? accent.withValues(alpha: 0.9)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(radius: 18, backgroundColor: c),
                  ),
                );
              }).toList(),
            ),
          ],

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
              color: Colors.white.withValues(alpha: 0.05),
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
