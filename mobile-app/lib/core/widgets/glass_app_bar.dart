import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/glass.dart';

/// Drop-in replacement for [AppBar]. On iOS it renders as a translucent,
/// blurred "liquid glass" bar (matching the iOS system chrome look); on
/// Android/other platforms it renders as a standard flat Material 3
/// [AppBar] — no visual change there.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.centerTitle,
    this.leading,
  });

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;
  final Widget? leading;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    if (!isLiquidGlassPlatform(context)) {
      return AppBar(title: title, actions: actions, bottom: bottom, centerTitle: centerTitle, leading: leading);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? const Color(0xFF0B1220) : Colors.white;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AppBar(
          title: title,
          actions: actions,
          bottom: bottom,
          centerTitle: centerTitle,
          leading: leading,
          backgroundColor: tint.withValues(alpha: 0.65),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.5), width: 0.6)),
        ),
      ),
    );
  }
}
