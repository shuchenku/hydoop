import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import '../../../data/models/race_result.dart';
import '../../../data/repositories/race_repository.dart';
import '../../../routes/app_router.dart';

class AthleteDetailScreen extends StatefulWidget {
  const AthleteDetailScreen({
    super.key,
    required this.athleteId,
    this.eventId,
  });

  final int athleteId;
  final String? eventId;

  @override
  State<AthleteDetailScreen> createState() => _AthleteDetailScreenState();
}

class _AthleteDetailScreenState extends State<AthleteDetailScreen> {
  RaceResult? _athlete;
  bool _isLoading = true;
  String? _error;

  // Rankings
  int _overallRank = 0;
  int _divisionRank = 0;
  int _ageGroupRank = 0;

  // Station percentiles
  List<double> _stationPercentiles = [];
  List<int> _stationRanks = [];

  @override
  void initState() {
    super.initState();
    _loadAthleteData();
  }

  Future<void> _loadAthleteData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final repository = context.read<RaceRepository>();

      // Get athlete data
      final athlete = await repository.getRaceResultById(widget.athleteId);
      if (athlete == null) {
        throw Exception('Athlete not found');
      }

      // Calculate rankings within same event and division
      await _calculateRankings(repository, athlete);

      // Calculate station percentiles
      await _calculateStationPercentiles(repository, athlete);

      setState(() {
        _athlete = athlete;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateRankings(
      RaceRepository repository, RaceResult athlete) async {
    // Get all results for same event
    final allEventResults = await repository.getRaceResultsByEvent(
      eventId: athlete.eventId,
    );

    // Overall rank (by total time)
    allEventResults.sort((a, b) => a.totalDuration.compareTo(b.totalDuration));
    _overallRank = allEventResults.indexWhere((r) => r.id == athlete.id) + 1;

    // Division rank
    final divisionResults =
        allEventResults.where((r) => r.division == athlete.division).toList();
    divisionResults.sort((a, b) => a.totalDuration.compareTo(b.totalDuration));
    _divisionRank = divisionResults.indexWhere((r) => r.id == athlete.id) + 1;

    // Age group rank
    final ageGroupResults = allEventResults
        .where((r) =>
            r.division == athlete.division && r.ageGroup == athlete.ageGroup)
        .toList();
    ageGroupResults.sort((a, b) => a.totalDuration.compareTo(b.totalDuration));
    _ageGroupRank = ageGroupResults.indexWhere((r) => r.id == athlete.id) + 1;
  }

  Future<void> _calculateStationPercentiles(
      RaceRepository repository, RaceResult athlete) async {
    // Get comparison group (same division and age group)
    final comparisonResults = await repository.searchRaceResults(
      eventId: athlete.eventId,
      division: athlete.division,
      ageGroup: athlete.ageGroup,
    );

    _stationPercentiles = [];
    _stationRanks = [];

    for (int i = 0; i < 8; i++) {
      // Sort by this station time
      final sortedResults = comparisonResults.toList();
      sortedResults
          .sort((a, b) => a.workDurations[i].compareTo(b.workDurations[i]));

      // Find athlete's rank for this station
      final rank = sortedResults.indexWhere((r) => r.id == athlete.id) + 1;
      _stationRanks.add(rank);

      // Calculate percentile
      final percentile =
          ((sortedResults.length - rank) / sortedResults.length) * 100;
      _stationPercentiles.add(percentile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => AppRouter.goBack(context),
            icon: Icon(
              Icons.arrow_back,
              color: theme.colorScheme.onSurface,
            ),
          ),
          title: Text(
            _athlete?.name ?? 'Athlete Details',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {
                // TODO: Save to My Races
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Athlete saved to My Races')),
                );
              },
              icon: Icon(
                Icons.bookmark_border,
                color: theme.colorScheme.onSurface,
              ),
              tooltip: 'Save to My Races',
            ),
          ],
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor:
                theme.colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: theme.colorScheme.primary,
            dividerColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorWeight: 2,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Stations'),
              Tab(text: 'Running'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildStationsTab(context),
            _buildRunningTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Error loading athlete data'),
            const SizedBox(height: 8),
            Text(_error!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAthleteData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_athlete == null) {
      return const Center(child: Text('Athlete not found'));
    }

    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Athlete info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        _athlete!.name
                            .split(' ')
                            .map((n) => n[0])
                            .take(2)
                            .join(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _athlete!.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Bib #${_athlete!.id} • ${_athlete!.nationality} • ${_athlete!.gender}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            '${_athlete!.division} • ${_athlete!.ageGroup}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          TimeUtils.formatTimeString(_athlete!.totalTime),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total Time',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Rankings
          Text(
            'Rankings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRankCard(
                  context,
                  'Overall',
                  _overallRank.toString(),
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRankCard(
                  context,
                  'Division',
                  _divisionRank.toString(),
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRankCard(
                  context,
                  'Age Group',
                  _ageGroupRank.toString(),
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Time breakdown pie chart
          Text(
            'Time Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Pie chart
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(),
                      centerSpaceRadius: 60,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Legend
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(
                        context, 'Running', Colors.blue, _athlete!.runTime),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                        context, 'Workouts', Colors.orange, _athlete!.workTime),
                    const SizedBox(height: 8),
                    _buildLegendItem(
                        context, 'Roxzone', Colors.grey, _athlete!.roxzoneTime),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard(
      BuildContext context, String title, String rank, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            rank,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      BuildContext context, String label, Color color, String time) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              TimeUtils.formatTimeString(time),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    if (_athlete == null) return [];

    final totalSeconds = _athlete!.totalDuration.inSeconds;
    final runSeconds = _athlete!.runDuration.inSeconds;
    final workSeconds = _athlete!.workDuration.inSeconds;
    final roxzoneSeconds = _athlete!.roxzoneDuration.inSeconds;

    return [
      PieChartSectionData(
        value: runSeconds.toDouble(),
        color: Colors.blue,
        title: '${((runSeconds / totalSeconds) * 100).round()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: workSeconds.toDouble(),
        color: Colors.orange,
        title: '${((workSeconds / totalSeconds) * 100).round()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: roxzoneSeconds.toDouble(),
        color: Colors.grey,
        title: '${((roxzoneSeconds / totalSeconds) * 100).round()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildStationsTab(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_athlete == null) {
      return const Center(child: Text('Athlete data not available'));
    }

    final stations = [
      'SkiErg',
      'Sled Push',
      'Sled Pull',
      'Burpee Broad Jump',
      'Row',
      'Farmers Carry',
      'Sandbag Lunges',
      'Wall Balls'
    ];

    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final stationTime = _athlete!.works[index];
        final stationRank =
            _stationRanks.length > index ? _stationRanks[index] : 0;
        final percentile = _stationPercentiles.length > index
            ? _stationPercentiles[index]
            : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${index + 1}. ${stations[index]}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          TimeUtils.formatTimeString(stationTime),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '#$stationRank',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _getPercentileColor(percentile),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${percentile.round()}th Percentile',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getPercentileColor(double percentile) {
    if (percentile >= 90) return AppTheme.excellentColor;
    if (percentile >= 75) return AppTheme.goodColor;
    if (percentile >= 50) return AppTheme.averageColor;
    if (percentile >= 25) return AppTheme.belowAverageColor;
    return AppTheme.poorColor;
  }

  Widget _buildRunningTab(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_athlete == null) {
      return const Center(child: Text('Athlete data not available'));
    }

    final theme = Theme.of(context);

    // Calculate average run time
    final runTimes = _athlete!.runDurations;
    final totalRunSeconds =
        runTimes.fold(0, (sum, duration) => sum + duration.inSeconds);
    final averageSeconds = totalRunSeconds / 8;
    final averageTime = Duration(seconds: averageSeconds.round());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Running Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          TimeUtils.formatTimeString(_athlete!.runTime),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total Run Time',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          _formatDuration(averageTime),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Avg per 1km',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          _calculatePaceVariation(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Variation %',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Run Splits (1km each)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              final runTime = _athlete!.runs[index];
              final runDuration = _athlete!.runDurations[index];
              final isPaceGood = runDuration <= averageTime;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Run ${index + 1}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          isPaceGood ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: isPaceGood ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TimeUtils.formatTimeString(runTime),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRunPerformanceText(runDuration, averageTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPaceGood ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _calculatePaceVariation() {
    if (_athlete == null) return '0%';

    final runTimes =
        _athlete!.runDurations.map((d) => d.inSeconds.toDouble()).toList();
    final average = runTimes.reduce((a, b) => a + b) / runTimes.length;

    // Calculate standard deviation
    final variance = runTimes
            .map((time) => (time - average) * (time - average))
            .reduce((a, b) => a + b) /
        runTimes.length;
    final standardDeviation = sqrt(variance);

    final coefficientOfVariation = (standardDeviation / average) * 100;
    return '${coefficientOfVariation.round()}%';
  }

  String _getRunPerformanceText(Duration runTime, Duration averageTime) {
    final difference = runTime.inSeconds - averageTime.inSeconds;
    if (difference.abs() < 5) return 'On pace';
    if (difference < 0) return '${difference.abs()}s faster';
    return '${difference}s slower';
  }
}
