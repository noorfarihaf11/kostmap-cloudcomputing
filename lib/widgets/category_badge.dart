import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  final double fontSize;

  const CategoryBadge({
    super.key,
    required this.category,
    this.fontSize = 11,
  });

  Color get _backgroundColor {
    switch (category) {
      case 'Putra':
        return AppColors.categoryPutraBackground;
      case 'Putri':
        return AppColors.categoryPutriBackground;
      default:
        return AppColors.categoryCampurBackground;
    }
  }

  Color get _textColor {
    switch (category) {
      case 'Putra':
        return AppColors.categoryPutraText;
      case 'Putri':
        return AppColors.categoryPutriText;
      default:
        return AppColors.categoryCampurText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: GoogleFonts.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}
