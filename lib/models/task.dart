import 'package:flutter/material.dart';

enum Priority { low, medium, high }

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.low: return 'Thấp';
      case Priority.medium: return 'Trung bình';
      case Priority.high: return 'Cao';
    }
  }

  Color get color {
    switch (this) {
      case Priority.low: return const Color(0xFF38A169);
      case Priority.medium: return const Color(0xFFFF9800);
      case Priority.high: return const Color(0xFFE53E3E);
    }
  }
}

enum Category { work, study, personal, health, other }

extension CategoryExtension on Category {
  String get label {
    switch (this) {
      case Category.work: return 'Công việc';
      case Category.study: return 'Học tập';
      case Category.personal: return 'Cá nhân';
      case Category.health: return 'Sức khỏe';
      case Category.other: return 'Khác';
    }
  }

  IconData get icon {
    switch (this) {
      case Category.work: return Icons.business_center;
      case Category.study: return Icons.school;
      case Category.personal: return Icons.person;
      case Category.health: return Icons.favorite;
      case Category.other: return Icons.label;
    }
  }

  Color get color {
    switch (this) {
      case Category.work: return const Color(0xFF3182CE);
      case Category.study: return const Color(0xFF805AD5);
      case Category.personal: return const Color(0xFFD53F8C);
      case Category.health: return const Color(0xFF38A169);
      case Category.other: return const Color(0xFF718096);
    }
  }
}

// MỚI: Loại lặp lại
enum RecurringType { none, daily, weekly, monthly, yearly }

extension RecurringTypeExtension on RecurringType {
  String get label {
    switch (this) {
      case RecurringType.none: return 'Không lặp';
      case RecurringType.daily: return 'Hàng ngày';
      case RecurringType.weekly: return 'Hàng tuần';
      case RecurringType.monthly: return 'Hàng tháng';
      case RecurringType.yearly: return 'Hàng năm';
    }
  }

  IconData get icon {
    switch (this) {
      case RecurringType.none: return Icons.refresh;
      case RecurringType.daily: return Icons.today;
      case RecurringType.weekly: return Icons.view_week;
      case RecurringType.monthly: return Icons.calendar_month;
      case RecurringType.yearly: return Icons.event;
    }
  }

  // Tính ngày lặp tiếp theo
  DateTime? getNextDate(DateTime currentDate) {
    switch (this) {
      case RecurringType.none: return null;
      case RecurringType.daily: return currentDate.add(const Duration(days: 1));
      case RecurringType.weekly: return currentDate.add(const Duration(days: 7));
      case RecurringType.monthly:
        return DateTime(currentDate.year, currentDate.month + 1, currentDate.day,
            currentDate.hour, currentDate.minute);
      case RecurringType.yearly:
        return DateTime(currentDate.year + 1, currentDate.month, currentDate.day,
            currentDate.hour, currentDate.minute);
    }
  }
}

class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final Priority priority;
  final Category category;
  final bool isCompleted;
  final bool hasReminder;
  final DateTime? reminderTime;
  final DateTime createdAt;
  
  // MỚI
  final RecurringType recurringType;
  final DateTime? recurringEndDate;
  final int? parentTaskId;
  final int? goalId;
  final DateTime? completedAt;
  final int pomodoroCount;

  Task({
    this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = Priority.medium,
    this.category = Category.other,
    this.isCompleted = false,
    this.hasReminder = false,
    this.reminderTime,
    DateTime? createdAt,
    this.recurringType = RecurringType.none,
    this.recurringEndDate,
    this.parentTaskId,
    this.goalId,
    this.completedAt,
    this.pomodoroCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.index,
      'category': category.index,
      'isCompleted': isCompleted ? 1 : 0,
      'hasReminder': hasReminder ? 1 : 0,
      'reminderTime': reminderTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'recurringType': recurringType.index,
      'recurringEndDate': recurringEndDate?.toIso8601String(),
      'parentTaskId': parentTaskId,
      'goalId': goalId,
      'completedAt': completedAt?.toIso8601String(),
      'pomodoroCount': pomodoroCount,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      dueDate: DateTime.parse(map['dueDate'] as String),
      priority: Priority.values[map['priority'] as int],
      category: Category.values[map['category'] as int],
      isCompleted: (map['isCompleted'] as int) == 1,
      hasReminder: (map['hasReminder'] as int) == 1,
      reminderTime: map['reminderTime'] != null
          ? DateTime.parse(map['reminderTime'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      recurringType: RecurringType.values[map['recurringType'] as int? ?? 0],
      recurringEndDate: map['recurringEndDate'] != null
          ? DateTime.parse(map['recurringEndDate'] as String)
          : null,
      parentTaskId: map['parentTaskId'] as int?,
      goalId: map['goalId'] as int?,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      pomodoroCount: map['pomodoroCount'] as int? ?? 0,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    Category? category,
    bool? isCompleted,
    bool? hasReminder,
    DateTime? reminderTime,
    DateTime? createdAt,
    RecurringType? recurringType,
    DateTime? recurringEndDate,
    int? parentTaskId,
    int? goalId,
    DateTime? completedAt,
    int? pomodoroCount,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      recurringType: recurringType ?? this.recurringType,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      goalId: goalId ?? this.goalId,
      completedAt: completedAt ?? this.completedAt,
      pomodoroCount: pomodoroCount ?? this.pomodoroCount,
    );
  }

  bool get isOverdue {
    return !isCompleted && dueDate.isBefore(DateTime.now());
  }

  bool get isRecurring => recurringType != RecurringType.none;
}