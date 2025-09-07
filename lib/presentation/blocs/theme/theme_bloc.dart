import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  late final SharedPreferences _prefs;

  ThemeBloc() : super(const ThemeState()) {
    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeChanged>(_onThemeChanged);
  }

  Future<void> _onThemeInitialized(ThemeInitialized event, Emitter<ThemeState> emit) async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedThemeIndex = _prefs.getInt(AppConstants.themeKey);
      
      if (savedThemeIndex != null) {
        final themeMode = ThemeMode.values[savedThemeIndex];
        emit(state.copyWith(themeMode: themeMode));
      }
    } catch (e) {
      // If there's an error loading preferences, use default theme
      emit(state.copyWith(themeMode: ThemeMode.system));
    }
  }

  Future<void> _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) async {
    try {
      await _prefs.setInt(AppConstants.themeKey, event.themeMode.index);
      emit(state.copyWith(themeMode: event.themeMode));
    } catch (e) {
      // If saving fails, still update the state but don't persist
      emit(state.copyWith(themeMode: event.themeMode));
    }
  }
}