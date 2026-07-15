import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A gradient-circle avatar showing initials, used everywhere a real photo
/// isn't available (users, family members, instructors).
class AvatarPlaceholder extends StatelessWidget {
  const AvatarPlaceholder({
    super.key,
    required this.initials,
    this.size = 44,
    this.colors,
  });

  final String initials;
  final double size;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ?? [AppColors.primary, AppColors.secondary];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
