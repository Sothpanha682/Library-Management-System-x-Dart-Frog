import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/reservation.dart';
import '../../providers/reservation_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/status_badge.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationProvider>().fetchMyReservations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleCancel(Reservation reservation) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Cancel Reservation Hold',
      message: 'Are you sure you want to release your hold on "${reservation.bookTitle ?? 'this textbook'}"? Other students in line will move ahead.',
      confirmLabel: 'Cancel Hold',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    final reservationProvider = context.read<ReservationProvider>();
    final success = await reservationProvider.cancelReservation(reservation.id);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reservation cancelled successfully.'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reservationProvider.errorMessage ?? 'Cancellation failed'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reservationProvider = context.watch<ReservationProvider>();
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Catalog Holds'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          tabs: [
            Tab(text: 'Active Holds (${reservationProvider.activeReservations.length})'),
            Tab(text: 'History (${reservationProvider.historyReservations.length})'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => reservationProvider.fetchMyReservations(),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildList(
              items: reservationProvider.activeReservations,
              dateFormat: dateFormat,
              isActive: true,
              isLoading: reservationProvider.isLoading,
              isDark: isDark,
            ),
            _buildList(
              items: reservationProvider.historyReservations,
              dateFormat: dateFormat,
              isActive: false,
              isLoading: reservationProvider.isLoading,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList({
    required List<Reservation> items,
    required DateFormat dateFormat,
    required bool isActive,
    required bool isLoading,
    required bool isDark,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyStateView(
        icon: Icons.bookmark_border_rounded,
        title: isActive ? 'No Active Holds' : 'No Past Reservations',
        subtitle: isActive
            ? 'When a textbook is fully loaned out by other scholars, place a hold to queue for next availability.'
            : 'Completed, expired, or cancelled reservations will be archived here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.bookTitle ?? 'Library Book #${item.bookId}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (item.bookAuthor != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              item.bookAuthor!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge.reservation(item.status),
                  ],
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PLACED ON',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              dateFormat.format(item.reservedAt),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HOLD EXPIRES',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              dateFormat.format(item.expiresAt),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: BorderSide(color: AppTheme.errorRed.withValues(alpha: 0.7), width: 1.2),
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _handleCancel(item),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel Reservation Hold', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
