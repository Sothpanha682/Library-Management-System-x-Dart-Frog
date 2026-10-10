import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/borrowing.dart';
import '../../providers/book_provider.dart';
import '../../providers/borrowing_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/status_badge.dart';

class MyBorrowingsScreen extends StatefulWidget {
  const MyBorrowingsScreen({super.key});

  @override
  State<MyBorrowingsScreen> createState() => _MyBorrowingsScreenState();
}

class _MyBorrowingsScreenState extends State<MyBorrowingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowingProvider>().fetchMyBorrowings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleReturn(Borrowing borrowing) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Return Book',
      message: 'Are you sure you want to return "${borrowing.bookTitle ?? 'this textbook'}"? The library catalog availability will immediately update.',
      confirmLabel: 'Confirm Return',
    );

    if (!confirmed || !mounted) return;

    final borrowingProvider = context.read<BorrowingProvider>();
    final success = await borrowingProvider.returnBook(borrowing.id);

    if (!mounted) return;
    if (success) {
      context.read<BookProvider>().fetchBooks();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Book returned successfully! Thank you for prompt return.'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(borrowingProvider.errorMessage ?? 'Return failed'),
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
    final borrowingProvider = context.watch<BorrowingProvider>();
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Borrowed Loans'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          tabs: [
            Tab(text: 'Active Loans (${borrowingProvider.activeBorrowings.length})'),
            Tab(text: 'History (${borrowingProvider.historyBorrowings.length})'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => borrowingProvider.fetchMyBorrowings(),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Active Loans
            _buildBorrowingList(
              items: borrowingProvider.activeBorrowings,
              dateFormat: dateFormat,
              isActive: true,
              isLoading: borrowingProvider.isLoading,
              isDark: isDark,
            ),
            // History
            _buildBorrowingList(
              items: borrowingProvider.historyBorrowings,
              dateFormat: dateFormat,
              isActive: false,
              isLoading: borrowingProvider.isLoading,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowingList({
    required List<Borrowing> items,
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
        icon: isActive ? Icons.bookmark_remove_rounded : Icons.history_edu_rounded,
        title: isActive ? 'No Active Loans' : 'No Borrowing History',
        subtitle: isActive
            ? 'You currently have no active loans checked out. Browse the catalog to borrow textbooks.'
            : 'Returned books and previous loan receipts will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOverdue = item.isOverdue;
        final daysRemaining = item.dueDate.difference(DateTime.now()).inDays;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isOverdue
                  ? AppTheme.errorRed.withValues(alpha: 0.5)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isOverdue ? 1.5 : 1,
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
                    if (item.isReturned)
                      StatusBadge.returned()
                    else
                      StatusBadge.borrowed(isOverdue: isOverdue),
                  ],
                ),
                const SizedBox(height: 14),

                // Loan metadata container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? AppTheme.errorRed.withValues(alpha: isDark ? 0.15 : 0.06)
                        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOverdue
                          ? AppTheme.errorRed.withValues(alpha: 0.3)
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BORROWED ON',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              dateFormat.format(item.borrowedAt),
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
                              item.isReturned ? 'RETURNED ON' : 'DUE DATE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isOverdue
                                    ? AppTheme.errorRed
                                    : (isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight),
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.isReturned && item.returnedAt != null
                                  ? dateFormat.format(item.returnedAt!)
                                  : dateFormat.format(item.dueDate),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isOverdue
                                    ? AppTheme.errorRed
                                    : (isDark ? Colors.white : AppTheme.textPrimaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? AppTheme.errorRed.withValues(alpha: 0.15)
                                : (daysRemaining <= 3
                                    ? AppTheme.accentAmber.withValues(alpha: 0.15)
                                    : AppTheme.successGreen.withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isOverdue
                                ? 'OVERDUE'
                                : '$daysRemaining d left',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isOverdue
                                  ? AppTheme.errorRed
                                  : (daysRemaining <= 3 ? AppTheme.accentAmber : AppTheme.successGreen),
                            ),
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
                        foregroundColor: AppTheme.secondaryTeal,
                        side: const BorderSide(color: AppTheme.secondaryTeal, width: 1.5),
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _handleReturn(item),
                      icon: const Icon(Icons.assignment_return_rounded, size: 18),
                      label: const Text('Return Book to Library', style: TextStyle(fontWeight: FontWeight.w600)),
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
