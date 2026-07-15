import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Gradient + icon placeholder standing in for a real class photo.
class ClassHeroPlaceholder extends StatelessWidget {
  const ClassHeroPlaceholder({
    super.key,
    required this.colorHex,
    required this.iconName,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.height,
  });

  final String colorHex;
  final String iconName;
  final BorderRadius borderRadius;
  final double? height;

  static const Map<String, IconData> _icons = {
    'pool': Icons.pool_rounded,
    'child_friendly': Icons.child_friendly_rounded,
    'emoji_events': Icons.emoji_events_rounded,
    'bolt': Icons.bolt_rounded,
    'favorite': Icons.favorite_rounded,
    'star': Icons.star_rounded,
    'waves': Icons.waves_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(colorHex);
    final icon = _icons[iconName] ?? Icons.pool_rounded;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: (height ?? 120) * 0.4),
      ),
    );
  }
}
