import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'navigation_wrapper.dart';

class FolderPage extends StatelessWidget {
  final String folderId;
  final Function? onPictureAdded;

  const FolderPage({required this.folderId, this.onPictureAdded, super.key});

  Future<String> _getFolderName(String folderId) async {
    try {
      // Query to get the folder name from Firestore
      final folderDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid) // Current user ID
          .collection('Folders')
          .doc(folderId) // Folder ID
          .get();

      // Return the folder name if it exists
      if (folderDoc.exists) {
        return folderDoc['name'] ?? 'Unknown Folder';
      } else {
        return 'Folder Not Found';
      }
    } catch (e) {
      print("Error fetching folder name: $e");
      return 'Error Fetching Name';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getFolderName(folderId), // Fetch folder name
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: const Center(child: Text('Error fetching folder name')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('No Folder'),
            ),
            body: const Center(child: Text('No folder found')),
          );
        }

        // Folder name fetched successfully, display the FolderPage
        final folderName = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(folderName), // Set folder name as title
            backgroundColor: const Color(0xFFB39DDB),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const NavigationWrapper()),
                ); // Go back to the previous screen
              },
            ),
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
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text("No pictures in this folder."));
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
                        final picture = pictures[index].data() as Map<
                            String,
                            dynamic>;
                        final pictureId = pictures[index].id;

                        return GestureDetector(
                          onLongPress: () =>
                              _confirmDeletePicture(context, pictureId),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Displaying the image from the URL
                              picture['imageUrl'] != null
                                  ? Image.network(
                                picture['imageUrl'],
                                height: 100,
                                // Constrained size for the image
                                width: 100,
                                // You can adjust this based on your layout
                                fit: BoxFit
                                    .cover, // Make sure it fits well inside the box
                              )
                                  : const Icon(Icons.image, size: 40),
                              // Default icon if no image URL
                              const SizedBox(height: 5),
                              // Wrap the description text with an Expanded widget
                              Expanded(
                                child: Text(
                                  picture['description'] ?? "No Description",
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow
                                      .ellipsis, // Adds an ellipsis if the text overflows
                                ),
                              ),
                            ],
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
                      return const Center(
                          child: Text("No locations in this folder."));
                    }

                    final locations = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        final location = locations[index].data() as Map<
                            String,
                            dynamic>;
                        final locationId = locations[index].id;

                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(location['title'] ?? "No Title"),
                          subtitle: Text(location['address'] ?? "No Address"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _confirmDeleteLocation(context, locationId),
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
      },
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
                await _deleteFolderAndContents(folderId);
                Navigator.pop(context);
                Navigator.pop(context);// Navigate back after deleting
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFolderAndContents(String folderId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final folderRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Folders')
        .doc(folderId);

    try {
      // Delete all documents in the 'Pictures' collection
      final picturesSnapshot = await folderRef.collection('Pictures').get();
      for (var doc in picturesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all documents in the 'Locations' collection
      final locationsSnapshot = await folderRef.collection('Locations').get();
      for (var doc in locationsSnapshot.docs) {
        await doc.reference.delete();
      }

      // After deleting subcollections, delete the folder itself
      await folderRef.delete();
      print('Folder and all contents deleted successfully!');
    } catch (e) {
      print("Error deleting folder and contents: $e");
    }
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

  void _showAddPictureDialog(BuildContext context) async {
    final TextEditingController descriptionController = TextEditingController();
    String? uploadedImageUrl;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text("Add Picture"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final FilePickerResult? result =
                      await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null && result.files.single.path != null) {
                        final String? imageUrl =
                        await uploadImageToImgBB(File(result.files.single.path!));
                        if (imageUrl != null) {
                          setState(() {
                            uploadedImageUrl = imageUrl;
                          });
                          print("Uploaded image URL: $uploadedImageUrl");
                        } else {
                          print("Failed to upload image.");
                        }
                      }
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text("Upload Picture"),
                  ),
                  const SizedBox(height: 16),
                  if (uploadedImageUrl != null)
                    Text(
                      "Image Uploaded!",
                      style: const TextStyle(color: Colors.green),
                    ),
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
                    if (uploadedImageUrl == null) {
                      print("UploadedImageUrl is null!");
                      return;
                    }
                    if (descriptionController.text.trim().isEmpty) {
                      print("Description is empty!");
                      return;
                    }
                    await _savePicture(
                      uploadedImageUrl!,
                      descriptionController.text.trim(),
                    );
                    if (onPictureAdded != null) {
                      onPictureAdded!();
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<String?> uploadImageToImgBB(File image) async {
    const String apiKey = '8b852bb8ae100c94125ec2305f07a310'; // Replace with your ImgBB API key
    final Uri url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

    try {
      final http.MultipartRequest request =
      http.MultipartRequest("POST", url)
        ..files.add(await http.MultipartFile.fromPath("image", image.path));

      final http.StreamedResponse response = await request.send();
      final String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(responseBody);
        return responseData['data']['url'];
      } else {
        print("Failed to upload to ImgBB: ${response.statusCode}");
        print(responseBody);
        return null;
      }
    } catch (e) {
      print("Error uploading to ImgBB: $e");
      return null;
    }
  }

  Future<void> _savePicture(String imageUrl, String description) async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final CollectionReference picturesRef = FirebaseFirestore.instance
          .collection("Users")
          .doc(uid)
          .collection("Folders")
          .doc(folderId)
          .collection("Pictures");

      await picturesRef.add({
        'imageUrl': imageUrl,
        'description': description,
        'folderId': folderId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Picture saved successfully!");
    } catch (e) {
      print("Error saving picture: $e");
    }
  }

}
