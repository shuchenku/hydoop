import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_router.dart';
import '../../blocs/theme/theme_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () => AppRouter.goBack(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
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
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppTheme.spacingSm,
            bottom: AppTheme.spacingSm,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
        const SizedBox(height: AppTheme.spacingLg),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeMode currentTheme) {
    return Column(
      children: [
        _buildRadioTile(
          context,
          'System Default',
          'Follow system theme',
          Icons.brightness_auto,
          currentTheme == ThemeMode.system,
          () => context.read<ThemeBloc>().add(const ThemeChanged(ThemeMode.system)),
        ),
        const Divider(height: 1),
        _buildRadioTile(
          context,
          'Light Theme',
          'Always use light theme',
          Icons.light_mode,
          currentTheme == ThemeMode.light,
          () => context.read<ThemeBloc>().add(const ThemeChanged(ThemeMode.light)),
        ),
        const Divider(height: 1),
        _buildRadioTile(
          context,
          'Dark Theme',
          'Always use dark theme',
          Icons.dark_mode,
          currentTheme == ThemeMode.dark,
          () => context.read<ThemeBloc>().add(const ThemeChanged(ThemeMode.dark)),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Column(
      children: [
        _buildRadioTile(
          context,
          'English',
          'English (US)',
          Icons.language,
          true, // Currently selected
          () {
            // TODO: Implement language change
          },
        ),
        const Divider(height: 1),
        _buildRadioTile(
          context,
          '简体中文',
          'Simplified Chinese',
          Icons.language,
          false,
          () {
            // TODO: Implement language change
          },
        ),
      ],
    );
  }

  Widget _buildTimeFormatSelector(BuildContext context) {
    return Column(
      children: [
        _buildRadioTile(
          context,
          'HH:MM:SS Format',
          'Display times as hours, minutes, seconds',
          Icons.access_time,
          true, // Currently selected
          () {
            // TODO: Implement time format change
          },
        ),
        const Divider(height: 1),
        _buildRadioTile(
          context,
          'Decimal Format',
          'Display times in decimal format',
          Icons.access_time,
          false,
          () {
            // TODO: Implement time format change
          },
        ),
      ],
    );
  }

  Widget _buildDataManagementTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.storage),
      title: const Text('Data Management'),
      subtitle: const Text('Manage local race data'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showDataManagementDialog(context);
      },
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('About ${AppConstants.appName}'),
      subtitle: const Text('Version ${AppConstants.appVersion}'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        _showAboutDialog(context);
      },
    );
  }

  Widget _buildRadioTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Radio<bool>(
        value: true,
        groupValue: isSelected,
        onChanged: (_) => onTap(),
      ),
      onTap: onTap,
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