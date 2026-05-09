import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../theme/app_theme.dart';

/// Shell widget wrapping protected routes with bottom navigation bar.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.dashboard)) return 0;
    if (location.startsWith(AppRoutes.urlScan)) return 1;
    if (location.startsWith(AppRoutes.emailScan)) return 2;
    if (location.startsWith(AppRoutes.history)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: _PhishEyeBottomNav(
        selectedIndex: selectedIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.dashboard);
            case 1:
              context.go(AppRoutes.urlScan);
            case 2:
              context.go(AppRoutes.emailScan);
            case 3:
              context.go(AppRoutes.history);
          }
        },
      ),
    );
  }
}

class _PhishEyeBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _PhishEyeBottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
          top: BorderSide(color: AppTheme.borderSubtle, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                index: 0,
                selectedIndex: selectedIndex,
                icon: Icons.shield_outlined,
                activeIcon: Icons.shield,
                label: 'RADAR',
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                selectedIndex: selectedIndex,
                icon: Icons.link_outlined,
                activeIcon: Icons.link,
                label: 'URL',
                onTap: onTap,
              ),
              _NavItem(
                index: 2,
                selectedIndex: selectedIndex,
                icon: Icons.email_outlined,
                activeIcon: Icons.email,
                label: 'EMAIL',
                onTap: onTap,
              ),
              _NavItem(
                index: 3,
                selectedIndex: selectedIndex,
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'HISTORY',
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentCyan.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.accentCyan : AppTheme.textMuted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: isSelected ? AppTheme.accentCyan : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
