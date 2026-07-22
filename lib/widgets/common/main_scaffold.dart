import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../routes/app_router.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;

  final List<_NavItem> _items = [
    _NavItem(
      icon: Icons.grid_view_rounded,
      label: 'Home',
      route: AppRoutes.home,
    ),
    _NavItem(
      icon: Icons.biotech_rounded,
      label: 'Diagnose',
      route: AppRoutes.diseaseDetection,
    ),
    _NavItem(
      icon: Icons.forum_rounded,
      label: 'Forum',
      route: AppRoutes.communityForum,
    ),
    _NavItem(
      icon: Icons.account_circle_rounded,
      label: 'Profile',
      route: AppRoutes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Allow scaffold body to extend behind floating navigation bar
      body: widget.child,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: isDark 
                  ? AppTheme.cardDark.withOpacity(0.85) 
                  : AppTheme.cardLight.withOpacity(0.9),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: (isDark ? Colors.white : AppTheme.primaryGreen)
                    .withOpacity(0.08),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_items.length, (i) {
                    final item = _items[i];
                    final isSelected = _selectedIndex == i;
                    return _NavBarItem(
                      item: item,
                      isSelected: isSelected,
                      badge: item.route == AppRoutes.home && unreadCount > 0
                          ? unreadCount.toString()
                          : null,
                      onTap: () {
                        setState(() => _selectedIndex = i);
                        context.go(item.route);
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppTheme.lightGreen.withOpacity(0.15) : AppTheme.primaryGreen.withOpacity(0.12))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    item.icon,
                    color: isSelected 
                        ? (isDark ? AppTheme.accentGreen : AppTheme.primaryGreen) 
                        : Colors.grey[500],
                    size: 22,
                  ),
                  if (badge != null)
                    Positioned(
                      top: -6,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.alertRed,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              color: isSelected 
                  ? (isDark ? AppTheme.accentGreen : AppTheme.primaryGreen) 
                  : Colors.grey[400],
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
