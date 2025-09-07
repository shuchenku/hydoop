import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_router.dart';

class CrossRaceTrendsScreen extends StatelessWidget {
  const CrossRaceTrendsScreen({
    super.key,
    required this.athleteIds,
  });

  final List<int> athleteIds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cross-Race Trends'),
        leading: IconButton(
          onPressed: () => AppRouter.goBack(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Athletes info
            Text(
              'Comparing ${athleteIds.length} athletes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            
            Text(
              'Athlete IDs: ${athleteIds.join(', ')}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.mutedForeground,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Analysis sections
            Expanded(
              child: ListView(
                children: [
                  _buildAnalysisCard(
                    context,
                    'Overall Time Trends',
                    'Line graph comparing performance across multiple races',
                    Icons.timeline,
                  ),
                  _buildAnalysisCard(
                    context,
                    'Station Performance Heatmap',
                    'Visual heatmap showing strengths and weaknesses by station',
                    Icons.grid_view,
                  ),
                  _buildAnalysisCard(
                    context,
                    'Running Consistency',
                    'Bar chart showing pace consistency across race segments',
                    Icons.bar_chart,
                  ),
                  _buildAnalysisCard(
                    context,
                    'Improvement Tracking',
                    'Track progress over time with trend analysis',
                    Icons.trending_up,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: context.theme.colorScheme.primary,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Placeholder for chart
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.muted,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: context.theme.colorScheme.mutedForeground,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'Chart placeholder',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}