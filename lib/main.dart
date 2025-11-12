import 'dart:convert';

import 'package:classwork/repository/todo_repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/home_screen.dart';
import 'helper/state.dart';
import 'helper/theme_helper.dart';
import 'model/todo_model.dart';

// -----------------------
// App
// -----------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repo = TodoRepository(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(false)),
        ChangeNotifierProvider(create: (_) => TodoProvider(repository: repo)),
      ],
      child: const TodoApp(),
    ),
  );
}

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);
  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  @override
  void initState() {
    super.initState();
    // load todos once provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, theme, _) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Polished ToDo',
        theme: _lightTheme,
        darkTheme: _darkTheme,
        themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
        home: const HomeScreen(),
      );
    });
  }
}

final _lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.indigo,
  useMaterial3: true,
);

final _darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.indigo,
  useMaterial3: true,
);

