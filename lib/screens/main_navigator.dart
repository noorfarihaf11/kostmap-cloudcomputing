import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'kosts_map_screen.dart';
import 'favorite_screen.dart';
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
    FavoriteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // IMPORTANT: Allows body to go behind the bottom nav
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildFloatingDock(),
    );
  }

  Widget _buildFloatingDock() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded),
                _buildNavItem(1, Icons.map_outlined, Icons.map_rounded),
                _buildNavItem(2, Icons.favorite_outline_rounded, Icons.favorite_rounded),
                _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconOutlined, IconData iconRounded) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 64,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSelected ? iconRounded : iconOutlined,
              color: isSelected ? Colors.white : AppColors.textSecondary.withOpacity(0.6),
              size: isSelected ? 22 : 24,
            ),
          ),
        ),
      ),
    );
  }
}
