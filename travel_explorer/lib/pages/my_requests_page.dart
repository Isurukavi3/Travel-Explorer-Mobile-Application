import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/booking_request_model.dart';
import '../providers/app_provider.dart';

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  static const _accent = Color(0xFF2E7D32);
  static const _bg = Color(0xFFF8F9FF);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Sign in to view your requests')),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1C1C2E),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Requests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1C1C2E),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<BookingRequestModel>>(
        stream: provider.service.getMyBookingRequests(user.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }
          final bookings = snap.data ?? [];
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inbox_rounded,
                      size: 52,
                      color: _accent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No requests yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C1C2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Book a guide to see your requests here',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            itemCount: bookings.length,
            itemBuilder: (_, i) => _RequestCard(booking: bookings[i]),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final BookingRequestModel booking;
  const _RequestCard({required this.booking});

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _ratingLoading = false;

  static const _statusConfig = {
    'pending': {
      'color': Color(0xFFFFB703),
      'icon': Icons.hourglass_top_rounded,
      'label': 'Pending',
      'bg': Color(0xFFFFF8E1),
    },
    'accepted': {
      'color': Color(0xFF2D9B4E),
      'icon': Icons.check_circle_rounded,
      'label': 'Accepted',
      'bg': Color(0xFFE8F5E9),
    },
    'declined': {
      'color': Color(0xFFE63946),
      'icon': Icons.cancel_rounded,
      'label': 'Declined',
      'bg': Color(0xFFFFEBEE),
    },
    'completed': {
      'color': Color(0xFF2E7D32),
      'icon': Icons.verified_rounded,
      'label': 'Completed',
      'bg': Color(0xFFEDE7F6),
    },
  };

  static const _avatarColors = [
    Color(0xFF2E7D32),
    Color(0xFF00B4D8),
    Color(0xFF2D9B4E),
    Color(0xFFE07B39),
    Color(0xFF7B5EA7),
    Color(0xFFE63946),
  ];

  Color _guideColor() {
    final b = widget.booking;
    final code = b.guideName.isNotEmpty ? b.guideName.codeUnitAt(0) : 0;
    return _avatarColors[code % _avatarColors.length];
  }

  Future<void> _showRatingDialog() async {
    double selectedRating = 3.0;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        title: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB703).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFB703),
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
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
              const SizedBox(height: 20),
              RatingBar.builder(
                initialRating: selectedRating,
                minRating: 1,
                itemCount: 5,
                itemSize: 44,
                glow: false,
                itemBuilder: (_, i) =>
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB703)),
                onRatingUpdate: (r) => setInner(() => selectedRating = r),
              ),
              const SizedBox(height: 10),
              Text(
                _ratingLabel(selectedRating),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _ratingLabel(double r) {
    if (r <= 1) return 'Poor 😞';
    if (r <= 2) return 'Fair 😐';
    if (r <= 3) return 'Good 🙂';
    if (r <= 4) return 'Great 😊';
    return 'Excellent! 🤩';
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final cfg = _statusConfig[b.status] ?? _statusConfig['pending']!;
    final statusColor = cfg['color'] as Color;
    final statusIcon = cfg['icon'] as IconData;
    final statusLabel = cfg['label'] as String;
    final statusBg = cfg['bg'] as Color;
    final guideColor = _guideColor();
    final canRate =
        (b.status == 'accepted' || b.status == 'completed') &&
        b.guideRating == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: guideColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top colored strip
          Container(
            height: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [guideColor, const Color(0xFF66BB6A)],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: guideColor.withValues(alpha: 0.15),
                      child: Text(
                        b.guideName.isNotEmpty
                            ? b.guideName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: guideColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1C1C2E),
                            ),
                          ),
                          Text(
                            'Requested ${DateFormat('MMM d, y').format(b.createdAt)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
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
                const SizedBox(height: 14),

                // Info chips row
                Row(
                  children: [
                    _Chip(
                      icon: Icons.calendar_month_rounded,
                      label: DateFormat('MMM d, y').format(b.requestedDate),
                      color: guideColor,
                    ),
                    const SizedBox(width: 10),
                    _Chip(
                      icon: Icons.schedule_rounded,
                      label: '${b.hours} hr${b.hours > 1 ? 's' : ''}',
                      color: guideColor,
                    ),
                  ],
                ),

                if (b.message != null && b.message!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      '"${b.message}"',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],

                // Already rated
                if (b.guideRating != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: Color(0xFF2D9B4E),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Your rating: ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2D9B4E),
                            fontWeight: FontWeight.w600,
                          ),
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
                  ),
                ],

                // Rate button
                if (canRate) ...[
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _ratingLoading ? null : _showRatingDialog,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [guideColor, const Color(0xFF66BB6A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: guideColor.withValues(alpha: 0.3),
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
                                  SizedBox(width: 8),
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
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
