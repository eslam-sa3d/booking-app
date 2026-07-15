import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;

import '../theme/glass.dart';

/// Adaptive replacement for [showDialog]. On Android, behaves identically
/// to [showDialog] — the builder's [AlertDialog]/[StatefulBuilder] content
/// is untouched. On iOS, the same builder output is left completely
/// untouched too; only the framework's own dialog chrome (background,
/// elevation, shape) is made transparent via a [Theme] override, so a real
/// [glass.GlassContainer] shell shows through underneath instead.
Future<T?> showAppDialog<T>(BuildContext context, {required WidgetBuilder builder}) {
  if (!isLiquidGlassPlatform(context)) {
    return showDialog<T>(context: context, builder: builder);
  }

  return showDialog<T>(
    context: context,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return Theme(
        data: Theme.of(ctx).copyWith(
          dialogTheme: const DialogThemeData(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        child: Center(
          child: glass.GlassContainer(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            shape: const glass.LiquidRoundedSuperellipse(borderRadius: 24),
            settings: glass.LiquidGlassSettings(
              glassColor: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.35),
            ),
            child: builder(ctx),
          ),
        ),
      );
    },
  );
}
