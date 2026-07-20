import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _weatherAlerts = true;
  bool _pestAlerts = true;
  bool _priceAlerts = false;
  bool _irrigationReminders = true;
  bool _smsUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FarmAIAppBar(
        title: 'Notification Settings',
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Intro
          Text(
            'Customize your notifications to receive immediate alerts for crops and fields.',
            style:
                TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
          ).animate().fadeIn(),
          const SizedBox(height: 20),

          // Categories
          Card(
            child: Column(
              children: [
                _SwitchListTile(
                  icon: Icons.cloud_outlined,
                  title: 'Weather Forecasts',
                  subtitle: 'Daily rain forecasts and climate warnings',
                  value: _weatherAlerts,
                  onChanged: (v) => setState(() => _weatherAlerts = v),
                ),
                const Divider(height: 1),
                _SwitchListTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Pest & Disease Warnings',
                  subtitle: 'Regional alerts for crop disease outbreaks',
                  value: _pestAlerts,
                  onChanged: (v) => setState(() => _pestAlerts = v),
                ),
                const Divider(height: 1),
                _SwitchListTile(
                  icon: Icons.trending_up_rounded,
                  title: 'Market Prices',
                  subtitle: 'Notify when crop prices change by over 5%',
                  value: _priceAlerts,
                  onChanged: (v) => setState(() => _priceAlerts = v),
                ),
                const Divider(height: 1),
                _SwitchListTile(
                  icon: Icons.water_drop_outlined,
                  title: 'Irrigation Triggers',
                  subtitle: 'Water recommendations for scheduled crops',
                  value: _irrigationReminders,
                  onChanged: (v) => setState(() => _irrigationReminders = v),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),
          const SectionHeader(title: 'Alternative Delivery Channel')
              .animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 12),

          Card(
            child: _SwitchListTile(
              icon: Icons.sms_outlined,
              title: 'SMS Status Updates',
              subtitle:
                  'Receive severe alerts on your registered mobile number',
              value: _smsUpdates,
              onChanged: (v) => setState(() => _smsUpdates = v),
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Preferences saved successfully!')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save Preferences'),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _SwitchListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGreen,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
