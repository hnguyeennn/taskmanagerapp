enum PomodoroType { work, shortBreak, longBreak }

class PomodoroSession {
  final int? id;
  final int? taskId;
  final DateTime startTime;
  final int durationMinutes;
  final PomodoroType type;
  final bool completed;

  PomodoroSession({
    this.id,
    this.taskId,
    required this.startTime,
    required this.durationMinutes,
    this.type = PomodoroType.work,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'type': type.index,
      'completed': completed ? 1 : 0,
    };
  }

  factory PomodoroSession.fromMap(Map<String, dynamic> map) {
    return PomodoroSession(
      id: map['id'] as int?,
      taskId: map['taskId'] as int?,
      startTime: DateTime.parse(map['startTime'] as String),
      durationMinutes: map['durationMinutes'] as int,
      type: PomodoroType.values[map['type'] as int],
      completed: (map['completed'] as int) == 1,
    );
  }

  PomodoroSession copyWith({
    int? id,
    int? taskId,
    DateTime? startTime,
    int? durationMinutes,
    PomodoroType? type,
    bool? completed,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      type: type ?? this.type,
      completed: completed ?? this.completed,
    );
  }
}