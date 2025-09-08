import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_router.dart';
import '../../blocs/theme/theme_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'Settings',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: ListView(
          children: [
            // Theme Section
            _buildSection(
              context,
              'Appearance',
              [
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return _buildThemeSelector(context, state.themeMode);
                  },
                ),
              ],
            ),
            
            // Language Section
            _buildSection(
              context,
              'Language',
              [
                _buildLanguageSelector(context),
              ],
            ),
            
            // Data Section
            _buildSection(
              context,
              'Data & Display',
              [
                _buildTimeFormatSelector(context),
                _buildDataManagementTile(context),
              ],
            ),
            
            // About Section
            _buildSection(
              context,
              'About',
              [
                _buildAboutTile(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            bottom: 12,
            top: 8,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: AppTheme.spacingLg),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeMode currentTheme) {
    return Column(
      children: [
        _buildSettingsTile(
          context,
          'System Default',
          'Follow system theme',
          Icons.brightness_auto,
          isSelected: currentTheme == ThemeMode.system,
          onTap: () => context.read<ThemeBloc>().add(const ThemeChanged(ThemeMode.system)),
        ),
        _buildDivider(context),
        _buildSettingsTile(
          context,
          'Light Theme',
          'Always use light theme',
          Icons.light_mode,
          isSelected: currentTheme == ThemeMode.light,
          onTap: () => context.read<ThemeBloc>().add(const ThemeChanged(ThemeMode.light)),
        ),
        _buildDivider(context),
        _buildSettingsTile(
          context,
          'Dark Theme',
          'Always use dark theme',
          Icons.dark_mode,
          isSelected: currentTheme == ThemeMode.dark,
          onTap: () => context.read<ThemeBloc>().add(const ThemeChanged(ThemeMode.dark)),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Column(
      children: [
        _buildSettingsTile(
          context,
          'English',
          'English (US)',
          Icons.language,
          isSelected: true,
          onTap: () {
            // TODO: Implement language change
          },
        ),
        _buildDivider(context),
        _buildSettingsTile(
          context,
          '简体中文',
          'Simplified Chinese',
          Icons.language,
          isSelected: false,
          onTap: () {
            // TODO: Implement language change
          },
        ),
      ],
    );
  }

  Widget _buildTimeFormatSelector(BuildContext context) {
    return Column(
      children: [
        _buildSettingsTile(
          context,
          'HH:MM:SS Format',
          'Display times as hours, minutes, seconds',
          Icons.access_time,
          isSelected: true,
          onTap: () {
            // TODO: Implement time format change
          },
        ),
        _buildDivider(context),
        _buildSettingsTile(
          context,
          'Decimal Format',
          'Display times in decimal format',
          Icons.access_time,
          isSelected: false,
          onTap: () {
            // TODO: Implement time format change
          },
        ),
      ],
    );
  }

  Widget _buildDataManagementTile(BuildContext context) {
    return _buildActionTile(
      context,
      'Data Management',
      'Manage local race data',
      Icons.storage,
      onTap: () => _showDataManagementDialog(context),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return _buildActionTile(
      context,
      'About ${AppConstants.appName}',
      'Version ${AppConstants.appVersion}',
      Icons.info,
      onTap: () => _showAboutDialog(context),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              Icon(
                Icons.check,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.dividerColor.withValues(alpha: 0.1),
      indent: 56,
    );
  }

  void _showDataManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Management'),
        content: const Text(
          'This will clear all local race data and reimport from the bundled CSV files. '
          'Any saved athletes will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement data refresh
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data refresh not yet implemented')),
              );
            },
            child: const Text('Refresh Data'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(Icons.fitness_center, size: 48),
      children: const [
        Text(
          'A Flutter app for analyzing HYROX race data and tracking athlete performance.',
        ),
      ],
    );
  }
}