import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/place_model.dart';
import 'place_detail_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng _center = const LatLng(0, 0);
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _center = loc;
        _currentLocation = loc;
      });
      final ctrl = await _controller.future;
      ctrl.animateCamera(CameraUpdate.newLatLngZoom(loc, 13));
    } catch (_) {}
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() => _currentLocation = loc);
      final ctrl = await _controller.future;
      ctrl.animateCamera(CameraUpdate.newLatLngZoom(loc, 15));
    } catch (_) {
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _updateMarkers(List<PlaceModel> places) {
    _markers = places.map((p) {
      return Marker(
        markerId: MarkerId(p.id),
        position: LatLng(p.latitude, p.longitude),
        icon: p.category == 'hidden'
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: p.title,
          snippet: '⭐ ${p.averageRating.toStringAsFixed(1)} · ${p.category}',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlaceDetailPage(place: p)),
          ),
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return StreamBuilder<List<PlaceModel>>(
      stream: provider.placesStream,
      builder: (context, snap) {
        if (snap.hasData) _updateMarkers(snap.data!);
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _center, zoom: 5),
              onMapCreated: (ctrl) => _controller.complete(ctrl),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // using custom button
              mapToolbarEnabled: false,
            ),
            // Custom location button
            Positioned(
              right: 16,
              bottom: 100,
              child: GestureDetector(
                onTap: _locating ? null : _goToCurrentLocation,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _locating
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF2E7D32),
                          ),
                        )
                      : Icon(
                          _currentLocation != null
                              ? Icons.my_location_rounded
                              : Icons.location_searching_rounded,
                          color: _currentLocation != null
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF6B7280),
                          size: 22,
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
