import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).fullPath ?? '';
    
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        height: AppConstants.bottomNavigationHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.search,
                label: 'Browse',
                isActive: currentLocation.startsWith(AppConstants.browseRoute),
                onTap: () => AppRouter.goToBrowse(context),
              ),
            ),
            Expanded(
              child: _NavItem(
                icon: Icons.bookmark,
                label: 'My Races',
                isActive: currentLocation.startsWith(AppConstants.myRacesRoute),
                onTap: () => AppRouter.goToMyRaces(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}