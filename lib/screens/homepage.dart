import 'package:flutter/material.dart';
import 'folderpage.dart'; // Import the FolderPage

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
                  "Folders",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(10, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to the FolderPage when a folder is clicked
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FolderPage(folderName: "Folder ${index + 1}"),
                              ),
                            );
                          },
                          child: FolderCard(title: "Folder ${index + 1}"),
                        ),
                      );
                    }),
                  ),
                ),
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
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Adjust number of columns
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 20, // Replace with the number of photos
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 40),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // "Create Folder" button at the bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Add create folder functionality
              },
              icon: const Icon(Icons.create_new_folder),
              label: const Text("Create Folder"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
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
            const Icon(Icons.folder, color: Colors.teal),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
      ),
    );
  }
}