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
      title: 'Cancel Reservation',
      message: 'Are you sure you want to cancel your hold on "${reservation.bookTitle ?? 'this book'}"?',
      confirmLabel: 'Cancel Hold',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    final reservationProvider = context.read<ReservationProvider>();
    final success = await reservationProvider.cancelReservation(reservation.id);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation cancelled successfully.'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reservationProvider.errorMessage ?? 'Cancellation failed'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationProvider = context.watch<ReservationProvider>();
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Book Holds'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          indicatorColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textSecondary,
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
            ),
            _buildList(
              items: reservationProvider.historyReservations,
              dateFormat: dateFormat,
              isActive: false,
              isLoading: reservationProvider.isLoading,
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
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyStateView(
        icon: Icons.bookmark_border_rounded,
        title: isActive ? 'No Active Holds' : 'No Past Reservations',
        subtitle: isActive
            ? 'When a textbook is fully loaned out, you can reserve it to hold your place in line.'
            : 'Completed or cancelled reservations will be archived here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (item.bookAuthor != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.bookAuthor!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
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
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PLACED ON',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormat.format(item.reservedAt),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HOLD EXPIRES',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormat.format(item.expiresAt),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                        side: const BorderSide(color: AppTheme.errorRed, width: 1.2),
                        minimumSize: const Size.fromHeight(40),
                      ),
                      onPressed: () => _handleCancel(item),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel Reservation'),
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
