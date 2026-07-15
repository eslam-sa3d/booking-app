import 'dart:ui';

import 'package:flutter/material.dart';

/// True when running on iOS, where the app uses the frosted "liquid glass"
/// chrome instead of flat Material 3 surfaces. Android (and everything
/// else) keeps standard Material 3.
bool isLiquidGlassPlatform(BuildContext context) => Theme.of(context).platform == TargetPlatform.iOS;

/// A frosted-glass panel: blurred backdrop, translucent tint, hairline
/// border and a soft highlight — the building block for iOS chrome
/// (bottom nav, app bars, sheets). On Android this is unused; Material 3's
/// own Card/AppBar surfaces are used instead.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.blurSigma = 24,
    this.tintOpacity = 0.55,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final double tintOpacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? const Color(0xFF141E30) : Colors.white;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: tint.withValues(alpha: tintOpacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: (isDark ? Colors.white : Colors.white).withValues(alpha: isDark ? 0.08 : 0.6),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
