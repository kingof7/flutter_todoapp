class TaskItem {
  final int? id;
  final String title;
  final bool isDone;

  TaskItem({
    this.id,
    required this.title,
    this.isDone = false,
  });

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      isDone: map['done'] == 'Y',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'done': isDone ? 'Y' : 'N',
    };
  }

  TaskItem copyWith({
    int? id,
    String? title,
    bool? isDone,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
