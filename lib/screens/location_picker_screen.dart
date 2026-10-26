import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../core/theme/app_tokens.dart';

class LocationPickerResult {
  final double latitude;
  final double longitude;
  final String spotName;

  LocationPickerResult({
    required this.latitude,
    required this.longitude,
    required this.spotName,
  });
}

class LocationPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const LocationPickerScreen({
    super.key,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _pickedLocation;
  String _detectedAddress = 'Memuat nama lokasi...';
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _pickedLocation = LatLng(widget.initialLat, widget.initialLng);
    _reverseGeocode(_pickedLocation);
  }

  Future<void> _reverseGeocode(LatLng target) async {
    setState(() => _isGeocoding = true);
    String spot = 'Spot (${target.latitude.toStringAsFixed(4)}, ${target.longitude.toStringAsFixed(4)})';

    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(
        target.latitude,
        target.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          if (place.name != null && place.name!.isNotEmpty) place.name,
          if (place.subLocality != null && place.subLocality!.isNotEmpty) place.subLocality,
          if (place.locality != null && place.locality!.isNotEmpty) place.locality,
          if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) place.subAdministrativeArea,
        ];
        if (parts.isNotEmpty) {
          spot = parts.toSet().take(3).join(', ');
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _detectedAddress = spot;
        _isGeocoding = false;
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    _pickedLocation = position.target;
  }

  void _onCameraIdle() {
    _reverseGeocode(_pickedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Titik Spot Mancing', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Google Map view
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickedLocation,
              zoom: 15.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
          ),

          // Center Pin Marker
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Text(
                      'Geser peta untuk memilih spot',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.location_on,
                    size: 46,
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(Icons.pin_drop, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Spot Terpilih:',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            _isGeocoding
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    _detectedAddress,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            const SizedBox(height: 2),
                            Text(
                              '${_pickedLocation.latitude.toStringAsFixed(5)}, ${_pickedLocation.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(color: AppColors.tealAccent, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(
                        context,
                        LocationPickerResult(
                          latitude: _pickedLocation.latitude,
                          longitude: _pickedLocation.longitude,
                          spotName: _detectedAddress,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text(
                      'Gunakan Titik Spot Ini',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
