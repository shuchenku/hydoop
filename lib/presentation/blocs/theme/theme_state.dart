part of 'theme_bloc.dart';

final class ThemeState extends Equatable {
  const ThemeState({
    this.themeMode = ThemeMode.system,
  });

  final ThemeMode themeMode;

  ThemeState copyWith({
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object> get props => [themeMode];
}