import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;

import '../theme/glass.dart';

/// Adaptive replacement for [showModalBottomSheet]. Android (and iOS when
/// [useGlass] is false) behaves identically to [showModalBottomSheet] — the
/// builder's content and [shape] are untouched. On iOS with [useGlass] true
/// (the default), the same builder content is wrapped, unmodified, in a real
/// [glass.GlassSheet] shell instead of the plain Material sheet surface.
///
/// [useGlass] is an escape hatch for sheets with known scroll-perf risk in
/// [glass.GlassSheet] (e.g. a [DraggableScrollableSheet] body) — those stay
/// on the plain Material sheet even on iOS.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useGlass = true,
  ShapeBorder? shape,
}) {
  if (!isLiquidGlassPlatform(context) || !useGlass) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      shape: shape,
      builder: builder,
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: (ctx) => glass.GlassSheet(child: builder(ctx)),
  );
}
