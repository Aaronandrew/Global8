import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// ✅ Function to parse Firestore location data
LatLng? _parseLocation(dynamic positionData) {
  if (positionData is LatLng) {
    // ✅ Already a valid LatLng, return as is
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


final rinkProvider = FutureProvider<Map<MarkerId, Map<String, dynamic>>>((ref) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference rinksCollection = firestore.collection('rinks');

  try {
    QuerySnapshot snapshot = await rinksCollection.get();
    Map<MarkerId, Map<String, dynamic>> rinks = {};

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      MarkerId markerId = MarkerId(doc.id);

      print("🔥 Firestore Raw Data for ${doc.id}: $data");

      LatLng? position = _parseLocation(data['position']);

      if (position != null) {
        rinks[markerId] = {
          'name': data['name'] ?? 'Unknown',
          'position': position, // Ensure this is now a proper LatLng object
          'address': data['address'] ?? 'No address available',
          'phone': data['phone'] ?? 'No phone available',
          'website': data['website'] ?? '',
          'image': data['image'] ?? '',
          'hours': data['hours'] ?? 'No hours available',
        };
      } else {
        print("⚠️ Missing or invalid location data for rink: ${doc.id}");
      }
    }

    return rinks;
  } catch (e) {
    print("❌ Error fetching rinks: $e");
    return {};
  }
});


/// **Converts "40.6782° N" to 40.6782, "73.9442° W" to -73.9442**
double? _convertToDouble(String coordinate) {
  if (coordinate.contains("°")) {
    coordinate = coordinate.replaceAll("°", "").trim();
  }

  List<String> parts = coordinate.split(" ");
  if (parts.length != 2) return null;

  double? value = double.tryParse(parts[0]);
  if (value == null) return null;

  String direction = parts[1].toUpperCase();
  if (direction == "S" || direction == "W") {
    value = -value;
  }

  return value;
}

