import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/auth_service.dart';
import '../data/favorite_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kost_card.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    FavoriteService().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Favorit',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          ListenableBuilder(
            listenable: FavoriteService(),
            builder: (_, __) {
              if (!FavoriteService().isLoading &&
                  FavoriteService().favorites.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.primary),
                  onPressed: FavoriteService().loadFavorites,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([AuthService(), FavoriteService()]),
        builder: (context, _) {
          if (!AuthService().isLoggedIn) {
            return _buildLoginPrompt(context);
          }
          if (FavoriteService().isLoading) {
            return _buildLoading();
          }
          if (FavoriteService().error != null) {
            return _buildError(FavoriteService().error!);
          }
          if (FavoriteService().favorites.isEmpty) {
            return _buildEmptyState();
          }
          return _buildList();
        },
      ),
    );
  }

  Widget _buildList() {
    final favs = FavoriteService().favorites;
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: favs.length,
      itemBuilder: (context, index) {
        final kost = favs[index];
        return KostCard(
          kost: kost,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(kost: kost)),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              color: AppColors.secondary, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text(
            'Memuat favorit...',
            style: GoogleFonts.dmSans(
                fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 52,
                color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat favorit',
              style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(message,
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: FavoriteService().loadFavorites,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Coba Lagi',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline_rounded,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'Belum ada favorit',
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tekan ikon hati pada kost yang kamu suka\nuntuk menyimpannya di sini.',
            style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 64,
                color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'Login diperlukan',
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Masuk untuk menyimpan dan\nmelihat kost favoritmu.',
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: Text('Masuk',
                    style:
                        GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
