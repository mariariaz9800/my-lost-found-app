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
  LatLng? _selectedLocation = const LatLng(33.7828, 72.3548); // Default location

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
        initialCameraPosition: const CameraPosition(
          target: LatLng(12.9716, 77.5946), // Default location
          zoom: 12,
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
          )
        }
            : const <Marker>{},
      ),
    );
  }
}