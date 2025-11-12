import 'dart:convert';

import 'package:eecohm_mobile_assignment/repository/todo_repo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/state.dart';
import '../helper/theme_helper.dart';
import '../model/todo_model.dart';


// -----------------------
// Home Screen
// -----------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchCtrl = TextEditingController();

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => themeNotifier.toggle(),
            icon: Consumer<ThemeNotifier>(builder: (_, t, __) {
              return Icon(t.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined);
            }),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _buildSearchRow(context),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildFilterChips(),
          const SizedBox(height: 8),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    return TextField(
      controller: searchCtrl,
      onChanged: provider.setSearch,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search tasks or notes',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            searchCtrl.clear();
            provider.setSearch('');
          },
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.06),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<TodoProvider>(builder: (context, provider, _) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _buildChip('All', TodoFilter.all, provider.filter == TodoFilter.all, provider),
            const SizedBox(width: 8),
            _buildChip('Active', TodoFilter.active, provider.filter == TodoFilter.active, provider),
            const SizedBox(width: 8),
            _buildChip('Done', TodoFilter.done, provider.filter == TodoFilter.done, provider),
            const Spacer(),
            Text(
              '${provider.todos.where((t) => !t.done).length} open',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChip(String label, TodoFilter f, bool selected, TodoProvider provider) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => provider.setFilter(f),
    );
  }

  Widget _buildList() {
    return Consumer<TodoProvider>(builder: (context, provider, _) {
      final items = provider.visibleTodos;
      if (items.isEmpty) {
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.task_alt_outlined, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
            const SizedBox(height: 8),
            const Text('No tasks here', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Tap + to create your first task', style: TextStyle(color: Colors.grey)),
          ]),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final t = items[index];
          return Dismissible(
            key: ValueKey(t.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.error.withOpacity(0.95), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => provider.remove(t.id),
            child: _TodoCard(todo: t),
          );
        },
      );
    });
  }

  void _openAddSheet(BuildContext context, {Todo? edit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: TodoFormSheet(existing: edit),
      ),
    );
  }
}

// -----------------------
// Todo Card (animated)
// -----------------------
class _TodoCard extends StatelessWidget {
  final Todo todo;
  const _TodoCard({required this.todo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: todo.done ? theme.colorScheme.surface.withOpacity(0.6) : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: GestureDetector(
          onTap: () => provider.toggleDone(todo.id),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: todo.done
                ? const Icon(Icons.check_circle, key: ValueKey('done'), size: 28, color: Colors.green)
                : const Icon(Icons.radio_button_unchecked, key: ValueKey('undone'), size: 28),
          ),
        ),
        title: Text(
          todo.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: todo.done ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: todo.note.isNotEmpty ? Text(todo.note, maxLines: 2, overflow: TextOverflow.ellipsis) : null,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEdit(context),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => provider.remove(todo.id),
          )
        ]),
        onTap: () => provider.toggleDone(todo.id),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: TodoFormSheet(existing: todo),
      ),
    );
  }
}

// -----------------------
// Add / Edit sheet
// -----------------------
class TodoFormSheet extends StatefulWidget {
  final Todo? existing;
  const TodoFormSheet({this.existing, Key? key}) : super(key: key);

  @override
  State<TodoFormSheet> createState() => _TodoFormSheetState();
}

class _TodoFormSheetState extends State<TodoFormSheet> {
  late final TextEditingController _titleCtl;
  late final TextEditingController _noteCtl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.existing?.title ?? '');
    _noteCtl = TextEditingController(text: widget.existing?.note ?? '');
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _noteCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final provider = Provider.of<TodoProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(height: 4, width: 40, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8))),
        Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _titleCtl,
              autofocus: true,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteCtl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final title = _titleCtl.text.trim();
                    final note = _noteCtl.text.trim();
                    if (isEdit) {
                      final old = widget.existing!;
                      final updated = Todo(id: old.id, title: title, note: note, done: old.done, createdAt: old.createdAt);
                      await provider.updateTodo(updated);
                    } else {
                      await provider.addTodo(title, note: note);
                    }
                    if (!mounted) return;
                    Navigator.pop(context);
                  },
                  child: Text(isEdit ? 'Save changes' : 'Add task'),
                ),
              ),
            ])
          ]),
        )
      ]),
    );
  }
}
