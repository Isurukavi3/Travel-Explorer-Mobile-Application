import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../providers/app_provider.dart';
import '../models/place_model.dart';
import 'add_place_page.dart';
import 'map_page.dart';
import 'place_detail_page.dart';
import 'guides_list_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  static const _accent = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      resizeToAvoidBottomInset: false,
      body: _tab == 0
          ? const _HomeView()
          : _tab == 1
          ? const MapPage()
          : _tab == 2
          ? const GuidesListPage()
          : const ProfilePage(),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              elevation: 6,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPlacePage()),
              ),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: _accent,
          unselectedItemColor: const Color(0xFFB0B7C3),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Guides',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _topRatedOnly = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _categories = [
    {'label': 'All', 'color': Color(0xFF2E7D32)},
    {'label': 'Beach', 'color': Color(0xFF00B4D8)},
    {'label': 'Jungle', 'color': Color(0xFF2D9B4E)},
    {'label': 'Temple', 'color': Color(0xFFE07B39)},
    {'label': 'Hidden', 'color': Color(0xFF7B5EA7)},
    {'label': 'Other', 'color': Color(0xFFE63946)},
  ];

  static const _accent = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'Traveler';

    return StreamBuilder<List<PlaceModel>>(
      stream: provider.placesStream,
      builder: (context, snap) {
        final allPlaces = snap.data ?? [];
        final query = _searchQuery.toLowerCase();
        final places = allPlaces.where((p) {
          final matchesCategory =
              _selectedCategory == 'All' ||
              p.category.toLowerCase() == _selectedCategory.toLowerCase();
          final matchesSearch =
              query.isEmpty ||
              p.title.toLowerCase().contains(query) ||
              p.address.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query);
          final matchesTopRated = !_topRatedOnly || p.averageRating >= 4;
          return matchesCategory && matchesSearch && matchesTopRated;
        }).toList();

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 20,
                    20,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $firstName',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Where to explore today?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.25,
                            ),
                            child: Text(
                              firstName.isNotEmpty
                                  ? firstName[0].toUpperCase()
                                  : 'T',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1C1C2E),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search destinations...',
                            hintStyle: const TextStyle(
                              color: Color(0xFFB0B7C3),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFFB0B7C3),
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFFB0B7C3),
                                      size: 18,
                                    ),
                                    onPressed: () => setState(() {
                                      _searchQuery = '';
                                      _searchController.clear();
                                    }),
                                  )
                                : null,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      _StatCard(
                        icon: Icons.place_rounded,
                        label: 'Places',
                        value: '${allPlaces.length}',
                        color: _accent,
                        onTap: () => setState(() {
                          _selectedCategory = 'All';
                          _topRatedOnly = false;
                        }),
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.star_rounded,
                        label: 'Top Rated',
                        value: allPlaces.isEmpty
                            ? '0'
                            : '${allPlaces.where((p) => p.averageRating >= 4).length}',
                        color: const Color(0xFFFFB703),
                        onTap: () => setState(() {
                          _selectedCategory = 'All';
                          _topRatedOnly = true;
                        }),
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.explore_rounded,
                        label: 'Hidden',
                        value:
                            '${allPlaces.where((p) => p.category.toLowerCase() == 'hidden').length}',
                        color: const Color(0xFF7B5EA7),
                        onTap: () => setState(() {
                          _selectedCategory = 'Hidden';
                          _topRatedOnly = false;
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 0, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CATEGORIES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final label = cat['label'] as String;
                            final color = cat['color'] as Color;
                            final selected = _selectedCategory == label;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = label),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected ? color : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: selected
                                        ? color
                                        : const Color(0xFFE5E7EB),
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: color.withValues(
                                              alpha: 0.35,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Featured label
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FEATURED PLACES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '${places.length} places',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB0B7C3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Places list
              if (snap.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _accent),
                  ),
                )
              else if (places.isEmpty)
                SliverFillRemaining(
                  child: Center(
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
                            Icons.explore_off_rounded,
                            size: 48,
                            color: _accent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No places yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1C1C2E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Be the first to add one!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final place = places[i];
                      return _FeaturedCard(
                        place: place,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaceDetailPage(place: place),
                          ),
                        ),
                      );
                    }, childCount: places.length),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onTap;

  const _FeaturedCard({required this.place, required this.onTap});

  static const _categoryColors = {
    'beach': Color(0xFF00B4D8),
    'jungle': Color(0xFF2D9B4E),
    'temple': Color(0xFFE07B39),
    'hidden': Color(0xFF7B5EA7),
    'other': Color(0xFFE63946),
    'popular': Color(0xFF2E7D32),
  };

  Color get _catColor =>
      _categoryColors[place.category.toLowerCase()] ?? const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _catColor.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: place.imageUrls.isNotEmpty
                  ? Image.network(
                      place.imageUrls.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _PlaceholderImage(color: _catColor),
                    )
                  : _PlaceholderImage(color: _catColor),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C1C2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          place.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _catColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: _catColor,
                      ),
                      const SizedBox(width: 4),
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
                  const SizedBox(height: 8),
                  Text(
                    place.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: place.averageRating,
                        itemBuilder: (_, _i) => const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB703),
                        ),
                        itemCount: 5,
                        itemSize: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        place.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C2E),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${place.ratingCount})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFB0B7C3),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 14,
                        color: _catColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${place.commentCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _catColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final Color color;

  const _PlaceholderImage({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
