import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/auth_service.dart';
import '../data/favorite_service.dart';
import '../models/kost_model.dart';
import '../theme/app_theme.dart';
import 'category_badge.dart';

String _imageUrl(String rawUrl) {
  if (!kIsWeb) return rawUrl;
  final encoded = Uri.encodeComponent(rawUrl);
  return 'http://localhost:3000/api/image-proxy?url=$encoded';
}

class KostCard extends StatelessWidget {
  final Kost kost;
  final VoidCallback onTap;

  const KostCard({super.key, required this.kost, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF724A24).withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  _KostImage(kost: kost),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavoriteButton(kost: kost),
                  ),
                ],
              ),
              _CardContent(kost: kost),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final Kost kost;
  const _FavoriteButton({required this.kost});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoriteService(),
      builder: (context, _) {
        final isFav = FavoriteService().isFavorite(kost.id);
        return GestureDetector(
          onTap: () async {
            if (!AuthService().isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Login untuk menyimpan favorit',
                    style: GoogleFonts.dmSans(fontSize: 13),
                  ),
                  backgroundColor: AppColors.textPrimary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }
            await FavoriteService().toggleFavorite(kost);
          },
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              size: 18,
              color: isFav ? const Color(0xFFE53935) : AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}

class _KostImage extends StatelessWidget {
  final Kost kost;

  const _KostImage({required this.kost});

  List<Color> get _gradientColors {
    switch (kost.label) {
      case 'Putra':
        return [const Color(0xFF8B5E3C), const Color(0xFF5C3D1E)];
      case 'Putri':
        return [const Color(0xFFA0647A), const Color(0xFF724A24)];
      default:
        return [const Color(0xFF9C6B3C), const Color(0xFF724A24)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawUrl = kost.validImageUrl;
    if (rawUrl != null) {
      return SizedBox(
        height: 136,
        width: double.infinity,
        child: Image.network(
          _imageUrl(rawUrl),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder();
          },
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 136,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: -24,
            bottom: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.home_rounded,
                  size: 32,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  kost.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final Kost kost;

  const _CardContent({required this.kost});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  kost.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              CategoryBadge(category: kost.label),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  kost.displayAddress,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kost.formattedPrice,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              if (kost.distanceKm != null)
                _DistanceBadge(distance: kost.formattedDistance),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistanceBadge extends StatelessWidget {
  final String distance;

  const _DistanceBadge({required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.near_me_rounded,
            size: 11,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            distance,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
