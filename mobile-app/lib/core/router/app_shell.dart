import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as glass;

import '../localization/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/glass.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isGlass = isLiquidGlassPlatform(context);

    final destinations = [
      (Icons.home_outlined, Icons.home_rounded, l10n.navHome),
      (Icons.event_note_outlined, Icons.event_note_rounded, l10n.navBookings),
      (Icons.calendar_month_outlined, Icons.calendar_month_rounded, l10n.navCalendar),
      (Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
    ];

    if (!isGlass) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
          destinations: [
            for (final d in destinations) NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3),
          ],
        ),
      );
    }

    // A deliberate dark floating pill (matching Instagram/Claude-style
    // floating tab bars) for the bar itself — the liquid_glass_widgets
    // shader path was tried extensively for the OUTER surface and kept
    // rendering as an inconsistent pale smudge, since GlassContainer always
    // paints a visible surface across its full bounds and blurring the
    // mostly-flat page background behind it just produces a washed-out
    // rectangle. The bar shell below is hand-rolled: real BackdropFilter
    // blur plus a solid tint for a predictable resting look.
    //
    // The SELECTED-TAB indicator is different: a single real liquid-glass
    // blob (glass.GlassContainer, GlassQuality.premium) that physically
    // slides between tab positions via AnimatedPositioned in a Stack,
    // instead of each tab having its own independent fade-in/fade-out
    // highlight — this is what actually produces the "floating lens"
    // look (refraction + specular sheen) real iOS 26 tab bars have, rather
    // than a flat opacity highlight.
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        // MediaQuery.padding.bottom is the actual home-indicator safe-area
        // inset — without adding it here, the pill sits flush against the
        // bottom edge instead of floating clear above it.
        padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.6),
                ),
                child: _SlidingTabBar(
                  destinations: destinations,
                  currentIndex: navigationShell.currentIndex,
                  onTap: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlidingTabBar extends StatelessWidget {
  const _SlidingTabBar({required this.destinations, required this.currentIndex, required this.onTap});

  final List<(IconData, IconData, String)> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final slotWidth = constraints.maxWidth / destinations.length;
        const blobMargin = 6.0;
        const blobHeight = 48.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              left: currentIndex * slotWidth + blobMargin,
              top: (60 - blobHeight) / 2,
              width: slotWidth - blobMargin * 2,
              height: blobHeight,
              child: glass.GlassContainer(
                // Premium quality is what actually runs the refraction/
                // specular shader — without it this would just be a flat
                // tinted blob. useOwnLayer is required since this sits
                // outside any AdaptiveLiquidGlassLayer ancestor.
                quality: glass.GlassQuality.premium,
                useOwnLayer: true,
                // A subtle shader effect over a flat, unvaried teal bar
                // background was previously invisible (nothing to refract,
                // low-alpha tint blends straight in) — this shape needs to
                // be unmistakably visible on its own merits first via a
                // strong white fill + crisp border, with the shader/
                // chromatic settings layered on top rather than relied on
                // for the shape's basic legibility.
                settings: glass.LiquidGlassSettings(
                  glassColor: Colors.white.withValues(alpha: 0.5),
                  thickness: 34,
                  lightIntensity: 0.75,
                  chromaticAberration: 0.06,
                  saturation: 1.8,
                  specularSharpness: glass.GlassSpecularSharpness.sharp,
                ),
                shape: const glass.LiquidRoundedSuperellipse(
                  borderRadius: 22,
                  side: BorderSide(color: Colors.white, width: 1.2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < destinations.length; i++)
                  _TabIcon(
                    outlineIcon: destinations[i].$1,
                    filledIcon: destinations[i].$2,
                    label: destinations[i].$3,
                    isSelected: currentIndex == i,
                    onTap: () => onTap(i),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TabIcon extends StatefulWidget {
  const _TabIcon({
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData outlineIcon;
  final IconData filledIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_TabIcon> createState() => _TabIconState();
}

class _TabIconState extends State<_TabIcon> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final foreground = Colors.white.withValues(alpha: widget.isSelected ? 1 : 0.65);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.isSelected ? widget.filledIcon : widget.outlineIcon, color: foreground, size: 22),
              const SizedBox(height: 2),
              Text(widget.label, style: TextStyle(color: foreground, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
