import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../routes/app_router.dart';
import '../../widgets/common/common_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _diseaseAlerts = true;
  bool _pestAlerts = true;
  bool _weatherAlerts = true;
  bool _marketAlerts = true;
  bool _irrigationReminders = true;
  bool _expertReplies = true;
  bool _darkMode = false;
  String _language = 'English';
  String _location = 'Chennai, Tamil Nadu';

  final List<String> _languages = [
    'English', 'Tamil', 'Telugu', 'Hindi', 'Kannada',
    'Malayalam', 'Marathi', 'Gujarati', 'Bengali', 'Punjabi',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: FarmAIAppBar(
        title: 'Settings',
        showBack: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Notifications Settings
          _SettingsSection(
            title: 'Notifications',
            icon: Icons.notifications_active_rounded,
            color: const Color(0xFF7B1FA2),
            children: [
              _SwitchTile(
                label: 'Disease Alerts',
                subtitle: 'Get notified about crop disease risks',
                value: _diseaseAlerts,
                onChanged: (v) => setState(() => _diseaseAlerts = v),
              ),
              _divider(),
              _SwitchTile(
                label: 'Pest Alerts',
                subtitle: 'Alerts about pest activity in your area',
                value: _pestAlerts,
                onChanged: (v) => setState(() => _pestAlerts = v),
              ),
              _divider(),
              _SwitchTile(
                label: 'Weather Alerts',
                subtitle: 'Severe weather and farming advisories',
                value: _weatherAlerts,
                onChanged: (v) => setState(() => _weatherAlerts = v),
              ),
              _divider(),
              _SwitchTile(
                label: 'Market Price Alerts',
                subtitle: 'Price changes for your crops',
                value: _marketAlerts,
                onChanged: (v) => setState(() => _marketAlerts = v),
              ),
              _divider(),
              _SwitchTile(
                label: 'Irrigation Reminders',
                subtitle: 'Daily irrigation schedule reminders',
                value: _irrigationReminders,
                onChanged: (v) => setState(() => _irrigationReminders = v),
              ),
              _divider(),
              _SwitchTile(
                label: 'Expert Replies',
                subtitle: 'When experts answer your questions',
                value: _expertReplies,
                onChanged: (v) => setState(() => _expertReplies = v),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 18),

          // Preferences Settings
          _SettingsSection(
            title: 'Preferences',
            icon: Icons.palette_rounded,
            color: AppTheme.primaryGreen,
            children: [
              _SwitchTile(
                label: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              _divider(),
              _NavTile(
                label: 'Language Selection',
                icon: Icons.language_rounded,
                onTap: () => context.push(AppRoutes.languageSelection),
              ),
              _divider(),
              _NavTile(
                label: 'Custom Alerts Settings',
                icon: Icons.notifications_active_outlined,
                onTap: () => context.push(AppRoutes.notificationSettings),
              ),
            ],
          ).animate(delay: 150.ms).fadeIn(),

          const SizedBox(height: 18),

          // Location settings
          _SettingsSection(
            title: 'Location Settings',
            icon: Icons.location_on_rounded,
            color: AppTheme.alertRed,
            children: [
              _InfoTile(
                label: 'Current Farm Location',
                value: _location,
                icon: Icons.edit_location_alt_rounded,
                onTap: () => _editLocation(context),
              ),
            ],
          ).animate(delay: 250.ms).fadeIn(),

          const SizedBox(height: 18),

          // Data & Privacy Settings
          _SettingsSection(
            title: 'Data & Privacy',
            icon: Icons.security_rounded,
            color: const Color(0xFF00695C),
            children: [
              _NavTile(
                label: 'Privacy Policy',
                icon: Icons.privacy_tip_outlined,
                onTap: () {},
              ),
              _divider(),
              _NavTile(
                label: 'Terms of Service',
                icon: Icons.article_outlined,
                onTap: () {},
              ),
              _divider(),
              _NavTile(
                label: 'Export My Farming Data',
                icon: Icons.download_rounded,
                onTap: () {},
              ),
              _divider(),
              _NavTile(
                label: 'Delete Account',
                icon: Icons.delete_forever_rounded,
                color: AppTheme.alertRed,
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ).animate(delay: 350.ms).fadeIn(),

          const SizedBox(height: 18),

          // About App Settings
          _SettingsSection(
            title: 'About Assist',
            icon: Icons.info_rounded,
            color: AppTheme.skyBlue,
            children: [
              _InfoTile(
                label: 'App Version',
                value: '1.0.0 (Build 1)',
                icon: Icons.smartphone_rounded,
                onTap: () {},
              ),
              _divider(),
              _NavTile(
                label: 'Rate FARMAI',
                icon: Icons.star_rounded,
                onTap: () {},
              ),
              _divider(),
              _NavTile(
                label: 'Share App with Farmers',
                icon: Icons.share_rounded,
                onTap: () {},
              ),
              _divider(),
              _NavTile(
                label: 'Contact Helpline Support',
                icon: Icons.support_agent_rounded,
                onTap: () => context.push(AppRoutes.helpSupport),
              ),
            ],
          ).animate(delay: 450.ms).fadeIn(),

          const SizedBox(height: 28),

          // Logout Button
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out Account'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.alertRed,
              side: const BorderSide(color: AppTheme.alertRed, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ).animate(delay: 550.ms).fadeIn(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _divider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1.0,
      indent: 16,
      endIndent: 16,
      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
    );
  }

  void _editLocation(BuildContext context) {
    final ctrl = TextEditingController(text: _location);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Update Location', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: 'City, State',
            prefixIcon: Icon(Icons.location_on_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _location = ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'This will permanently delete your account and all data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.alertRed),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppTheme.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _SwitchTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGreen,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _NavTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      leading: Icon(icon, size: 20, color: color ?? Colors.grey[600]),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      subtitle: Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
      trailing: Icon(icon, size: 20, color: Colors.grey[400]),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
    );
  }
}
