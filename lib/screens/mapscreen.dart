import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:geocoding/geocoding.dart';
import 'folderpage.dart'; // Import FolderPage

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _fetchAllLocations(); // Fetch locations when the screen is loaded
  }

  // Fetch all locations from Firestore and add them as markers
  Future<void> _fetchAllLocations() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    // Fetch folders
    final foldersSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Folders')
        .get();

    List<Marker> allMarkers = [];

    for (var folder in foldersSnapshot.docs) {
      final folderId = folder.id;

      // Fetch locations for each folder
      final locationsSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Folders')
          .doc(folderId)
          .collection('Locations')
          .get();

      for (var location in locationsSnapshot.docs) {
        final locationData = location.data();
        final title = locationData['title'] ?? 'Unnamed Location';
        final address = locationData['address'] ?? 'No Address';
        final pinColor = Color(locationData['pinColor'] ?? Colors.red.value);
        final lat = locationData['latitude'];
        final lng = locationData['longitude'];

        // Create a new marker for each location
        allMarkers.add(Marker(
          point: LatLng(lat, lng),
          width: 80.0,
          height: 80.0,
          child: Icon(
            Icons.location_on,
            size: 40,
            color: pinColor, // Set the color of the pin
          ),
        ));
      }
    }

    // Update the state with all fetched markers
    setState(() {
      _markers = allMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(41.9028, 12.4964), // Initial center of the map
              initialZoom: 12.0, // Initial zoom level
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _markers, // Use the list of markers
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Button to show location picker dialog
          FloatingActionButton(
            backgroundColor: Colors.grey[300],
            onPressed: () {
              _showAddMarkerDialog();
            },
            child: const Icon(Icons.add_location_alt),
          ),
          const SizedBox(width: 16),
          // Button to reset map position
          FloatingActionButton(
            backgroundColor: Colors.grey[300],
            onPressed: () {
              _mapController.move(const LatLng(41.9028, 12.4964), 12.0);
            },
            child: const Icon(Icons.location_searching),
          ),
        ],
      ),
    );
  }

  void _showAddMarkerDialog() async {
    String? title;
    String? address;
    Color? pinColor;
    String? selectedFolderId;

    // Fetch the list of folders to choose from
    List<QueryDocumentSnapshot> folders = await _getFolders();

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input for title and address
              TextField(
                decoration: const InputDecoration(labelText: 'Location Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Location Address'),
                onChanged: (value) {
                  address = value;
                },
              ),
              // Folder selection dropdown
              DropdownButton<String>(
                hint: const Text('Select Folder'),
                value: selectedFolderId,
                onChanged: (String? newFolderId) {
                  setState(() {
                    selectedFolderId = newFolderId;
                  });
                },
                items: folders.map((folder) {
                  final folderData = folder.data() as Map<String, dynamic>;
                  final folderName = folderData['name'] ?? "Unnamed Folder";
                  final folderId = folder.id;
                  return DropdownMenuItem<String>(
                    value: folderId,
                    child: Text(folderName),
                  );
                }).toList(),
              ),
              // Color Picker Button
              ElevatedButton(
                onPressed: () {
                  // Show color picker dialog
                  _selectPinColor(context, (newColor) {
                    setState(() {
                      pinColor = newColor; // Update pin color
                    });
                  });
                },
                child: const Text('Select Pin Color'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (title != null && address != null && pinColor != null && selectedFolderId != null) {
                  // Geocode the address to get latitude and longitude
                  try {
                    List<Location> locations = await locationFromAddress(address!);

                    // Ensure that at least one location was found
                    if (locations.isNotEmpty) {
                      // Use the first location result
                      Location location = locations.first;
                      double lat = location.latitude;
                      double lng = location.longitude;

                      // Add the marker to the map and save to the folder
                      _addMarker(title!, address!, pinColor!, lat, lng, selectedFolderId!);
                    } else {
                      // If no location is found, show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address could not be geocoded')),
                      );
                    }
                  } catch (e) {
                    // Handle error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error geocoding address: $e')),
                    );
                  }

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Marker'),
            ),
          ],
        );
      },
    );
  }

  Future<List<QueryDocumentSnapshot>> _getFolders() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Folders')
        .get();
    return snapshot.docs;
  }


  Future<void> _addMarker(String title, String address, Color color, double lat, double lng, String folderId) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid; // Get current user's UID
    final CollectionReference folderCollection = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid) // User's UID
        .collection('Folders')
        .doc(folderId) // Folder ID
        .collection('Locations'); // New subcollection for locations

    try {
      await folderCollection.add({
        'title': title,
        'address': address,
        'latitude': lat,
        'longitude': lng,
        'pinColor': color.value, // Store color as an integer value
        'createdAt': FieldValue.serverTimestamp(),
      });
      // After adding to Firestore, update the markers list
      setState(() {
        _markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 80.0,
            height: 80.0,
            child: Icon(
              Icons.location_on,
              size: 40,
              color: color,
            ),
          ),
        );
      });
      print("Location added successfully!");
    } catch (e) {
      print("Error adding location: $e");
    }
  }

  // Show color picker to select pin color
  void _selectPinColor(BuildContext context, ValueChanged<Color> onColorSelected) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Pin Color"),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: Colors.red, // Initial color
              onColorChanged: onColorSelected, // Callback when a new color is selected
            ),
          ),
          actions: [
            // OK Button to close the dialog after selecting a color
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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
