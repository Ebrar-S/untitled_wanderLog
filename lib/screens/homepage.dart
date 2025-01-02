import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'folderpage.dart';  // Import FolderPage

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section for folders with horizontal scroll
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "My Trips",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Fetching folders from Firestore for the currently authenticated user
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid) // User's UID
                      .collection('Folders')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text("Error fetching folders"));
                    }

                    final folders = snapshot.data!.docs;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(folders.length, (index) {

                          final folder = folders[index];
                          final folderName = folder['name'];
                          final folderId = folder.id;  // Get the document ID

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                // Pass both folderName and folderId to FolderPage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FolderPage(
                                      folderName: folderName,
                                      folderId: folderId,
                                      // Pass the folderId here

                                    ),
                                  ),
                                );
                              },
                              child: FolderCard(title: folderName),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
          const Divider(),
          // Section for photos with vertical scroll
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Photos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser!.uid) // Current user ID
                          .collection('Folders') // All folders
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No folders found."));
                        }

                        final folders = snapshot.data!.docs;

                        // Create a list to collect all pictures from all folders
                        List<Future<QuerySnapshot<Map<String, dynamic>>>> allPictures = [];

                        // Iterate through each folder and fetch its pictures
                        for (var folder in folders) {
                          var folderId = folder.id;

                          // Fetch pictures for the current folder
                          allPictures.add(
                            FirebaseFirestore.instance
                                .collection('Users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('Folders')
                                .doc(folderId)
                                .collection('Pictures')
                                .orderBy('createdAt', descending: true)
                                .get(),
                          );
                        }

                        return FutureBuilder<List<QuerySnapshot>>(
                          future: Future.wait(allPictures),
                          builder: (context, pictureSnapshot) {
                            if (pictureSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!pictureSnapshot.hasData || pictureSnapshot.data!.isEmpty) {
                              return const Center(child: Text("No pictures available."));
                            }

                            // Flatten the list of pictures from all folders
                            final pictures = pictureSnapshot.data!
                                .expand((snapshot) => snapshot.docs)
                                .toList();

                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, // Adjust number of columns
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: pictures.length,
                              itemBuilder: (context, index) {
                                final picture = pictures[index].data() as Map<String, dynamic>;
                                final pictureId = pictures[index].id;

                                return GestureDetector(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Displaying the image from the URL
                                      picture['imageUrl'] != null
                                          ? Image.network(
                                        picture['imageUrl'],
                                        height: 100, // Constrained size for the image
                                        width: 100,  // You can adjust this based on your layout
                                        fit: BoxFit.cover, // Make sure it fits well inside the box
                                      )
                                          : const Icon(Icons.image, size: 40), // Default icon if no image URL
                                      const SizedBox(height: 8),
                                      // Wrap the description text with an Expanded widget
                                      Expanded(
                                        child: Text(
                                          picture['description'] ?? "No Description",
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis, // Adds an ellipsis if the text overflows
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )


        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[300],
        onPressed: () {
          _showCreateFolderDialog(context);
        },
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }

  // Floating Dialog for Creating Folder
  void _showCreateFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController folderNameController = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("Create New Folder"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: folderNameController,
                decoration: const InputDecoration(
                  labelText: "Folder Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Create a folder with the provided name
                  createFolder(folderNameController.text);

                  Navigator.pop(context); // Close the dialog
                },
                icon: const Icon(Icons.check),
                label: const Text("Create"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to create a folder in Firestore for the current user
  Future<void> createFolder(String folderName) async {
    try {
      // Firestore instance and collection reference
      String uid = FirebaseAuth.instance.currentUser!.uid; // Get current user's UID
      CollectionReference folders = FirebaseFirestore.instance
          .collection('Users')
          .doc(uid) // User's UID
          .collection('Folders');

      // Add folder to Firestore
      await folders.add({
        'name': folderName,
        'createdAt': FieldValue.serverTimestamp(),  // Adds timestamp automatically
      });
      print("Folder created successfully");
    } catch (e) {
      print("Error creating folder: $e");
    }
  }
}

class FolderCard extends StatelessWidget {
  final String title;

  const FolderCard({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder, color: Color(0xFF4B0082)),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
      ),
    );
  }
}
