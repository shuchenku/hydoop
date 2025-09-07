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
  
  List<String> _divisions = ['All'];
  List<String> _ageGroups = ['All'];
  List<RaceResult> _allResults = [];
  List<RaceResult> _filteredResults = [];
  bool _isLoading = true;
  String? _error;
  
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
      _filteredResults = _allResults.where((result) {
        final divisionMatch = _selectedDivision == 'All' || result.division == _selectedDivision;
        final ageGroupMatch = _selectedAgeGroup == 'All' || result.ageGroup == _selectedAgeGroup;
        return divisionMatch && ageGroupMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName ?? 'Race Results'),
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
            // Filter Section
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
                const SizedBox(width: AppTheme.spacingSm),
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
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Results count
            Text(
              _isLoading 
                ? 'Loading results...' 
                : 'Showing ${_filteredResults.length} of ${_allResults.length} results',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingSm),
            
            // Results list
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _filteredResults.length,
      itemBuilder: (context, index) {
        final result = _filteredResults[index];
        return _buildResultCard(result, index + 1);
      },
    );
  }
  
  Widget _buildResultCard(RaceResult result, int position) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: InkWell(
        onTap: () => AppRouter.goToAthleteDetail(
          context, 
          result.id,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with position, name, and total time
              Row(
                children: [
                  // Position badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getPositionColor(position),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        position.toString(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  
                  // Name and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bib #${result.id} • ${result.gender} • ${result.ageGroup}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Total time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        TimeUtils.formatTimeString(result.totalTime),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        result.division,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingMd),
              
              // Time breakdown
              Row(
                children: [
                  _buildTimeChip('RUN', result.runTime, Colors.blue),
                  const SizedBox(width: AppTheme.spacingSm),
                  _buildTimeChip('WORK', result.workTime, Colors.orange),
                  const SizedBox(width: AppTheme.spacingSm),
                  _buildTimeChip('ROX', result.roxzoneTime, Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTimeChip(String label, String time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            TimeUtils.formatTimeString(time),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getPositionColor(int position) {
    if (position == 1) return Colors.amber; // Gold
    if (position == 2) return Colors.grey.shade400; // Silver
    if (position == 3) return Colors.brown; // Bronze
    if (position <= 10) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.secondary;
  }
  
  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    List<String> options,
    String selectedValue,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: onChanged,
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}