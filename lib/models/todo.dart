class Todo {
  final int? id;
  final String task;
  final bool isDone;

  Todo({
    this.id,
    required this.task,
    this.isDone = false,
  });

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      task: map['task'] as String,
      isDone: map['is_done'] == 'Y',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'is_done': isDone ? 'Y' : 'N',
    };
  }

  Todo copyWith({
    int? id,
    String? task,
    bool? isDone,
  }) {
    return Todo(
      id: id ?? this.id,
      task: task ?? this.task,
      isDone: isDone ?? this.isDone,
    );
  }
}
