import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../routes/app_router.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common/common_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;
    final profile = await SupabaseService.getUserProfile(user.id);
    if (profile != null && mounted) {
      _nameCtrl.text = profile.fullName;
      _phoneCtrl.text = profile.phone ?? '';
      _locationCtrl.text = profile.location ?? '';
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final user = SupabaseService.currentUser;
    if (user != null) {
      await SupabaseService.updateUserProfile(user.id, {
        'full_name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
      });
    }
    setState(() {
      _saving = false;
      _editing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton(
            onPressed: () {
              if (_editing) {
                _saveProfile();
              } else {
                setState(() => _editing = true);
              }
            },
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _editing ? 'Save' : 'Edit',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.darkGreen, AppTheme.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          (user?.email ?? 'F')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (_editing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.sunYellow,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ).animate().scale(curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  Text(
                    _nameCtrl.text.isNotEmpty
                        ? _nameCtrl.text
                        : (user?.email?.split('@')[0] ?? 'Farmer'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ProfileStat(value: '12', label: 'Diagnoses'),
                      _vDivider(),
                      _ProfileStat(value: '5', label: 'Questions'),
                      _vDivider(),
                      _ProfileStat(value: '8', label: 'Forum Posts'),
                    ],
                  ),
                ],
              ),
            ),

            // Transform card to overlap header
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    FarmTextField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      hint: 'Your full name',
                      prefixIcon: Icons.person_outline,
                      readOnly: !_editing,
                    ),
                    const SizedBox(height: 12),
                    FarmTextField(
                      controller: _phoneCtrl,
                      label: 'Phone Number',
                      hint: '+91 98765 43210',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      readOnly: !_editing,
                    ),
                    const SizedBox(height: 12),
                    FarmTextField(
                      controller: _locationCtrl,
                      label: 'Village / Town',
                      hint: 'Your location',
                      prefixIcon: Icons.location_on_outlined,
                      readOnly: !_editing,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            ),

            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _MenuSection(
                    title: 'Farm & Crops',
                    items: [
                      _MenuItem(
                        icon: Icons.landscape_rounded,
                        label: 'My Farms',
                        color: AppTheme.primaryGreen,
                        onTap: () => context.push(AppRoutes.farmManagement),
                      ),
                      _MenuItem(
                        icon: Icons.science_rounded,
                        label: 'Soil Health',
                        color: AppTheme.soilBrown,
                        onTap: () => context.push(AppRoutes.soilHealth),
                      ),
                      _MenuItem(
                        icon: Icons.calendar_today_rounded,
                        label: 'Crop Calendar',
                        color: AppTheme.warningOrange,
                        onTap: () => context.push(AppRoutes.cropCalendar),
                      ),
                      _MenuItem(
                        icon: Icons.history_rounded,
                        label: 'Diagnosis History',
                        color: AppTheme.skyBlue,
                        onTap: () => context.push(AppRoutes.diseaseHistory),
                      ),
                    ],
                  ).animate(delay: 300.ms).fadeIn(),
                  const SizedBox(height: 16),
                  _MenuSection(
                    title: 'Account',
                    items: [
                      _MenuItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        color: Colors.grey[700]!,
                        onTap: () => context.push(AppRoutes.settings),
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        color: AppTheme.warningOrange,
                        onTap: () => context.push(AppRoutes.helpSupport),
                      ),
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        color: AppTheme.alertRed,
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ).animate(delay: 400.ms).fadeIn(),
                  const SizedBox(height: 32),
                  Text(
                    'FARMAI v1.0.0 · Smart Farming Assistant',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final user = SupabaseService.currentUser;
      if (user == null) return;
      final url = await SupabaseService.uploadImage(
        file: File(picked.path),
        bucket: AppConstants.profileImagesBucket,
        path: '${user.id}/profile.jpg',
      );
      await SupabaseService.updateUserProfile(
          user.id, {'profile_image_url': url});
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.alertRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        height: 30,
        width: 1,
        color: Colors.white.withOpacity(0.3),
        margin: const EdgeInsets.symmetric(horizontal: 20),
      );
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items.map((item) => _MenuItemTile(item: item)).toList(),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _MenuItemTile extends StatelessWidget {
  final _MenuItem item;
  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
