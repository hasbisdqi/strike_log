import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';
import '../models/strike_model.dart';
import 'widgets/strike_card_tile.dart';

class StrikeMapScreen extends StatefulWidget {
  final List<StrikeModel> strikes;

  const StrikeMapScreen({super.key, required this.strikes});

  @override
  State<StrikeMapScreen> createState() => _StrikeMapScreenState();
}

class _StrikeMapScreenState extends State<StrikeMapScreen> {
  GoogleMapController? _mapController;
  StrikeModel? _selectedStrike;
  MapType _currentMapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    // Filter strikes that have valid GPS coordinates
    final gpsStrikes = widget.strikes
        .where((s) => s.latitude != null && s.longitude != null)
        .toList();

    // Default center (Indonesia or first strike)
    LatLng initialCenter = const LatLng(-6.2088, 106.8456); // Jakarta default
    if (gpsStrikes.isNotEmpty) {
      initialCenter = LatLng(gpsStrikes.first.latitude!, gpsStrikes.first.longitude!);
    }

    // Google Maps Markers
    final Set<Marker> markers = gpsStrikes.map((strike) {
      final markerId = MarkerId(strike.id);
      return Marker(
        markerId: markerId,
        position: LatLng(strike.latitude!, strike.longitude!),
        infoWindow: InfoWindow(
          title: strike.fishName,
          snippet: '${strike.weightKg} kg • ${strike.spotName}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _selectedStrike?.id == strike.id
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueAzure,
        ),
        onTap: () {
          setState(() => _selectedStrike = strike);
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(strike.latitude!, strike.longitude!),
              14.0,
            ),
          );
        },
      );
    }).toSet();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Google Maps Spot Strike', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Ganti Tampilan Peta',
            icon: Icon(
              _currentMapType == MapType.normal ? Icons.satellite_alt : Icons.map,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _currentMapType = _currentMapType == MapType.normal
                    ? MapType.hybrid
                    : MapType.normal;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map View
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: CameraPosition(
              target: initialCenter,
              zoom: gpsStrikes.isNotEmpty ? 12.0 : 5.0,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (_) {
              if (_selectedStrike != null) {
                setState(() => _selectedStrike = null);
              }
            },
          ),

          // Total GPS strikes pill header
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              borderRadius: AppRadius.pill,
              child: Row(
                children: [
                  const Icon(Icons.pin_drop, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${gpsStrikes.length} dari ${widget.strikes.length} Tangkapan Berkoordinat GPS',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Selected Strike Detail Popup Card
          if (_selectedStrike != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Stack(
                children: [
                  StrikeCardTile(item: _selectedStrike!),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close, size: 14, color: Colors.white),
                        onPressed: () => setState(() => _selectedStrike = null),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Empty alert if no strikes have GPS
          if (gpsStrikes.isEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_off_outlined, color: AppColors.error, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Belum Ada Log dengan GPS',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Saat mencatat strike baru via tombol +, aktifkan izin lokasi agar titik tangkapan otomatis muncul di Google Maps!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
