import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final String color;
  final IconData icon;
  final DateTime createdAt;

  const Category({
    this.id,
    required this.name,
    required this.color,
    this.icon = Icons.label,
    required this.createdAt,
  });

  // Copy with method for immutable updates
  Category copyWith({
    int? id,
    String? name,
    String? color,
    IconData? icon,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create Category from Map (database result)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      color: map['color'] ?? '#2196F3',
      icon: IconData(
        map['iconCodePoint'] ?? Icons.label.codePoint,
        fontFamily: map['iconFontFamily'],
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'iconCodePoint': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toInt(),
      name: json['name'] ?? '',
      color: json['color'] ?? '#2196F3',
      icon: IconData(
        json['iconCodePoint'] ?? Icons.label.codePoint,
        fontFamily: json['iconFontFamily'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Get Color object from hex string
  Color get colorValue {
    final hexColor = color.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.icon == icon &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, color, icon, createdAt);
  }
}

// Predefined categories
class DefaultCategories {
  static final List<Category> defaults = [
    Category(
      name: 'Personal',
      color: '#2196F3',
      icon: Icons.person,
      createdAt: DateTime.now(),
    ),
    Category(
      name: 'Work',
      color: '#FF9800',
      icon: Icons.work,
      createdAt: DateTime.now(),
    ),
    Category(
      name: 'Shopping',
      color: '#4CAF50',
      icon: Icons.shopping_cart,
      createdAt: DateTime.now(),
    ),
    Category(
      name: 'Health',
      color: '#E53E3E',
      icon: Icons.favorite,
      createdAt: DateTime.now(),
    ),
    Category(
      name: 'Study',
      color: '#9C27B0',
      icon: Icons.school,
      createdAt: DateTime.now(),
    ),
  ];
}
