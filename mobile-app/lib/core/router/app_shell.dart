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

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom > 0 ? 8 : 16),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(28),
          blurSigma: 30,
          tintOpacity: Theme.of(context).brightness == Brightness.dark ? 0.55 : 0.7,
          child: SizedBox(
            height: 60,
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
    );
  }
}

class _GlassTabIcon extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? filledIcon : outlineIcon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
