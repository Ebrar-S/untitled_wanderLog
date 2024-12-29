import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                  title: constg Text("Edit Profile"),
                  onTap: () {
                    // Navigate to profile editing screen
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Log Out"),
                  onTap: () {
                    // Log out functionality
                  },
                ),
              ],
            ),
            const Divider(),

            // App Theme Section
            SettingsSection(
              title: "Theme",
              children: [
                SwitchListTile(
                  value: true, // Replace with actual state management
                  title: const Text("Dark Mode"),
                  onChanged: (bool value) {
                    // Handle theme toggling
                  },
                ),
              ],
            ),
            const Divider(),

            // Notifications Section
            SettingsSection(
              title: "Notifications",
              children: [
                SwitchListTile(
                  value: true, // Replace with actual state management
                  title: const Text("Enable Notifications"),
                  onChanged: (bool value) {
                    // Handle notifications toggling
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text("Notification Preferences"),
                  onTap: () {
                    // Open notification settings
                  },
                ),
              ],
            ),
            const Divider(),

            // Data Management Section
            SettingsSection(
              title: "Data Management",
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload),
                  title: const Text("Backup Data"),
                  onTap: () {
                    // Backup functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cloud_download),
                  title: const Text("Restore Data"),
                  onTap: () {
                    // Restore functionality
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

  const SettingsSection({required this.title, required this.children, super.key});

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
