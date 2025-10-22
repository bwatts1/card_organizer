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
      'folder_name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FolderModel.fromMap(Map<String, dynamic> m) {
    return FolderModel(
      id: m['folder_id'] as int?,
      name: m['folder_name'] as String,
      createdAt: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({Key? key}) : super(key: key);

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<FolderModel> folders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    setState(() => _isLoading = true);

    final data = await dbHelper.queryAllFolders();
    folders = data.map((m) => FolderModel.fromMap(m)).toList();

    if (folders.isEmpty) {
      await _createDefaultFolders();
      final refreshedData = await dbHelper.queryAllFolders();
      folders = refreshedData.map((m) => FolderModel.fromMap(m)).toList();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _createDefaultFolders() async {
    final defaultNames = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    for (final name in defaultNames) {
      final id = await dbHelper.insertFolder({
        'folder_name': name,
        'created_at': DateTime.now().toIso8601String(),
      });
      folders.add(FolderModel(id: id, name: name));
      print("Created folder '$name' with ID $id"); // Optional log
    }
  }

  void _openFolder(FolderModel folder) {
    if (folder.id == null) {
      print("Error: Folder ID is missing!");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardsScreen(folder: folder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Card Organizer - Folders"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return ListTile(
                  leading: const Icon(Icons.folder, color: Colors.blueAccent),
                  title: Text(folder.name),
                  subtitle: Text(
                    "Created: ${folder.createdAt.toLocal().toString().split('.')[0]}",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openFolder(folder),
                );
              },
            ),
    );
  }
}
