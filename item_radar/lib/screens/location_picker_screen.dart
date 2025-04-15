import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final Function(LatLng) onLocationSelected;

  const LocationPickerScreen({
    super.key,
    this.initialPosition,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  LatLng? _selectedLocation;

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
          target: widget.initialPosition ?? const LatLng(0, 0),
          zoom: 15,
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