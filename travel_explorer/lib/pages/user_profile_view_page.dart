import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_profile_model.dart';
import '../models/place_model.dart';
import '../providers/app_provider.dart';
import 'place_detail_page.dart';

class UserProfileViewPage extends StatefulWidget {
  final String userId;
  final String displayName;

  const UserProfileViewPage({
    super.key,
    required this.userId,
    required this.displayName,
  });

  @override
  State<UserProfileViewPage> createState() => _UserProfileViewPageState();
}

class _UserProfileViewPageState extends State<UserProfileViewPage> {
  static const _accent = Color(0xFF2E7D32);

  static const _avatarColors = [
    Color(0xFF2E7D32),
    Color(0xFF00B4D8),
    Color(0xFF2D9B4E),
    Color(0xFFE07B39),
    Color(0xFF7B5EA7),
    Color(0xFFE63946),
  ];

  Color _avatarColor(String name) {
    final code = name.isNotEmpty ? name.codeUnitAt(0) : 0;
    return _avatarColors[code % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<AppProvider>().service;
    final color = _avatarColor(widget.displayName);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: FutureBuilder<UserProfileModel?>(
        future: service.getUserProfile(widget.userId),
        builder: (context, snap) {
          final profile = snap.data;
          final name = profile?.name ?? widget.displayName;

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, _accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 12,
                    20,
                    32,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        backgroundImage: profile?.profileImageUrl != null
                            ? NetworkImage(profile!.profileImageUrl!)
                            : null,
                        child: profile?.profileImageUrl == null
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      if (snap.connectionState == ConnectionState.waiting) ...[
                        const SizedBox(height: 12),
                        const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Contact info
                    if (profile != null &&
                        (profile.phone != null ||
                            profile.email != null ||
                            profile.website != null)) ...[
                      _SectionLabel('CONTACT INFORMATION'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (profile.phone != null)
                              _ContactRow(
                                icon: Icons.phone_outlined,
                                label: profile.phone!,
                                color: color,
                                onTap: () => _copy(context, profile.phone!),
                              ),
                            if (profile.phone != null &&
                                (profile.email != null ||
                                    profile.website != null))
                              const Divider(height: 20),
                            if (profile.email != null)
                              _ContactRow(
                                icon: Icons.mail_outline_rounded,
                                label: profile.email!,
                                color: color,
                                onTap: () => _copy(context, profile.email!),
                              ),
                            if (profile.email != null &&
                                profile.website != null)
                              const Divider(height: 20),
                            if (profile.website != null)
                              _ContactRow(
                                icon: Icons.link_rounded,
                                label: profile.website!,
                                color: color,
                                onTap: () => _copy(context, profile.website!),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Interests
                    if (profile != null && profile.interests.isNotEmpty) ...[
                      _SectionLabel('TRAVEL INTERESTS'),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.interests.map((i) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                i,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Their places
                    _SectionLabel('PLACES ADDED'),
                    const SizedBox(height: 12),
                    StreamBuilder<List<PlaceModel>>(
                      stream: service.getPlacesByAuthor(widget.userId),
                      builder: (context, placesSnap) {
                        if (placesSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(color: _accent),
                            ),
                          );
                        }
                        final places = placesSnap.data ?? [];
                        if (places.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text(
                                'No places added yet',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: places
                              .map((p) => _PlaceRow(place: p, color: color))
                              .toList(),
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: Color(0xFF6B7280),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1C1C2E)),
            ),
          ),
          Icon(
            Icons.copy_rounded,
            size: 14,
            color: color.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final PlaceModel place;
  final Color color;
  const _PlaceRow({required this.place, required this.color});

  static const _categoryColors = {
    'beach': Color(0xFF00B4D8),
    'jungle': Color(0xFF2D9B4E),
    'temple': Color(0xFFE07B39),
    'hidden': Color(0xFF7B5EA7),
    'other': Color(0xFFE63946),
    'popular': Color(0xFF2E7D32),
  };

  Color get _catColor => _categoryColors[place.category.toLowerCase()] ?? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlaceDetailPage(place: place)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _catColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _catColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.place_rounded, color: _catColor, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.address,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _catColor),
          ],
        ),
      ),
    );
  }
}
