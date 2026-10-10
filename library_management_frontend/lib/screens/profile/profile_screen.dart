import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/borrowing_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Update Profile Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final success = await context.read<AuthProvider>().updateProfile(controller.text.trim());
                if (dialogCtx.mounted) {
                  Navigator.of(dialogCtx).pop();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Profile updated successfully!' : 'Failed to update profile'),
                      backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Sign Out of Account',
      message: 'Are you sure you want to sign out of your university library session?',
      confirmLabel: 'Sign Out',
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) return;

    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final borrowingProvider = context.watch<BorrowingProvider>();
    final reservationProvider = context.watch<ReservationProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.user;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: isAdmin ? AppTheme.accentAmber : theme.colorScheme.primary,
                  child: Text(
                    user != null && user.name.isNotEmpty
                        ? user.name.substring(0, 1).toUpperCase()
                        : 'U',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'University Scholar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? AppTheme.accentAmber.withValues(alpha: 0.16)
                        : theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAdmin ? 'LIBRARY ADMINISTRATOR' : 'STUDENT MEMBER',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isAdmin ? AppTheme.accentAmber : theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(140, 38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showEditNameDialog(context, user?.name ?? ''),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Name'),
                ),
              ],
            ),
          ),

          // Quick Account Activity Summary
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.menu_book_rounded, size: 16, color: theme.colorScheme.primary),
                          const Spacer(),
                          Text(
                            '${borrowingProvider.activeBorrowings.length}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Active Loans',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bookmark_rounded, size: 16, color: AppTheme.accentAmber),
                          Spacer(),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Holds',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                            ),
                          ),
                          Text(
                            '${reservationProvider.activeReservations.length}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Material 3 Theme Appearance Switcher
          const SizedBox(height: 20),
          Text(
            'Interface Appearance (Material 3)',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.textPrimaryLight,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Color Theme',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                            ),
                          ),
                          Text(
                            'Select light canvas, deep dark slate, or match system',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.settings_brightness_rounded, size: 16),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_rounded, size: 16),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_rounded, size: 16),
                      ),
                    ],
                    selected: {themeProvider.themeMode},
                    onSelectionChanged: (newSelection) {
                      themeProvider.setThemeMode(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Admin Management Dashboard Entry
          if (isAdmin) ...[
            const SizedBox(height: 20),
            Text(
              'Administrative Tools',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withValues(alpha: isDark ? 0.14 : 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentAmber.withValues(alpha: isDark ? 0.4 : 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmber.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shield_rounded, color: AppTheme.accentAmber, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Management Dashboard',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Catalog inventory, all loans, holds, and student records',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.accentAmber),
                  ],
                ),
              ),
            ),
          ],

          // Library Guidelines
          const SizedBox(height: 20),
          Text(
            'Library Guidelines & Policies',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.textPrimaryLight,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.access_time_rounded, color: theme.colorScheme.primary),
                  title: const Text('Operating Hours', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    'Mon - Fri: 8:00 AM - 10:00 PM\nSat - Sun: 10:00 AM - 6:00 PM',
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.rule_folder_outlined, color: theme.colorScheme.primary),
                  title: const Text('Loan Duration Policy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    '14 days per textbook. Up to 5 books concurrently per scholar account.',
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight),
                  ),
                ),
              ],
            ),
          ),

          // Sign Out Button
          const SizedBox(height: 28),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sign Out of Library Account', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
