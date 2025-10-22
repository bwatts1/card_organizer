import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'cards_screen.dart';

class FolderModel {
  final int? id;
  final String name;
  final DateTime createdAt;

  FolderModel({this.id, required this.name, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FolderModel.fromMap(Map<String, dynamic> m) {
    return FolderModel(
      id: m['id'] as int?,
      name: m['name'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }
}
