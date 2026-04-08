import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/guide_model.dart';
import '../models/booking_request_model.dart';
import '../providers/app_provider.dart';
import 'request_guide_page.dart';

class GuidesListPage extends StatefulWidget {
  const GuidesListPage({super.key});

  @override
  State<GuidesListPage> createState() => _GuidesListPageState();
}

class _GuidesListPageState extends State<GuidesListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _search = '';

  static const _accent = Color(0xFF2E7D32);
  static const _bg = Color(0xFFF8F9FF);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Local Guides',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1C1C2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Find your perfect travel companion',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search guides...',
                        hintStyle: const TextStyle(
                          color: Color(0xFFB0B7C3),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFFB0B7C3),
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabCtrl,
                      labelColor: _accent,
                      unselectedLabelColor: const Color(0xFF6B7280),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      indicator: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Browse Guides'),
                        Tab(text: 'My Bookings'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _GuidesTab(search: _search),
                  user != null
                      ? _MyBookingsTab(touristId: user.uid)
                      : const Center(child: Text('Sign in to view bookings')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Browse Guides Tab ──────────────────────────────────────────────────────────

class _GuidesTab extends StatelessWidget {
  final String search;

  const _GuidesTab({required this.search});

  static const _accent = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final service = context.read<AppProvider>().service;
    return StreamBuilder<List<GuideModel>>(
      stream: service.getAllGuides(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accent));
        }
        var guides = snap.data ?? [];
        if (search.isNotEmpty) {
          guides = guides
              .where(
                (g) =>
                    g.name.toLowerCase().contains(search.toLowerCase()) ||
                    g.expertise.toLowerCase().contains(search.toLowerCase()),
              )
              .toList();
        }
        if (guides.isEmpty) {
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
                    Icons.person_search_rounded,
                    size: 48,
                    color: _accent,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No guides found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C2E),
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: guides.length,
          itemBuilder: (_, i) => _GuideCard(guide: guides[i]),
        );
      },
    );
  }
}

class _GuideCard extends StatelessWidget {
  final GuideModel guide;
  const _GuideCard({required this.guide});

  // Assign a color per guide initial for visual variety
  static const _avatarColors = [
    Color(0xFF2E7D32),
    Color(0xFF00B4D8),
    Color(0xFF2D9B4E),
    Color(0xFFE07B39),
    Color(0xFF7B5EA7),
    Color(0xFFE63946),
  ];

  Color _avatarColor() {
    final code = guide.name.isNotEmpty ? guide.name.codeUnitAt(0) : 0;
    return _avatarColors[code % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                guide.name.isNotEmpty ? guide.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C1C2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  RatingBarIndicator(
                    rating: guide.rating,
                    itemBuilder: (_, i) => const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB703),
                    ),
                    itemCount: 5,
                    itemSize: 16,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.work_outline_rounded, size: 12, color: color),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${guide.reviewCount} yrs experience',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.explore_rounded, size: 12, color: color),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${guide.reviewCount * 14} trips',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // View button
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RequestGuidePage(guide: guide),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'VIEW',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 1,
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

// ── My Bookings Tab ────────────────────────────────────────────────────────────

class _MyBookingsTab extends StatelessWidget {
  final String touristId;
  const _MyBookingsTab({required this.touristId});

  @override
  Widget build(BuildContext context) {
    final service = context.read<AppProvider>().service;
    return StreamBuilder<List<BookingRequestModel>>(
      stream: service.getMyBookingRequests(touristId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          );
        }
        final bookings = snap.data ?? [];
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0x1A6C63FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    size: 48,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No bookings yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C2E),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Book a guide to get started',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: bookings.length,
          itemBuilder: (_, i) => _BookingCard(booking: bookings[i]),
        );
      },
    );
  }
}

class _BookingCard extends StatefulWidget {
  final BookingRequestModel booking;
  const _BookingCard({required this.booking});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _ratingLoading = false;

  static const _statusConfig = {
    'pending': {
      'color': Color(0xFFFFB703),
      'icon': Icons.hourglass_top_rounded,
      'label': 'Pending',
    },
    'accepted': {
      'color': Color(0xFF2D9B4E),
      'icon': Icons.check_circle_rounded,
      'label': 'Accepted',
    },
    'declined': {
      'color': Color(0xFFE63946),
      'icon': Icons.cancel_rounded,
      'label': 'Declined',
    },
    'completed': {
      'color': Color(0xFF2E7D32),
      'icon': Icons.verified_rounded,
      'label': 'Completed',
    },
  };

  Future<void> _showRatingDialog() async {
    double selectedRating = 3.0;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFB703), size: 40),
            const SizedBox(height: 8),
            Text(
              'Rate ${widget.booking.guideName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (_, setInner) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How was your experience?',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              ),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: selectedRating,
                minRating: 1,
                itemCount: 5,
                itemSize: 40,
                itemBuilder: (_, i) =>
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB703)),
                onRatingUpdate: (r) => setInner(() => selectedRating = r),
              ),
              const SizedBox(height: 8),
              Text(
                _ratingLabel(selectedRating),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
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
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _ratingLoading = true);
              try {
                await context.read<AppProvider>().service.rateGuide(
                  guideId: widget.booking.guideId,
                  bookingId: widget.booking.id,
                  rating: selectedRating,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rating submitted, thank you!'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } finally {
                if (mounted) setState(() => _ratingLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(double r) {
    if (r <= 1) return 'Poor';
    if (r <= 2) return 'Fair';
    if (r <= 3) return 'Good';
    if (r <= 4) return 'Great';
    return 'Excellent!';
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final cfg = _statusConfig[b.status] ?? _statusConfig['pending']!;
    final statusColor = cfg['color'] as Color;
    final statusIcon = cfg['icon'] as IconData;
    final statusLabel = cfg['label'] as String;
    final canRate =
        (b.status == 'accepted' || b.status == 'completed') &&
        b.guideRating == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  child: Text(
                    b.guideName.isNotEmpty ? b.guideName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.guideName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1C1C2E),
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, y').format(b.requestedDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _InfoChip(
                    icon: Icons.schedule_rounded,
                    label: '${b.hours}h',
                    color: statusColor,
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.place_rounded,
                    label: b.placeName,
                    color: statusColor,
                  ),
                ],
              ),
            ),
            if (b.message != null && b.message!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                '"${b.message}"',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Already rated
            if (b.guideRating != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: Color(0xFF2D9B4E),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'You rated: ',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  RatingBarIndicator(
                    rating: b.guideRating!,
                    itemBuilder: (_, i) => const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB703),
                    ),
                    itemCount: 5,
                    itemSize: 14,
                  ),
                ],
              ),
            ],
            // Rate button
            if (canRate) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _ratingLoading ? null : _showRatingDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _ratingLoading
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
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Rate this Guide',
                                style: TextStyle(
                                  fontSize: 13,
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
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
