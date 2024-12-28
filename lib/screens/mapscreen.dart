import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'folderpage.dart'; // Import FolderPage

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(37.7749, -122.4194), // Initial center of the map
              initialZoom: 12.0, // Initial zoom level
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              const MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(37.7749, -122.4194), // San Francisco coordinates
                    width: 80.0,
                    height: 80.0,
                    child: Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Floating Buttons (Tabs)
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('Folders')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No folders available."));
                }

                final folders = snapshot.data!.docs;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: folders.map((folder) {
                      final folderData = folder.data() as Map<String, dynamic>;
                      final folderName = folderData['name'] ?? "Unnamed Folder";
                      final folderId = folder.id;

                      return _buildFolderButton(folderName, folderId);
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[300],
        onPressed: () {
          _mapController.move(LatLng(37.7749, -122.4194), 12.0);
        },
        child: const Icon(Icons.location_searching),
      ),
    );
  }

  // Helper method to create folder buttons
  Widget _buildFolderButton(String folderName, String folderId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderPage(
              folderName: folderName,
              folderId: folderId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.folder, color: Color(0xFF4B0082)),
            const SizedBox(width: 6),
            Text(
              folderName,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B0082),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
