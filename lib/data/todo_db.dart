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

    final Directory dir = await getApplicationSupportDirectory();
    final String path = join(dir.path, 'nolio.db');

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            text TEXT NOT NULL,
            done INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getTodos(String date) async {
    return db.query(
      'todos',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
  }

  Future<void> addTodo(String date, String text) async {
    await db.insert('todos', {
      'date': date,
      'text': text,
      'done': 0,
    });
  }

  Future<void> toggleDone(int id, bool done) async {
    await db.update(
      'todos',
      {'done': done ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
