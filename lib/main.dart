import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'data/todo_db.dart';
import 'features/calendar/calendar_page.dart';
import 'features/timer/timer_page.dart';
import 'features/timeline/timeline_page.dart';
import 'features/settings/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TodoDB.instance.init();

  runApp(const NolioApp());
}

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
      ),
      const _ContentShell(child: TimerPage()),
      const _ContentShell(child: TimelinePage()),
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
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                    ),
                    child: child,
                  ),
                );
              },
              child: pages[index],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Custom left sidebar with smooth animations
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
      Icons.timer,          // Timer
      Icons.view_agenda,    // Timeline
      Icons.settings,       // Settings
    ];

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
      ),
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

class _NavIconState extends State<_NavIcon> with SingleTickerProviderStateMixin {
  bool hover = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_NavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _controller.forward();
    } else if (!widget.selected && oldWidget.selected) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? widget.accent
        : hover
            ? Colors.white
            : Colors.white54;

    return MouseRegion(
      onEnter: (_) {
        if (!widget.selected) {
          setState(() => hover = true);
        }
      },
      onExit: (_) {
        if (!widget.selected) {
          setState(() => hover = false);
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutQuad,
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
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Content wrapper with smooth animations
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
    )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeInOutCubic)
        .slideX(begin: 0.05, duration: 400.ms, curve: Curves.easeInOutCubic);
  }
}