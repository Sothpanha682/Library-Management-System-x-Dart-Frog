import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/book_provider.dart';
import 'admin_borrowings_screen.dart';
import 'admin_reservations_screen.dart';
import 'admin_users_screen.dart';
import 'manage_books_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookProvider = context.watch<BookProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Operations Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                    : const [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentAmber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.shield_rounded, color: AppTheme.accentAmber, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Administrative Console',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Catalog Records: ${bookProvider.books.length} Active Titles',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Library Management Services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppTheme.textPrimaryLight,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),

          _buildAdminTile(
            context,
            icon: Icons.menu_book_rounded,
            color: AppTheme.primaryBlueLight,
            title: 'Manage Books Catalog',
            subtitle: 'Add new books, edit stock counts, update details, or remove titles',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageBooksScreen()),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          _buildAdminTile(
            context,
            icon: Icons.assignment_rounded,
            color: AppTheme.secondaryTeal,
            title: 'All Student Borrowings',
            subtitle: 'View live and returned loans across the entire student body',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminBorrowingsScreen()),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          _buildAdminTile(
            context,
            icon: Icons.bookmark_rounded,
            color: AppTheme.accentAmber,
            title: 'Catalog Holds & Reservations',
            subtitle: 'Monitor pending waitlists, hold expiries, and pickup statuses',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminReservationsScreen()),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          _buildAdminTile(
            context,
            icon: Icons.people_alt_rounded,
            color: AppTheme.accentPurple,
            title: 'University User Directory',
            subtitle: 'Inspect registered student members and administrative staff',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
              );
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
