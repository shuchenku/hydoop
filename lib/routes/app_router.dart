import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/browse/browse_screen.dart';
import '../presentation/screens/race_results/race_results_screen.dart';
import '../presentation/screens/search/search_athletes_screen.dart';
import '../presentation/screens/athlete_detail/athlete_detail_screen.dart';
import '../presentation/screens/my_races/my_races_screen.dart';
import '../presentation/screens/analysis/race_analysis_screen.dart';
import '../presentation/screens/analysis/cross_race_trends_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/main/main_screen.dart';
import '../core/constants/app_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.browseRoute,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          GoRoute(
            path: AppConstants.browseRoute,
            name: 'browse',
            builder: (context, state) => const BrowseScreen(),
            routes: [
              GoRoute(
                path: 'race-results/:eventId',
                name: 'race-results',
                builder: (context, state) {
                  final eventId = state.pathParameters['eventId']!;
                  final eventName = state.uri.queryParameters['eventName'];
                  return RaceResultsScreen(
                    eventId: eventId,
                    eventName: eventName,
                  );
                },
              ),
              GoRoute(
                path: 'search',
                name: 'search-athletes',
                builder: (context, state) => const SearchAthletesScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppConstants.myRacesRoute,
            name: 'my-races',
            builder: (context, state) => const MyRacesScreen(),
            routes: [
              GoRoute(
                path: 'analysis/:athleteId',
                name: 'race-analysis',
                builder: (context, state) {
                  final athleteId = int.parse(state.pathParameters['athleteId']!);
                  return RaceAnalysisScreen(athleteId: athleteId);
                },
              ),
              GoRoute(
                path: 'trends',
                name: 'cross-race-trends',
                builder: (context, state) {
                  final athleteIds = state.uri.queryParameters['athleteIds']?.split(',')
                      .map((id) => int.parse(id))
                      .toList() ?? [];
                  return CrossRaceTrendsScreen(athleteIds: athleteIds);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '${AppConstants.athleteDetailRoute}/:athleteId',
        name: 'athlete-detail',
        builder: (context, state) {
          final athleteId = int.parse(state.pathParameters['athleteId']!);
          return AthleteDetailScreen(athleteId: athleteId);
        },
      ),
      GoRoute(
        path: AppConstants.settingsRoute,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.browseRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  // Navigation helpers
  static void goToBrowse(BuildContext context) {
    context.go(AppConstants.browseRoute);
  }

  static void goToRaceResults(BuildContext context, String eventId, {String? eventName}) {
    final uri = Uri(
      path: '${AppConstants.browseRoute}/race-results/$eventId',
      queryParameters: eventName != null ? {'eventName': eventName} : null,
    );
    context.go(uri.toString());
  }

  static void goToSearchAthletes(BuildContext context) {
    context.go('${AppConstants.browseRoute}/search');
  }

  static void goToAthleteDetail(BuildContext context, int athleteId) {
    context.go('${AppConstants.athleteDetailRoute}/$athleteId');
  }

  static void goToMyRaces(BuildContext context) {
    context.go(AppConstants.myRacesRoute);
  }

  static void goToRaceAnalysis(BuildContext context, int athleteId) {
    context.go('${AppConstants.myRacesRoute}/analysis/$athleteId');
  }

  static void goToCrossRaceTrends(BuildContext context, List<int> athleteIds) {
    final idsString = athleteIds.join(',');
    final uri = Uri(
      path: '${AppConstants.myRacesRoute}/trends',
      queryParameters: {'athleteIds': idsString},
    );
    context.go(uri.toString());
  }

  static void goToSettings(BuildContext context) {
    context.go(AppConstants.settingsRoute);
  }

  // Check current route
  static bool isCurrentRoute(BuildContext context, String route) {
    final currentRoute = GoRouterState.of(context).fullPath;
    return currentRoute?.startsWith(route) ?? false;
  }

  // Get current route name
  static String? getCurrentRouteName(BuildContext context) {
    return GoRouterState.of(context).name;
  }

  // Back navigation with fallback
  static void goBack(BuildContext context, {String? fallback}) {
    if (context.canPop()) {
      context.pop();
    } else if (fallback != null) {
      context.go(fallback);
    } else {
      context.go(AppConstants.browseRoute);
    }
  }
}