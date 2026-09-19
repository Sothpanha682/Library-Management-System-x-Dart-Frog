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
    final bookProvider = context.watch<BookProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: AppTheme.accentAmber, size: 42),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Administrative Control',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Books in Catalog: ${bookProvider.books.length}',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Management Sections',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),

          _buildAdminTile(
            context,
            icon: Icons.menu_book_rounded,
            color: AppTheme.primaryBlue,
            title: 'Manage Books Catalog',
            subtitle: 'Add new books, edit details, update stock, remove titles',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageBooksScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildAdminTile(
            context,
            icon: Icons.assignment_rounded,
            color: AppTheme.secondaryTeal,
            title: 'University Borrowings',
            subtitle: 'View all active and returned loans across all students',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminBorrowingsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildAdminTile(
            context,
            icon: Icons.bookmark_rounded,
            color: AppTheme.accentAmber,
            title: 'Reservations & Holds',
            subtitle: 'Monitor pending holds and pickup statuses',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminReservationsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildAdminTile(
            context,
            icon: Icons.people_alt_rounded,
            color: const Color(0xFF7C3AED),
            title: 'User Directory',
            subtitle: 'View registered students and staff accounts',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
              );
            },
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
  }) {
    return Card(
      margin: EdgeInsets.zero,
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
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
