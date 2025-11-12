// -----------------------
// State
// -----------------------
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/todo_model.dart';
import '../repository/todo_repo.dart';
import 'package:provider/provider.dart';

enum TodoFilter { all, active, done }

class TodoProvider extends ChangeNotifier {
  final TodoRepository repository;
  List<Todo> _todos = [];
  String _search = '';
  TodoFilter _filter = TodoFilter.all;

  TodoProvider({required this.repository});

  List<Todo> get todos => List.unmodifiable(_todos);
  String get search => _search;
  TodoFilter get filter => _filter;

  List<Todo> get visibleTodos {
    final base = _todos.where((t) {
      if (_filter == TodoFilter.active) return !t.done;
      if (_filter == TodoFilter.done) return t.done;
      return true;
    }).toList();

    if (_search.isEmpty) return base;
    final q = _search.toLowerCase();
    return base.where((t) => t.title.toLowerCase().contains(q) || t.note.toLowerCase().contains(q)).toList();
  }

  Future<void> load() async {
    _todos = repository.loadTodos();
    notifyListeners();
  }

  Future<void> addTodo(String title, {String note = ''}) async {
    final t = Todo(id: DateTime.now().microsecondsSinceEpoch.toString(), title: title, note: note);
    _todos.insert(0, t);
    await repository.saveTodos(_todos);
    notifyListeners();
  }

  Future<void> updateTodo(Todo todo) async {
    final idx = _todos.indexWhere((t) => t.id == todo.id);
    if (idx != -1) {
      _todos[idx] = todo;
      await repository.saveTodos(_todos);
      notifyListeners();
    }
  }

  Future<void> toggleDone(String id) async {
    final idx = _todos.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _todos[idx].done = !_todos[idx].done;
    // move completed items to bottom for clarity
    final changed = _todos.removeAt(idx);
    if (changed.done) {
      _todos.add(changed);
    } else {
      _todos.insert(0, changed);
    }
    await repository.saveTodos(_todos);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _todos.removeWhere((t) => t.id == id);
    await repository.saveTodos(_todos);
    notifyListeners();
  }

  void setSearch(String q) {
    _search = q;
    notifyListeners();
  }

  void setFilter(TodoFilter f) {
    _filter = f;
    notifyListeners();
  }
}