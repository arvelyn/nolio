import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/todo_db.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  bool loading = true;
  late DateTime weekStart;
  List<_DayTasks> weekTasks = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    weekStart = _startOfWeek(now);
    _loadWeek();
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1));
  }

  String _dateKey(DateTime date) => date.toIso8601String().split('T')[0];

  String _weekdayLabel(DateTime date) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }

  String _monthLabel(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }

  String _weekRangeLabel() {
    final end = weekStart.add(const Duration(days: 6));
    final startLabel = '${_monthLabel(weekStart.month)} ${weekStart.day}';
    final endLabel = '${_monthLabel(end.month)} ${end.day}';
    return '$startLabel - $endLabel';
  }

  Future<void> _loadWeek() async {
    setState(() => loading = true);
    final data = <_DayTasks>[];

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final todos = await TodoDB.instance.getTodos(_dateKey(day));
      data.add(_DayTasks(date: day, todos: todos));
    }

    if (!mounted) return;
    setState(() {
      weekTasks = data;
      loading = false;
    });
  }

  Future<void> _toggleDone(int id, bool done) async {
    await TodoDB.instance.toggleDone(id, done);
    await _loadWeek();
  }

  Color _tagColor(String raw) {
    if (!raw.contains('|')) return Colors.grey;
    final parts = raw.split('|');
    if (parts.length != 2) return Colors.grey;
    return Color(int.tryParse(parts[1]) ?? Colors.grey.toARGB32());
  }

  String _tagLabel(String raw) {
    if (!raw.contains('|')) return '';
    final parts = raw.split('|');
    if (parts.isEmpty) return '';
    return parts[0];
  }

  List<_WeekTodoItem> _flattenedWeekTodos() {
    final items = <_WeekTodoItem>[];
    for (final day in weekTasks) {
      for (final todo in day.todos) {
        items.add(_WeekTodoItem(date: day.date, todo: todo));
      }
    }

    items.sort((a, b) {
      final dayCompare = a.date.compareTo(b.date);
      if (dayCompare != 0) return dayCompare;
      final aPos = a.todo['position'] as int? ?? 0;
      final bPos = b.todo['position'] as int? ?? 0;
      return aPos.compareTo(bPos);
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final weekItems = _flattenedWeekTodos();
    final totalTasks = weekTasks.fold<int>(0, (sum, d) => sum + d.todos.length);
    final doneTasks = weekTasks.fold<int>(
      0,
      (sum, d) =>
          sum + d.todos.where((t) => (t['done'] as int? ?? 0) == 1).length,
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Timeline',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _weekRangeLabel(),
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _loadWeek,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Icon(Icons.refresh, color: accent, size: 20),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 350.ms, curve: Curves.easeInOutCubic)
              .slideY(
                begin: -0.08,
                duration: 350.ms,
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              '$doneTasks / $totalTasks completed',
              style: const TextStyle(color: Colors.white70),
            ),
          ).animate().fadeIn(
            delay: 80.ms,
            duration: 300.ms,
            curve: Curves.easeInOutCubic,
          ),

          const SizedBox(height: 18),

          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator(color: accent))
                : weekItems.isEmpty
                ? Center(
                    child: Text(
                      'No tasks this week',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white60),
                    ),
                  )
                : ListView.builder(
                    itemCount: weekItems.length,
                    itemBuilder: (context, index) {
                      final item = weekItems[index];
                      final todo = item.todo;
                      final date = item.date;
                      final isToday =
                          _dateKey(date) == _dateKey(DateTime.now());
                      final isDone = (todo['done'] as int? ?? 0) == 1;
                      final rawTag = todo['tag']?.toString() ?? '';
                      final tag = _tagLabel(rawTag);
                      final tagColor = _tagColor(rawTag);

                      return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border(
                                left: BorderSide(
                                  width: 3,
                                  color: isDone
                                      ? accent.withValues(alpha: 0.25)
                                      : accent,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      _toggleDone(todo['id'] as int, !isDone),
                                  child: Icon(
                                    isDone
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 19,
                                    color: isDone ? accent : Colors.white54,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo['text']?.toString() ?? '',
                                        style: TextStyle(
                                          color: isDone
                                              ? Colors.white54
                                              : Colors.white,
                                          decoration: isDone
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isToday
                                                  ? accent.withValues(
                                                      alpha: 0.15,
                                                    )
                                                  : Colors.white.withValues(
                                                      alpha: 0.06,
                                                    ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '${_weekdayLabel(date)} ${date.day}',
                                              style: TextStyle(
                                                color: isToday
                                                    ? accent
                                                    : Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (tag.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: tagColor.withValues(
                                                  alpha: 0.16,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                tag,
                                                style: TextStyle(
                                                  color: tagColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 80 + (index * 40)),
                            duration: 320.ms,
                            curve: Curves.easeInOutCubic,
                          )
                          .slideY(
                            begin: 0.18,
                            delay: Duration(milliseconds: 80 + (index * 40)),
                            duration: 320.ms,
                            curve: Curves.easeOutCubic,
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DayTasks {
  final DateTime date;
  final List<Map<String, dynamic>> todos;

  const _DayTasks({required this.date, required this.todos});
}

class _WeekTodoItem {
  final DateTime date;
  final Map<String, dynamic> todo;

  const _WeekTodoItem({required this.date, required this.todo});
}
