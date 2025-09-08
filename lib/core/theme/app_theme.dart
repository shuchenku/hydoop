import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

class AppTheme {
  // Light theme colors - matching reference design exactly
  static const Color lightPrimary = Color(0xFFFFCC00);
  static const Color lightAccent = Color(0xFFFF6B00);
  static const Color lightSecondary = Color(0xFFF5F5F5);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightOnPrimary = Color(0xFF000000);
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightOnSurface = Color(0xFF666666);
  
  // Dark theme colors - matching reference design exactly
  static const Color darkPrimary = Color(0xFFFFCC00);
  static const Color darkAccent = Color(0xFFFF6B00);
  static const Color darkSecondary = Color(0xFF2D2D2D);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFB0B0B0);

  // Create light theme using Forui
  static FThemeData lightTheme = FThemeData(
    colors: FColors(
      brightness: Brightness.light,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      barrier: Colors.black54,
      background: lightBackground,
      foreground: lightOnBackground,
      primary: lightPrimary,
      primaryForeground: lightOnPrimary,
      secondary: lightSecondary,
      secondaryForeground: lightOnSurface,
      muted: lightSecondary,
      mutedForeground: lightOnSurface,
      destructive: const Color(0xFFFF4444),
      destructiveForeground: lightBackground,
      error: const Color(0xFFFF4444),
      errorForeground: lightBackground,
      border: const Color(0xFFE5E5E5),
    ),
  );

  // Create dark theme using Forui
  static FThemeData darkTheme = FThemeData(
    colors: FColors(
      brightness: Brightness.dark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      barrier: Colors.black87,
      background: darkBackground,
      foreground: darkOnBackground,
      primary: darkPrimary,
      primaryForeground: darkOnPrimary,
      secondary: darkSecondary,
      secondaryForeground: darkOnSurface,
      muted: darkSecondary,
      mutedForeground: darkOnSurface,
      destructive: const Color(0xFFFF4444),
      destructiveForeground: darkOnBackground,
      error: const Color(0xFFFF4444),
      errorForeground: darkOnBackground,
      border: const Color(0xFF404040),
    ),
  );

  // Component-specific styling - matching reference design
  static const double cardElevation = 0.0;  // Reference uses flat design
  static const double borderRadius = 10.0;   // Reference uses 0.625rem = 10px
  static const double buttonHeight = 48.0;
  static const double inputHeight = 44.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 16.0;
  
  // Spacing constants
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Shadow definitions
  static List<BoxShadow> get lightCardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get darkCardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Chart colors for data visualization
  static const List<Color> chartColors = [
    Color(0xFFFF6B00), // Orange
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFF44336), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF9800), // Amber
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF795548), // Brown
  ];

  // Station/workout colors
  static const Map<String, Color> stationColors = {
    'SkiErg': Color(0xFF2196F3),
    'Sled Push': Color(0xFFFF6B00),
    'Sled Pull': Color(0xFF4CAF50),
    'Burpee Broad Jump': Color(0xFFF44336),
    'Row': Color(0xFF9C27B0),
    'Farmers Walk': Color(0xFFFF9800),
    'Sandbag Lunges': Color(0xFF607D8B),
    'Wall Balls': Color(0xFF795548),
    'Running': Color(0xFF00BCD4),
    'Roxzone': Color(0xFF9E9E9E),
  };

  // Gender colors
  static const Color maleColor = Color(0xFF2196F3);
  static const Color femaleColor = Color(0xFFE91E63);
  
  // Performance colors (for percentiles)
  static const Color excellentColor = Color(0xFF4CAF50);
  static const Color goodColor = Color(0xFF8BC34A);
  static const Color averageColor = Color(0xFFFF9800);
  static const Color belowAverageColor = Color(0xFFFF5722);
  static const Color poorColor = Color(0xFFF44336);
}