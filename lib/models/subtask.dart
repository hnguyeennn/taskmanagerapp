class SubTask {
  final int? id;
  final int taskId;
  final String title;
  final bool isCompleted;
  final int sortOrder;

  SubTask({
    this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'sortOrder': sortOrder,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] as int?,
      taskId: map['taskId'] as int,
      title: map['title'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }

  SubTask copyWith({
    int? id,
    int? taskId,
    String? title,
    bool? isCompleted,
    int? sortOrder,
  }) {
    return SubTask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}