import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/race_repository.dart';
import '../../../routes/app_router.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _selectedSeason = 'All';
  
  List<String> _availableSeasons = ['All'];
  List<Map<String, dynamic>> _allRaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRaceData();
  }

  Future<void> _loadRaceData() async {
    try {
      final repository = context.read<RaceRepository>();
      
      // Get unique events from actual database
      final events = await repository.getUniqueEvents();
      
      // Build race data with participant counts
      List<Map<String, dynamic>> races = [];
      Set<String> seasons = {};
      
      for (String eventName in events) {
        // Extract season from event name (e.g., "S8 2025 Beijing" -> "S8")
        String season = _extractSeasonFromEventName(eventName);
        seasons.add(season);
        
        // Get event ID (we need to map this properly)
        String eventId = _getEventIdFromName(eventName);
        
        // Count participants for this event
        final count = await repository.getResultCount(eventId: eventId);
        
        races.add({
          'eventId': eventId,
          'eventName': eventName,
          'season': season,
          'location': _extractLocationFromEventName(eventName),
          'year': _extractYearFromEventName(eventName),
          'participantCount': count,
        });
      }
      
      setState(() {
        _allRaces = races;
        _availableSeasons = ['All', ...seasons.toList()..sort()];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _extractSeasonFromEventName(String eventName) {
    // Extract season from names like "S8 2025 Beijing", "S7 2025 Shanghai"
    RegExp regex = RegExp(r'S(\d+)');
    Match? match = regex.firstMatch(eventName);
    return match != null ? 'S${match.group(1)}' : 'Unknown';
  }

  String _extractLocationFromEventName(String eventName) {
    // Extract location from names like "S8 2025 Beijing", "S7 2025 Shanghai"
    List<String> parts = eventName.split(' ');
    return parts.length >= 3 ? parts.sublist(2).join(' ') : eventName;
  }

  String _extractYearFromEventName(String eventName) {
    // Extract year from names like "S8 2025 Beijing"
    RegExp regex = RegExp(r'(\d{4})');
    Match? match = regex.firstMatch(eventName);
    return match != null ? match.group(1)! : '';
  }

  String _getEventIdFromName(String eventName) {
    // Map event names to their IDs - this should come from database
    const Map<String, String> eventMapping = {
      'S8 2025 Beijing': 'HPRO_LR3MS4JICA9',
      'S7 2025 Shanghai': 'HPRO_LR3MS4JIA3E',
    };
    return eventMapping[eventName] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Browse',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => AppRouter.goToSearchAthletes(context),
            icon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: () => AppRouter.goToSettings(context),
            icon: Icon(
              Icons.settings,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // Season selector with badge-style buttons
              Row(
                children: _availableSeasons.map((season) => 
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildSeasonBadge(
                      context, 
                      season, 
                      _selectedSeason == season,
                      () => setState(() => _selectedSeason = season),
                    ),
                  ),
                ).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Races List
              Expanded(
                child: ListView.separated(
                  itemCount: _getFilteredRaces().length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildRaceCard(context, _getFilteredRaces()[index]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredRaces() {
    if (_selectedSeason == 'All') {
      return _allRaces;
    }
    return _allRaces.where((race) => race['season'] == _selectedSeason).toList();
  }
  
  Widget _buildSeasonBadge(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRaceCard(BuildContext context, Map<String, dynamic> race) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => AppRouter.goToRaceResults(
          context, 
          race['eventId']!, 
          eventName: race['eventName']!,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                race['eventName']!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          race['location']!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${race['participantCount']} athletes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
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
}