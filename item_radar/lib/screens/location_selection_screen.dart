import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectionScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const LocationSelectionScreen({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation = const LatLng(33.7828, 72.3548); // University of Education Attock campus location

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          TextButton(
            onPressed: _selectedLocation == null
                ? null
                : () => widget.onLocationSelected(_selectedLocation!),
            child: const Text('SELECT'),
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(
          target: const LatLng(33.7828, 72.3548), // University of Education Attock campus
          zoom: 15, // Adjust zoom level for a better view
        ),
        onTap: (latLng) {
          setState(() {
            _selectedLocation = latLng;
          });
        },
        markers: _selectedLocation != null
            ? {
          Marker(
            markerId: const MarkerId('selectedLocation'),
            position: _selectedLocation!,
            infoWindow: const InfoWindow(title: 'University of Education Attock'),
          ),
        }
            : {
          Marker(
            markerId: const MarkerId('universityLocation'),
            position: const LatLng(33.7828, 72.3548),
            infoWindow: const InfoWindow(title: 'University of Education Attock'),
          ),
        },
      ),
    );
  }
}
