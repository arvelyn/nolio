import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/todo_db.dart';

class TodosPage extends StatefulWidget {
  final DateTime selectedDate;
  const TodosPage({super.key, required this.selectedDate});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  final taskCtrl = TextEditingController();
  final tagCtrl = TextEditingController();
  Color tagColor = Colors.blue;

  List<Map<String, dynamic>> todos = [];

  String get dateKey =>
      widget.selectedDate.toIso8601String().split('T')[0];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    todos = await TodoDB.instance.getTodos(dateKey);
    setState(() {});
  }

  Future<void> add() async {
    if (taskCtrl.text.trim().isEmpty) return;
    await TodoDB.instance.addTodo(
      dateKey,
      taskCtrl.text,
      '${tagCtrl.text}|${tagColor.value}',
    );
    taskCtrl.clear();
    tagCtrl.clear();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: taskCtrl,
                  decoration: const InputDecoration(labelText: 'Task'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: tagCtrl,
                  decoration: const InputDecoration(labelText: '#tag'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.color_lens, color: tagColor),
                onPressed: () async {
                  final c = await showDialog<Color>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Tag color'),
                      content: Wrap(
                        spacing: 14,
                        runSpacing: 14, 
                        children: Colors.primaries.map((c) {
                          return GestureDetector(
                            onTap: () => Navigator.pop(context, c),
                            child: CircleAvatar(backgroundColor: c),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                  if (c != null) setState(() => tagColor = c);
                },
              ),
              IconButton(
                icon: Icon(Icons.add, color: accent),
                onPressed: add,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ReorderableListView(
              onReorder: (oldI, newI) async {
                if (newI > oldI) newI--;
                final item = todos.removeAt(oldI);
                todos.insert(newI, item);
                setState(() {});
                for (int i = 0; i < todos.length; i++) {
                  await TodoDB.instance.reorder(todos[i]['id'], i);
                }
              },
              children: [
                for (final t in todos)
                  KeyedSubtree(
                    key: ValueKey(t['id']),
                    child: _TodoCard(t: t),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  final Map<String, dynamic> t;
  const _TodoCard({required this.t});

  @override
  Widget build(BuildContext context) {
    String tag = '';
    Color tagColor = Colors.grey;

    if (t['tag'] != null && t['tag'].toString().contains('|')) {
      final parts = t['tag'].split('|');
      tag = parts[0];
      tagColor = Color(int.parse(parts[1]));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            width: 4,
            color: Theme.of(context).colorScheme.primary,
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
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}
