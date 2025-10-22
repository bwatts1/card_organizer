import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'cards_screen.dart';

class CardModel {
  final int? id;
  final String name;
  final String suit; 
  final String imageUrl;
  final int? folderId; 

  CardModel({
    this.id,
    required this.name,
    required this.suit,
    required this.imageUrl,
    this.folderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'suit': suit,
      'image_url': imageUrl,
      'folder_id': folderId,
    };
  }

  factory CardModel.fromMap(Map<String, dynamic> m) {
    return CardModel(
      id: m['id'] as int?,
      name: m['name'] as String,
      suit: m['suit'] as String,
      imageUrl: m['image_url'] as String,
      folderId: m['folder_id'] as int?,
    );
  }

  String displayName() {
    return '$name of $suit';
  }
}
