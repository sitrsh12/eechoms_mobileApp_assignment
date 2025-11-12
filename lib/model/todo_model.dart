
// -----------------------
// Model
// -----------------------
class Todo {
  String id;
  String title;
  String note;
  bool done;
  DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.note = '',
    this.done = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'note': note,
    'done': done,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    title: json['title'],
    note: json['note'] ?? '',
    done: json['done'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
  );
}