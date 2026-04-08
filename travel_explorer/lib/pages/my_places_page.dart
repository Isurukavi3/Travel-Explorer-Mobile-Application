import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../providers/app_provider.dart';
import 'place_detail_page.dart';

class MyPlacesPage extends StatelessWidget {
  const MyPlacesPage({super.key});

  static const _accent = Color(0xFF00B4D8);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final uid = provider.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text(
          'My Places',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFF8F9FF),
        foregroundColor: const Color(0xFF1C1C2E),
        elevation: 0,
      ),
      body: StreamBuilder<List<PlaceModel>>(
        stream: provider.service.getPlacesByAuthor(uid),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error: ${snap.error}',
                style: const TextStyle(color: Color(0xFFE63946), fontSize: 13),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }
          final places = snap.data ?? [];
          if (places.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.place_rounded,
                      size: 48,
                      color: _accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No places added yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Add a place from the home screen',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            itemCount: places.length,
            itemBuilder: (_, i) => _PlaceRow(place: places[i]),
          );
        },
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final PlaceModel place;
  const _PlaceRow({required this.place});

  static const _categoryColors = {
    'beach': Color(0xFF00B4D8),
    'jungle': Color(0xFF2D9B4E),
    'temple': Color(0xFFE07B39),
    'hidden': Color(0xFF7B5EA7),
    'other': Color(0xFFE63946),
    'popular': Color(0xFF6C63FF),
  };

  Color get _color =>
      _categoryColors[place.category.toLowerCase()] ?? const Color(0xFF6C63FF);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceDetailPage(place: place)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail / placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: place.imageUrls.isNotEmpty
                  ? Image.network(
                      place.imageUrls.first,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _Thumb(color: _color, category: place.category),
                    )
                  : _Thumb(color: _color, category: place.category),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C1C2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 12, color: _color),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          place.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: place.averageRating,
                        itemBuilder: (_, __) => const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB703),
                        ),
                        itemCount: 5,
                        itemSize: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        place.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C2E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 12,
                        color: _color,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${place.commentCount}',
                        style: TextStyle(fontSize: 12, color: _color),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _color),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final Color color;
  final String category;
  const _Thumb({required this.color, required this.category});

  static const _icons = {
    'beach': '🏖️',
    'jungle': '🌿',
    'temple': '🛕',
    'hidden': '🔮',
    'other': '📍',
    'popular': '⭐',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _icons[category.toLowerCase()] ?? '📍',
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}
