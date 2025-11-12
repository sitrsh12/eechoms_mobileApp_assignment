// -----------------------
// Repository (SharedPreferences)
// -----------------------
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/todo_model.dart';

class TodoRepository {
  static const _kKey = 'todos_v1';
  final SharedPreferences prefs;

  TodoRepository(this.prefs);

  List<Todo> loadTodos() {
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list.map((e) => Todo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final raw = json.encode(todos.map((t) => t.toJson()).toList());
    await prefs.setString(_kKey, raw);
  }
}