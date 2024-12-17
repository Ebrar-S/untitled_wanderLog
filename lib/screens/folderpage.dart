import 'package:flutter/material.dart';

class FolderPage extends StatelessWidget {
  final String folderName;

  const FolderPage({required this.folderName, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to $folderName!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.folder, size: 80, color: Colors.teal),
            // Add more content for each folder here
          ],
        ),
      ),
    );
  }
}
