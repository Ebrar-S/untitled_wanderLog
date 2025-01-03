import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'homepage.dart'; // Import HomePage
import 'mapscreen.dart'; // Import MapScreen (placeholder)
import 'settingsscreen.dart';
import 'profilescreen.dart';// Import SettingsScreen (placeholder)
import 'login.dart'; // Import LoginPage for logout functionality
import 'package:google_fonts/google_fonts.dart';

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> _getProfileImageUrlFromFirestore() async {
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
                leading: const Icon(Icons.person),
                title: const Text("Your Profile"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {
                  Navigator.pop(context); // Close the modal bottom sheet
                  setState(() {
                    _selectedIndex = 2; // Index of the SettingsScreen in the bottom navigation bar
                  });
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
        backgroundColor: const Color(0xFFB39DDB),
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            print('WanderLog tapped!');
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "WanderLog",
                style: GoogleFonts.agbalumo(
                  textStyle: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B0082),
                  ),
                ),
              ),
              const Spacer(), // Pushes the GestureDetector to the right
              GestureDetector(
                onTap: () {
                  _showProfileSettings(context); // Function to show profile settings
                },
                child: FutureBuilder<String?>(
                  future: _getProfileImageUrlFromFirestore(), // Function to fetch URL from Firestore
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While waiting for data, show a loading indicator
                      return CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[300],
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      );
                    } else if (snapshot.hasError || snapshot.data == null) {
                      // If there's an error or no data, show a placeholder
                      return CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, size: 18, color: Colors.grey),
                      );
                    } else {
                      // Successfully loaded data, show the profile image
                      return CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(snapshot.data!),
                        backgroundColor: Colors.grey[300],
                      );
                    }
                  },
                ),
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