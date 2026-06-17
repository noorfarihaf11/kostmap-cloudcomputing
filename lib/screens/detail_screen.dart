import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/kost_model.dart';
import '../theme/app_theme.dart';
import 'map_screen.dart';

String _imageUrl(String rawUrl) {
  if (!kIsWeb) return rawUrl;
  final encoded = Uri.encodeComponent(rawUrl);
  return 'http://localhost:3000/api/image-proxy?url=$encoded';
}

class DetailScreen extends StatelessWidget {
  final Kost kost;

  const DetailScreen({super.key, required this.kost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full-bleed Background Image
          Positioned.fill(
            child: kost.validImageUrl != null
                ? Image.network(
                    _imageUrl(kost.validImageUrl!),
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.grey.shade900),
          ),
          
          // 2. Top Gradient for Back Button visibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ),
          
          // 3. Top Bar (Back Button & Actions)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGlassButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      _buildGlassButton(
                        icon: Icons.share_rounded,
                        onTap: () {}, // share
                      ),
                      const SizedBox(width: 12),
                      _buildGlassButton(
                        icon: Icons.favorite_border_rounded,
                        onTap: () {}, // favorite
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. Draggable Scrollable Sheet (The Content)
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
                      ),
                    ),
                    child: Stack(
                      children: [
                        CustomScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  // Drag Handle
                                  Container(
                                    width: 48,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  _buildHeader(),
                                  const SizedBox(height: 24),
                                  _buildDivider(),
                                  const SizedBox(height: 24),
                                  _buildHostInfo(),
                                  const SizedBox(height: 24),
                                  _buildDivider(),
                                  const SizedBox(height: 24),
                                  if (kost.description != null && kost.description!.isNotEmpty) ...[
                                    _buildDescription(),
                                    const SizedBox(height: 24),
                                    _buildDivider(),
                                    const SizedBox(height: 24),
                                  ],
                                  _buildAmenities(),
                                  const SizedBox(height: 24),
                                  _buildDivider(),
                                  const SizedBox(height: 24),
                                  _buildMapPreview(context),
                                  const SizedBox(height: 120), // Bottom padding for sticky bar
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // 5. Sticky Bottom Bar (Glassmorphism)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStickyBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.15));
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kost.label.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getLabelColor(kost.label),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              kost.label.toUpperCase(),
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          kost.title,
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
            const SizedBox(width: 6),
            Text(
              '4.8',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text('·', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white54)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                kost.displayAddress,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHostInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dikelola oleh Pemilik Kost',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                kost.label.isNotEmpty ? 'Kategori: ${kost.label}' : 'Kost Tersedia',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tentang tempat ini',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          kost.description!,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.85),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fasilitas yang ditawarkan',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildAmenityRow(Icons.wifi_rounded, 'Wifi Cepat'),
        const SizedBox(height: 16),
        _buildAmenityRow(Icons.bed_rounded, 'Kamar Tidur Nyaman'),
        const SizedBox(height: 16),
        _buildAmenityRow(Icons.shower_rounded, 'Kamar Mandi Dalam'),
        if (kost.phone != null) ...[
          const SizedBox(height: 16),
          _buildAmenityRow(
            Icons.phone_rounded,
            'Telepon: ${kost.phone}',
            onTap: () => launchUrl(Uri.parse('tel:${kost.phone}')),
          ),
        ],
      ],
    );
  }

  Widget _buildAmenityRow(IconData icon, String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 26, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    final pos = LatLng(kost.lat, kost.lng);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lokasi',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        if (kost.neighborhood != null) ...[
          Text(
            kost.neighborhood!,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: IgnorePointer(
              ignoring: true, // make it just a preview
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: pos,
                  initialZoom: 15.5,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.kostmap',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pos,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    kost.formattedPrice,
                    style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (kost.distanceKm != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      kost.formattedDistance,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapScreen(
                      lat: kost.lat,
                      lng: kost.lng,
                      title: kost.title,
                      distanceKm: kost.distanceKm,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Lihat Rute',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'putra':
        return AppColors.categoryPutraText;
      case 'putri':
        return AppColors.categoryPutriText;
      case 'campur':
      default:
        return AppColors.categoryCampurText;
    }
  }
}
