import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// Import FolderPage

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
                subdomains: const ['a', 'b', 'c'],
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFolderButton("Restaurants", Icons.restaurant),
                    _buildFolderButton("Coffee Shops", Icons.local_cafe),
                    _buildFolderButton("Shopping", Icons.shopping_bag),
                    _buildFolderButton("Parks", Icons.park),
                    _buildFolderButton("Hotels", Icons.hotel),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[300],
        onPressed: () {
          _mapController.move(const LatLng(37.7749, -122.4194), 12.0);
        },
        child: const Icon(Icons.location_searching),
      ),
    );
  }

  // Helper method to create folder buttons
  Widget _buildFolderButton(String title, IconData icon) {
    return GestureDetector(
      onTap: () => {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4B0082)),
            const SizedBox(width: 6),
            Text(
              title,
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
