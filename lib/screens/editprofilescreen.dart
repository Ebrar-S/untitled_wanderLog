import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get the profile image URL from Firestore
  Future<String?> _getProfileImageUrl() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return null;

      final userDoc = await _firestore.collection('Users').doc(userId).get();
      return userDoc.data()?['profileImageUrl'] as String?;
    } catch (e) {
      print("Error fetching profile image: $e");
      return null;
    }
  }

  Future<void> _loadCurrentUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('Users').doc(user.uid).get();
      final data = userDoc.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _emailController.text = user.email ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load user data: $e")),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userId = user.uid;
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      if (email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
      }

      String? profileImageUrl;

      if (_selectedImage != null) {
        // Upload the selected image to ImgBB
        profileImageUrl = await _uploadImageToImgBB(_selectedImage!);
      }

      await _firestore.collection('Users').doc(userId).update({
        'name': name,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _uploadImageToImgBB(File image) async {
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

  void _showChangeImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("Change Profile Picture"),
          content: const Text("Do you want to change your profile image?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                final result = await FilePicker.platform.pickFiles(
                    type: FileType.image);
                if (result != null && result.files.single.path != null) {
                  setState(() {
                    _selectedImage = File(result.files.single.path!);
                  });
                  await _updateProfile(); // Update profile after image is selected
                }
              },
              child: const Text("Change Image"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFFB39DDB),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture
                FutureBuilder<String?>(
                  future: _getProfileImageUrl(),
                  builder: (context, snapshot) {
                    Widget avatarChild;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      avatarChild = const CircularProgressIndicator();
                    } else if (snapshot.hasError || snapshot.data == null) {
                      avatarChild = const Icon(Icons.person, size: 60); // Placeholder icon
                    } else {
                      avatarChild = CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(snapshot.data!),
                        onBackgroundImageError: (error, stackTrace) {
                          setState(() {
                            // Use a fallback image or handle errors
                          });
                        },
                        backgroundColor: Colors.grey[300],
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        print("Avatar tapped!");
                        _showChangeImageDialog();
                      },
                      child: CircleAvatar(
                        radius: 60,
                        child: avatarChild,
                        backgroundColor: Colors.grey[300],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Name is required.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || !RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return "Enter a valid email.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text("Save Changes"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
