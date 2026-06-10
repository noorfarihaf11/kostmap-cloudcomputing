import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'placeholder_screen.dart';
import 'kosts_map_screen.dart';
import 'profile_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    KostsMapScreen(),
    PlaceholderScreen(
      title: 'Favorit',
      icon: Icons.favorite_outline_rounded,
      message: 'Kost yang kamu simpan akan tampil di sini',
    ),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          _navItem(
            label: 'Beranda',
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            index: 0,
          ),
          _navItem(
            label: 'Peta',
            icon: Icons.map_outlined,
            activeIcon: Icons.map_rounded,
            index: 1,
          ),
          _navItem(
            label: 'Favorit',
            icon: Icons.favorite_outline_rounded,
            activeIcon: Icons.favorite_rounded,
            index: 2,
          ),
          _navItem(
            label: 'Profil',
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            index: 3,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _navItem({
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24),
      activeIcon: Icon(activeIcon, size: 24),
      label: label,
      backgroundColor: Colors.transparent,
      tooltip: '',
    );
  }
}
