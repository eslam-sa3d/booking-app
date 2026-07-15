import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    // floating tab bars) rather than a theme-tinted translucent surface —
    // the liquid_glass_widgets shader path was tried extensively here and
    // kept rendering as an inconsistent pale smudge regardless of settings,
    // since GlassContainer always paints a visible surface across its full
    // bounds and blurring the mostly-flat page background behind it just
    // produces a washed-out rectangle, not a clean intentional look. This
    // is hand-rolled instead: a real BackdropFilter blur (so the edge still
    // softens whatever's behind it) plus a solid dark tint for a
    // consistent, predictable resting appearance, with a per-tab
    // AnimatedContainer as the selected-tab indicator pill.
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < destinations.length; i++)
                      _GlassTabIcon(
                        outlineIcon: destinations[i].$1,
                        filledIcon: destinations[i].$2,
                        label: destinations[i].$3,
                        isSelected: navigationShell.currentIndex == i,
                        onTap: () => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassTabIcon extends StatefulWidget {
  const _GlassTabIcon({
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
  State<_GlassTabIcon> createState() => _GlassTabIconState();
}

class _GlassTabIconState extends State<_GlassTabIcon> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final foreground = Colors.white.withValues(alpha: widget.isSelected ? 1 : 0.65);
    // Selected tabs always show their capsule; any tab additionally
    // brightens further while actively pressed — a quick touch-glow, closer
    // to how iOS system controls visually respond, instead of a flat
    // Material ripple.
    final backgroundAlpha = widget.isSelected ? (_pressed ? 0.28 : 0.18) : (_pressed ? 0.12 : 0.0);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: _pressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // A moderate rounded-square hugging just the icon — not a
                  // full stadium stretched around the whole icon+label
                  // column — matching a standard tab-bar touch highlight.
                  color: Colors.white.withValues(alpha: backgroundAlpha),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.isSelected ? widget.filledIcon : widget.outlineIcon, color: foreground, size: 22),
              ),
            ),
            const SizedBox(height: 2),
            Text(widget.label, style: TextStyle(color: foreground, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
