import 'package:flutter/material.dart';

class Goal {
  final int? id;
  final String title;
  final String description;
  final DateTime targetDate;
  final Color color;
  final IconData icon;
  final DateTime createdAt;
  final bool isArchived;

  Goal({
    this.id,
    required this.title,
    this.description = '',
    required this.targetDate,
    this.color = const Color(0xFF6C63FF),
    this.icon = Icons.flag,
    DateTime? createdAt,
    this.isArchived = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetDate': targetDate.toIso8601String(),
      'color': color.value,
      'icon': icon.codePoint,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived ? 1 : 0,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      targetDate: DateTime.parse(map['targetDate'] as String),
      color: Color(map['color'] as int),
      // ignore: prefer_const_constructors
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isArchived: (map['isArchived'] as int) == 1,
    );
  }

  Goal copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? targetDate,
    Color? color,
    IconData? icon,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}