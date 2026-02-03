import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TodoDB {
  static final TodoDB instance = TodoDB._internal();
  TodoDB._internal();

  late Database db;

  Future<void> init() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dir = await getApplicationSupportDirectory();
    final path = join(dir.path, 'nolio.db');

    db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            text TEXT NOT NULL,
            tag TEXT,
            position INTEGER,
            done INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, old, _) async {
        if (old < 2) {
          await db.execute('ALTER TABLE todos ADD COLUMN tag TEXT');
          await db.execute('ALTER TABLE todos ADD COLUMN position INTEGER');
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getTodos(String date) async {
    return db.query(
      'todos',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'position ASC',
    );
  }

  Future<void> addTodo(String date, String text, String tag) async {
    final res = await db.rawQuery(
      'SELECT MAX(position) as maxPos FROM todos WHERE date = ?',
      [date],
    );

    final maxPos =
        res.isNotEmpty && res.first['maxPos'] != null
            ? res.first['maxPos'] as int
            : 0;

    await db.insert('todos', {
      'date': date,
      'text': text,
      'tag': tag,
      'position': maxPos + 1,
      'done': 0,
    });
  }

  Future<void> reorder(int id, int newPos) async {
    await db.update(
      'todos',
      {'position': newPos},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleDone(int id, bool done) async {
    await db.update(
      'todos',
      {'done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTodo(int id) async {
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
