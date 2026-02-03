import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:window_manager/window_manager.dart';

import 'data/todo_db.dart';
import 'features/calendar/calendar_page.dart';
import 'features/todos/todos_page.dart';
import 'features/timer/timer_page.dart';
import 'features/settings/settings_page.dart';
import 'features/timeline/timeline_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await TodoDB.instance.init();

  const windowOptions = WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    backgroundColor: Colors.transparent,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const NolioApp());
}

/// ─────────────────────────────────────────────
/// App root (accent color state lives here)
/// ─────────────────────────────────────────────
class NolioApp extends StatefulWidget {
  const NolioApp({super.key});

  @override
  State<NolioApp> createState() => _NolioAppState();
}

class _NolioAppState extends State<NolioApp> {
  Color accent = const Color(0xFF1DB954);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ),
      ),
      home: AppShell(
        onAccentChange: (c) => setState(() => accent = c),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Main app shell (sidebar + pages)
/// ─────────────────────────────────────────────
class AppShell extends StatefulWidget {
  final ValueChanged<Color> onAccentChange;
  const AppShell({super.key, required this.onAccentChange});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final pages = [
      CalendarPage(
        selectedDate: selectedDate,
        onDateSelected: (d) => setState(() => selectedDate = d),
        onOpenTodos: () => setState(() => index = 1),
      ),
      _ContentShell(child: TodosPage(selectedDate: selectedDate)),
      const _ContentShell(child: TimerPage()),
      const _ContentShell(child: TimelinePage()), // 4th tab (Coming Soon)
      _ContentShell(
        child: SettingsPage(onAccentChange: widget.onAccentChange),
      ),
    ];

    return Scaffold(
      body: Row(
        children: [
          _SideNav(
            selectedIndex: index,
            onSelect: (i) => setState(() => index = i),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: 250.ms,
              switchInCurve: Curves.easeOutCubic,
              child: pages[index],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Custom left sidebar (uniform + hover)
/// ─────────────────────────────────────────────
class _SideNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _SideNav({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    final icons = [
      Icons.calendar_month, // Calendar
      Icons.check_circle,   // Todos
      Icons.timer,          // Timer
      Icons.view_agenda,    // Overview (coming soon)
      Icons.settings,       // Settings
    ];

    return Container(
      width: 72,
      color: Colors.black.withOpacity(0.15),
      child: Column(
        children: [
          const Spacer(),
          for (int i = 0; i < icons.length; i++)
            _NavIcon(
              icon: icons[i],
              selected: selectedIndex == i,
              accent: accent,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _NavIcon extends StatefulWidget {
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? widget.accent
        : hover
            ? Colors.white
            : Colors.white54;

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.accent.withOpacity(0.15)
                : hover
                    ? Colors.white.withOpacity(0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            widget.icon,
            size: 28,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Content wrapper (for non-calendar tabs)
/// ─────────────────────────────────────────────
class _ContentShell extends StatelessWidget {
  final Widget child;
  const _ContentShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(24),
          ),
          child: child,
        ),
      ),
    );
  }
}
