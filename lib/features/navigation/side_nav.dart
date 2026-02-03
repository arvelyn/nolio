import 'package:flutter/material.dart';

class _SideNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _SideNav({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    final items = [
      Icons.calendar_month,
      Icons.check_circle,
      Icons.timer,
      Icons.timeline,
      Icons.settings,
    ];

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
      ),
      child: Column(
        children: [
          const Spacer(),
          for (int i = 0; i < items.length; i++)
            _NavIcon(
              icon: items[i],
              selected: selected == i,
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
          child: Icon(widget.icon, size: 28, color: color),
        ),
      ),
    );
  }
}
