import 'package:flutter/material.dart';
import 'editprofilescreen.dart';
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
        automaticallyImplyLeading: false,
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