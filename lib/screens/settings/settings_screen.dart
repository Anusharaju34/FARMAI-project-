import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../routes/app_router.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications
          _SettingsSection(
            title: 'Notifications',
            icon: Icons.notifications_rounded,
            color: const Color(0xFF7B1FA2),
            children: [
              _SwitchTile(
                label: 'Disease Alerts',
                subtitle: 'Get notified about crop disease risks',
                value: _diseaseAlerts,
                onChanged: (v) => setState(() => _diseaseAlerts = v),
              ),
              _SwitchTile(
                label: 'Pest Alerts',
                subtitle: 'Alerts about pest activity in your area',
                value: _pestAlerts,
                onChanged: (v) => setState(() => _pestAlerts = v),
              ),
              _SwitchTile(
                label: 'Weather Alerts',
                subtitle: 'Severe weather and farming advisories',
                value: _weatherAlerts,
                onChanged: (v) => setState(() => _weatherAlerts = v),
              ),
              _SwitchTile(
                label: 'Market Price Alerts',
                subtitle: 'Price changes for your crops',
                value: _marketAlerts,
                onChanged: (v) => setState(() => _marketAlerts = v),
              ),
              _SwitchTile(
                label: 'Irrigation Reminders',
                subtitle: 'Daily irrigation schedule reminders',
                value: _irrigationReminders,
                onChanged: (v) => setState(() => _irrigationReminders = v),
              ),
              _SwitchTile(
                label: 'Expert Replies',
                subtitle: 'When experts answer your questions',
                value: _expertReplies,
                onChanged: (v) => setState(() => _expertReplies = v),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          // Appearance
          _SettingsSection(
            title: 'Appearance',
            icon: Icons.palette_rounded,
            color: AppTheme.primaryGreen,
            children: [
              _SwitchTile(
                label: 'Dark Mode',
                subtitle: 'Switch to dark theme',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              _DropdownTile(
                label: 'Language',
                value: _language,
                items: _languages,
                onChanged: (v) => setState(() => _language = v!),
              ),
            ],
          ).animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 16),

          // Location
          _SettingsSection(
            title: 'Location',
            icon: Icons.location_on_rounded,
            color: AppTheme.alertRed,
            children: [
              _InfoTile(
                label: 'Current Location',
                value: _location,
                icon: Icons.edit_location_alt_rounded,
                onTap: () => _editLocation(context),
              ),
            ],
          ).animate(delay: 300.ms).fadeIn(),

          const SizedBox(height: 16),

          // Data & Privacy
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
              _NavTile(
                label: 'Terms of Service',
                icon: Icons.article_outlined,
                onTap: () {},
              ),
              _NavTile(
                label: 'Data Export',
                icon: Icons.download_rounded,
                onTap: () {},
              ),
              _NavTile(
                label: 'Delete Account',
                icon: Icons.delete_forever_rounded,
                color: AppTheme.alertRed,
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ).animate(delay: 400.ms).fadeIn(),

          const SizedBox(height: 16),

          // About
          _SettingsSection(
            title: 'About',
            icon: Icons.info_rounded,
            color: AppTheme.skyBlue,
            children: [
              _InfoTile(
                label: 'App Version',
                value: '1.0.0 (Build 1)',
                icon: Icons.smartphone_rounded,
                onTap: () {},
              ),
              _NavTile(
                label: 'Rate App',
                icon: Icons.star_rounded,
                onTap: () {},
              ),
              _NavTile(
                label: 'Share App',
                icon: Icons.share_rounded,
                onTap: () {},
              ),
              _NavTile(
                label: 'Contact Support',
                icon: Icons.support_agent_rounded,
                onTap: () {},
              ),
            ],
          ).animate(delay: 500.ms).fadeIn(),

          const SizedBox(height: 32),

          // Logout
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.alertRed,
              side: const BorderSide(color: AppTheme.alertRed),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ).animate(delay: 600.ms).fadeIn(),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _editLocation(BuildContext context) {
    final ctrl = TextEditingController(text: _location);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Location'),
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
              child: const Text('Cancel')),
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
        title: const Text('Delete Account'),
        content: const Text(
            'This will permanently delete your account and all data. This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.alertRed),
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
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
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
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
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
      title: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGreen,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      leading: Icon(icon, size: 18, color: color ?? Colors.grey[600]),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
      title: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(value,
          style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      trailing: Icon(icon, size: 18, color: Colors.grey[400]),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _DropdownTile({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox.shrink(),
            style: TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            items: items
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
