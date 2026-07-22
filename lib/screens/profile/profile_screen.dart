import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  bool _editing = false;
  bool _saving = false;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return;

      final profile = await SupabaseService.getUserProfile(user.id);
      if (!mounted) return;

      if (profile != null) {
        setState(() {
          _nameCtrl.text = profile.fullName;
          _phoneCtrl.text = profile.phone ?? '';
          _locationCtrl.text = profile.location ?? '';
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load profile: $error'),
          backgroundColor: AppTheme.alertRed,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final user = SupabaseService.currentUser;
      if (user == null) throw Exception('User is not logged in.');

      await SupabaseService.updateUserProfile(
        user.id,
        {
          'full_name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'location': _locationCtrl.text.trim(),
        },
      );

      if (!mounted) return;
      setState(() => _editing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update profile: $error'),
          backgroundColor: AppTheme.alertRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _pickProfileImage() async {
    if (_uploadingImage) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) return;

      final user = SupabaseService.currentUser;
      if (user == null) throw Exception('User is not logged in.');

      if (mounted) {
        setState(() => _uploadingImage = true);
      }

      final String extension = _getFileExtension(picked.name);
      final String url = await SupabaseService.uploadImage(
        file: picked,
        bucket: AppConstants.profileImagesBucket,
        path: '${user.id}/profile.$extension',
      );

      await SupabaseService.updateUserProfile(
        user.id,
        {'profile_image_url': url},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image updated successfully'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile image upload failed: $error'),
          backgroundColor: AppTheme.alertRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingImage = false);
      }
    }
  }

  String _getFileExtension(String fileName) {
    if (!fileName.contains('.')) return 'jpg';
    final String extension = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      return extension;
    }
    return 'jpg';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton(
            onPressed: _saving
                ? null
                : () {
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                  )
                : Text(
                    _editing ? 'Save' : 'Edit',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Cover Image Banner with Avatar & Stats Card overlay
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen, Color(0xFF1B5E20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                ),
                Positioned(
                  top: 90,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? AppTheme.backgroundDark : Colors.white, width: 4),
                          boxShadow: AppTheme.premiumShadow,
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                          child: Text(
                            (user?.email ?? 'F')[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      if (_editing)
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: _uploadingImage ? null : _pickProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.warningOrange,
                                shape: BoxShape.circle,
                              ),
                              child: _uploadingImage
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms),
                ),
              ],
            ),

            const SizedBox(height: 64),

            // Profile info header
            Text(
              _nameCtrl.text.isNotEmpty ? _nameCtrl.text : (user?.email?.split('@')[0] ?? 'Farmer'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 24),

            // Glass stats summary panel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PremiumGlassCard(
                padding: const EdgeInsets.symmetric(vertical: 18),
                color: isDark ? AppTheme.cardDark : Colors.white,
                borderOpacity: 0.05,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const _ProfileStat(value: '12', label: 'Diagnoses'),
                    _vDivider(context),
                    const _ProfileStat(value: '5', label: 'Queries'),
                    _vDivider(context),
                    const _ProfileStat(value: '8', label: 'Feed Posts'),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 150.ms).scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 24),

            // Personal Info Form Block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 18),
                    FarmTextField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      hint: 'Your full name',
                      prefixIcon: Icons.person_outline_rounded,
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
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15),

            // Menus List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  _MenuSection(
                    title: 'Farm & Crop Details',
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
                        color: AppTheme.earthBrown,
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
                    title: 'Account Settings',
                    items: [
                      _MenuItem(
                        icon: Icons.settings_rounded,
                        label: 'Settings',
                        color: Colors.grey[600]!,
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
                    style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w800)),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.alertRed),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _vDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 30,
      width: 1.2,
      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppTheme.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.primaryGreen.withOpacity(0.8),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            ...items.map((item) => _MenuItemTile(item: item)),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
            const SizedBox(width: 14),
            Text(
              item.label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}