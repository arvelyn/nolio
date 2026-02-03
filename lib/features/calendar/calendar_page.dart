import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

class _CalendarPageState extends State<CalendarPage> {
  static const double blur = 24;
  final TextEditingController addCtrl = TextEditingController();
  List<Map<String, dynamic>> todos = [];

  String get dateKey =>
      widget.selectedDate.toIso8601String().split('T')[0];

  @override
  void initState() {
    super.initState();
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
    if (mounted) setState(() => todos = data);
  }

  Future<void> addTodo() async {
    if (addCtrl.text.trim().isEmpty) return;
    await TodoDB.instance.addTodo(dateKey, addCtrl.text, '');
    addCtrl.clear();
    await loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2035),
                  focusedDay: widget.selectedDate,
                  selectedDayPredicate: (d) =>
                      isSameDay(d, widget.selectedDate),
                  onDaySelected: (d, _) =>
                      widget.onDateSelected(d),
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: accent.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: -0.1),

                const SizedBox(height: 12),

                TextField(
                  controller: addCtrl,
                  onSubmitted: (_) => addTodo(),
                  decoration: InputDecoration(
                    hintText: 'Add task for this day',
                    filled: true,
                    fillColor:
                        Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: addTodo,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, i) {
                      final t = todos[i];
                      final raw = t['tag']?.toString() ?? '';
                      String tag = '';
                      Color tagColor = Colors.grey;

                      if (raw.contains('|')) {
                        final parts = raw.split('|');
                        tag = parts[0];
                        tagColor = Color(int.parse(parts[1]));
                      }

                      return GestureDetector(
                        onTap: widget.onOpenTodos,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              left: BorderSide(
                                width: 4,
                                color: accent,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.task_alt, size: 18),
                              const SizedBox(width: 10),
                              Expanded(child: Text(t['text'])),
                              if (tag.isNotEmpty)
                                Chip(
                                  avatar: Icon(Icons.tag, size: 14, color: tagColor),
                                  label: Text(tag),
                                ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2);
                    },
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
