import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'folders_screen.dart';

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

class CardsScreen extends StatefulWidget {
  final FolderModel folder;

  const CardsScreen({Key? key, required this.folder}) : super(key: key);

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<CardModel> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final folderId = widget.folder.id;
    if (folderId == null) {
      print("Error: Folder ID is missing!");
      return;
    }

    final data = await dbHelper.queryCardsByFolder(folderId);
    setState(() {
      cards = data.map((m) => CardModel.fromMap(m)).toList();
    });
  }


  Future<void> _addCard() async {
    if (cards.length >= 6) {
      _showError("This folder can only hold 6 cards.");
      return;
    }

    final nameController = TextEditingController();
    final suit = widget.folder.name;
    final imageUrlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add New Card"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: "Card Name (e.g., Ace, King, 7)"),
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final imageUrl = imageUrlController.text.trim();

                if (name.isEmpty || imageUrl.isEmpty) return;

                await dbHelper.insertCard({
                  'name': name,
                  'suit': suit,
                  'image_url': imageUrl,
                  'folder_id': widget.folder.id,
                });
                Navigator.pop(context);
                _loadCards();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCard(int cardId) async {
    await dbHelper.deleteCard(cardId);
    _loadCards();
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final folderName = widget.folder.name;

    return Scaffold(
      appBar: AppBar(
        title: Text("$folderName Cards"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCard,
          ),
        ],
      ),
      body: cards.isEmpty
          ? const Center(child: Text("No cards yet. Tap + to add one."))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            card.imageUrl,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported, size: 40),
                          ),
                          const SizedBox(height: 8),
                          Text(card.displayName(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),
                        ],
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteCard(card.id!),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cards.length < 3
          ? Container(
              color: Colors.yellow[700],
              padding: const EdgeInsets.all(12),
              child: const Text(
                "⚠️ You need at least 3 cards in this folder!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}
