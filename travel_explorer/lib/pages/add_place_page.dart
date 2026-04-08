import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../providers/app_provider.dart';

class AddPlacePage extends StatefulWidget {
  const AddPlacePage({super.key});

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _category = 'Beach';
  final List<File> _images = [];
  LatLng? _pickedLocation;
  bool _loading = false;
  bool _locating = false;

  // Category config: label, icon, color
  static const List<Map<String, dynamic>> _categories = [
    {'label': 'Beach', 'icon': '🏖️', 'color': Color(0xFF00B4D8)},
    {'label': 'Jungle', 'icon': '🌿', 'color': Color(0xFF2D9B4E)},
    {'label': 'Temple', 'icon': '🛕', 'color': Color(0xFFE07B39)},
    {'label': 'Hidden', 'icon': '🔮', 'color': Color(0xFF7B5EA7)},
    {'label': 'Other', 'icon': '📍', 'color': Color(0xFFE63946)},
  ];

  static const _accent = Color(0xFF6C63FF);
  static const _bg = Color(0xFFF8F9FF);
  static const _cardBg = Colors.white;
  static const _textDark = Color(0xFF1C1C2E);
  static const _textMid = Color(0xFF6B7280);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      setState(() {
        _images.clear();
        _images.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permission denied');
        }
      }
      final pos = await Geolocator.getCurrentPosition();
      _pickedLocation = LatLng(pos.latitude, pos.longitude);
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _addressCtrl.text = [
          p.street,
          p.locality,
          p.country,
        ].where((s) => s != null && s.isNotEmpty).join(', ');
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickOnMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => _MapPickerPage(initial: _pickedLocation),
      ),
    );
    if (result != null) {
      _pickedLocation = result;
      try {
        final placemarks = await placemarkFromCoordinates(
          result.latitude,
          result.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          _addressCtrl.text = [
            p.street,
            p.locality,
            p.country,
          ].where((s) => s != null && s.isNotEmpty).join(', ');
        }
      } catch (_) {}
      setState(() {});
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a location on the map')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final provider = context.read<AppProvider>();
      final user = provider.currentUser!;
      final place = PlaceModel(
        id: provider.service.generateId(),
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        tags: [_category],
        latitude: _pickedLocation!.latitude,
        longitude: _pickedLocation!.longitude,
        address: _addressCtrl.text.trim(),
        imageUrls: const [],
        authorId: user.uid,
        authorName: user.displayName ?? 'Anonymous',
        createdAt: DateTime.now(),
      );
      await provider.service.addPlace(place);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Place added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color get _selectedCategoryColor {
    return _categories.firstWhere(
          (c) => c['label'] == _category,
          orElse: () => _categories.first,
        )['color']
        as Color;
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: _textMid,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint, {IconData? icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0B7C3), fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, color: _accent, size: 20) : null,
        filled: true,
        fillColor: _cardBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add a Place',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // Hero gradient banner
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_selectedCategoryColor, _accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _categories.firstWhere((c) => c['label'] == _category)['icon']
                      as String,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Destination name
            _sectionLabel('DESTINATION NAME'),
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(fontSize: 14, color: _textDark),
              decoration: _inputDecoration(
                'Enter destination name',
                icon: Icons.place_rounded,
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // Description
            _sectionLabel('DESCRIPTION'),
            TextFormField(
              controller: _descCtrl,
              style: const TextStyle(fontSize: 14, color: _textDark),
              decoration: _inputDecoration(
                'Describe this place...',
                icon: Icons.notes_rounded,
              ),
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // Category chips
            _sectionLabel('CATEGORY'),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _categories.map((cat) {
                final label = cat['label'] as String;
                final color = cat['color'] as Color;
                final icon = cat['icon'] as String;
                final selected = _category == label;
                return GestureDetector(
                  onTap: () => setState(() => _category = label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? color : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: selected ? color : const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : _textMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Upload images
            _sectionLabel('UPLOAD IMAGES'),
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _accent.withOpacity(0.4),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _images.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_rounded,
                              color: _accent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap to upload photos',
                            style: TextStyle(
                              color: _textMid,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(10),
                        itemCount: _images.length + 1,
                        itemBuilder: (_, i) {
                          if (i == _images.length) {
                            return Center(
                              child: Container(
                                width: 80,
                                height: 110,
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  color: _accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _accent.withOpacity(0.4),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: _accent,
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _images[i],
                                width: 90,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Pick location
            _sectionLabel('PICK LOCATION ON MAP'),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                onTap: _pickOnMap,
                child: Container(
                  height: 170,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAF6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _pickedLocation != null
                      ? Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _pickedLocation!,
                                zoom: 14,
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId('picked'),
                                  position: _pickedLocation!,
                                ),
                              },
                              zoomControlsEnabled: false,
                              scrollGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                              tiltGesturesEnabled: false,
                              zoomGesturesEnabled: false,
                              myLocationButtonEnabled: false,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                                child: const Text(
                                  '📍  Tap to change pin',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.map_rounded,
                                color: _accent,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tap to drop a pin',
                              style: TextStyle(
                                color: _textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: _locating ? null : _useCurrentLocation,
                              child: Text(
                                _locating
                                    ? 'Detecting location...'
                                    : 'or use my current location',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _accent,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                  decorationColor: _accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            if (_pickedLocation != null) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                style: const TextStyle(fontSize: 14, color: _textDark),
                decoration: _inputDecoration(
                  'Address',
                  icon: Icons.location_on_rounded,
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
            const SizedBox(height: 32),

            // Submit button
            GestureDetector(
              onTap: _loading ? null : _submit,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_selectedCategoryColor, _accent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Submit Place',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPickerPage extends StatefulWidget {
  final LatLng? initial;
  const _MapPickerPage({this.initial});

  @override
  State<_MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<_MapPickerPage> {
  LatLng? _picked;

  static const _accent = Color(0xFF6C63FF);
  static const _textDark = Color(0xFF1C1C2E);

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pick Location',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_picked != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: () => Navigator.pop(context, _picked),
                style: TextButton.styleFrom(
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _picked ?? const LatLng(13.7563, 100.5018),
          zoom: _picked != null ? 14 : 5,
        ),
        onTap: (pos) => setState(() => _picked = pos),
        markers: _picked != null
            ? {Marker(markerId: const MarkerId('picked'), position: _picked!)}
            : {},
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

