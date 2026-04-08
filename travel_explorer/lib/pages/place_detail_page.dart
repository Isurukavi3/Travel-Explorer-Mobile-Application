import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place_model.dart';
import '../models/comment_model.dart';
import '../providers/app_provider.dart';
import 'user_profile_view_page.dart';

class PlaceDetailPage extends StatefulWidget {
  final PlaceModel place;
  const PlaceDetailPage({super.key, required this.place});

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  final _commentCtrl = TextEditingController();
  double _rating = 3;
  bool _submitting = false;

  static const _accent = Color(0xFF6C63FF);
  static const _bg = Color(0xFFF8F9FF);

  static const _categoryColors = {
    'beach': Color(0xFF00B4D8),
    'jungle': Color(0xFF2D9B4E),
    'temple': Color(0xFFE07B39),
    'hidden': Color(0xFF7B5EA7),
    'other': Color(0xFFE63946),
    'popular': Color(0xFF6C63FF),
  };

  static const _categoryIcons = {
    'beach': '🏖️',
    'jungle': '🌿',
    'temple': '🛕',
    'hidden': '🔮',
    'other': '📍',
    'popular': '⭐',
  };

  Color get _catColor =>
      _categoryColors[widget.place.category.toLowerCase()] ?? _accent;
  String get _catIcon =>
      _categoryIcons[widget.place.category.toLowerCase()] ?? '📍';

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    // Capture context-dependent values before the async gap
    final provider = context.read<AppProvider>();
    final user = provider.currentUser!;
    final text = _commentCtrl.text.trim();
    try {
      final comment = CommentModel(
        id: provider.service.generateId(),
        placeId: widget.place.id,
        authorId: user.uid,
        authorName: user.displayName ?? 'Anonymous',
        text: text,
        rating: _rating,
        createdAt: DateTime.now(),
      );
      await provider.service.addComment(comment);
      if (mounted) {
        _commentCtrl.clear();
        setState(() => _rating = 3);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _openDirections() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${widget.place.latitude},${widget.place.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _deletePlace(AppProvider provider) async {
    try {
      await provider.service.deletePlace(widget.place.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Place deleted')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final provider = context.read<AppProvider>();
    final isAuthor = provider.currentUser?.uid == place.authorId;
    final color = _catColor;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          // App bar with hero image / gradient placeholder
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            actions: [
              if (isAuthor)
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text(
                        'Delete Place?',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      content: const Text(
                        'This action cannot be undone.',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _deletePlace(provider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE63946),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: place.imageUrls.isNotEmpty
                  ? PageView.builder(
                      itemCount: place.imageUrls.length,
                      itemBuilder: (_, i) => Image.network(
                        place.imageUrls[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _HeroPlaceholder(color: color, icon: _catIcon),
                      ),
                    )
                  : _HeroPlaceholder(color: color, icon: _catIcon),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main info card
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + category badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              place.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1C1C2E),
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$_catIcon ${place.category}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Rating row
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: place.averageRating,
                            itemBuilder: (_, i) => const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFB703),
                            ),
                            itemCount: 5,
                            itemSize: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            place.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1C1C2E),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${place.ratingCount} reviews)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Address
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              place.address,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Directions button
                      GestureDetector(
                        onTap: _openDirections,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color, _accent],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Get Directions',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        place.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Posted by
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfileViewPage(
                              userId: place.authorId,
                              displayName: place.authorName,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: color.withValues(alpha: 0.15),
                              child: Text(
                                place.authorName.isNotEmpty
                                    ? place.authorName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Posted by ${place.authorName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: color,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('MMM d, y').format(place.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFB0B7C3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Reviews section header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Reviews',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1C1C2E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${place.commentCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Write review form
                _ReviewForm(
                  controller: _commentCtrl,
                  rating: _rating,
                  color: color,
                  onRatingChanged: (r) => setState(() => _rating = r),
                  onSubmit: _submitComment,
                  submitting: _submitting,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Comments list
          StreamBuilder<List<CommentModel>>(
            stream: context.read<AppProvider>().service.getComments(place.id),
            builder: (context, snap) {
              if (snap.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Could not load reviews: ${snap.error}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE63946),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              final comments = snap.data ?? [];
              if (comments.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No reviews yet — be the first!',
                        style: TextStyle(
                          fontSize: 13,
                          color: color.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) =>
                      _ReviewTile(comment: comments[i], accentColor: color),
                  childCount: comments.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ── Hero placeholder ───────────────────────────────────────────────────────────

class _HeroPlaceholder extends StatelessWidget {
  final Color color;
  final String icon;
  const _HeroPlaceholder({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 80))),
    );
  }
}

// ── Review form ────────────────────────────────────────────────────────────────

class _ReviewForm extends StatelessWidget {
  final TextEditingController controller;
  final double rating;
  final Color color;
  final void Function(double) onRatingChanged;
  final VoidCallback onSubmit;
  final bool submitting;

  const _ReviewForm({
    required this.controller,
    required this.rating,
    required this.color,
    required this.onRatingChanged,
    required this.onSubmit,
    required this.submitting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rate_review_rounded, color: color, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1C2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Star picker
          Center(
            child: RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              itemCount: 5,
              itemSize: 36,
              glow: false,
              itemBuilder: (_, i) =>
                  const Icon(Icons.star_rounded, color: Color(0xFFFFB703)),
              onRatingUpdate: onRatingChanged,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              _label(rating),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1C1C2E)),
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              hintStyle: const TextStyle(
                color: Color(0xFFB0B7C3),
                fontSize: 14,
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FF),
              contentPadding: const EdgeInsets.all(14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: color, width: 2),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: submitting ? null : onSubmit,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, const Color(0xFF48CAE4)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Post Review',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _label(double r) {
    if (r <= 1) return 'Poor 😞';
    if (r <= 2) return 'Fair 😐';
    if (r <= 3) return 'Good 🙂';
    if (r <= 4) return 'Great 😊';
    return 'Excellent! 🤩';
  }
}

// ── Review tile ────────────────────────────────────────────────────────────────

class _ReviewTile extends StatelessWidget {
  final CommentModel comment;
  final Color accentColor;

  const _ReviewTile({required this.comment, required this.accentColor});

  static const _avatarColors = [
    Color(0xFF6C63FF),
    Color(0xFF00B4D8),
    Color(0xFF2D9B4E),
    Color(0xFFE07B39),
    Color(0xFF7B5EA7),
    Color(0xFFE63946),
  ];

  Color _avatarColor() {
    final code = comment.authorName.isNotEmpty
        ? comment.authorName.codeUnitAt(0)
        : 0;
    return _avatarColors[code % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor();
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(
                  comment.authorName.isNotEmpty
                      ? comment.authorName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfileViewPage(
                        userId: comment.authorId,
                        displayName: comment.authorName,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: color,
                          decoration: TextDecoration.underline,
                          decorationColor: color,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, y').format(comment.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB0B7C3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Rating badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB703).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: Color(0xFFFFB703),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      comment.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFB703),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment.text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
