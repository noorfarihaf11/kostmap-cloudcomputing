import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/auth_service.dart';
import '../data/favorite_service.dart';
import '../models/kost_model.dart';
import '../theme/app_theme.dart';

String _imageUrl(String rawUrl) {
  if (!kIsWeb) return rawUrl;
  final encoded = Uri.encodeComponent(rawUrl);
  return 'http://localhost:3000/api/image-proxy?url=$encoded';
}

class KostCard extends StatelessWidget {
  final Kost kost;
  final VoidCallback onTap;
  final bool isHorizontal;

  const KostCard({
    super.key,
    required this.kost,
    required this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = isHorizontal ? 300.0 : 260.0;
    final width = isHorizontal ? 240.0 : double.infinity;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        margin: isHorizontal ? const EdgeInsets.only(right: 16) : EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _KostImage(kost: kost),
              
              // Dark gradient overlay from bottom
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),

              // Badges
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    if (kost.label.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getLabelColor(kost.label),
                          borderRadius: BorderRadius.circular(12),
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
                  ],
                ),
              ),

              // Favorite Heart
              Positioned(
                top: 16,
                right: 16,
                child: _FavoriteButton(kost: kost),
              ),

              // Content at the bottom
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kost.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            kost.displayAddress,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (kost.distanceKm != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              kost.formattedDistance,
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        else
                          const SizedBox(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            kost.formattedPrice,
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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

class _FavoriteButton extends StatefulWidget {
  final Kost kost;
  const _FavoriteButton({required this.kost});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FavoriteService(),
      builder: (context, _) {
        final isFav = FavoriteService().isFavorite(widget.kost.id);
        return GestureDetector(
          onTap: () async {
            if (!AuthService().isLoggedIn) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Login untuk menyimpan favorit',
                      style: GoogleFonts.dmSans(fontSize: 13)),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }
            await FavoriteService().toggleFavorite(widget.kost);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isFav ? AppColors.primary : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 20,
              color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final rawUrl = kost.validImageUrl;
    if (rawUrl != null) {
      return Image.network(
        _imageUrl(rawUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(
          Icons.home_rounded,
          size: 48,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
