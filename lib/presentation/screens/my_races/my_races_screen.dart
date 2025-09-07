import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MyRacesScreen extends StatelessWidget {
  const MyRacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Races'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show analysis options
            },
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Analysis Options',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_border,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'No saved races yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Save athletes from race results or search to track and analyze their performance here.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to browse
                },
                icon: const Icon(Icons.search),
                label: const Text('Browse Races'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}