class AppConstants {
  // App Information
  static const String appName = 'Hydoop';
  static const String appVersion = '1.0.0';
  
  // Database
  static const int pageSize = 50;
  static const int searchLimit = 100;
  
  // HYROX Stations
  static const List<String> stations = [
    'SkiErg',
    'Sled Push',
    'Sled Pull', 
    'Burpee Broad Jump',
    'Row',
    'Farmers Walk',
    'Sandbag Lunges',
    'Wall Balls',
  ];
  
  // Workout Station Options (for filtering/search)
  static const List<String> workoutStations = [
    'Total',
    'Total Run',
    'Total Work',
    'Total Roxzone',
    '1000m SkiErg',
    '50m Sled Push',
    '50m Sled Pull',
    '80m Burpee Broad Jump',
    '1000m Row',
    '200m Farmers Walk',
    '100m Sandbag Lunges',
    '100 Wall Balls',
  ];
  
  // Divisions
  static const List<String> divisions = [
    'Pro',
    'Open', 
    'Pro Doubles',
    'Open Doubles',
    'Pro Relay',
    'Open Relay',
  ];
  
  // Age Groups
  static const List<String> ageGroups = [
    'All',
    '16-24',
    '25-29',
    '30-34',
    '35-39',
    '40-44',
    '45-49',
    '50-54',
    '55-59',
    '60+',
  ];
  
  // Genders
  static const List<String> genders = [
    'All',
    'Male',
    'Female',
  ];
  
  // Time Formats
  static const String timeFormatHMS = 'H:mm:ss';
  static const String timeFormatMS = 'm:ss';
  
  // Navigation Routes
  static const String browseRoute = '/browse';
  static const String raceResultsRoute = '/race-results';
  static const String searchAthletesRoute = '/search-athletes';
  static const String athleteDetailRoute = '/athlete-detail';
  static const String myRacesRoute = '/my-races';
  static const String raceAnalysisRoute = '/race-analysis';
  static const String crossRaceTrendsRoute = '/cross-race-trends';
  static const String settingsRoute = '/settings';
  
  // SharedPreferences Keys
  static const String savedAthletesKey = 'saved_athletes';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String timeFormatKey = 'time_format';
  
  // Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'zh': '简体中文',
  };
  
  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultTimeFormat = timeFormatHMS;
  
  // Animation Durations (in milliseconds)
  static const int fastAnimationMs = 150;
  static const int normalAnimationMs = 300;
  static const int slowAnimationMs = 500;
  
  // Network & API (for future use)
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // Chart Configuration
  static const double chartAspectRatio = 1.5;
  static const double pieChartRadius = 80.0;
  static const double barChartMaxY = 100.0;
  
  // Performance Thresholds (percentiles)
  static const double excellentThreshold = 90.0;
  static const double goodThreshold = 75.0;
  static const double averageThreshold = 50.0;
  static const double belowAverageThreshold = 25.0;
  // Below 25% is considered poor
  
  // Countries/Nationalities (most common in HYROX)
  static const List<String> commonNationalities = [
    'USA', 'GER', 'GBR', 'CAN', 'AUS', 'NED', 'FRA', 
    'CHN', 'JPN', 'KOR', 'BRA', 'ESP', 'ITA', 'SWE',
    'NOR', 'DNK', 'FIN', 'AUT', 'CHE', 'BEL', 'IRL',
  ];
  
  // Error Messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String dataNotFoundMessage = 'No data found.';
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String noResultsMessage = 'No results found for your search criteria.';
  
  // Success Messages
  static const String athleteSavedMessage = 'Athlete saved to My Races';
  static const String athleteRemovedMessage = 'Athlete removed from My Races';
  static const String dataImportedMessage = 'Data imported successfully';
  
  // Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minBibNumber = 1;
  static const int maxBibNumber = 999999;
  
  // UI Constants
  static const double bottomNavigationHeight = 60.0;
  static const double appBarHeight = 56.0;
  static const double tabBarHeight = 48.0;
  static const double listItemHeight = 72.0;
  static const double cardMinHeight = 120.0;
  
  // Pagination
  static const int initialPage = 0;
  static const int resultsPerPage = 25;
  static const int maxPaginationButtons = 5;
  
  // Search
  static const int minSearchLength = 2;
  static const Duration searchDebounceDelay = Duration(milliseconds: 500);
  
  // File Paths
  static const String csvDataPath = 'assets/data/';
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  
  // Regex Patterns
  static final RegExp namePattern = RegExp(r'^[a-zA-Z\s\-\.]+$');
  static final RegExp bibNumberPattern = RegExp(r'^\d+$');
  static final RegExp timePattern = RegExp(r'^\d{1,2}:\d{2}:\d{2}$');
}