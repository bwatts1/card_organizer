import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static const _databaseName = "CardAppDatabase.db";
  static const _databaseVersion = 1;

  static const folderTable = 'folders';
  static const cardTable = 'cards';

  static const columnFolderId = 'folder_id';
  static const columnFolderName = 'folder_name';

  static const columnCardId = 'card_id';
  static const columnCardFront = 'front_text';
  static const columnCardBack = 'back_text';
  static const columnCardFolderId = 'folder_id'; 

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE $folderTable (
      $columnFolderId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnFolderName TEXT NOT NULL,
      created_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE $cardTable (
      $columnCardId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnCardFront TEXT NOT NULL,
      $columnCardBack TEXT NOT NULL,
      $columnCardFolderId INTEGER NOT NULL,
      FOREIGN KEY ($columnCardFolderId) REFERENCES $folderTable ($columnFolderId) ON DELETE CASCADE
    )
  ''');
}



  Future<int> insertFolder(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(folderTable, row);
  }

  Future<int> insertCard(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(cardTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllFolders() async {
    Database db = await instance.database;
    return await db.query(folderTable);
  }

  Future<List<Map<String, dynamic>>> queryCardsByFolder(int folderId) async {
    Database db = await instance.database;
    return await db.query(
      cardTable,
      where: '$columnCardFolderId = ?',
      whereArgs: [folderId],
    );
  }

  Future<Map<String, dynamic>?> queryCardById(int id) async {
    Database db = await instance.database;
    final results = await db.query(
      cardTable,
      where: '$columnCardId = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateFolder(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnFolderId];
    return await db.update(
      folderTable,
      row,
      where: '$columnFolderId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateCard(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnCardId];
    return await db.update(
      cardTable,
      row,
      where: '$columnCardId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFolder(int id) async {
    Database db = await instance.database;
    return await db.delete(
      folderTable,
      where: '$columnFolderId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCard(int id) async {
    Database db = await instance.database;
    return await db.delete(
      cardTable,
      where: '$columnCardId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllFolders() async {
    Database db = await instance.database;
    return await db.delete(folderTable);
  }

  Future<int> deleteAllCards() async {
    Database db = await instance.database;
    return await db.delete(cardTable);
  }

  Future<int> queryFolderCount() async {
    Database db = await instance.database;
    final results = await db.rawQuery('SELECT COUNT(*) FROM $folderTable');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> queryCardCount() async {
    Database db = await instance.database;
    final results = await db.rawQuery('SELECT COUNT(*) FROM $cardTable');
    return Sqflite.firstIntValue(results) ?? 0;
  }
}
