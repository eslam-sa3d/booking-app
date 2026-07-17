import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;

import '../theme/app_colors.dart';
import '../theme/glass.dart';

/// Adaptive primary/secondary button. Renders `FilledButton`/
/// `FilledButton.tonal` (Material 3 button hierarchy) on Android, and the
/// real `liquid_glass_widgets` [glass.GlassButton] on iOS.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
    this.compact = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;
  final bool compact;

  /// Overrides the button's accent color (defaults to [AppColors.primary]).
  /// Use for destructive actions (e.g. cancel) — the rest of the styling
  /// (outlined/filled, compact sizing) stays the same.
  final Color? color;

  static final ButtonStyle _compactStyle = FilledButton.styleFrom(
    minimumSize: const Size(64, 36),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
  );

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;

    if (!isLiquidGlassPlatform(context)) {
      final content = _content(color: null);
      var style = compact ? _compactStyle : null;
      if (color != null) {
        final colorOverride = ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(outlined ? accent.withValues(alpha: 0.12) : accent),
          foregroundColor: WidgetStatePropertyAll(outlined ? accent : Colors.white),
        );
        style = (style ?? const ButtonStyle()).merge(colorOverride);
      }
      if (outlined) {
        return FilledButton.tonal(onPressed: isLoading ? null : onPressed, style: style, child: content);
      }
      return FilledButton(onPressed: isLoading ? null : onPressed, style: style, child: content);
    }

    // The package's default glass tint is fully transparent (alpha 0) — an
    // explicit color is required or the button renders as blur with no fill,
    // which reads as barely-there/low-contrast against light backgrounds.
    final foreground = outlined ? accent : Colors.white;
    final glassColor = outlined ? accent.withValues(alpha: 0.16) : accent.withValues(alpha: 0.5);

    return glass.GlassButton.custom(
      onTap: onPressed ?? _noop,
      enabled: !isLoading && onPressed != null,
      style: outlined ? glass.GlassButtonStyle.filled : glass.GlassButtonStyle.prominent,
      settings: glass.LiquidGlassSettings(glassColor: glassColor),
      shape: const glass.LiquidRoundedSuperellipse(borderRadius: 14),
      height: compact ? 36 : 52,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: compact ? 13 : 16,
          color: foreground,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground),
          child: _content(color: foreground),
        ),
      ),
    );
  }

  static void _noop() {}

  Widget _content({required Color? color}) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4, color: color ?? Colors.white),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(label),
      ],
    );
  }
}
