import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../providers/rink_provider.dart';
import '../utils/colors.dart';
import 'RinkDetailScreen.dart';



class MapScreen extends ConsumerStatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _initialLocation = LatLng(40.56, -74.2083); // Woodbridge, NJ
  MarkerId? _selectedRink;
  LatLng? _parseLocation(dynamic positionData) {
    if (positionData is LatLng) {
      return positionData;
    } else if (positionData is GeoPoint) {
      return LatLng(positionData.latitude, positionData.longitude);
    } else if (positionData is Map<String, dynamic>) {
      if (positionData.containsKey('latitude') && positionData.containsKey('longitude')) {
        return LatLng(positionData['latitude'], positionData['longitude']);
      }
    } else if (positionData is String) {
      RegExp regExp = RegExp(r"LatLng\((-?\d+\.\d+),\s*(-?\d+\.\d+)\)");
      var match = regExp.firstMatch(positionData);
      if (match != null) {
        return LatLng(double.parse(match.group(1)!), double.parse(match.group(2)!));
      }
    }

    print("⚠️ Invalid location format: $positionData");
    return null;
  }


  @override
  Widget build(BuildContext context) {
    final rinkData = ref.watch(rinkProvider);
    print("Rink Data: $rinkData");


    return Scaffold(
      appBar: AppBar(
         // Use dynamic app bar color
        elevation: 0, // Remove shadow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            const SizedBox(width: 110), // Optional spacing between icon and title
            Text(
              'Map',
              style: TextStyle(), // Use dynamic text color
            ),
          ],
        ),
        centerTitle: false, // Set to false to align title to the start
        actions: [
   //add a second icon to the right here
        ],
      ),
      body: Stack(
        children: [
          rinkData.when(
            data: (rinks) {
              if (rinks.isEmpty) {
                return Center(child: Text("No rinks available"));
              }

              Set<Marker> markers = rinks.entries.map((entry) {
                LatLng? position = _parseLocation(entry.value['position']);
                if (position == null) {
                  print("⚠️ Missing or invalid location data for rink: ${entry.key.value}");
                  return null;
                }

                return Marker(
                  markerId: entry.key,
                  position: position,
                  onTap: () => _onMarkerTapped(entry.key), // Pass the correct MarkerId
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
                );

              }).whereType<Marker>().toSet();

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialLocation,
                  zoom: 7,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                markers: markers,
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, stack) {
              print("Error: $err");
              return Center(child: Text("Error loading rinks: $err"));
            },
          ),
          // Positioned Back Button (this will stay on top of the map)
         /* Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.purple, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ), */
        ],
      ),
    );
  }

  // This function is called when a marker is tapped, updating the selected rink.
  void _onMarkerTapped(MarkerId markerId) {
    final selectedRinkData = ref.read(rinkProvider).value?[markerId];

    if (selectedRinkData != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.5, // Modal takes up half of the screen
            child: _buildBottomCard(selectedRinkData),
          );
        },
      );
    }
  }



  // Function to build the bottom card widget.
  // Function to build the bottom card widget
  Widget _buildBottomCard(Map<String, dynamic> rinkData) {

    return Card(

      elevation: 8,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(
              'assets/images/overlay.png', // Replace network image with local asset
              height: 140,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 8),
            Text(
              rinkData['name'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, ),
            ),
            SizedBox(height: 8),
            Text("Address: ${rinkData['address']}",
              style: TextStyle(),),
            SizedBox(height: 8),
            Text("Phone: ${rinkData['phone']}",
                style: TextStyle()),
            SizedBox(height: 8),
            Text("Hours: ${rinkData['hours']}",
                style: TextStyle()),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                launch(rinkData['website']);
              },
              child: Text("Visit Website"),
            ),
            SizedBox(height: 8),
            // Close Button to dismiss the card
            IconButton(
              icon: Icon(Icons.directions, color: Colors.blue),
              onPressed: () async {
                if (_selectedRink != null && rinkData != null) {
                  final selectedRinkData = rinkData[_selectedRink];
                  if (selectedRinkData != null) {
                    final LatLng? position = _parseLocation(selectedRinkData['position']);

                    if (position != null) {
                      final double lat = position.latitude;
                      final double lng = position.longitude;
                      final Uri googleMapsUri = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$lng");
                      final Uri appleMapsUri = Uri.parse("https://maps.apple.com/?daddr=$lat,$lng");

                      Uri mapUrl = Platform.isIOS ? appleMapsUri : googleMapsUri;

                      if (await canLaunchUrl(mapUrl)) {
                        await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
                      } else {
                        print("Could not open Maps");
                      }
                    }
                  }
                }
              },
            ),

          ],
        ),
      ),
    );
  }
}


