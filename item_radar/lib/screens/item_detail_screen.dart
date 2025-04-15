import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ItemDetailScreen extends StatelessWidget {
  final String title;
  final String category;
  final LatLng location;
  final String time;
  final String date;
  final String description;
  final List<String?> images;
  final String status;
  final Color buttonColor;

  const ItemDetailScreen({
    super.key,
    required this.title,
    required this.category,
    required this.location,
    required this.time,
    required this.date,
    required this.description,
    required this.images,
    required this.status,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Images Carousel
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  if (images[index] == null) {
                    return const Center(child: Icon(Icons.image, size: 50));
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      images[index]!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error));
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Item Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Item Category
            Text(
              'Category: $category',
              style: TextStyle(color: Colors.grey[600]),
            ),

            const SizedBox(height: 10),

            // Item Location Map
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: location,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('itemLocation'),
                    position: location,
                    infoWindow: const InfoWindow(title: 'Item Location'),
                  )
                },
              ),
            ),

            const SizedBox(height: 10),

            // Item Time and Date
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Time: $time',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Date: $date',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Item Description
            const Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description),

            const SizedBox(height: 20),

            // Status Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {},
                child: Text(
                  status,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
