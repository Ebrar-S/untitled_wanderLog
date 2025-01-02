import 'package:flutter/material.dart';
import 'login.dart'; // Import LoginPage for logout functionality
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/main.dart'; // Import themeNotifier

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isDarkMode = themeNotifier.value == ThemeMode.dark;
  bool isNotificationsEnabled = true;

  void _navigateToEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }

  void _toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
      themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Account Settings Section
            SettingsSection(
              title: "Account",
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Edit Profile"),
                  onTap: _navigateToEditProfile,
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Log Out"),
                  onTap: () async {
                    await _auth.signOut();
                    // Navigate back to Login page
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false, // Remove all previous routes
                    );
                  },
                ),
              ],
            ),
            const Divider(),

            // App Theme Section
            SettingsSection(
              title: "Theme",
              children: [
                // Theme Section
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text("Dark Mode"),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: _toggleTheme,
                  ),
                ),
              ],
            ),
            const Divider(),

            // Notifications Section
            SettingsSection(
              title: "Notifications",
              children: [
                SwitchListTile(
                  value: isNotificationsEnabled,
                  title: const Text("Enable Notifications"),
                  onChanged: (bool value) {
                    setState(() {
                      isNotificationsEnabled = value;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text("Notification Preferences"),
                  onTap: () {
                    // Open notification settings or dialog
                  },
                ),
              ],
            ),
            const Divider(),

            // About Section
            SettingsSection(
              title: "About",
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("App Version"),
                  subtitle: const Text("1.0.0"),
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text("Help & Support"),
                  onTap: () {
                    // Navigate to help/support
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text("Privacy Policy"),
                  onTap: () {
                    // Show privacy policy
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
    }
  }

  Future<void> _updateProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(_nameController.text);
        await user.updateEmail(_emailController.text);
        await user.reload();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView( // Wrap the entire content in a scrollable view
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}



class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}