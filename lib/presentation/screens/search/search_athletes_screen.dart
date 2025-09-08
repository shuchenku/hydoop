import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import '../../../data/models/race_result.dart';
import '../../../data/repositories/race_repository.dart';
import '../../../routes/app_router.dart';

class SearchAthletesScreen extends StatefulWidget {
  const SearchAthletesScreen({super.key});

  @override
  State<SearchAthletesScreen> createState() => _SearchAthletesScreenState();
}

class _SearchAthletesScreenState extends State<SearchAthletesScreen> {
  String _selectedRace = 'S8 2025 Beijing';
  String _selectedDivision = 'All';
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _bibController = TextEditingController();
  
  List<String> _races = [];
  List<String> _divisions = ['All'];
  List<RaceResult> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;
  
  // Map event names to IDs for search
  final Map<String, String> _raceEventIds = {
    'S8 2025 Beijing': 'HPRO_LR3MS4JICA9',
    'S7 2025 Shanghai': 'HPRO_LR3MS4JIA3E',
  };

  String _getEventIdFromRaceName(String raceName) {
    return _raceEventIds[raceName] ?? '';
  }
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    try {
      final repository = context.read<RaceRepository>();
      final events = await repository.getUniqueEvents();
      final divisions = await repository.getUniqueDivisions();
      
      setState(() {
        _races = events;
        _divisions = ['All', ...divisions];
        if (_races.isNotEmpty) {
          _selectedRace = _races.first;
        }
      });
    } catch (e) {
      // Handle error silently for now
    }
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _bibController.dispose();
    super.dispose();
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
          'Search Athletes',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Form (max 30% screen height)
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              children: [
                // Race dropdown
                _buildDropdown(
                  context, 
                  'Race', 
                  _races, 
                  _selectedRace,
                  (value) => setState(() => _selectedRace = value!),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                
                // Division dropdown
                _buildDropdown(
                  context, 
                  'Division', 
                  _divisions,
                  _selectedDivision,
                  (value) => setState(() => _selectedDivision = value!),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                
                // Name and bib number fields
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          hintText: 'Enter first name',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: TextField(
                        controller: _bibController,
                        decoration: const InputDecoration(
                          labelText: 'Bib Number',
                          hintText: 'Enter bib',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                
                // Search button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _performSearch,
                    icon: const Icon(Icons.search),
                    label: const Text('Search Athletes'),
                  ),
                ),
              ],
            ),
          ),
          
          // Results section
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: AppTheme.spacingSm),
                  
                  Text(
                    'Search Results',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  
                  Expanded(
                    child: _buildSearchResults(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch() async {
    final firstName = _firstNameController.text.trim();
    final bibNumber = _bibController.text.trim();
    
    if (firstName.isEmpty && bibNumber.isEmpty && _selectedDivision == 'All') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one search criteria'),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });
    
    try {
      final repository = context.read<RaceRepository>();
      final eventId = _getEventIdFromRaceName(_selectedRace);
      
      final results = await repository.searchRaceResults(
        eventId: eventId.isNotEmpty ? eventId : null,
        division: _selectedDivision == 'All' ? null : _selectedDivision,
        firstName: firstName.isNotEmpty ? firstName : null,
        bibNumber: bibNumber.isNotEmpty ? bibNumber : null,
      );
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppTheme.spacingMd),
            Text('Searching...'),
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
              'Search Error',
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
          ],
        ),
      );
    }
    
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Enter search criteria above',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Search by name, bib number, or filter by race/division',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
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
              'No athletes found',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Try different search criteria',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Found ${_searchResults.length} athlete${_searchResults.length == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              return _buildAthleteCard(result);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAthleteCard(RaceResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: InkWell(
        onTap: () => AppRouter.goToAthleteDetail(context, result.id, eventId: result.eventId),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              // Athlete info
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
                    const SizedBox(height: 4),
                    Text(
                      'Bib #${result.id} • ${result.gender} • ${result.ageGroup}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${result.division} • ${result.nationality}',
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    result.eventName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
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