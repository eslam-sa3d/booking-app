import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;

import '../theme/glass.dart';

/// Drop-in replacement for [AppBar]. On iOS it renders as a real
/// `liquid_glass_widgets` [glass.GlassAppBar] (genuine iOS 26 Liquid Glass
/// chrome); on Android/other platforms it renders as a standard flat
/// Material 3 [AppBar] — no visual change there.
///
/// [glass.GlassAppBar] has no `bottom` slot (its own design intentionally
/// keeps the bar to a simple leading/title/actions layout — see its
/// doc comment). The one call site that needs a `bottom` (a [TabBar] in
/// `my_bookings_screen.dart`) keeps the previous hand-rolled
/// `BackdropFilter`-blurred [AppBar] instead, since that's the only way to
/// blur a bar that also hosts a bottom widget at this package version.
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
    // Stock AppBar auto-implies a back button whenever the route can be
    // popped and no leading widget was given — glass.GlassAppBar (used on
    // iOS below) has no such logic and silently renders nothing, so every
    // pushed screen loses its back button on iOS unless we synthesize one
    // here ourselves.
    final weSynthesizedLeading = leading == null && Navigator.canPop(context);
    final effectiveLeading = leading ?? (weSynthesizedLeading ? _GlassBackButton(isGlass: isLiquidGlassPlatform(context)) : null);

    if (!isLiquidGlassPlatform(context)) {
      return AppBar(title: title, actions: actions, bottom: bottom, centerTitle: centerTitle, leading: effectiveLeading);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? const Color(0xFF0B1220) : Colors.white;
    final hairline = Border(bottom: BorderSide(color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.5), width: 0.6));
    // BackdropFilter only blurs whatever's already painted behind it — none
    // of these screens set extendBodyBehindAppBar, so the appBar's own
    // region has nothing but flat scaffold background behind it, and
    // blurring flat color against flat color is invisible. A soft shadow
    // (unclipped, so it can bleed past the bar's own bounds) gives the bar
    // real depth/separation regardless of what's behind it.
    final depthShadow = BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.08),
      blurRadius: 18,
      offset: const Offset(0, 6),
    );

    if (bottom != null) {
      return DecoratedBox(
        decoration: BoxDecoration(boxShadow: [depthShadow]),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              title: title,
              actions: actions,
              bottom: bottom,
              centerTitle: centerTitle,
              leading: effectiveLeading,
              backgroundColor: tint.withValues(alpha: 0.78),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              shape: hairline,
            ),
          ),
        ),
      );
    }

    // [glass.GlassAppBar] itself only paints a flat backgroundColor — the
    // package's own design intentionally leaves blur to the scroll content
    // passing underneath (see the class doc comment), which isn't wired up
    // here since screen bodies aren't being touched.
    return DecoratedBox(
      decoration: BoxDecoration(boxShadow: [depthShadow]),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(border: hairline),
            child: glass.GlassAppBar(
              title: title,
              leading: effectiveLeading,
              // glass.GlassAppBar centers the title within whatever space is
              // left between leading and actions, not the bar's full width —
              // so a leading-only bar (the common case here) reads as
              // off-center, shifted right by half the back button's width.
              // Balancing it with a matching invisible spacer on the
              // trailing side keeps the title visually centered on screen.
              actions: (weSynthesizedLeading && (actions == null || actions!.isEmpty))
                  ? const [SizedBox(width: _GlassBackButton.width)]
                  : actions,
              centerTitle: centerTitle ?? true,
              backgroundColor: tint.withValues(alpha: 0.78),
              preferredSize: const Size.fromHeight(kToolbarHeight),
            ),
          ),
        ),
      ),
    );
  }
}

/// Default back button synthesized by [GlassAppBar] when a screen is pushed
/// and doesn't supply its own `leading`. Uses a real [glass.GlassButton] on
/// iOS to match the rest of the bar's chrome; a plain [BackButton] elsewhere.
class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.isGlass});

  static const double width = 40;

  final bool isGlass;

  @override
  Widget build(BuildContext context) {
    if (!isGlass) return const BackButton();
    return glass.GlassButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      iconSize: 18,
      width: width,
      height: width,
      style: glass.GlassButtonStyle.transparent,
      onTap: () => Navigator.maybePop(context),
    );
  }
}
