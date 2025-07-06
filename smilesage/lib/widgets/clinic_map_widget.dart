import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/clinic.dart';
import '../services/location_service.dart';

class ClinicMapWidget extends StatefulWidget {
  final List<Clinic> clinics;
  final Function(Clinic)? onClinicSelected;

  const ClinicMapWidget({
    Key? key,
    required this.clinics,
    this.onClinicSelected,
  }) : super(key: key);

  @override
  State<ClinicMapWidget> createState() => _ClinicMapWidgetState();
}

class _ClinicMapWidgetState extends State<ClinicMapWidget> {
  GoogleMapController? _mapController;
  Position? _userPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get user's current location
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _userPosition = position;
          _isLoading = false;
        });
        _createMarkers();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error initializing map: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createMarkers() {
    final markers = <Marker>{};

    // Add user location marker
    if (_userPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Add clinic markers
    for (int i = 0; i < widget.clinics.length; i++) {
      final clinic = widget.clinics[i];
      markers.add(
        Marker(
          markerId: MarkerId('clinic_${clinic.id}'),
          position: LatLng(clinic.latitude, clinic.longitude),
          infoWindow: InfoWindow(
            title: clinic.name,
            snippet: clinic.address,
            onTap: () {
              if (widget.onClinicSelected != null) {
                widget.onClinicSelected!(clinic);
              }
            },
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  @override
  void didUpdateWidget(ClinicMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clinics != widget.clinics) {
      _createMarkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_userPosition == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                'Location not available',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(_userPosition!.latitude, _userPosition!.longitude),
            zoom: 13.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onTap: (_) {
            // Close any open info windows
            _mapController
                ?.hideMarkerInfoWindow(const MarkerId('user_location'));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
