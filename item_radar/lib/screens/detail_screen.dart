import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String time;
  final String location;
  final String description;
  final String imagePath;
  final Color buttonColor;
  final String phoneNumber;
  final String buttonText;

  DetailScreen({
    required this.title,
    required this.category,
    required this.date,
    this.time = "Not Specified", // Default value added
    required this.location,
    required this.description,
    required this.imagePath,
    required this.buttonColor,
    required this.phoneNumber,
    required this.buttonText,
  });

  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    LatLng latLng = _parseLocation(location);

    return Scaffold(
      appBar: AppBar(title: Text("Item Details")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                imagePath,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            SizedBox(height: 20),
            Text("Item Name: $title", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Category: $category", style: TextStyle(fontSize: 18)),
            Text("Date: $date", style: TextStyle(fontSize: 16, color: Colors.grey)),
            Text("Time: $time", style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 10),
            Text("Location:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: latLng, zoom: 14.0),
                markers: {Marker(markerId: MarkerId("itemLocation"), position: latLng)},
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            SizedBox(height: 10),
            Text("Description:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _makePhoneCall(phoneNumber),
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
              child: Text(buttonText, style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () => _makePhoneCall(phoneNumber),
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.call, color: Colors.white),
                ),
                FloatingActionButton(
                  onPressed: () => _openWhatsApp(phoneNumber),
                  backgroundColor: Colors.green,
                  child: Icon(Icons.chat, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LatLng _parseLocation(String location) {
    try {
      List<String> latLng = location.split(",");
      return LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
    } catch (e) {
      return LatLng(33.6844, 73.0479); // Default to Islamabad, Pakistan if parsing fails
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: "tel", path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print("Could not launch phone dialer");
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    final Uri uri = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print("Could not launch WhatsApp");
    }
  }
}