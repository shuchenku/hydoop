import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_router.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  String _selectedSeason = 'S8 (2025)';
  
  final List<Map<String, String>> _seasons = [
    {'label': 'S8 (2025)', 'value': 'S8'},
    {'label': 'S7 (2025)', 'value': 'S7'},
    {'label': 'S6 (2024)', 'value': 'S6'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Races'),
        actions: [
          IconButton(
            onPressed: () => AppRouter.goToSearchAthletes(context),
            icon: const Icon(Icons.search),
            tooltip: 'Search Athletes',
          ),
          IconButton(
            onPressed: () => AppRouter.goToSettings(context),
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Season Filter Section
            Text(
              'Filter by Season',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            
            // Season chips
            Wrap(
              spacing: AppTheme.spacingSm,
              children: _seasons.map((season) => 
                _buildSeasonChip(
                  context, 
                  season['label']!, 
                  _selectedSeason == season['label'],
                  () => setState(() => _selectedSeason = season['label']!),
                ),
              ).toList(),
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Races List
            Text(
              'Available Races',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            
            Expanded(
              child: ListView(
                children: _getFilteredRaces(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getFilteredRaces() {
    final allRaces = [
      {
        'eventId': 'HPRO_LR3MS4JICA9',
        'title': 'S8 2025 Beijing',
        'location': 'Beijing, China',
        'date': '2025',
        'participants': '450',
        'season': 'S8 (2025)',
      },
      {
        'eventId': 'HPRO_LR3MS4JIA3E',
        'title': 'S7 2025 Shanghai',
        'location': 'Shanghai, China',
        'date': '2025',
        'participants': '520',
        'season': 'S7 (2025)',
      },
      {
        'eventId': 'HPRO_LR3MS4JIA3F',
        'title': 'S6 2024 Demo Race',
        'location': 'Demo City',
        'date': '2024',
        'participants': '300',
        'season': 'S6 (2024)',
      },
    ];
    
    final filteredRaces = allRaces.where((race) => race['season'] == _selectedSeason).toList();
    
    return filteredRaces.map((race) => _buildRaceCard(
      context,
      eventId: race['eventId']!,
      title: race['title']!,
      location: race['location']!,
      date: race['date']!,
      participants: race['participants']!,
    )).toList();
  }
  
  Widget _buildSeasonChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected 
          ? Theme.of(context).colorScheme.onPrimary 
          : Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }

  Widget _buildRaceCard(
    BuildContext context, {
    required String eventId,
    required String title,
    required String location,
    required String date,
    required String participants,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: InkWell(
        onTap: () => AppRouter.goToRaceResults(context, eventId, eventName: title),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm,
                      vertical: AppTheme.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$participants participants',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    location,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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