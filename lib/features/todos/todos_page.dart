import 'package:flutter/material.dart';
import '../../data/todo_db.dart';

class TodosPage extends StatefulWidget {
  final DateTime selectedDate;
  const TodosPage({super.key, required this.selectedDate});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> todos = [];

  String get dateKey =>
      widget.selectedDate.toIso8601String().split('T')[0];

  @override
  void didUpdateWidget(covariant TodosPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      loadTodos();
    }
  }

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Future<void> loadTodos() async {
    final data = await TodoDB.instance.getTodos(dateKey);
    setState(() => todos = data);
  }

  Future<void> addTodo() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    await TodoDB.instance.addTodo(dateKey, text);
    controller.clear();
    loadTodos();
  }

  Future<void> toggle(int id, bool done) async {
    await TodoDB.instance.toggleDone(id, done);
    loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Add todo',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => addTodo(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: addTodo,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: todos.isEmpty
                ? const Center(child: Text('No todos'))
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, i) {
                      final t = todos[i];
                      return Card(
                        elevation: 0,
                        margin:
                            const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CheckboxListTile(
                          value: t['done'] == 1,
                          title: Text(
                            t['text'],
                            style: TextStyle(
                              decoration: t['done'] == 1
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          onChanged: (v) =>
                              toggle(t['id'], v ?? false),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
