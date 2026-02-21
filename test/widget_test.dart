import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nolio/features/settings/settings_page.dart';
import 'package:nolio/theme/nolio_theme.dart';

void main() {
  testWidgets('Settings renders theme options', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: NolioThemes.build(
          themeId: NolioThemeId.defaultTheme,
          defaultAccent: const Color(0xFF1DB954),
        ),
        home: Scaffold(
          body: SettingsPage(
            themeId: NolioThemeId.defaultTheme,
            onThemeChange: (_) {},
            defaultAccent: const Color(0xFF1DB954),
            onAccentChange: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Theme'), findsOneWidget);
    expect(find.byType(DropdownMenu<NolioThemeId>), findsOneWidget);
  });
}
