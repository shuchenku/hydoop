import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/race_repository.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'routes/app_router.dart';

class HydoopApp extends StatelessWidget {
  const HydoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<RaceRepository>(
          create: (context) => RaceRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc()..add(const ThemeInitialized()),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp.router(
              title: 'Hydoop',
              debugShowCheckedModeBanner: false,
              
              // Theme configuration
              theme: _buildMaterialTheme(AppTheme.lightTheme),
              darkTheme: _buildMaterialTheme(AppTheme.darkTheme),
              themeMode: state.themeMode,
              
              // Forui theme
              builder: (context, child) {
                return FTheme(
                  data: _getForuiTheme(context, state.themeMode),
                  child: child ?? const SizedBox(),
                );
              },
              
              // Router configuration
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }

  ThemeData _buildMaterialTheme(FThemeData fTheme) {
    final colorScheme = fTheme.colorScheme;
    
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      
      // Color scheme
      colorScheme: ColorScheme(
        brightness: colorScheme.brightness,
        primary: colorScheme.primary,
        onPrimary: colorScheme.primaryForeground,
        secondary: colorScheme.secondary,
        onSecondary: colorScheme.secondaryForeground,
        error: colorScheme.destructive,
        onError: colorScheme.destructiveForeground,
        surface: colorScheme.background,
        onSurface: colorScheme.foreground,
      ),
      
      // App Bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.background,
        foregroundColor: colorScheme.foreground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.foreground,
        ),
      ),
      
      // Scaffold theme
      scaffoldBackgroundColor: colorScheme.background,
      
      // Card theme
      cardTheme: CardTheme(
        color: colorScheme.background,
        elevation: AppTheme.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.primaryForeground,
          minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.input,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          borderSide: BorderSide(color: colorScheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          borderSide: BorderSide(color: colorScheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          borderSide: BorderSide(color: colorScheme.ring, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 36, height: 1.1),
        displayMedium: TextStyle(fontSize: 30, height: 1.2),
        displaySmall: TextStyle(fontSize: 24, height: 1.4),
        headlineLarge: TextStyle(fontSize: 20, height: 1.6),
        headlineMedium: TextStyle(fontSize: 18, height: 1.6),
        headlineSmall: TextStyle(fontSize: 16, height: 1.5),
        titleLarge: TextStyle(fontSize: 18, height: 1.6),
        titleMedium: TextStyle(fontSize: 16, height: 1.5),
        titleSmall: TextStyle(fontSize: 14, height: 1.5),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, height: 1.5),
        labelMedium: TextStyle(fontSize: 12, height: 1.4),
        labelSmall: TextStyle(fontSize: 12, height: 1.4),
      ),
    );
  }

  FThemeData _getForuiTheme(BuildContext context, ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return AppTheme.lightTheme;
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.system:
        final brightness = MediaQuery.platformBrightnessOf(context);
        return brightness == Brightness.dark 
          ? AppTheme.darkTheme 
          : AppTheme.lightTheme;
    }
  }
}