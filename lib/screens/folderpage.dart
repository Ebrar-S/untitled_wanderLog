import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FolderPage extends StatelessWidget {
  final String folderName;
  final String folderId;

  const FolderPage({required this.folderName, required this.folderId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folderName),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid) // User's UID
                  .collection('Folders')
                  .doc(folderId) // Folder ID
                  .collection('Pictures') // Subcollection of pictures
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No pictures in this folder."));
                }

                final pictures = snapshot.data!.docs;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: pictures.length,
                  itemBuilder: (context, index) {
                    final picture = pictures[index].data() as Map<String, dynamic>;
                    return Container(
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, size: 40),
                          const SizedBox(height: 8),
                          Text(picture['description'] ?? "No Description"),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _showAddPictureDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Picture"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show dialog to add picture
  void _showAddPictureDialog(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("Add Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Simulating adding a picture URL."),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Picture Description",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final description = descriptionController.text.trim();
                if (description.isNotEmpty) {
                  await addPictureToFolder(description);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // Method to add a picture to Firestore
  Future<void> addPictureToFolder(String description) async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid; // Get current user's UID
      final CollectionReference picturesCollection = FirebaseFirestore.instance
          .collection('Users')
          .doc(uid) // User's UID
          .collection('Folders')
          .doc(folderId) // Folder ID
          .collection('Pictures');

      await picturesCollection.add({
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Picture added successfully!");
    } catch (e) {
      print("Error adding picture: $e");
    }
  }
}
