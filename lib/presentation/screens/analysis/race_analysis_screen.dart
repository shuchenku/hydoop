import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_router.dart';

class RaceAnalysisScreen extends StatelessWidget {
  const RaceAnalysisScreen({
    super.key,
    required this.athleteId,
  });

  final int athleteId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Race Analysis'),
          leading: IconButton(
            onPressed: () => AppRouter.goBack(context),
            icon: const Icon(Icons.arrow_back),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Comparisons'),
              Tab(text: 'Trends'),
              Tab(text: 'Stations'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSummaryTab(context),
            _buildComparisonsTab(context),
            _buildTrendsTab(context),
            _buildStationsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.radar,
              size: 64,
              color: context.theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Performance Radar Chart',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Spider chart showing percentile performance across all stations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: context.theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Performance Comparison',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Horizontal bar charts comparing percentiles with division average',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: context.theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Performance Trends',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Line graphs showing run pace variation and consistency metrics',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: context.theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Station Analysis',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Detailed analysis of each workout station with recommendations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}