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
        backgroundColor: const Color(0xFFB39DDB),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteFolder(context),
          ),
        ],
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
                    final pictureId = pictures[index].id;

                    return GestureDetector(
                      onLongPress: () => _confirmDeletePicture(context, pictureId),
                      child: Container(
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image, size: 40),
                            const SizedBox(height: 8),
                            Text(picture['description'] ?? "No Description"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('Folders')
                  .doc(folderId)
                  .collection('Locations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No locations in this folder."));
                }

                final locations = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final location = locations[index].data() as Map<String, dynamic>;
                    final locationId = locations[index].id;

                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(location['title'] ?? "No Title"),
                      subtitle: Text(location['address'] ?? "No Address"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteLocation(context, locationId),
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
                backgroundColor: const Color(0xFFB39DDB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFolder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Folder"),
          content: const Text("Are you sure you want to delete this folder?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('Folders')
                    .doc(folderId)
                    .delete();
                Navigator.pop(context);
                Navigator.pop(context); // Navigate back after deleting
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletePicture(BuildContext context, String pictureId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Picture"),
          content: const Text("Are you sure you want to delete this picture?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('Folders')
                    .doc(folderId)
                    .collection('Pictures')
                    .doc(pictureId)
                    .delete();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteLocation(BuildContext context, String locationId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Location"),
          content: const Text("Are you sure you want to delete this location?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('Folders')
                    .doc(folderId)
                    .collection('Locations')
                    .doc(locationId)
                    .delete();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

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
