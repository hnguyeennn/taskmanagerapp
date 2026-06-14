import 'package:flutter/material.dart';

class Tag {
  final int? id;
  final String name;
  final Color color;
  final DateTime createdAt;

  Tag({
    this.id,
    required this.name,
    required this.color,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.toARGB32(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Tag copyWith({
    int? id,
    String? name,
    Color? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}