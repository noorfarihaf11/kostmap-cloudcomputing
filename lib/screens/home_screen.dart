import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/kost_service.dart';
import '../models/kost_model.dart';
import '../theme/app_theme.dart';
import '../data/auth_service.dart';
import '../widgets/kost_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  List<Kost> _allKosts = [];
  List<Kost> _displayList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Putra', 'Putri', 'Campur'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final kosts = await KostService.fetchAllKost();
      if (!mounted) return;

      setState(() {
        _allKosts = kosts;
        _displayList = kosts;
        _isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _displayList = _allKosts.where((kost) {
        final matchesFilter =
            _selectedFilter == 'Semua' || kost.label == _selectedFilter;
        final query = _searchQuery.toLowerCase();
        final matchesSearch = kost.title.toLowerCase().contains(query) ||
            kost.displayAddress.toLowerCase().contains(query);
        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Body
          RefreshIndicator(
            onRefresh: _fetchData,
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                _buildFilterChips(),
                if (_isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (_errorMessage != null)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Gagal memuat data',
                            style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _fetchData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_displayList.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Kost tidak ditemukan',
                            style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  _buildHorizontalCarousel(),
                  _buildSectionTitle('Rekomendasi Lainnya'),
                  _buildMasonryGrid(),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)), // space for search bar and dock
                ],
              ],
            ),
          ),
          // Thumb-friendly Floating Search Bar
          Positioned(
            bottom: 100, // Above the floating dock
            left: 24,
            right: 24,
            child: _buildFloatingSearchBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.secondary,
      elevation: 0,
      expandedHeight: 120,
      floating: true,
      pinned: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
        title: ListenableBuilder(
          listenable: AuthService(),
          builder: (context, _) {
            final user = AuthService().currentUser;
            final name = user?.name ?? 'Pencari Kost';
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Halo, $name',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Beranda',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: SizedBox(
          height: 48,
          child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = filter == _selectedFilter;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter);
                _applyFilter();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

  Widget _buildHorizontalCarousel() {
    if (_displayList.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
    
    // Take up to 5 items for the carousel
    final carouselItems = _displayList.take(5).toList();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Text(
              'Pilihan Populer',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            height: 340,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: carouselItems.length,
              itemBuilder: (context, index) {
                return KostCard(
                  kost: carouselItems[index],
                  isHorizontal: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(kost: carouselItems[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    if (_displayList.length <= 5) return const SliverToBoxAdapter(child: SizedBox());
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildMasonryGrid() {
    if (_displayList.length <= 5) return const SliverToBoxAdapter(child: SizedBox());
    
    final gridItems = _displayList.skip(5).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // we process 2 items per row
            if (index % 2 != 0) return const SizedBox.shrink();
            final leftItem = gridItems[index];
            final rightItem = (index + 1 < gridItems.length) ? gridItems[index + 1] : null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: KostCard(
                      kost: leftItem,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailScreen(kost: leftItem)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: rightItem != null
                        ? KostCard(
                            kost: rightItem,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DetailScreen(kost: rightItem)),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          },
          childCount: gridItems.length,
        ),
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(Icons.search_rounded, color: AppColors.primary.withOpacity(0.8), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _applyFilter();
                  },
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari kost di mana?',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _applyFilter();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}
