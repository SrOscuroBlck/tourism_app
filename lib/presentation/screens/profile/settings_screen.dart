// lib/presentation/screens/profile/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../injection_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SharedPreferences _prefs = sl<SharedPreferences>();

  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _analyticsEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'Light';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
      _locationEnabled = _prefs.getBool('location_enabled') ?? true;
      _analyticsEnabled = _prefs.getBool('analytics_enabled') ?? true;
      _selectedLanguage = _prefs.getString('selected_language') ?? 'English';
      _selectedTheme = _prefs.getString('selected_theme') ?? 'Light';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null
          ? Icon(icon, color: AppColors.primary)
          : null,
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSelectTile({
    required String title,
    String? subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null
          ? Icon(icon, color: AppColors.primary)
          : null,
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select $title',
                  style: AppTextStyles.titleLarge,
                ),
              ),
              ...options.map((option) => ListTile(
                title: Text(option),
                trailing: value == option
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  onChanged(option);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    IconData? icon,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: icon != null
          ? Icon(icon, color: iconColor ?? AppColors.primary)
          : null,
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Data'),
        content: const Text(
          'This will clear all cached data including favorites and saved routes. '
              'Your account data will remain safe. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Clear SharedPreferences (except auth data)
              final keys = _prefs.getKeys();
              for (final key in keys) {
                if (!key.startsWith('flutter.')) {
                  await _prefs.remove(key);
                }
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Local data cleared successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Settings',
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSection(
              'Notifications',
              [
                _buildSwitchTile(
                  title: 'Push Notifications',
                  subtitle: 'Receive updates about new places and features',
                  value: _notificationsEnabled,
                  icon: Icons.notifications,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    _saveSetting('notifications_enabled', value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Privacy Section
            _buildSection(
              'Privacy',
              [
                _buildSwitchTile(
                  title: 'Location Services',
                  subtitle: 'Allow app to access your location',
                  value: _locationEnabled,
                  icon: Icons.location_on,
                  onChanged: (value) {
                    setState(() => _locationEnabled = value);
                    _saveSetting('location_enabled', value);
                  },
                ),
                const Divider(height: 1),
                _buildSwitchTile(
                  title: 'Analytics',
                  subtitle: 'Help improve the app by sharing usage data',
                  value: _analyticsEnabled,
                  icon: Icons.analytics,
                  onChanged: (value) {
                    setState(() => _analyticsEnabled = value);
                    _saveSetting('analytics_enabled', value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Appearance Section
            _buildSection(
              'Appearance',
              [
                _buildSelectTile(
                  title: 'Language',
                  subtitle: 'Change app language',
                  value: _selectedLanguage,
                  options: ['English', 'Spanish'],
                  icon: Icons.language,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value);
                    _saveSetting('selected_language', value);
                  },
                ),
                const Divider(height: 1),
                _buildSelectTile(
                  title: 'Theme',
                  subtitle: 'Choose app appearance',
                  value: _selectedTheme,
                  options: ['Light', 'Dark', 'System'],
                  icon: Icons.palette,
                  onChanged: (value) {
                    setState(() => _selectedTheme = value);
                    _saveSetting('selected_theme', value);
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data Section
            _buildSection(
              'Data',
              [
                _buildActionTile(
                  title: 'Clear Local Data',
                  subtitle: 'Remove cached data and reset app',
                  icon: Icons.cleaning_services,
                  iconColor: AppColors.warning,
                  textColor: AppColors.warning,
                  onTap: _showClearDataDialog,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Account Section
            _buildSection(
              'Account',
              [
                _buildActionTile(
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  icon: Icons.logout,
                  iconColor: AppColors.error,
                  textColor: AppColors.error,
                  onTap: _showLogoutDialog,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Tourism App',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}