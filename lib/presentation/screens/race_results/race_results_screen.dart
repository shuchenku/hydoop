import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import '../../../data/models/race_result.dart';
import '../../../data/repositories/race_repository.dart';
import '../../../routes/app_router.dart';

class RaceResultsScreen extends StatefulWidget {
  const RaceResultsScreen({
    super.key,
    required this.eventId,
    this.eventName,
  });

  final String eventId;
  final String? eventName;

  @override
  State<RaceResultsScreen> createState() => _RaceResultsScreenState();
}

class _RaceResultsScreenState extends State<RaceResultsScreen> {
  String _selectedDivision = 'All';
  String _selectedAgeGroup = 'All';
  String _selectedWorkout = 'Total'; // New workout selector

  List<String> _divisions = ['All'];
  List<String> _ageGroups = ['All'];
  List<RaceResult> _allResults = [];
  List<RaceResult> _filteredResults = [];
  bool _isLoading = true;
  String? _error;

  // Workout options for the selector
  static const List<String> _workoutOptions = [
    'Total',
    'Total Run',
    'SkiErg',
    'Sled Push',
    'Sled Pull',
    'Burpee Broad Jumps',
    'Row',
    'Farmers Carry',
    'Sandbag Lunges',
    'Wall Balls',
  ];

  @override
  void initState() {
    super.initState();
    _loadRaceResults();
  }

  Future<void> _loadRaceResults() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final repository = context.read<RaceRepository>();

      // Load race results for this specific event
      final results = await repository.getRaceResultsByEvent(
        eventId: widget.eventId,
      );

      // Load unique divisions and age groups for this event
      final allDivisions = await repository.getUniqueDivisions();
      final allAgeGroups = await repository.getUniqueAgeGroups();

      setState(() {
        _allResults = results;
        _filteredResults = results;
        _divisions = ['All', ...allDivisions];
        _ageGroups = ['All', ...allAgeGroups];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      // Filter by division and age group
      _filteredResults = _allResults.where((result) {
        final divisionMatch =
            _selectedDivision == 'All' || result.division == _selectedDivision;
        final ageGroupMatch =
            _selectedAgeGroup == 'All' || result.ageGroup == _selectedAgeGroup;
        return divisionMatch && ageGroupMatch;
      }).toList();

      // Sort by selected workout time column
      _filteredResults.sort((a, b) {
        String timeA = _getWorkoutTime(a, _selectedWorkout);
        String timeB = _getWorkoutTime(b, _selectedWorkout);
        return _compareTimeStrings(timeA, timeB);
      });
    });
  }

  String _getWorkoutTime(RaceResult result, String workout) {
    switch (workout) {
      case 'Total':
        return result.totalTime;
      case 'Total Run':
        return result.runTime;
      case 'SkiErg':
        return result.works[0]; // work_1 = SkiErg
      case 'Sled Push':
        return result.works[1]; // work_2 = Sled Push
      case 'Sled Pull':
        return result.works[2]; // work_3 = Sled Pull
      case 'Burpee Broad Jumps':
        return result.works[3]; // work_4 = Burpee Broad Jumps
      case 'Row':
        return result.works[4]; // work_5 = Row
      case 'Farmers Carry':
        return result.works[5]; // work_6 = Farmers Carry
      case 'Sandbag Lunges':
        return result.works[6]; // work_7 = Sandbag Lunges
      case 'Wall Balls':
        return result.works[7]; // work_8 = Wall Balls
      default:
        return result.totalTime;
    }
  }

  int _compareTimeStrings(String timeA, String timeB) {
    // Parse time strings (HH:MM:SS) and compare
    List<String> partsA = timeA.split(':');
    List<String> partsB = timeB.split(':');

    if (partsA.length != 3 || partsB.length != 3) return 0;

    int secondsA = int.parse(partsA[0]) * 3600 +
        int.parse(partsA[1]) * 60 +
        int.parse(partsA[2]);
    int secondsB = int.parse(partsB[0]) * 3600 +
        int.parse(partsB[1]) * 60 +
        int.parse(partsB[2]);

    return secondsA.compareTo(secondsB);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
          widget.eventName ?? 'Event Results',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        context,
                        'Division',
                        _divisions,
                        _selectedDivision,
                        (value) {
                          setState(() => _selectedDivision = value!);
                          _applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        context,
                        'Age Group',
                        _ageGroups,
                        _selectedAgeGroup,
                        (value) {
                          setState(() => _selectedAgeGroup = value!);
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        context,
                        'Workout',
                        _workoutOptions,
                        _selectedWorkout,
                        (value) {
                          setState(() => _selectedWorkout = value!);
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Results list with header
            Expanded(
              child: _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppTheme.spacingMd),
            Text('Loading race results...'),
          ],
        ),
      );
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
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Error loading results',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(
              onPressed: _loadRaceResults,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Try adjusting your filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                  width: 40,
                  child: Text('#',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.w500))),
              const SizedBox(width: 12),
              Expanded(
                  flex: 5,
                  child: Text('Name',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.w500))),
              Expanded(
                  flex: 2,
                  child: Text('Age Group',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.w500))),
              Expanded(
                  flex: 2,
                  child: Text('Time',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                      textAlign: TextAlign.end)),
            ],
          ),
        ),
        // Results
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ListView.builder(
              itemCount: _filteredResults.length,
              itemBuilder: (context, index) {
                final result = _filteredResults[index];
                return _buildResultRow(result, index + 1, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(RaceResult result, int position, int index) {
    final theme = Theme.of(context);
    final isEven = index % 2 == 0;

    return InkWell(
      onTap: () => AppRouter.goToAthleteDetail(context, result.id,
          eventId: widget.eventId),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        color: isEven
            ? theme.colorScheme.surface
            : theme.colorScheme.secondary.withValues(alpha: 0.3),
        child: Row(
          children: [
            // Position
            SizedBox(
              width: 40,
              child: Text(
                position.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _getPositionColor(position),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name
            Expanded(
              flex: 5,
              child: Text(
                result.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Age Group
            Expanded(
              flex: 2,
              child: Text(
                result.ageGroup,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),

            // Selected Workout Time
            Expanded(
              flex: 2,
              child: Text(
                TimeUtils.formatTimeString(
                    _getWorkoutTime(result, _selectedWorkout)),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position <= 3) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8);
  }

  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    List<String> options,
    String selectedValue,
    void Function(String?) onChanged,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: theme.colorScheme.onSecondary,
            size: 20,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
          dropdownColor: theme.colorScheme.surface,
          onChanged: onChanged,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
