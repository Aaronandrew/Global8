import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RinkDetailScreen extends StatelessWidget {
  final Map<String, dynamic> rinkData;

  const RinkDetailScreen({Key? key, required this.rinkData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(rinkData['name']),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(rinkData['image'], height: 200, fit: BoxFit.cover),
            SizedBox(height: 16),
            Text("Address: ${rinkData['address']}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Phone: ${rinkData['phone']}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Hours: ${rinkData['hours']}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                launch(rinkData['website']);
              },
              child: Text("Visit Website"),
            ),
          ],
        ),
      ),
    );
  }
}
