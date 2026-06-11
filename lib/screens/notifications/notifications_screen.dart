import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends ConsumerState<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'n1',
      'title': '🌧️ Heavy Rain Alert',
      'body': 'Heavy rainfall (65mm) expected in your area tomorrow. Ensure proper drainage in paddy fields.',
      'type': 'weather',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
    },
    {
      'id': 'n2',
      'title': '🐛 Pest Alert: Brown Planthopper',
      'body': 'High BPH activity reported in Kanchipuram district. Monitor your rice crop basal area.',
      'type': 'pest',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': 'n3',
      'title': '📈 Tomato Price Rise',
      'body': 'Tomato prices up 12% today at Koyambedu market (₹890/quintal). Good time to sell.',
      'type': 'market',
      'is_read': false,
      'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'id': 'n4',
      'title': '💊 Disease Detection Complete',
      'body': 'Your crop image analysis is ready. Leaf Blight detected with 92% confidence. View treatment plan.',
      'type': 'disease',
      'is_read': true,
      'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
    },
    {
      'id': 'n5',
      'title': '👨‍🌾 Expert Replied',
      'body': 'Dr. Krishnaswamy answered your question about wheat leaf yellowing. Tap to read.',
      'type': 'expert',
      'is_read': true,
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 'n6',
      'title': '💧 Irrigation Reminder',
      'body': 'Today is scheduled irrigation day for your Cotton field. Recommended: 2.4m³ water.',
      'type': 'irrigation',
      'is_read': true,
      'created_at': DateTime.now().subtract(const Duration(days: 1, hours: 6)).toIso8601String(),
    },
    {
      'id': 'n7',
      'title': '🌡️ Heat Stress Warning',
      'body': 'Temperature expected to exceed 40°C this week. Protect crops with shade nets or mulching.',
      'type': 'weather',
      'is_read': true,
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !(n['is_read'] as bool)).toList();
    final read = _notifications.where((n) => n['is_read'] as bool).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread.isNotEmpty)
            TextButton(
              onPressed: () => setState(() {
                for (final n in _notifications) {
                  n['is_read'] = true;
                }
              }),
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.notifications_none_rounded,
              title: 'No Notifications',
              subtitle: 'You\'re all caught up! Stay tuned for farming alerts.',
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (unread.isNotEmpty) ...[
                  _SectionLabel(
                      label: 'New (${unread.length})').animate().fadeIn(),
                  const SizedBox(height: 8),
                  ...unread.asMap().entries.map(
                        (e) => _NotifCard(
                          notif: e.value,
                          onTap: () => setState(
                              () => e.value['is_read'] = true),
                        ).animate(delay: Duration(milliseconds: 60 * e.key)).fadeIn().slideX(begin: -0.05),
                      ),
                  const SizedBox(height: 16),
                ],
                if (read.isNotEmpty) ...[
                  _SectionLabel(label: 'Earlier').animate().fadeIn(),
                  const SizedBox(height: 8),
                  ...read.asMap().entries.map(
                        (e) => _NotifCard(
                          notif: e.value,
                          onTap: () {},
                        )
                            .animate(
                                delay: Duration(
                                    milliseconds: 60 * (unread.length + e.key)))
                            .fadeIn(),
                      ),
                ],
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final Map<String, dynamic> notif;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.onTap});

  static const _typeConfig = {
    'weather': {'color': 0xFF1565C0, 'icon': Icons.cloud_rounded},
    'pest': {'color': 0xFFE65100, 'icon': Icons.pest_control_rounded},
    'disease': {'color': 0xFFC62828, 'icon': Icons.coronavirus_rounded},
    'market': {'color': 0xFF6A1B9A, 'icon': Icons.trending_up_rounded},
    'expert': {'color': 0xFF00695C, 'icon': Icons.support_agent_rounded},
    'irrigation': {'color': 0xFF0277BD, 'icon': Icons.water_drop_rounded},
    'system': {'color': 0xFF37474F, 'icon': Icons.notifications_rounded},
  };

  @override
  Widget build(BuildContext context) {
    final isRead = notif['is_read'] as bool;
    final type = notif['type'] as String;
    final cfg = _typeConfig[type] ?? _typeConfig['system']!;
    final color = Color(cfg['color'] as int);
    final icon = cfg['icon'] as IconData;
    final createdAt = DateTime.parse(notif['created_at'] as String);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? Theme.of(context).colorScheme.surface
              : color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead
                ? Theme.of(context).colorScheme.outline.withOpacity(0.1)
                : color.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif['title'] as String,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif['body'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
