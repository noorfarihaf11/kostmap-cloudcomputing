import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/kost_model.dart';
import '../theme/app_theme.dart';
import '../widgets/category_badge.dart';
import 'map_screen.dart';

class DetailScreen extends StatelessWidget {
  final Kost kost;

  const DetailScreen({super.key, required this.kost});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildMapSliver(),
              SliverToBoxAdapter(child: _buildContent(context)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          _buildBackButton(context),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildMapSliver() {
    final pos = LatLng(kost.lat, kost.lng);
    final hasImage = kost.imageUrl != null && kost.imageUrl!.isNotEmpty;

    Widget background = hasImage
        ? Image.network(
            kost.imageUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _buildOsmPreview(pos),
          )
        : _buildOsmPreview(pos);

    return SliverAppBar(
      expandedHeight: 260,
      pinned: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(background: background),
    );
  }

  Widget _buildOsmPreview(LatLng pos) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: pos,
        initialZoom: 15.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
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
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_pin,
                color: AppColors.primary,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
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
          icon: const Icon(Icons.map_rounded, size: 18),
          label: Text(
            'Lihat di Peta',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameSection(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            if (kost.description != null && kost.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDescriptionSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                kost.title,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            CategoryBadge(category: kost.label, fontSize: 12),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          kost.formattedPrice,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final rows = <Widget>[
      _InfoRow(
        icon: Icons.location_on_outlined,
        label: 'Alamat',
        value: kost.displayAddress,
      ),
      if (kost.neighborhood != null) ...[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: AppColors.divider, height: 1),
        ),
        _InfoRow(
          icon: Icons.place_outlined,
          label: 'Kelurahan',
          value: kost.neighborhood!,
        ),
      ],
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(color: AppColors.divider, height: 1),
      ),
      _InfoRow(
        icon: Icons.my_location_rounded,
        label: 'Koordinat',
        value: '${kost.lat.toStringAsFixed(5)}, ${kost.lng.toStringAsFixed(5)}',
      ),
      if (kost.distanceKm != null) ...[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: AppColors.divider, height: 1),
        ),
        _InfoRow(
          icon: Icons.near_me_rounded,
          label: 'Jarak dari kamu',
          value: kost.formattedDistance,
        ),
      ],
      if (kost.phone != null) ...[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: AppColors.divider, height: 1),
        ),
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Telepon',
          value: kost.phone!,
          onTap: () => launchUrl(Uri.parse('tel:${kost.phone}')),
        ),
      ],
      if (kost.website != null) ...[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: AppColors.divider, height: 1),
        ),
        _InfoRow(
          icon: Icons.language_outlined,
          label: 'Website',
          value: kost.website!,
          onTap: () => launchUrl(Uri.parse(kost.website!),
              mode: LaunchMode.externalApplication),
        ),
      ],
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(children: rows),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          kost.description!,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: onTap != null ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

