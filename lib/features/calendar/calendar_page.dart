import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/todo_db.dart';

class CalendarPage extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onOpenTodos;

  const CalendarPage({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onOpenTodos,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  late DateTime focusedDay;
  List<Map<String, dynamic>> todos = [];
  bool expanded = true;

  final TextEditingController addController = TextEditingController();

  String get dateKey =>
      widget.selectedDate.toIso8601String().split('T')[0];

  @override
  void initState() {
    super.initState();
    focusedDay = widget.selectedDate;
    loadTodos();
  }

  @override
  void didUpdateWidget(covariant CalendarPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      loadTodos();
    }
  }

  Future<void> loadTodos() async {
    final data = await TodoDB.instance.getTodos(dateKey);
    setState(() => todos = data);
  }

  Future<void> addTodo() async {
    final text = addController.text.trim();
    if (text.isEmpty) return;

    await TodoDB.instance.addTodo(dateKey, text);
    addController.clear();
    loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    final blur = 20.0; // centralized → easy to adapt later

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ───────── Calendar ─────────
                TableCalendar(
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2035),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (d) =>
                      isSameDay(widget.selectedDate, d),
                  onDaySelected: (d, f) {
                    widget.onDateSelected(d);
                    setState(() => focusedDay = f);
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, day, _) {
                      return _AnimatedBlob(day: day);
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // ───────── Header row ─────────
                Row(
                  children: [
                    Text(
                      'Tasks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: expanded ? 0.5 : 0,
                        child: const Icon(Icons.expand_more),
                      ),
                      onPressed: () =>
                          setState(() => expanded = !expanded),
                    ),
                  ],
                ),

                // ───────── Inline add ─────────
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: expanded
                      ? Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          child: TextField(
                            controller: addController,
                            onSubmitted: (_) => addTodo(),
                            decoration: InputDecoration(
                              hintText: 'Add task',
                              filled: true,
                              fillColor:
                                  Colors.white.withOpacity(0.08),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // ───────── Task list ─────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    child: !expanded
                        ? const SizedBox.shrink()
                        : todos.isEmpty
                            ? Center(
                                child: Text(
                                  'No tasks',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: todos.length,
                                itemBuilder: (context, i) {
                                  final t = todos[i];
                                  return _HoverTaskRow(
                                    text: t['text'],
                                    done: t['done'] == 1,
                                    onTap: widget.onOpenTodos,
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Smooth organic date selector
class _AnimatedBlob extends StatelessWidget {
  final DateTime day;
  const _AnimatedBlob({required this.day});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          '${day.day}',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Hover + click task row
class _HoverTaskRow extends StatefulWidget {
  final String text;
  final bool done;
  final VoidCallback onTap;

  const _HoverTaskRow({
    required this.text,
    required this.done,
    required this.onTap,
  });

  @override
  State<_HoverTaskRow> createState() => _HoverTaskRowState();
}

class _HoverTaskRowState extends State<_HoverTaskRow> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hover
                ? Colors.white.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                widget.done
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 18,
                color: widget.done
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    decoration: widget.done
                        ? TextDecoration.lineThrough
                        : null,
                    color: widget.done
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
