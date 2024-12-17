import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'homepage.dart'; // Import HomePage
import 'mapscreen.dart'; // Import MapScreen (placeholder)
import 'settingsscreen.dart'; // Import SettingsScreen (placeholder)
import 'login.dart'; // Import LoginPage for logout functionality

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;

  // List of screens to navigate
  final List<Widget> _screens = [
    const HomePage(), // Home screen
    const MapScreen(), // Map screen (placeholder)
    const SettingsScreen(), // Settings screen (placeholder)
  ];

  // Handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Show profile settings modal
  void _showProfileSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text("Your Profile"),
                onTap: () {
                  Navigator.pop(context);
                  print('Go to Profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {
                  Navigator.pop(context);
                  print('Go to Settings');
                },
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: GestureDetector(
          onTap: () {
            print('WanderLog tapped!');
          },
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  _showProfileSettings(context);
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    "https://via.placeholder.com/150", // Replace with user's profile picture URL
                  ),
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "WanderLog",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}