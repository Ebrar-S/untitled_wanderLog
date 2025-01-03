import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _displayName;
  String? _email;

  Future<String?> _getProfileImageUrl() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final userDoc = await _firestore.collection('Users').doc(userId).get();
      return userDoc.data()?['profileImageUrl'] as String?;
    } catch (e) {
      print("Error fetching profile image: $e");
      return null;
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('Users').doc(user.uid).get();
        setState(() {
          _displayName = userDoc.data()?['name'] ?? "No name available";
          _email = user.email ?? "No email available";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Profile"),
        backgroundColor: const Color(0xFFB39DDB),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              FutureBuilder<String?>(
                future: _getProfileImageUrl(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                      radius: 60,
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError || snapshot.data == null) {
                    return const CircleAvatar(
                      radius: 60,
                      child: Icon(Icons.error, size: 40),
                    );
                  } else {
                    return CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(snapshot.data!),
                      backgroundColor: Colors.grey[300],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                _displayName ?? "Loading name...",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                _email ?? "Loading email...",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Account Options
              SettingsSection(
                title: "Account Settings",
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text("Edit Profile"),
                    onTap: () {
                      // Navigate to Edit Profile screen
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("Change Password"),
                    onTap: () {
                      _showChangePasswordDialog(context);
                    },
                  ),
                ],
              ),
              const Divider(),

              // App Info
              SettingsSection(
                title: "App Information",
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text("Terms and Conditions"),
                    onTap: () {
                      // Show Terms and Conditions
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text("Privacy Policy"),
                    onTap: () {
                      // Show Privacy Policy
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({required this.title, required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

void _showChangePasswordDialog(BuildContext context) {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your current password and new password:"),
            const SizedBox(height: 10),
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
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
              final oldPassword = oldPasswordController.text.trim();
              final newPassword = newPasswordController.text.trim();

              if (oldPassword.isEmpty || newPassword.isEmpty || newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill in all fields correctly.")),
                );
                return;
              }

              try {
                final user = _auth.currentUser;
                if (user == null) throw Exception("User not logged in.");
                final email = user.email;
                if (email == null) throw Exception("User email not found.");

                final credential = EmailAuthProvider.credential(
                  email: email,
                  password: oldPassword,
                );
                await user.reauthenticateWithCredential(credential);
                await user.updatePassword(newPassword);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password updated successfully.")),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Change"),
          ),
        ],
      );
    },
  );
}
